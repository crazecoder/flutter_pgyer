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
        iOSAppId: "appid",
        androidAppId: "appid",
      );

//用户反馈附带参数
FlutterPgyer.setEnableFeedback(param: map);

//检查更新，android用户获取更新信息，iOS直接弹窗
//可选参数
//bool autoDownload = false, //android专用，自动下载安装，没有交互界面
FlutterPgyer.checkUpdate();
```
###Android 
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

4、控制台预览
----
#### 统计
![](https://github.com/crazecoder/flutter_pgyer/blob/master/screenshot/1.png)
![](https://github.com/crazecoder/flutter_pgyer/blob/master/screenshot/5.png)
#### android异常上报
![](https://github.com/crazecoder/flutter_pgyer/blob/master/screenshot/2.png)
![](https://github.com/crazecoder/flutter_pgyer/blob/master/screenshot/3.png)
#### iOS反馈
![](https://github.com/crazecoder/flutter_pgyer/blob/master/screenshot/6.png)



