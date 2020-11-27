#########################################################################
# File Name: build_cmake_mac.sh
# Author: liuwch
# mail: liuwenchang1234@163.com
# Created Time: 四  1/ 9 10:40:44 2020
#########################################################################
#!/bin/bash


CWD=`pwd`

BUILD_MODE=Release
LINK_MODE=static

BUILD_MODE=$1
if [ -n "$BUILD_MODE" ]
then
    BUILD_MODE=Debug
else
    BUILD_MODE=Release
fi

PLATFORM_CONFIG="-DCMAKE_BUILD_TYPE=$BUILD_MODE"
PROTOBUF_CONFIG="-Dprotobuf_BUILD_TESTS=OFF \
                -Dprotobuf_WITH_ZLIB=OFF"

CMAKE_BUILD_CONFIG="-DCMAKE_VERBOSE_MAKEFILE=OFF"

# CMakeList.txt 所在文件夹
SOURCE_PATH=$CWD/cmake
# 编译中间文件夹
OBJECT_DIR="$CWD/out/build/mac_$BUILD_MODE"
#安装文件夹
INSTALL_DIR="$CWD/out/install/mac_$BUILD_MODE"

SYSROOT="$(xcode-select -print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/"
CC=`xcrun -sdk ${SYSROOT} -find clang`
CXX=`xcrun -sdk ${SYSROOT} -find clang++`

build_protobuf() {
    if [ ! -d $OBJECT_DIR ]
    then
    mkdir -p $OBJECT_DIR
    fi

    cd $OBJECT_DIR

    CMAKE_CONFIG="$CMAKE_BUILD_CONFIG \
                -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
                -DCMAKE_OSX_DEPLOYMENT_TARGET=10.10 \
                -DCMAKE_C_COMPILER=$CC \
                -DCMAKE_CXX_COMPILER=$CXX"

    cmake -G"Ninja" $PLATFORM_CONFIG $PROTOBUF_CONFIG $CMAKE_CONFIG $SOURCE_PATH || exit 1
    echo "**************** config done *******************"
    #cmake --build . --config Release
    ninja -j8 install || exit 1
    echo "**************** build done *****************"
}

copy_lib() {
    echo "**************** install lib *****************"
    LIB_DIR=$CWD/lib/mac/$BUILD_MODE
    if [ ! -d $LIB_DIR ]
    then
        mkdir -p $LIB_DIR
    fi

    cp -Rfv $INSTALL_DIR/lib/*.a $LIB_DIR/
}

copy_bin() {
    echo "**************** install bin *****************"
    BIN_DIR=$CWD/bin/mac
    if [ ! -d $BIN_DIR ]
    then
        mkdir -p $BIN_DIR
    fi

    cp -Rfv $INSTALL_DIR/bin/* $BIN_DIR/
}

build_protobuf || exit 1
copy_lib
copy_bin

echo Done
