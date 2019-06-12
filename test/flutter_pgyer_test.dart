import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pgyer/flutter_pgyer.dart';

void main() {
  const MethodChannel channel = MethodChannel('crazecoder/flutter_pgyer');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

//  test('initSdk', () async {
//    expect(await FlutterPgyer.init(), '42');
//  });
}
