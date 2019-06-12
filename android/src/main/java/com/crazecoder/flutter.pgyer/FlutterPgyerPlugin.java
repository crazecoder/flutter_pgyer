package com.crazecoder.flutter.pgyer;

import android.Manifest;
import android.app.Activity;
import android.net.Uri;
import android.text.TextUtils;

import androidx.core.content.ContextCompat;
import androidx.core.content.PermissionChecker;

import com.crazecoder.flutter.pgyer.bean.InitResultInfo;
import com.crazecoder.flutter.pgyer.utils.AppUtil;
import com.crazecoder.flutter.pgyer.utils.JsonUtil;
import com.crazecoder.flutter.pgyer.utils.LogUtil;
import com.crazecoder.flutter.pgyer.utils.MapUtil;
import com.pgyersdk.c.a;
import com.pgyersdk.crash.PgyCrashManager;
import com.pgyersdk.feedback.PgyerFeedbackManager;
import com.pgyersdk.update.DownloadFileListener;
import com.pgyersdk.update.PgyUpdateManager;
import com.pgyersdk.update.UpdateManagerListener;
import com.pgyersdk.update.javabean.AppBean;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterPgyerPlugin
 */
public class FlutterPgyerPlugin implements MethodCallHandler {

    private Activity activity;
    private PgyerFeedbackManager pgyerFeedbackManager;
    private AppBean flutterAppBean;

    private FlutterPgyerPlugin(Activity activity) {
        this.activity = activity;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "crazecoder/flutter_pgyer");
        FlutterPgyerPlugin plugin = new FlutterPgyerPlugin(registrar.activity());
        channel.setMethodCallHandler(plugin);
    }

    @Override
    public void onMethodCall(final MethodCall call, Result result) {
        if (call.method.equals("initSdk")) {
            if (call.hasArgument("appId")){
                a.l = call.argument("appId");
            }
            String json;
            try {
                if (!hasPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                    json = JsonUtil.toJson(MapUtil.deepToMap(getResultBean(false, "Permission denied: " + Manifest.permission.WRITE_EXTERNAL_STORAGE)));
                    result.success(json);
                    return;
                }
                PgyCrashManager.register(); //推荐使用
//                PgyCrashManager.setIsIgnoreDefaultHander(false);
                json = JsonUtil.toJson(MapUtil.deepToMap(getResultBean(true, "初始化成功")));
            } catch (Exception e) {
                json = JsonUtil.toJson(MapUtil.deepToMap(getResultBean(false, "初始化失败：" + e.getMessage())));
            }
            result.success(json);
        } else if (call.method.equals("reportException")) {
            String message = "";
            String detail = null;
            if (call.hasArgument("crash_message")) {
                message = call.argument("crash_message");
            }
            if (call.hasArgument("crash_detail")) {
                detail = call.argument("crash_detail");
            }
            if (TextUtils.isEmpty(detail)) return;
            String[] details = detail.split("#");
            List<StackTraceElement> elements = new ArrayList<>();
            for (String s : details) {
                if (!TextUtils.isEmpty(s)) {
                    String methodName = null;
                    String fileName = null;
                    int lineNum = -1;
                    String[] contents = s.split(" \\(");
                    if (contents.length > 0) {
                        methodName = contents[0];
                        if (contents.length < 2) {
                            break;
                        }
                        String packageContent = contents[1].replace(")", "");
                        String[] packageContentArray = packageContent.split("\\.dart:");
                        if (packageContentArray.length > 0) {
                            if (packageContentArray.length == 1) {
                                fileName = packageContentArray[0];
                            } else {
                                fileName = packageContentArray[0] + ".dart";
                                Pattern patternTrace = Pattern.compile("[1-9]\\d*");
                                Matcher m = patternTrace.matcher(packageContentArray[1]);
                                if (m.find()) {
                                    String lineNumStr = m.group();
                                    lineNum = Integer.parseInt(lineNumStr);
                                }
                            }
                        }
                    }
                    StackTraceElement element = new StackTraceElement("Dart", methodName, fileName, lineNum);
                    elements.add(element);
                }
            }
            Throwable throwable = new Throwable(message);
            if (elements.size() > 0) {
                StackTraceElement[] elementsArray = new StackTraceElement[elements.size()];
                throwable.setStackTrace(elements.toArray(elementsArray));
            }
            PgyCrashManager.reportCaughtException(new Exception(throwable));
            result.success(null);
        } else if (call.method.equals("setEnableFeedback")) {
            if (call.hasArgument("enable")) {
                boolean enable = call.argument("enable");
                if (enable) {
                    PgyerFeedbackManager.PgyerFeedbackBuilder builder = new PgyerFeedbackManager.PgyerFeedbackBuilder();
                    if (call.hasArgument("isDialog")) {
                        boolean isDialog = call.argument("isDialog");
                        builder.setDisplayType(isDialog ? PgyerFeedbackManager.TYPE.DIALOG_TYPE : PgyerFeedbackManager.TYPE.ACTIVITY_TYPE);
                        if (call.hasArgument("isThreeFingersPan")) {
                            boolean isThreeFingersPan = call.argument("isThreeFingersPan");
                            builder.setShakeInvoke(!isThreeFingersPan);

                        }
                        if (call.hasArgument("colorHex")) {
                            String colorHex = call.argument("colorHex");
                            if (!TextUtils.isEmpty(colorHex))
                                builder.setColorDialogTitle(colorHex)    //设置Dialog 标题的字体颜色，默认为颜色为#ffffff
                                        .setColorTitleBg(colorHex)        //设置Dialog 标题栏的背景色，默认为颜色为#2E2D2D
                                        .setBarBackgroundColor(colorHex)      // 设置顶部按钮和底部背景色，默认颜色为 #2E2D2D
                                        .setBarButtonPressedColor(colorHex)        //设置顶部按钮和底部按钮按下时的反馈色 默认颜色为 #383737
                                        .setColorPickerBackgroundColor(colorHex);   //设置颜色选择器的背景色,默认颜色为 #272828
                        }
                        if (call.hasArgument("param")) {
                            Map<String, String> param = call.argument("param");
                            for (Map.Entry<String, String> entry : param.entrySet()) {
                                builder.setMoreParam(entry.getKey(), entry.getValue());
                            }
                        }
                    }
                    pgyerFeedbackManager = builder.builder();
                    pgyerFeedbackManager.register();
                }
            }
            result.success(null);
        } else if (call.method.equals("showFeedbackView")) {
            if (pgyerFeedbackManager != null) {
                pgyerFeedbackManager.invoke();
            }
            result.success(null);
        } else if (call.method.equals("checkUpdate")) {
            new PgyUpdateManager.Builder()
//                    .setForced(true)                //设置是否强制提示更新,非自定义回调更新接口此方法有用
//                    .setUserCanRetry(false)         //失败后是否提示重新下载，非自定义下载 apk 回调此方法有用
//                    .setDeleteHistroyApk(false)     // 检查更新前是否删除本地历史 Apk， 默认为true
                    .setUpdateManagerListener(new UpdateManagerListener() {
                        @Override
                        public void onNoUpdateAvailable() {
                            //没有更新是回调此方法
                            LogUtil.d("pgyer", "there is no new version");
                        }

                        @Override
                        public void onUpdateAvailable(AppBean appBean) {
                            //有更新回调此方法
                            //调用以下方法，DownloadFileListener 才有效；
                            //如果完全使用自己的下载方法，不需要设置DownloadFileListener
                            if (call.hasArgument("autoDownload")) {
                                boolean autoDownload = call.argument("autoDownload");
                                if (autoDownload)
                                    PgyUpdateManager.downLoadApk(appBean.getDownloadURL());
                            }
                            flutterAppBean = appBean;
                            if (Integer.parseInt(appBean.getVersionCode()) > AppUtil.getAppVersionCode(activity)) {
                                AppUtil.saveAppBean(activity, appBean);
                            }
                        }

                        @Override
                        public void checkUpdateFailed(Exception e) {
                            //更新检测失败回调
                            //更新拒绝（应用被下架，过期，不在安装有效期，下载次数用尽）以及无网络情况会调用此接口
                            LogUtil.e("pgyer", "check update failed ", e);
                        }
                    })
//                    //注意 ：
//                    //下载方法调用 PgyUpdateManager.downLoadApk(appBean.getDownloadURL()); 此回调才有效
//                    //此方法是方便用户自己实现下载进度和状态的 UI 提供的回调
//                    //想要使用蒲公英的默认下载进度的UI则不设置此方法
                    .setDownloadFileListener(new DownloadFileListener() {
                        @Override
                        public void downloadFailed() {
                            //下载失败
                            LogUtil.e("pgyer", "download apk failed");
                        }

                        @Override
                        public void downloadSuccessful(Uri uri) {
                            LogUtil.e("pgyer", "download apk failed");
                            // 使用蒲公英提供的安装方法提示用户 安装apk
                            PgyUpdateManager.installApk(uri);
                        }

                        @Override
                        public void onProgressUpdate(Integer... integers) {
                            LogUtil.e("pgyer", "update download apk progress" + integers);
                        }
                    })
                    .register();
            result.success(null);
        } else if (call.method.equals("getAppBean")) {
            String json;
            if (flutterAppBean == null) {
                json = AppUtil.getAppBeanJson(activity);
            } else {
                json = JsonUtil.toJson(flutterAppBean);
            }
            result.success(json);
        } else {
            result.notImplemented();
        }
    }

    private InitResultInfo getResultBean(boolean isSuccess, String msg) {
        InitResultInfo bean = new InitResultInfo();
        bean.setSuccess(isSuccess);
        bean.setMessage(msg);
        return bean;
    }

    private boolean hasPermission(String permission) {
        return ContextCompat.checkSelfPermission(activity, permission) == PermissionChecker.PERMISSION_GRANTED;
    }

}
