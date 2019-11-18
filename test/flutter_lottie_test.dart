import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mark922_flutter_lottie/mark922_flutter_lottie.dart';

void main() {
  const MethodChannel channel = MethodChannel('mark922_flutter_lottie');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await FlutterLottie.platformVersion, '42');
  // });
}
