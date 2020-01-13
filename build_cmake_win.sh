#!/bin/bash

CWD=`pwd`

BUILD_MODE="Release"

ARCHS=(
    "Win32"
    "x64"
)

SOURCE_DIR="$CWD"
OBJECT_DIR="$CWD/output/win/object"
INSTALL_DIR="$CWD/output/win/install"

rm -rf $OBJECT_DIR

# CMAKE_CONFIG="-DCMAKE_BUILD_TYPE=$BUILD_MODE"
PROTOBUF_CONFIG="-Dprotobuf_BUILD_TESTS=OFF"

num=${#ARCHS[@]}
for((i=0; i<num; i++))
do
    mkdir -p $OBJECT_DIR/${ARCHS[i]}
    mkdir -p $INSTALL_DIR/${ARCHS[i]}
    cd $OBJECT_DIR/${ARCHS[i]}

    cmake -G"Visual Studio 14 2015" $CMAKE_CONFIG -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR/${ARCHS[i]}" -A ${ARCHS[i]} $SOURCE_DIR/cmake

    cmake --build . --config $BUILD_MODE
    cmake --install . --config $BUILD_MODE
done
