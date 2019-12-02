//
//  IPAServerManifest.h
//  IPAServer
//
//  Created by 冷秋 on 2019/12/2.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPAServerManifest : NSObject

@property (nonatomic, copy) NSString *fullSizeImage;
@property (nonatomic, copy) NSString *displayImage;
@property (nonatomic, copy) NSString *softwarePackage;

@property (nonatomic, copy) NSString *bundleIdentifier;
@property (nonatomic, copy) NSString *bundleVersion;
@property (nonatomic, copy) NSString *title;

- (NSDictionary *)propertyList;

- (NSData *)propertyListDataWithFormat:(NSPropertyListFormat)format;

- (NSData *)propertyListDataWithXMLFormat;

@end
