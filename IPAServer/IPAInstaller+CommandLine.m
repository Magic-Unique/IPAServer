//
//  IPAInstaller+CommandLine.m
//  IPAServer
//
//  Created by 冷秋 on 2019/12/4.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "IPAInstaller+CommandLine.h"
#import "QRCode+IPAServer.h"
#import "IPAServer/IPAServer.h"
#import "IPAServer/IPASecurity.h"

#define ENV_IS_CHINESE ([IPALanguage isChinese])

@implementation IPAInstaller (CommandLine)

+ (void)__init_main {
    CLCommand *main = [CLCommand mainCommand];
    main.setQuery(@"port").setAbbr('p').optional().asNumber().setDefaultValue(@"10510").setExample(@"10510").setExplain(IPALocalizedString("port_explain", nil));
    main.addRequirePath(@"ipa").setExample(@"IPA_PATH").setExplain(IPALocalizedString("ipa_file_path", nil));
    main.setFlag(@"remote").setAbbr('r').setExplain(IPALocalizedString("use_remote_server", nil));
    [main handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
        MUPath *input = [MUPath pathWithString:[process pathForIndex:0]];
        NSString *port = [process stringForQuery:@"port"];
        
        if (!input.isFile) {
            CLError(IPALocalizedString("file_is_not_exist", nil));
            return 1;
        }
        
        MUPath *rootDirectory = [[MUPath homePath] subpathWithComponent:@".IPAServer"];
        [rootDirectory createDirectoryWithCleanContents:NO];
        
        BOOL local = ![process flag:@"remote"];
        CLInfo(IPALocalizedString("use_server", nil), local ? @"localhost" : @"file.io");
        
        IPAServer *server = [[IPAServer alloc] initWithConfiguration:({
            IPAServerConfiguration *configuration = [[IPAServerConfiguration alloc] init];
            configuration.rootDirectory = rootDirectory;
            configuration.manifestUploadPolicy = IPAManifestUploadingPolicyPreuploadBeforeInstall;
            configuration.port = port.integerValue;
            configuration.serverType = local ? IPAServerTypeLocal : IPAServerTypeFileIO;
            configuration;
        })];
        if (![server start]) {
            CLError(IPALocalizedString("start_failed", nil), port);
            return EXIT_FAILURE;
        } else {
            CLInfo(IPALocalizedString("start_succee", nil), port);
        }
        
        [server import:input
                   key:IPATempPackageKey
               success:^(IPAServerPackage *package) {
            NSString *url = [server downloadURLWithPackage:package];
            CLInfo(@"URL: %@", url);
            QRCode *code = [QRCode codeWithString:url version:0 level:QRCodeLevelL mode:QRCodeMode8BitData];
            [code print];
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CLError(@"Can not create QRCode for this file: %@", error.localizedDescription);
                CLExit(EXIT_FAILURE);
            });
        }];
        [[NSRunLoop currentRunLoop] run];
        return 0;
    }];
}

+ (void)__init_ca {
    CLCommand *ssl = [[CLCommand mainCommand] defineSubcommand:@"ssl"];
    ssl.explain = IPALocalizedString("install_ca", nil);
    ssl.setQuery(@"port").optional().asNumber().setDefaultValue(@"10510").setExample(@"10510").setExplain(IPALocalizedString("port_explain", nil));
    [ssl handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
        NSString *port = [process stringForQuery:@"port"];
        
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
            CLError(IPALocalizedString("start_failed", nil), port);
            return EXIT_FAILURE;
        } else {
            CLInfo(IPALocalizedString("start_succee", nil), port);
        }
        NSString *url = [server rootCerURL];
        CLInfo(@"URL: %@", url);
        QRCode *code = [QRCode codeWithString:url version:0 level:QRCodeLevelL mode:QRCodeMode8BitData];
        [code print];
        [[NSRunLoop currentRunLoop] run];
        return 0;
    }];
}

@end
