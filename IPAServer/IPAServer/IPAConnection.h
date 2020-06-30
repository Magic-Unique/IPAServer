//
//  IPAConnection.h
//  IPAServer
//
//  Created by Unique on 2020/6/22.
//  Copyright © 2020 Magic-Unique. All rights reserved.
//

#import <CocoaHTTPServer/HTTPConnection.h>
#import <CocoaHTTPServer/HTTPServer.h>
#import <CocoaHTTPServer/HTTPMessage.h>
#import <CocoaHTTPServer/HTTPDataResponse.h>

@class IPAServer;

@interface IPAConnection : HTTPConnection

@end

@interface HTTPServer (IPAServer)

@property (nonatomic, assign) IPAServer *mainServer;

@property (readonly) NSNetService *netService;

@end
