//
//  IPAServerManifest.m
//  IPAServer
//
//  Created by 冷秋 on 2019/12/2.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "IPAServerManifest.h"

@implementation IPAServerManifest

- (NSDictionary *)propertyList {
    NSMutableDictionary *propertyList = [NSMutableDictionary dictionary];
    propertyList[@"items"] = ({
        NSMutableArray *items = [NSMutableArray array];
        [items addObject:({
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            item[@"assets"] = ({
                NSMutableArray *assets = [NSMutableArray array];
                [assets addObject:@{@"kind": @"full-size-image",
                                    @"needs-shine": @YES,
                                    @"url": self.fullSizeImage?:@""}];
                [assets addObject:@{@"kind": @"display-image",
                                    @"needs-shine": @YES,
                                    @"url": self.displayImage?:@""}];
                [assets addObject:@{@"kind": @"software-package",
                                    @"url": self.softwarePackage?:@""}];
                assets;
            });
            item[@"metadata"] = ({
                NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
                metadata[@"bundle-identifier"] = self.bundleIdentifier;
                metadata[@"bundle-version"] = self.bundleVersion;
                metadata[@"kind"] = @"software";
                metadata[@"title"] = self.title;
                metadata;
            });
            item;
        })];
        items;
    });
    return propertyList;
}

- (NSData *)propertyListDataWithFormat:(NSPropertyListFormat)format {
    NSDictionary *manifest = [self propertyList];
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:manifest format:format options:0 error:nil];
    return data;
}

- (NSData *)propertyListDataWithXMLFormat {
    return [self propertyListDataWithFormat:NSPropertyListXMLFormat_v1_0];
}

@end
