//
//  IPALanguage.h
//  IPAServer
//
//  Created by 吴双 on 2020/7/17.
//  Copyright © 2020 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPALanguage : NSObject

+ (BOOL)isChinese;

+ (NSString *)localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

@end
    
#define IPALocalizedString(key, default) [IPALanguage localizedStringForKey:@key defaultValue:default]
