//
//  main.m
//  IPAServer
//
//  Created by 冷秋 on 2019/6/2.
//  Copyright © 2019 Magic-Unique All rights reserved.
//

#import <Foundation/Foundation.h>
#import <qrencode.h>
#import "QRCode+IPAServer.h"
#import "IPAInstaller.h"

#import "IPAServer/IPAServer.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [GCDWebServer setLogLevel:5];
        CLMainExplain = @"IPA Wireless Installer";
        CLMakeSubcommand(IPAInstaller, __init_);
        CLCommandMain();
    }
    return 0;
}
