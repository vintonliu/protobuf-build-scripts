#########################################################################
# File Name: build_sdk.sh
# Author: Vinton
# Created Time: 2020-2-11
#########################################################################

#!/bin/bash

CWD=`pwd`

BUILD_MODE=$1
if [ -n "$BUILD_MODE" ]
then
    BUILD_MODE=Debug
else
    BUILD_MODE=MinSizeRel
fi

echo "BUILD_MODE: $BUILD_MODE"


#配置交叉编译链
# ANDROID_NDK_TOOLCHAIN_HOME=~/android-ndk-r17c
# windows平台，VSCode, git bash
ANDROID_NDK_TOOLCHAIN_HOME=~/android-ndk-r20b
CMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_TOOLCHAIN_HOME/build/cmake/android.toolchain.cmake

# CMakeList.txt 所在文件夹
SOURCE_PATH=$CWD/cmake
# 编译中间文件夹
OBJECT_DIR="$CWD/out/build/android_$BUILD_MODE"
#安装文件夹
INSTALL_DIR="$CWD/out/install/android_$BUILD_MODE"

if [ -n "$1" -a "$1" == "clean" ]; then
	echo "rm -rf $CWD/out/build/android"
	rm -rf "$CWD/out/build/android*"
exit 0
fi

# 五种类型cpu编译链
android_toolchains=(
    # armeabi is no longer support build
#   "armeabi"
    "armeabi-v7a"
    "arm64-v8a"
    "x86"
    "x86_64"
)

API=23


PLATFORM_CONFIG="-DANDROID=1 -DCMAKE_SYSTEM_NAME=Android \
                -DANDROID_NDK=$ANDROID_NDK_TOOLCHAIN_HOME \
                -DANDROID_TOOLCHAIN=clang \
                -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE \
                -DANDROID_NATIVE_API_LEVEL=$API \
                -DCMAKE_BUILD_TYPE=$BUILD_MODE"

BUILD_CONFIG="-DCMAKE_VERBOSE_MAKEFILE=ON"
PROTOBUF_CONFIG="-Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_BUILD_PROTOC_BINARIES=OFF"

num=${#android_toolchains[@]}
for((i=0; i<num; i++))
do
    echo "************* building ${android_toolchains[i]} ***********"
    
    # create build temp dir
    mkdir -p $OBJECT_DIR/${android_toolchains[i]}	
	mkdir -p $INSTALL_DIR/${android_toolchains[i]}

    cd $OBJECT_DIR/${android_toolchains[i]}

    PLATFORM_CONFIG="$PLATFORM_CONFIG \
                -DANDROID_ABI=${android_toolchains[i]} \
                -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/${android_toolchains[i]}"

    cmake -G "Ninja" $PLATFORM_CONFIG $BUILD_CONFIG $PROTOBUF_CONFIG $SOURCE_PATH
    echo "******************** cmake generator done ****************"
    #cmake --build .
    ninja -j8
    echo "******************** cmake build done ********************"
    
    ninja install

done