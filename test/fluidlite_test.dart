import 'package:flutter_test/flutter_test.dart';
import 'package:fluidlite/fluidlite.dart';
import 'package:fluidlite/fluidlite_platform_interface.dart';
import 'package:fluidlite/fluidlite_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFluidlitePlatform
    with MockPlatformInterfaceMixin
    implements FluidlitePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FluidlitePlatform initialPlatform = FluidlitePlatform.instance;

  test('$MethodChannelFluidlite is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFluidlite>());
  });

  test('getPlatformVersion', () async {
    Fluidlite fluidlitePlugin = Fluidlite();
    MockFluidlitePlatform fakePlatform = MockFluidlitePlatform();
    FluidlitePlatform.instance = fakePlatform;

    expect(await fluidlitePlugin.getPlatformVersion(), '42');
  });
}
