import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mno_lcp/r2_lcp_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('r2_lcp_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async => '42');
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await R2LcpFlutter.platformVersion, '42');
  });
}
