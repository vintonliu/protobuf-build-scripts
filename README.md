# protobuf-build-scripts
    记录各平台编译 protobuf 的脚本，自测正常编译通过。
## Build Guide
### Android
1. 自行下载 protobuf-3.11.2版本，并解压，将该仓库的 make_android_toolchain.sh 和 build_android.sh 拷贝至解压后的 protobuf 根目录；
2. 下载 ndk r20，并解压，然后执行脚本生成各架构独立工具链，修改以下脚本的中 NDK_HOME 指向解压后的 r20 根目录，执行脚本：
```
./make_android_toolchain.sh
```

3. 在上一步已经生成了各 cpu 架构的工具链，执行以下脚本：
```
./build_android.sh
```

4. 编译完成后的库目录在当前目录的 output 文件夹内。
   
### IOS && MAC
MACOS 内执行脚本 build_protobuf_ios_mac_3.11.2.sh
```
./build_protobuf_ios_mac_3.11.2.sh
```

### Win
1. 自行下载 protobuf-3.11.2版本，并解压，将该仓库的 build_cmake_win.sh 拷贝至解压后的 protobuf 根目录；
2. 在 windows 平台内执行 build_cmake_win.sh，windows 自带的命令提示符无法执行 shell 脚本，可以使用 VSCode 设置内部命令行集成环境为 git bash。
```
./build_cmake_win.sh
```
