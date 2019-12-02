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

/*
 - /
 -- {BUNDLE_ID}/
 --- {VERSION}/
 ---- package.ipa
 ---- icon.png
 ---- Info.plist
 
 */

@interface IPAServer : NSObject

@property (nonatomic, copy, readonly) IPAServerConfiguration *configuration;

@property (nonatomic, strong, readonly) NSArray<IPAServerPackage *> *packages;

- (instancetype)initWithConfiguration:(IPAServerConfiguration *)configuration;

- (void)import:(MUPath *)ipaPath
       success:(void (^)(IPAServerPackage *package))success
       failure:(void (^)(NSError *error))failure;

- (BOOL)start;

- (void)stop;

- (NSString *)downloadURLWithPackage:(IPAServerPackage *)package;

@end
