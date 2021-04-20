import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_pgyer/flutter_pgyer.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => FlutterPgyer.reportException(() => runApp(MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    Permission.phone.request().then((value) => initPlatformState());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;
    // Platform messages may fail, so we use a try/catch PlatformException.
    FlutterPgyer.init(
        iOSAppId: "09134f7da29170173fb0e842a4a17f7d",
        androidApiKey: "0a7a3c64217418800cf254ebd1839187",
        frontJSToken: "44f5a0de2ec979b186c13723e1c3eb6d",
        callBack: (result) {
          setState(() {
            _platformVersion = result.message;
          });
        });
    FlutterPgyer.setEnableFeedback(
        param: {"test": "dddddd", "test1": "dddddd1"});
    FlutterPgyer.checkUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: GestureDetector(
            child: Text('初始化: $_platformVersion\n'),
            onTap: () {
              throw FlutterError("message");
            },
          ),
        ),
      ),
    );
  }
}
