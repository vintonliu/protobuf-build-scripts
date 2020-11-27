#########################################################################
# File Name: build_ios.sh
# Author: liuwch
# mail: liuwenchang1234@163.com
# Created Time: 三  2/ 23 09:36:12 2020
#########################################################################
#!/bin/bash

CWD=`pwd`

# BUILD_MODE=Release
LINK_MODE=static

BUILD_MODE=$1
if [ -n "$BUILD_MODE" ]
then
    BUILD_MODE=Debug
else
    BUILD_MODE=Release
fi

SOURCE_PATH=$CWD/cmake
# 编译中间文件夹
OBJECT_DIR="$CWD/out/build/ios_$BUILD_MODE"
#安装文件夹
INSTALL_DIR="$CWD/out/install/ios_$BUILD_MODE"
THIN_DIR="$INSTALL_DIR"
FAT_DIR="$INSTALL_DIR/all"
rm -rf $FAT_DIR

# PLATFORM_CONFIG="-DCMAKE_TOOLCHAIN_FILE=$CWD/cmake/ios.toolchain.cmake \
#                -DCMAKE_BUILD_TYPE=$BUILD_MODE \
#                -DENABLE_BITCODE=0 \
#                -DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=E8TD92447B \
#                -DDEPLOYMENT_TARGET=9.0"

PLATFORM_CONFIG="-DCMAKE_BUILD_TYPE=$BUILD_MODE \
                -DCMAKE_SYSTEM_NAME=iOS"

PLATFORMS=(
    "OS"
    "SIMULATOR"
    "SIMULATOR64"
)

ARCHS=(
    "armv7;armv7s;arm64"
    "i386"
    "x86_64"
)

IOSFLAGS="-miphoneos-version-min=9.0"

PROTOBUF_CONFIG="-Dprotobuf_BUILD_TESTS=OFF \
                -Dprotobuf_WITH_ZLIB=OFF \
                -Dprotobuf_BUILD_PROTOC_BINARIES=OFF"

build_protobuf() {
    CFLAGS="$IOSFLAGS"

    num=${#PLATFORMS[@]}
    for((i=0; i<num; i++))
    do  
        echo "************** building for ${PLATFORMS[i]} *************"
        if [ ! -d "$OBJECT_DIR/${PLATFORMS[i]}" ]
        then
            mkdir -p "$OBJECT_DIR/${PLATFORMS[i]}"
        fi
        cd "$OBJECT_DIR/${PLATFORMS[i]}"

        if [ "${PLATFORMS[i]}" = "SIMULATOR" -o "${PLATFORMS[i]}" = "SIMULATOR64" ]
        then
            TARGET_SDK="iPhoneSimulator"
        else
            TARGET_SDK="iPhoneOS"
        fi

        SYSROOT="$(xcode-select -print-path)/Platforms/$TARGET_SDK.platform/Developer/SDKs/$TARGET_SDK.sdk/"
        CC=`xcodebuild -find clang`
        CXX=`xcodebuild -find clang++`

        CMAKE_CONFIG="$PLATFORM_CONFIG \
                    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/${PLATFORMS[i]} \
                    -DCMAKE_OSX_ARCHITECTURES=${ARCHS[i]} \
                    -DCMAKE_OSX_SYSROOT=$SYSROOT \
                    -DCMAKE_C_COMPILER=$CC \
                    -DCMAKE_CXX_COMPILER=$CXX \
                    -DCMAKE_C_FLAGS=$CFLAGS \
                    -DCMAKE_CXX_FLAGS=$CFLAGS"

        cmake -G"Ninja" $CMAKE_CONFIG $PROTOBUF_CONFIG $SOURCE_PATH || exit 1
        echo "**************** config done *******************"

        ninja -j8 install || exit 1
        # cmake --build . --config $BUILD_MODE || exit 1
        # cmake --install . --config $BUILD_MODE || exit 1
        echo "**************** build done *****************"
    done

    cd $CWD
}

combile_lib() {
    echo "*********************** combile lib **************************"
    mkdir -p $FAT_DIR/lib
    mkdir -p $FAT_DIR/include

    for LIB in `find $THIN_DIR/${PLATFORMS[0]} -name *.a`
    do
        libname=$(basename $LIB)
        # echo "LIB: $libname"
        target_lib=$FAT_DIR/lib/$libname
        lipo -create `find $THIN_DIR -name $libname` -output $target_lib
        lipo -info $target_lib
    done
    # cp -rvf $THIN_DIR/${PLATFORMS[0]}/include $FAT_DIR/

    cd $CWD
}

copy_lib() {
    echo "**************** install lib *****************"
    LIB_DIR=$CWD/lib/ios/$BUILD_MODE
    if [ ! -d $LIB_DIR ]
    then
        mkdir -p $LIB_DIR
    fi

    cp -Rfv $FAT_DIR/lib/*.a $LIB_DIR/
}

build_protobuf
combile_lib || exit 1
copy_lib

echo Done