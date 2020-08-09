//
//  IPAServerPackage.m
//  IPAServer
//
//  Created by 冷秋 on 2019/12/1.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "IPAServerPackage.h"

@implementation IPAServerPackage

- (instancetype)initWithRootDirectory:(MUPath *)path {
    self = [super init];
    if (self) {
        NSDictionary *Info = [NSDictionary dictionaryWithContentsOfFile:[path subpathWithComponent:@"Info.plist"].string];
        _bundleVersion = Info[@"CFBundleShortVersionString"];
        _displayName = Info[@"CFBundleDisplayName"];
        _bundleIdentifier = Info[@"CFBundleIdentifier"];
        _MD5 = path.lastPathComponent;
        _rootDirectory = path;
    }
    return self;
}

- (MUPath *)packagePath {
    return [self.rootDirectory subpathWithComponent:@"package.ipa"];
}

- (MUPath *)iconPath {
    return [self.rootDirectory subpathWithComponent:@"icon.png"];
}

@end
