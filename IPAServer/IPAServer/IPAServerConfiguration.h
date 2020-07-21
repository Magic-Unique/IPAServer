//
//  IPAServerConfiguration.h
//  IPAServer
//
//  Created by 冷秋 on 2019/12/1.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MUFoundation/MUPath.h>

typedef NS_ENUM(NSUInteger, IPAServerType) {
    IPAServerTypeLocal,
    IPAServerTypeFileIO,
};

typedef NS_ENUM(NSUInteger, IPAManifestUploadingPolicy) {
    IPAManifestUploadingPolicyUploadWhenInstall,
    IPAManifestUploadingPolicyPreuploadBeforeInstall,
};

@interface IPAServerConfiguration : NSObject <NSCopying>

@property (nonatomic, strong) MUPath *rootDirectory;

@property (nonatomic, assign) NSUInteger port;

@property (nonatomic, assign) IPAServerType serverType;

@property (nonatomic, assign) IPAManifestUploadingPolicy manifestUploadPolicy;

@end
