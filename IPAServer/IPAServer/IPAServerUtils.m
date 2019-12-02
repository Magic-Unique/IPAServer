//
//  IPAServerUtils.m
//  IPAServer
//
//  Created by 冷秋 on 2019/12/1.
//  Copyright © 2019 Magic-Unique. All rights reserved.
//

#import "IPAServerUtils.h"

// ip
#include <net/if.h>
#include <arpa/inet.h>
#include <ifaddrs.h>

@implementation IPAServerUtils

+ (NSString *)LANAddress {
    /*
     struct ifaddrs {
     struct ifaddrs  *ifa_next;
     char        *ifa_name;
     unsigned int     ifa_flags;
     struct sockaddr    *ifa_addr;
     struct sockaddr    *ifa_netmask;
     struct sockaddr    *ifa_dstaddr;
     void        *ifa_data;
     };
     */
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *localIP = nil;
    struct ifaddrs *addrs;
    if (getifaddrs(&addrs)==0) {
        const struct ifaddrs *cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0) {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"]) // Wi-Fi adapter
                {
                    localIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                    if (![array containsObject:localIP]) {
                        [array addObject:localIP];
                    }
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return localIP;
}

@end
