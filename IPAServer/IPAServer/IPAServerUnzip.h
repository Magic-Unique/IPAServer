//
//  IPAServerUnzip.h
//  IPAServer
//
//  Created by 吴双 on 2021/8/25.
//  Copyright © 2021 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPAServerPackage.h"

@class ZZArchiveEntry;

@interface IPAServerUnzip : NSObject

@property (nonatomic, strong) MUPath *ipaPath;
@property (nonatomic, strong) MUPath *toDirectory;

@property (nonatomic, strong, readonly) NSDictionary<NSString *, ZZArchiveEntry *> *entries;
@property (nonatomic, strong, readonly) NSDictionary *info;
@property (nonatomic, strong, readonly) NSString *appKey;

@property (nonatomic, strong, readonly) IPAServerPackage *package;

- (BOOL)unzip;

@end
