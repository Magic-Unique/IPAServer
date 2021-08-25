//
//  IPAServer.h
//  IPAServer
//
//  Created by 冷秋 on 2019/11/28.
//  Copyright © 2019 Magic-Unique All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MUFoundation/MUPath.h>
#import "IPAServerConfiguration.h"
#import "IPAServerPackage.h"
#import "IPAServerManifest.h"
#import "IPASecurity.h"

FOUNDATION_EXTERN NSString *IPASSLDirectory;
FOUNDATION_EXTERN NSString *IPAPackagesDirectory;

FOUNDATION_EXTERN NSString *IPATempPackageKey;

@interface IPAServer : NSObject

@property (nonatomic, copy, readonly) IPAServerConfiguration *configuration;

@property (nonatomic, strong, readonly) IPASecurity *security;

@property (nonatomic, strong, readonly) NSArray<IPAServerPackage *> *packages;

- (instancetype)initWithConfiguration:(IPAServerConfiguration *)configuration;

- (void)import:(MUPath *)ipaPath
           key:(NSString *)key
       success:(void (^)(IPAServerPackage *package))success
       failure:(void (^)(NSError *error))failure;

- (BOOL)start;

- (void)stop;

- (NSString *)downloadURLWithPackage:(IPAServerPackage *)package;

- (NSString *)rootCerURL;

- (IPAServerPackage *)packageForKey:(NSString *)key;

- (IPAServerManifest *)manifestWithPackage:(IPAServerPackage *)package;

@end
