//
//  IPAInstaller+CommandLine.m
//  IPAServer
//
//  Created by 吴双 on 2019/12/4.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "IPAInstaller+CommandLine.h"
#import "QRCode+IPAServer.h"
#import "IPAServer/IPAServer.h"

@implementation IPAInstaller (CommandLine)

+ (void)__init_main {
    CLCommand *main = [CLCommand mainCommand];
    main.setQuery(@"port").optional().asNumber().setDefaultValue(@"10510").setExample(@"10510").setExplain(@"Default: 10510");
    main.addRequirePath(@"ipa").setExample(@"IPA_PATH").setExplain(@"IPA file path");
    [main handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
        MUPath *input = [MUPath pathWithString:[process pathForIndex:0]];
        NSString *port = [process stringForQuery:@"port"];
        
        if (!input.isFile) {
            CLError(@"The file is not exist.");
            return 1;
        }
        
        MUPath *rootDirectory = [[MUPath tempPath] subpathWithComponent:[NSUUID UUID].UUIDString];
        [rootDirectory createDirectoryWithCleanContents:YES];
        
        IPAServer *server = [[IPAServer alloc] initWithConfiguration:({
            IPAServerConfiguration *configuration = [[IPAServerConfiguration alloc] init];
            configuration.rootDirectory = rootDirectory;
            configuration.manifestUploadPolicy = IPAManifestUploadingPolicyPreuploadBeforeInstall;
            configuration.port = port.integerValue;
            configuration;
        })];
        if (![server start]) {
            CLError(@"Can not start server at %@", port);
            return EXIT_FAILURE;
        } else {
            CLInfo(@"Server start at %@", port);
        }
        CLInfo(@"Reading MD5...");
        NSString *MD5 = input.MD5;
        CLInfo(@"Read MD5: %@", MD5);
        
        [server import:input
                   key:MD5
               success:^(IPAServerPackage *package) {
                   NSString *url = [server downloadURLWithPackage:package];
            CLInfo(@"URL: %@", url);
                   QRCode *code = [QRCode codeWithString:url version:0 level:QRCodeLevelL mode:QRCodeMode8BitData];
                   [code print];
               } failure:^(NSError *error) {
                   
               }];
        [[NSRunLoop currentRunLoop] run];
        return 0;
    }];
}

@end
