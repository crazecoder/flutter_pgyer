# 考虑到蒲公英异常上报及统计需要付费，白嫖党可以使用[pgyer_updater](https://github.com/crazecoder/pgyer_updater)实现应用更新和[flutter_bugly](https://github.com/crazecoder/flutter_bugly)实现异常上报及统计来配合使用


# flutter_pgyer
[![pub package](https://img.shields.io/pub/v/flutter_pgyer.svg)](https://pub.dartlang.org/packages/flutter_pgyer)

## 蒲公英内测分发：数据统计、原生异常上报、flutter异常上报、应用更新、用户反馈

---

1、引入
--
```yaml
dependencies:
  flutter_pgyer: lastVersion
```

2、使用
----
```dart
import 'package:flutter_pgyer/flutter_pgyer.dart';

//使用flutter异常上报
void main() => FlutterPgyer.reportException(()=>runApp(MyApp()));

//初始化
FlutterPgyer.init(
        iOSAppKey: "your ios appkey",
        androidApiKey: "your android apikey",
        frontJSToken: "your frontjs token",
      );

//用户反馈附带参数,iOS专用
FlutterPgyer.setEnableFeedback(param: map);

//检查更新，justNotify默认true
FlutterPgyer.checkSoftwareUpdate(justNotify: false);
//检查更新回调，justNotify为false时回调
FlutterPgyer.onCheckUpgrade.listen((result){});
//手动上报异常
FlutterPgyer.uploadException({String message, String detail});
```

### Android 
在项目manifest里添加（如果对统计没有要求，可不配置，区别在于上传apk到蒲公英时，能不能检测到集成，无法检测到就不会有统计）
```
<meta-data
        android:name="PGYER_API_KEY"
        android:value="your api key"/>
<meta-data
        android:name="PGYER_FRONTJS_KEY"
        android:value="your frontjs key"/>
```
3、已知问题
----
1）iOS异常上报debug不可用，打包ipa没有测试，如有问题请issue



