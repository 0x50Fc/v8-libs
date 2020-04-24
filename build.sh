#!/bin/bash

set -e

WORK_DIR=`pwd`

cd ../v8

rm -rf out.gn/armeabi
rm -rf out.gn/armeabi-v7a
rm -rf out.gn/arm64-v8a
rm -rf out.gn/x86

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

    rm -rf $WORK_DIR/$ANDROID_ARCH
    mkdir $WORK_DIR/$ANDROID_ARCH

    $AR rcsD $WORK_DIR/$ANDROID_ARCH/libv8_base.a $OUT_DIR/obj/v8_base_without_compiler/*.o
}

ANDROID_ARCH=armeabi
OUT_DIR=out.gn/$ANDROID_ARCH
TARGET_CPU=arm
ARM_VERSION=6
build_v8

rm -rf $WORK_DIR/include
mkdir $WORK_DIR/include
cp -r include/* $WORK_DIR/include

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