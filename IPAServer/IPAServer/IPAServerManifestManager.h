//
//  IPAServerManifestManager.h
//  IPAServer
//
//  Created by 冷秋 on 2019/12/2.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "IPAServerManifest.h"
#import "IPAServerConfiguration.h"

@interface IPAServerManifestManager : NSObject

@property (nonatomic, strong, readonly) AFHTTPSessionManager *sessionManager;

@property (nonatomic, strong, readonly) NSMutableDictionary *queues;

@property (nonatomic, assign, readonly) IPAManifestUploadingPolicy policy;

- (instancetype)initWithPolicy:(IPAManifestUploadingPolicy)policy sessionManager:(AFHTTPSessionManager *)sessionManager;

- (void)setManifest:(IPAServerManifest *)manifest forKey:(NSString *)key;

- (void)getDownloadURLForKey:(NSString *)key completed:(void (^)(NSString *url))completion;

@end
