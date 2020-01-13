#########################################################################
# File Name: build_android.sh
# Author: liuwch
# mail: liuwenchang1234@163.com
# Created Time: 四  1/ 9 17:06:32 2020
#########################################################################
#!/bin/bash

ROOT=`pwd`

#配置交叉编译链
export TOOL_ROOT=~/android-toolchain-r20-llvm

# 五种类型cpu编译链
android_toolchains=(
   "armeabi"
   "armeabi-v7a"
   "arm64-v8a"
   "x86"
   "x86_64"
)

# 优化编译项
API=23
extra_cflags=(
   "-march=armv5te -D__ANDROID__ -D__ANDROID_API__=$API -D__ARM_ARCH_5TE__ -D__ARM_ARCH_5TEJ__"
   "-march=armv7-a -mfloat-abi=softfp -mfpu=neon -mthumb -D__ANDROID__ -D__ANDROID_API__=$API -D__ARM_ARCH_7__ -D__ARM_ARCH_7A__ -D__ARM_ARCH_7R__ -D__ARM_ARCH_7M__ -D__ARM_ARCH_7S__"
   "-march=armv8-a -D__ANDROID__ -D__ANDROID_API__=$API -D__ARM_ARCH_8__ -D__ARM_ARCH_8A__"
   "-march=i686 -mtune=i686 -m32 -mmmx -msse2 -msse3 -mssse3 -D__ANDROID__ -D__ANDROID_API__=$API -D__i686__"
   "-march=core-avx-i -mtune=core-avx-i -m64 -mmmx -msse2 -msse3 -mssse3 -msse4.1 -msse4.2 -mpopcnt -D__ANDROID__ -D__ANDROID_API__=$API -D__x86_64__"
)

# extra_ldflags="-nostdlib"

#共同配置项,可以额外增加相关配置，详情可查看源文件目录下configure
# --enable-shared
configure="--with-protoc=protoc \
           --disable-shared \
           --enable-cross-compile"

#交叉编译后的运行环境
hosts=(
  "arm-linux-androideabi"
  "arm-linux-androideabi"
  "aarch64-linux-android"
  "i686-linux-android"
  "x86_64-linux-android"
)

PROJECT=protobuf
SOURCE_PATH=$ROOT

# 编译中间文件夹
OBJECT_DIR="$ROOT/output/android/$PROJECT/object"

#安装文件夹
INSTALL_DIR="$ROOT/output/android/$PROJECT/install"

# 缓存用户 PATH 变量
USER_PATH=$PATH

./autogen.sh

# 删除旧目录
rm -rf "$ROOT/output/android/$PROJECT"

num=${#android_toolchains[@]}
for((i=0; i<num; i++))
do
   export PATH="$TOOL_ROOT/${android_toolchains[i]}/bin:$USER_PATH"
   # echo "PATH=$PATH"
   
   mkdir -p $OBJECT_DIR/${android_toolchains[i]}
   cd $OBJECT_DIR/${android_toolchains[i]}

   echo "开始配置 ${android_toolchains[i]} 版本"

   LIBS="-llog -lz -lc++_static"
   CXXFLAGS="-frtti -fexceptions ${extra_cflags[i]}"
   export SYSROOT="$TOOL_ROOT/${android_toolchains[i]}/sysroot"
   export CC="${hosts[i]}-clang --sysroot $SYSROOT"
   export CXX="${hosts[i]}-clang++ --sysroot $SYSROOT"

   #交叉编译最重要的是配置--host、--cross-prefix、sysroot、以及extra-cflags和extra-ldflags
   $SOURCE_PATH/configure --prefix=$INSTALL_DIR/${android_toolchains[i]} \
                           ${configure} \
                           --host=${hosts[i]} \
                           --with-sysroot="$SYSROOT" \
                           CFLAGS="${extra_cflags[i]}" \
                           CXXFLAGS="$CXXFLAGS" \
                           LIBS="$LIBS" \
                           || exit 1
   # make clean
   echo "开始编译并安装 ${android_toolchains[i]} 版本"
   make -j8 install

   unset PATH
done