import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_pgyer/flutter_pgyer.dart';


void main() => FlutterPgyer.reportException(()=>runApp(MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;
    // Platform messages may fail, so we use a try/catch PlatformException.
    FlutterPgyer.init(
        iOSAppId: "09134f7da29170173fb0e842a4a17f7d",
        androidAppId: "c00c23e3a1c44b154d8853958c9d5c9c",
        callBack: (result) {
          setState(() {
            _platformVersion = result.message;
          });
        });
    FlutterPgyer.setEnableFeedback(param: {"test":"dddddd","test1":"dddddd1"});
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
          child: GestureDetector(child: Text('初始化: $_platformVersion\n'),onTap: (){
            FlutterPgyer.getAppBean().then((appBean){
              print(appBean?.downloadURL);
            });

          },),
        ),
      ),
    );
  }
}
