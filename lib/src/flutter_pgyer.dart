import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pgyer/src/bean/result.dart';
import 'package:flutter_pgyer/src/bean/app_bean.dart';

typedef FlutterPgyerInitCallBack = Function(InitResultInfo);

class FlutterPgyer {
  static const MethodChannel _channel =
      const MethodChannel('crazecoder/flutter_pgyer');

  static void init({
    FlutterPgyerInitCallBack callBack,
    String androidAppId,
    String iOSAppId,
  }) {
    assert((Platform.isAndroid && androidAppId != null) ||
        (Platform.isIOS && iOSAppId != null));
    Map<String, Object> map = {
      "appId": Platform.isAndroid ? androidAppId : iOSAppId,
    };
    var resultBean;
    runZoned(
      () async {
        final String result = await _channel.invokeMethod('initSdk', map);
        Map resultMap = json.decode(result);
        resultBean = InitResultInfo.fromJson(resultMap);
        callBack(resultBean);
      },
      onError: (error) {
        resultBean = InitResultInfo();
        callBack(resultBean);
      },
    );
  }

  ///用户反馈
  static Future<Null> setEnableFeedback({
    bool enable = true,
    String colorHex, //反馈界面主题颜色，16进制颜色字符串，如#FFFFFF
    bool isDialog = true, // android专用，设置用户反馈为弹窗，false 为activity
    Map<String, String> param, // android专用，自定义的反馈数据
    bool isThreeFingersPan =
        false, // ios，设置用户反馈界面激活方式为三指拖动 android，设置true时，不开启摇一摇，需要手动show
    double shakingThreshold = 2.3, //ios专用，自定义摇一摇灵敏度，默认为2.3，数值越小灵敏度越高
  }) async {
    Map<String, Object> map = {
      "enable": enable,
      "colorHex": colorHex,
      "isDialog": isDialog,
      "param": param,
      "shakingThreshold": shakingThreshold,
      "isThreeFingersPan": isThreeFingersPan,
    };
    await _channel.invokeMethod('setEnableFeedback', map);
  }

  ///手动显示用户反馈界面，需在setEnableFeedback后调用
  static Future<Null> showFeedbackView() async {
    await _channel.invokeMethod('showFeedbackView');
  }

  ///检查更新
  static Future<Null> checkUpdate({
    bool autoDownload = false, //android专用，自动下载安装，没有交互界面
  }) async {
    Map<String, Object> map = {
      "autoDownload": autoDownload,
    };
    await _channel.invokeMethod('checkUpdate', map);
  }

  ///android专用，获取更新信息，在checkUpdate后使用，尽量避免checkUpdate没监听到返回就调用此方法
  static Future<AppBean> getAppBean() async {
    final String result = await _channel.invokeMethod('getAppBean');
    if (result == null || result.isEmpty) return null;
    Map map = json.decode(result);
    var appBean = AppBean.fromJson(map);
    return appBean;
  }

  ///异常上报，官方设置
  ///调试模式下ios会因为当前为调试模式，所以异常信息将不会被上报至蒲公英。
  static void reportException<T>(
    T callback(), {
    FlutterExceptionHandler handler, //异常捕捉，用于自定义打印异常
    String filterRegExp, //异常上报过滤正则，针对message
  }) {
    bool useLog = false;
    assert(useLog = true);
    FlutterError.onError = (FlutterErrorDetails details) async {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    };
    Isolate.current.addErrorListener(RawReceivePort((dynamic pair) async {
      var isolateError = pair as List<dynamic>;
      var _error = isolateError.first;
      var _stackTrace = isolateError.last;
      Zone.current.handleUncaughtError(_error, _stackTrace);
    }).sendPort);
    runZoned<Future<Null>>(() async {
      callback();
    }, onError: (error, stackTrace) async {
      if (useLog || handler != null) {
        FlutterErrorDetails details =
            FlutterErrorDetails(exception: error, stack: stackTrace);
        // In development mode simply print to console.
        handler == null
            ? FlutterError.dumpErrorToConsole(details)
            : handler(details);
      }
      var errorStr = error.toString();
      //异常过滤
      if (filterRegExp != null) {
        RegExp reg = new RegExp(filterRegExp);
        Iterable<Match> matches = reg.allMatches(errorStr);
        if (matches.length > 0) {
          return;
        }
      }
      uploadException(message: errorStr,detail: stackTrace.toString());
    });
  }

  static Future<Null> uploadException({String message, String detail}) async {
    assert(message != null && detail != null);
    var map = {};
    map.putIfAbsent("crash_message", () => message);
    map.putIfAbsent("crash_detail", () => detail);
    await _channel.invokeMethod('reportException', map);
  }
}
