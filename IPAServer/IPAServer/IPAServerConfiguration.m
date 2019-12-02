//
//  IPAServerConfiguration.m
//  IPAServer
//
//  Created by 冷秋 on 2019/12/1.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "IPAServerConfiguration.h"

@implementation IPAServerConfiguration

- (instancetype)init {
    self = [super init];
    if (self) {
        _port = 8080;
        _manifestUploadPolicy = IPAManifestUploadingPolicyUploadWhenInstall;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    IPAServerConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration.rootDirectory = self.rootDirectory;
    configuration.port = self.port;
    configuration.manifestUploadPolicy = self.manifestUploadPolicy;
    return configuration;
}

@end
