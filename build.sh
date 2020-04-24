#!/bin/bash

set -e

cd v8

rm -rf out.gn/armeabi
rm -rf out.gn/armeabi-v7a
rm -rf out.gn/arm64-v8a
rm -rf out.gn/x86

rm -rf dist-android
mkdir dist-android

ANDROID_NDK_ROOT=`pwd`/third_party/android_ndk

build_v8()
{
    ARM_VERSION_CONFIG=""
    if [ $ARM_VERSION ];then
        ARM_VERSION_CONFIG="arm_version=$ARM_VERSION"
        echo "arm version: $ARM_VERSION"
    else
        echo "can't find arm version!"
    fi

    CLANG_BASE=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64
    BIN_DIR=$CLANG_BASE/bin
    AR=$BIN_DIR/llvm-ar

    ARGS="is_component_build = false \
    is_debug = false \
    target_cpu = \"$TARGET_CPU\" \
    v8_target_cpu = \"$TARGET_CPU\" \
    target_os = \"android\" \
    use_goma = false \
    goma_dir = \"None\" \
    v8_enable_backtrace = true \
    v8_enable_disassembler = true \
    v8_enable_object_print = true \
    v8_enable_verify_heap = true \
    $ARM_VERSION_CONFIG \
    "

    gn gen $OUT_DIR --args="${ARGS}"
    # gn args $OUT_DIR --list
    ninja -C $OUT_DIR d8 -v # -j1


    rm -rf $OUT_DIR/libs
    mkdir $OUT_DIR/libs
    pushd $OUT_DIR/libs
    $AR rcsD libv8_base.a ../obj/v8_base/*.o
    $AR rcsD libv8_libbase.a ../obj/v8_libbase/*.o
    $AR rcsD libv8_libsampler.a ../obj/v8_libsampler/*.o
    $AR rcsD libv8_libplatform.a ../obj/v8_libplatform/*.o
    $AR rcsD libv8_nosnapshot.a ../obj/v8_nosnapshot/*.o
    # added other 3 needed
    $AR rcsD libv8_builtins_generators.a ../obj/v8_builtins_generators/*.o
    $AR rcsD libv8_builtins_setup.a ../obj/v8_builtins_setup/*.o
    $AR rcsD libinspector.a ../obj/src/inspector/inspector/*.o
    # no strip cmd in $CLANG_BASE/bin
    # $STRIP --strip-unneeded libv8_base.a
    # $STRIP --strip-unneeded libv8_libbase.a
    # $STRIP --strip-unneeded libv8_libsampler.a
    # $STRIP --strip-unneeded libv8_libplatform.a
    # $STRIP --strip-unneeded libv8_nosnapshot.a
    popd

    mkdir -p dist-android/$ANDROID_ARCH/include
    mkdir -p dist-android/$ANDROID_ARCH/libs
    cp -r include/* dist-android/$ANDROID_ARCH/include
    cp $OUT_DIR/libs/lib*.a dist-android/$ANDROID_ARCH/libs
}

ANDROID_ARCH=armeabi
OUT_DIR=out.gn/$ANDROID_ARCH
TARGET_CPU=arm
ARM_VERSION=6
build_v8

ANDROID_ARCH=armeabi-v7a
OUT_DIR=out.gn/$ANDROID_ARCH
TARGET_CPU=arm
ARM_VERSION=7
build_v8

ANDROID_ARCH=arm64-v8a
OUT_DIR=out.gn/$ANDROID_ARCH
TARGET_CPU=arm64
ARM_VERSION=8
build_v8

ANDROID_ARCH=x86
OUT_DIR=out.gn/$ANDROID_ARCH
TARGET_CPU=x86
ARM_VERSION=
build_v8