//
//  IPAServerUtils.h
//  IPAServer
//
//  Created by 冷秋 on 2019/12/1.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPAServerUtils : NSObject

+ (NSString *)LANAddress;

+ (void)saveDefaultIcon:(MUPath *)path;

@end

NS_ASSUME_NONNULL_END
