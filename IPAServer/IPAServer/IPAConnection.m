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
#import "DDKeychain.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface HTTPConnection (Private)
- (void)startReadingRequest;
@end

@implementation IPAConnection

- (BOOL)isSecureServer {
    return YES;
}

- (NSArray *)sslIdentityAndCertificates {
    NSArray *result = [DDKeychain SSLIdentityAndCertificates];
    if ([result count] == 0) {
        [DDKeychain createNewIdentity];
        return [DDKeychain SSLIdentityAndCertificates];
    }
    return result;
}

//- (void)startConnection
//{
//    if ([self isSecureServer])
//    {
//        // We are configured to be an HTTPS server.
//        // That is, we secure via SSL/TLS the connection prior to any communication.
//        
//        NSArray *certificates = [self sslIdentityAndCertificates];
//        
//        if ([certificates count] > 0)
//        {
//            // All connections are assumed to be secure. Only secure connections are allowed on this server.
//            NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:3];
//            
//            // Configure this connection as the server
//            [settings setObject:[NSNumber numberWithBool:YES]
//                         forKey:(NSString *)kCFStreamSSLIsServer];
//            
//            [settings setObject:certificates
//                         forKey:(NSString *)kCFStreamSSLCertificates];
//            
//            // Configure this connection to use the highest possible SSL level
//            [settings setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL
//                         forKey:(NSString *)GCDAsyncSocketSSLProtocolVersionMin];
//            [settings setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL
//                         forKey:(NSString *)GCDAsyncSocketSSLProtocolVersionMax];
//            
//            [asyncSocket startTLS:settings];
//        }
//    }
//    
//    [self startReadingRequest];
//}

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
            return [[HTTPDataResponse alloc] initWithData:data];
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
