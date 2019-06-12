# flutter_pgyer
[![pub package](https://img.shields.io/pub/v/flutter_pgyer.svg)](https://pub.dartlang.org/packages/flutter_pgyer)

## 支持Android/iOS 运营统计、原生异常上报、flutter异常上报、应用更新、用户反馈

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
      });

//用户反馈附带参数
FlutterPgyer.setEnableFeedback(param: map);

//检查更新，android用户获取更新信息，iOS直接弹窗
//可选参数
//bool autoDownload = false, //android专用，自动下载安装，没有交互界面
FlutterPgyer.checkUpdate();

//获取更新信息
FlutterPgyer.getAppBean().then((appBean){
              print(appBean?.downloadURL);
            });

```
