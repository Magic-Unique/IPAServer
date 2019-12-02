//
//  IPAInstaller.m
//  IPAServer
//
//  Created by 冷秋 on 2019/11/21.
//  Copyright © 2019 Magic-Unique All rights reserved.
//

#import "IPAInstaller.h"
#import "QRCode+IPAServer.h"
#import "IPAServer/IPAServer.h"

@implementation IPAInstaller

+ (void)__init_main {
    CLCommand *main = [CLCommand mainCommand];
    main.setQuery(@"port").optional().asNumber().setDefaultValue(@"10510").setExplain(@"10510").setExplain(@"Default: 10510");
    main.addRequirePath(@"ipa").setExample(@"IPA_PATH").setExplain(@"IPA file path");
    [main handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
        MUPath *input = [MUPath pathWithString:[process pathForIndex:0]];
        NSString *port = [process stringForQuery:@"port"];
        
        MUPath *rootPath = [[MUPath tempPath] subpathWithComponent:[NSUUID UUID].UUIDString];
        [rootPath createDirectoryWithCleanContents:YES];
        
        IPAServer *server = [[IPAServer alloc] initWithConfiguration:({
            IPAServerConfiguration *configuration = [[IPAServerConfiguration alloc] init];
            configuration.rootDirectory = [[MUPath homePath] subpathWithComponent:@"IPAServer"];
            configuration.manifestUploadPolicy = IPAManifestUploadingPolicyPreuploadBeforeInstall;
            configuration.port = port.integerValue;
            configuration;
        })];
        if (![server start]) {
            CLError(@"Can not start server at 8080");
            return 1;
        } else {
            CLInfo(@"Server start at %@", port);
        }
        [server import:input
               success:^(IPAServerPackage *package) {
                   NSString *url = [server downloadURLWithPackage:package];
                   QRCode *code = [QRCode codeWithString:url version:0 level:QRCodeLevelL mode:QRCodeMode8BitData];
                   [code print];
               } failure:^(NSError *error) {
                   
               }];
        [[NSRunLoop currentRunLoop] run];
        return 0;
    }];
}

@end
