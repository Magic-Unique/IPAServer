//
//  IPAServerPackage.h
//  IPAServer
//
//  Created by 冷秋 on 2019/12/1.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPAServerPackage : NSObject

@property (nonatomic, copy, readonly) NSString *displayName;

@property (nonatomic, copy, readonly) NSString *bundleVersion;

@property (nonatomic, copy, readonly) NSString *bundleIdentifier;

@property (nonatomic, copy, readonly) NSString *MD5;

@property (nonatomic, strong, readonly) MUPath *rootDirectory;

@property (nonatomic, strong, readonly) MUPath *packagePath;

@property (nonatomic, strong, readonly) MUPath *iconPath;

- (instancetype)initWithRootDirectory:(MUPath *)path;

@end
