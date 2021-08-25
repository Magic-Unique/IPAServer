//
//  IPAServerUnzip.m
//  IPAServer
//
//  Created by 吴双 on 2021/8/25.
//  Copyright © 2021 Magic-Unique. All rights reserved.
//

#import "IPAServerUnzip.h"
#import <zipzap/ZipZap.h>

@implementation IPAServerUnzip

- (BOOL)unzip {
    NSError *error = nil;
    
    do {
        CLInfo(@"Unzip %@", self.ipaPath.lastPathComponent);
        ZZArchive *archive = [ZZArchive archiveWithURL:self.ipaPath.fileURL error:&error];
        if (error) {
            CLError(@"Unzip failed.");
            break;
        }
        
        // make entries
        NSString *appEntryKey = nil;
        NSMutableDictionary *entries = [NSMutableDictionary dictionary];
        for (ZZArchiveEntry *entry in archive.entries) {
            NSString *key = entry.fileName;
            entries[key] = entry;
            
            if (appEntryKey) {
                continue;
            }
            
            NSArray<NSString *> *components = [key componentsSeparatedByString:@"/"];
            if (components.count > 3) {
                if (![components[0] isEqualToString:@"Payload"]) {
                    continue;
                }
                if ([components[1].lowercaseString hasSuffix:@".app"]) {
                    appEntryKey = [@"Payload/" stringByAppendingString:components[1]];
                }
            }
        }
        if (!appEntryKey) {
            CLError(@"Can not found *.app folder");
            break;
        }
        CLVerbose(@"Found app entry: %@", appEntryKey);
        _entries = entries;
        _appKey = appEntryKey;
        
        // Read Info.plist
        NSDictionary *info = ({
            NSDictionary *info = nil;
            NSString *infoPlistKey = [appEntryKey stringByAppendingString:@"/Info.plist"];
            MUPath *infoPath = [self.toDirectory subpathWithComponent:@"Info.plist"];
            ZZArchiveEntry *entry = entries[infoPlistKey];
            if (entry && [self writeEntry:entry to:infoPath]) {
                info = [NSDictionary dictionaryWithContentsOfFile:infoPath.string];
            } else {
                CLVerbose(@"没办法读取info");
            }
            info;
        });
        if (!info) {
            CLError(@"Can not read Info.plist file");
            break;
        }
        _info = info;
        
        // Copy ipa
        if ([self.ipaPath copyTo:[self.toDirectory subpathWithComponent:@"package.ipa"] autoCover:YES]) {
            CLError(@"Can not copy ipa file");
            break;
        }
        
        // Copy icon
        NSString *iconKey = [self findAppIcon];
        if (iconKey) {
            CLVerbose(@"Found icon entry: %@", iconKey);
            [self writeEntry:self.entries[iconKey] to:[self.toDirectory subpathWithComponent:@"icon.png"]];
        } else {
            CLWarning(@"Can not found icon entry");
        }
        
        _package = [[IPAServerPackage alloc] initWithRootDirectory:self.toDirectory];
    } while (NO);
    return _package ? YES : NO;
}

- (NSString *)findAppIcon {
    NSArray *icons;
    NSString *iconName;
    
    NSArray *(^iconsListForDictionary)(NSDictionary *iconsDict) = ^NSArray *(NSDictionary *iconsDict) {
        if ([iconsDict isKindOfClass:[NSDictionary class]]) {
            id primaryIconDict = [iconsDict objectForKey:@"CFBundlePrimaryIcon"];
            if ([primaryIconDict isKindOfClass:[NSDictionary class]]) {
                id tempIcons = [primaryIconDict objectForKey:@"CFBundleIconFiles"];
                if ([tempIcons isKindOfClass:[NSArray class]]) {
                    return tempIcons;
                }
            }
        }
        return nil;
    };
    
    NSDictionary *appPropertyList = self.info;

    //Check for CFBundleIcons (since 5.0)
    icons = iconsListForDictionary([appPropertyList objectForKey:@"CFBundleIcons"]);
    if (!icons) {
        icons = iconsListForDictionary([appPropertyList objectForKey:@"CFBundleIcons~ipad"]);
    }

    if (!icons) {
        //Check for CFBundleIconFiles (since 3.2)
        id tempIcons = [appPropertyList objectForKey:@"CFBundleIconFiles"];
        if ([tempIcons isKindOfClass:[NSArray class]]) {
            icons = tempIcons;
        }
    }

    if (icons) {
        //Search some patterns for primary app icon (120x120)
        NSArray *matches = @[@"120",@"60"];

        for (NSString *match in matches) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",match];
            NSArray *results = [icons filteredArrayUsingPredicate:predicate];
            if ([results count]) {
                iconName = [results firstObject];
                break;
            }
        }

        //If no one matches any pattern, just take last item
        if (!iconName) {
            iconName = [icons lastObject];
        }
    } else {
        //Check for CFBundleIconFile (legacy, before 3.2)
        NSString *legacyIcon = [appPropertyList objectForKey:@"CFBundleIconFile"];
        if ([legacyIcon length]) {
            iconName = legacyIcon;
        }
    }
    
    if (iconName.pathExtension.length == 0) {
        
        NSString *(^MakeName)(NSString *name, NSUInteger scale) = ^NSString *(NSString *name, NSUInteger scale) {
            if (scale == 1) {
                return [name stringByAppendingPathExtension:@"png"];
            } else {
                return [name stringByAppendingFormat:@"@%@x.png", @(scale)];
            }
        };
        
        for (NSUInteger i = 3; i > 0; i--) {
            NSString *key = [self.appKey stringByAppendingFormat:@"/%@", MakeName(iconName, i)];
            if (self.entries[key]) {
                return key;
            }
        }
    }

    return nil;
}

- (BOOL)writeEntry:(ZZArchiveEntry *)entry to:(MUPath *)to {
    BOOL ret = NO;
    @autoreleasepool {
        NSError *error = nil;
        NSData *data = [entry newDataWithError:&error];
        if (!error && data) {
            [data writeToFile:to.string atomically:YES];
            ret = YES;
        }
    }
    return ret;
}

@end
