#!/bin/bash

CWD=`pwd`

BUILD_MODE="Release"

ARCHS=(
    "Win32"
    "x64"
)

SOURCE_DIR="$CWD"
OBJECT_DIR="$CWD/vsproject/"
INSTALL_DIR="$CWD/vsproject/install"

rm -rf $OBJECT_DIR

# set protobuf_MSVC_STATIC_RUNTIME=OFF for build /MD and MDd
PROTOBUF_CONFIG="-Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_MSVC_STATIC_RUNTIME=OFF"

num=${#ARCHS[@]}
for((i=0; i<num; i++))
do
    mkdir -p $OBJECT_DIR/${ARCHS[i]}
    mkdir -p $INSTALL_DIR/${ARCHS[i]}
    cd $OBJECT_DIR/${ARCHS[i]}

    cmake -G"Visual Studio 14 2015" $CMAKE_CONFIG $PROTOBUF_CONFIG -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR/${ARCHS[i]}" -A ${ARCHS[i]} $SOURCE_DIR/cmake

    # Release
    cmake --build . --config Release
    cmake --install . --config Release

    # Debug
    cmake --build . --config Debug
    cmake --install . --config Debug
done
