import 'dart:ffi';
import 'dart:io';

import 'fluidlite_bindings.dart';

class FluidLiteLibrary {
  static const _libName = 'fluidlite';

  static final DynamicLibrary _dylib = () {
    if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.open('lib$_libName.dylib');
    }
    if (Platform.isAndroid || Platform.isLinux) {
      return DynamicLibrary.open('lib$_libName.so');
    }
    if (Platform.isWindows) {
      return DynamicLibrary.open('$_libName.dll');
    }
    throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
  }();

  static FluidLiteBindings bindings = FluidLiteBindings(_dylib);

  const FluidLiteLibrary._();
}
