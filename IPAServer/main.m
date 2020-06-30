//
//  main.m
//  IPAServer
//
//  Created by 冷秋 on 2019/6/2.
//  Copyright © 2019 Magic-Unique All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPAInstaller.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [DDLog addLogger:[DDOSLogger sharedInstance]];
        [GCDWebServer setLogLevel:5];
        CLMainExplain = @"IPA Wireless Installer";
        CLCommand.mainCommand.version = @"1.1.0";
        CLMakeSubcommand(IPAInstaller, __init_);
        CLCommandMain();
    }
    return 0;
}
