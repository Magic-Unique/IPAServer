//
//  IPAConnection.m
//  IPAServer
//
//  Created by Unique on 2020/6/22.
//  Copyright © 2020 Magic-Unique. All rights reserved.
//

#import "IPAConnection.h"
#import <objc/runtime.h>
#import "IPAServer.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <CFNetwork/CFSocketStream.h>
#import "IPASecurity.h"
#import "IPAServerUtils.h"

#define ipa_response(cls, super) interface cls : super @end @implementation cls
#define ipa_end end

@ipa_response(IPAManifestResponse, HTTPDataResponse)

- (NSDictionary *)httpHeaders {
    return @{@"Content-Type": @"application/x-plist"};
}

@ipa_end

@ipa_response(IPAPackageResponse, HTTPDataResponse)

- (NSDictionary *)httpHeaders {
    return @{@"Content-Type": @"application/vnd.iphone"};
}

@ipa_end

@ipa_response(IPAImageResponse, HTTPDataResponse)

- (NSDictionary *)httpHeaders {
    return @{@"Content-Type": @"image/png"};
}

@ipa_end

@implementation IPAConnection

- (BOOL)isSecureServer {
    return YES;
}

- (NSArray *)sslIdentityAndCertificates {
    SecIdentityRef identity = [IPASecurity identityForCN:[IPAServerUtils LANAddress]];
    if (identity) {
        return @[(__bridge_transfer id)identity];
    }
    return nil;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    NSURL *url = request.url;
    NSURLComponents *component = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    if ([component.path hasPrefix:@"/download"]) {
        NSString *key = component.path.lastPathComponent;
        IPAServer *server = [self __mainServer];
        IPAServerPackage *package = [server packageForKey:key];
        if (package) {
            IPAServerManifest *manifest = [server manifestWithPackage:package];
            NSData *data = [manifest propertyListDataWithXMLFormat];
            return [[IPAManifestResponse alloc] initWithData:data];
        }
    }
    else if ([component.path hasPrefix:@"/icon"]) {
        NSString *key = component.path.lastPathComponent;
        IPAServer *server = [self __mainServer];
        IPAServerPackage *package = [server packageForKey:key];
        if (package) {
            MUPath *iconPath = package.iconPath;
            if (!iconPath.isFile) {
                [IPAServerUtils saveDefaultIcon:iconPath];
            }
            NSData *data = [NSData dataWithContentsOfFile:iconPath.string];
            IPAImageResponse *response = [[IPAImageResponse alloc] initWithData:data];
            return response;
        }
    }
    else if ([component.path hasPrefix:@"/package"]) {
        NSString *key = component.path.lastPathComponent;
        IPAServer *server = [self __mainServer];
        IPAServerPackage *package = [server packageForKey:key];
        if (package) {
            MUPath *packagePath = package.packagePath;
            if (packagePath.isFile) {
                NSData *data = [NSData dataWithContentsOfFile:packagePath.string];
                IPAPackageResponse *response = [[IPAPackageResponse alloc] initWithData:data];
                return response;
            }
        }
    }
    return [super httpResponseForMethod:method URI:path];
}

- (IPAServer *)__mainServer {
    return config.server.mainServer;
}

@end

@implementation HTTPServer (IPAServer)

- (void)setMainServer:(IPAServer *)mainServer {
    objc_setAssociatedObject(self, @selector(mainServer), mainServer, OBJC_ASSOCIATION_ASSIGN);
}

- (IPAServer *)mainServer {
    return objc_getAssociatedObject(self, @selector(mainServer));
}

- (NSNetService *)netService {
    return netService;
}

@end

@implementation GCDAsyncSocket (IPAServer)

+ (void)load {
    Method ori = class_getInstanceMethod(self, @selector(startTLS:));
    Method new = class_getInstanceMethod(self, @selector(ipaserver_startTLS:));
    method_exchangeImplementations(ori, new);
}

- (void)ipaserver_startTLS:(NSDictionary *)tlsSettings {
    if (tlsSettings[(__bridge NSString *)kCFStreamSSLLevel]) {
        NSMutableDictionary *newSettings = [tlsSettings mutableCopy];
        [newSettings removeObjectForKey:(__bridge NSString *)kCFStreamSSLLevel];
        tlsSettings = newSettings;
    }
    [self ipaserver_startTLS:tlsSettings];
}

@end
