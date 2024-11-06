#!/bin/bash
CMAKE="cmake"
SRC="./fluidlite"
BLD="./fluidlite"
NDK='/Users/akmal/Library/Android/sdk/ndk/25.1.8937393'

${CMAKE} -S ${SRC} -B ${BLD} \
    -DFLUIDLITE_BUILD_STATIC:BOOL="0" \
    -DFLUIDLITE_BUILD_SHARED:BOOL="1" \
    -DENABLE_SF3:BOOL="1" \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_SKIP_RPATH:BOOL="0" \
    -DCMAKE_INSTALL_LIBDIR="lib" \
    -DCMAKE_INSTALL_PREFIX=$HOME/FluidLite \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL="1" \
    $*
${CMAKE} --build $BLD

mv fluidlite/fluid_config.h fluidlite/src/fluid_config.h
mv fluidlite/fluidlite/version.h fluidlite/include/fluidlite/version.h
dart run ffigen --config ffigen.yaml

## Android
${NDK}/ndk-build -C fluidlite/android
cp -r fluidlite/android/libs/ android/src/main/jniLibs

# MacOS
cp fluidlite/*.dylib macos/Libraries