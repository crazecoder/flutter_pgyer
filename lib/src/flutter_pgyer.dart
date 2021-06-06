import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pgyer/src/bean/check_result.dart';
import 'package:flutter_pgyer/src/bean/check_soft_model.dart';
import 'package:flutter_pgyer/src/bean/ios_check_model.dart';
import 'package:flutter_pgyer/src/bean/result.dart';

typedef FlutterPgyerInitCallBack = Function(InitResultInfo);

class FlutterPgyer {
  static const MethodChannel _channel =
      const MethodChannel('crazecoder/flutter_pgyer');
  static final _onCheckUpgrade = StreamController<CheckResult>.broadcast();

  FlutterPgyer._();

  static Future<Null> _handleMessages(MethodCall call) async {
    switch (call.method) {
      case 'onCheckUpgrade':
        CheckResult _result = CheckResult(
          model: call.arguments == null ||
                  (Platform.isAndroid && call.arguments["model"] == null)
              ? null
              : Platform.isIOS
                  ? IOSCheckModel.fromJson(call.arguments)
                  : CheckSoftModel.fromJson(call.arguments["model"]),
          checkEnum: Platform.isIOS
              ? call.arguments == null
                  ? CheckEnum.NO_VERSION
                  : CheckEnum.SUCCESS
              : CheckEnum.values[call.arguments["enum"]],
        );
        _onCheckUpgrade.add(_result);
        break;
    }
  }

  static Stream<CheckResult> get onCheckUpgrade => _onCheckUpgrade.stream;

  static void init({
    FlutterPgyerInitCallBack? callBack,
    String? androidApiKey,
    String? frontJSToken,
    String? iOSAppKey,
  }) {
    assert(
        (Platform.isAndroid && androidApiKey != null && frontJSToken != null) ||
            (Platform.isIOS && iOSAppKey != null));
    _channel.setMethodCallHandler(_handleMessages);
    Map<String, Object?> map = {
      "apiKey": androidApiKey,
      "frontJSToken": frontJSToken,
      "appId": iOSAppKey,
    };
    var resultBean;
    Isolate.current.addErrorListener(new RawReceivePort((dynamic pair) {
      var isolateError = pair as List<dynamic>;
      var _error = isolateError.first;
      var _stackTrace = isolateError.last;
      Zone.current.handleUncaughtError(_error, _stackTrace);
    }).sendPort);
    runZonedGuarded(
      () async {
        final String result =
            await (_channel.invokeMethod('initSdk', map) as FutureOr<dynamic>);
        Map resultMap = json.decode(result);
        resultBean = InitResultInfo.fromJson(resultMap as Map<String, dynamic>);
        callBack!(resultBean);
      },
      (error, stackTrace) {
        resultBean = InitResultInfo();
        callBack!(resultBean);
      },
    );
    FlutterError.onError = (details) {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    };
  }

  ///用户反馈 iOS专用
  static Future<Null> setEnableFeedback({
    bool enable = true,
    String? colorHex, //反馈界面主题颜色，16进制颜色字符串，如#FFFFFF
    bool isDialog = true, // android专用，设置用户反馈为弹窗，false 为activity
    Map<String, String>? param, // android专用，自定义的反馈数据
    bool isThreeFingersPan =
        false, // ios，设置用户反馈界面激活方式为三指拖动 android，设置true时，不开启摇一摇，需要手动show
    double shakingThreshold = 2.3, //ios专用，自定义摇一摇灵敏度，默认为2.3，数值越小灵敏度越高
  }) async {
    if (Platform.isAndroid) {
      return;
    }
    Map<String, Object?> map = {
      "enable": enable,
      "colorHex": colorHex,
      "isDialog": isDialog,
      "param": param,
      "shakingThreshold": shakingThreshold,
      "isThreeFingersPan": isThreeFingersPan,
    };
    await _channel.invokeMethod('setEnableFeedback', map);
  }

  ///手动显示用户反馈界面，需在setEnableFeedback后调用 iOS专用
  static Future<Null> showFeedbackView() async {
    await _channel.invokeMethod('showFeedbackView');
  }

  ///检查更新
  static Future<Null> checkSoftwareUpdate({bool justNotify = true}) async {
    Map<String, Object> map = {
      "justNotify": justNotify,
    };
    await _channel.invokeMethod('checkSoftwareUpdate', map);
  }

  ///检查更新
  static Future<Null> checkVersionUpdate() async {
    await _channel.invokeMethod('checkVersionUpdate');
  }

  ///异常上报，官方设置
  ///调试模式下iOS会因为当前为调试模式，所以异常信息将不会被上报至蒲公英。
  static void reportException<T>(
    T callback(), {
    FlutterExceptionHandler? handler, //异常捕捉，用于自定义打印异常
    String? filterRegExp, //异常上报过滤正则，针对message
  }) {
    bool useLog = false;
    assert(useLog = true);

    Isolate.current.addErrorListener(RawReceivePort((dynamic pair) async {
      var isolateError = pair as List<dynamic>;
      var _error = isolateError.first;
      var _stackTrace = isolateError.last;
      Zone.current.handleUncaughtError(_error, _stackTrace);
    }).sendPort);
    runZonedGuarded<Future<Null>>(() async {
      callback();
    }, (error, stackTrace) async {
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
      uploadException(message: errorStr, detail: stackTrace.toString());
    });
    FlutterError.onError = (FlutterErrorDetails details) async {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    };
  }

  static Future<Null> uploadException({String? message, String? detail}) async {
    assert(message != null && detail != null);
    var map = {};
    map.putIfAbsent("crash_message", () => message);
    map.putIfAbsent("crash_detail", () => detail);
    await _channel.invokeMethod('reportException', map);
  }

  static void dispose() {
    _onCheckUpgrade.close();
  }
}
