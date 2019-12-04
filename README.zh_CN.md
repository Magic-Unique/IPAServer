# IPAServer

[English](README.md)

IPA 无线安装工具

# 安装

## 1. 使用 Homebrew 安装

```bash
$ brew tap magic-unique/tap && brew install ipainstaller
```

## 2. 编译最新的二进制文件

1. 克隆 (下载 *.zip) 此项目.
2. `$ pod install`
3. 打开 *IPAServer.xcworkspace*
4. 选择 *IPAServer (Release)* scheme
5. 编译
6. `$ ipainstaller`

你将会得到:

```
Usage:

    $ ipainstaller <IPA_PATH>

    IPA Wireless Installer

Requires:

    <IPA_PATH>      IPA file path

Options:

    --port <port>   Default: 10510



    --verbose       Show more information
    --help          Show help banner of specified command
    --silent        Show nothing
    --no-ansi       Show output without ANSI codes

```

# 使用

```shell
$ ipainstaller /path/to/*.ipa
```

你会得到一个二维码，然后使用你的 iOS 设备上的扫码 App 扫描此二维码即可安装。

![demo](resources/demo.png)

# 感谢

* [file.io](https://file.io)