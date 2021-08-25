//
//  IPALanguage.m
//  IPAServer
//
//  Created by 吴双 on 2020/7/17.
//  Copyright © 2020 Magic-Unique. All rights reserved.
//

#import "IPALanguage.h"

@implementation IPALanguage

+ (BOOL)isChinese {
    NSString *LANG = [NSProcessInfo processInfo].environment[@"LANG"];
    return [LANG containsString:@"zh_CN"];
}

+ (NSDictionary *)__localizedStrings {
    static NSDictionary *strings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *_strings = [NSMutableDictionary dictionary];
        NSString *LANG = [NSProcessInfo processInfo].environment[@"LANG"];
        LANG = [LANG componentsSeparatedByString:@"."].firstObject;
        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"__strings_%@:", LANG]);
        if ([self respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:sel withObject:_strings];
#pragma clang diagnostic pop
        } else {
            [self __strings_en_US:_strings];
        }
        strings = [_strings copy];
    });
    return strings;
}

+ (NSString *)localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    NSDictionary *strings = [self __localizedStrings];
    NSString *value = strings[key];
    return value ?: defaultValue;
}

+ (void)__strings_en_US:(NSMutableDictionary *)strings {
    strings[@"main_explain"] = ({
        NSMutableString *explain = [NSMutableString string];
        [explain appendFormat:@"IPA Wireless Installer\n"];
        [explain appendFormat:@"    \n"];
        [explain appendFormat:@"%@", CCStyleStringWithStyle(CCStyleLight)];
        [explain appendFormat:@"    Before install any app, your device must install root certificate to trust this server.\n"];
        [explain appendFormat:@"    Use follow command to get root certificate's QRCode, and scan it with your device.\n"];
        [explain appendFormat:@"    \n"];
        [explain appendFormat:@"    $ %@ ssl\n", [CLCommand mainCommand].name];
        [explain appendFormat:@"%@", CCStyleStringWithStyle(CCStyleNone)];
        explain;
    });
    strings[@"use_remote_server"] = @"Use file.io server(Ignore CA, but times limited per-day).";
    strings[@"ipa_file_path"] = @"IPA file path";
    strings[@"port_explain"] = @"Custom port, default is 10510";
    strings[@"file_is_not_exist"] = @"The file is not exist.";
    strings[@"use_server"] = @"Use server: %@";
    
    strings[@"install_ca"] = @"Install root certificate";
    
    strings[@"start_failed"] = @"Can not start server at %@";
    strings[@"start_succee"] = @"Server start at %@";
    
    strings[@"unzip_start"] = @"Unzip %@";
    strings[@"unzip_create_archive_failed"] = @"Can not read zip archive";
    strings[@"unzip_cannot_found_app"] = @"Can not found *.app folder";
    strings[@"unzip_found_app"] = @"Found app entry: %@";
    strings[@"unzip_cannot_found_info_plist"] = @"Can not read Info.plist file";
    strings[@"unzip_cannot_found_icon"] = @"Can not found icon entry";
    strings[@"unzip_found_icon"] = @"Found icon entry: %@";
}

+ (void)__strings_zh_CN:(NSMutableDictionary *)strings {
    strings[@"main_explain"] = ({
        NSMutableString *explain = [NSMutableString string];
        [explain appendFormat:@"IPA 无线安装器\n"];
        [explain appendFormat:@"    \n"];
        [explain appendFormat:@"%@", CCStyleStringWithStyle(CCStyleLight)];
        [explain appendFormat:@"    在安装任何 app 前，您的设备必须先安装根证书来信任此服务\n"];
        [explain appendFormat:@"    使用下面的命令来获取根证书下载二维码，然后使用你的 iOS 设备扫描它\n"];
        [explain appendFormat:@"    \n"];
        [explain appendFormat:@"    $ %@ ssl\n", [CLCommand mainCommand].name];
        [explain appendFormat:@"%@", CCStyleStringWithStyle(CCStyleNone)];
        explain;
    });
    strings[@"use_remote_server"] = @"使用 file.io 服务（无需安装 CA 证书，但每天有次数限制）";
    strings[@"ipa_file_path"] = @"IPA 文件路径";
    strings[@"port_explain"] = @"指定服务端口，默认端口: 10510";
    strings[@"file_is_not_exist"] = @"文件不存在";
    strings[@"use_server"] = @"使用服务: %@";
    
    strings[@"install_ca"] = @"安装根证书";
    
    strings[@"start_failed"] = @"无法监听端口 %@";
    strings[@"start_succee"] = @"开始监听端口 %@";
    
    strings[@"unzip_start"] = @"解压 %@";
    strings[@"unzip_create_archive_failed"] = @"无法读取压缩文件";
    strings[@"unzip_cannot_found_app"] = @"找不到 *.app 文件夹";
    strings[@"unzip_found_app"] = @"读取 app: %@";
    strings[@"unzip_cannot_found_info_plist"] = @"无法读取 Info.plist 文件";
    strings[@"unzip_cannot_found_icon"] = @"找不到图标";
    strings[@"unzip_found_icon"] = @"读取图标: %@";
}

@end
