//
//  IPAServer.m
//  IPAServer
//
//  Created by 冷秋 on 2019/11/28.
//  Copyright © 2019 Magic-Unique All rights reserved.
//

#import "IPAServer.h"
#import <GCDWebServer/GCDWebServer.h>
#import <GCDWebServer/GCDWebServerDataRequest.h>
#import <GCDWebServer/GCDWebServerResponse.h>
#import <GCDWebServer/GCDWebServerFileResponse.h>
#import <CocoaHTTPServer/HTTPServer.h>
#import "IPAConnection.h"

#import <SSZipArchive/SSZipArchive.h>
#import <AFNetworking/AFNetworking.h>
#import "IPAServerManifest.h"
#import "IPAServerManifestManager.h"

#import "IPAServerUtils.h"
#import "IPASecurity.h"

@interface IPAServer ()


@property (nonatomic, strong, readonly) GCDWebServer *webServer;
@property (nonatomic, strong, readonly) HTTPServer *httpServer;

@property (nonatomic, strong, readonly) NSOperationQueue *importQueue;
@property (nonatomic, strong, readonly) NSMutableDictionary *importedPackages;

@property (nonatomic, strong, readonly) IPAServerManifestManager *manifestManager;
@property (nonatomic, strong, readonly) AFHTTPSessionManager *sessionManager;

@property (nonatomic, strong, readonly) MUPath *rootDirectory;
@property (nonatomic, strong, readonly) MUPath *packagesDirectory;

@property (nonatomic, strong, readonly) NSString *cdnBaseURL;
@property (nonatomic, strong, readonly) NSString *tlsBaseURL;

@end

@implementation IPAServer

- (instancetype)initWithConfiguration:(IPAServerConfiguration *)configuration {
    self = [super init];
    if (self) {
        _configuration = configuration;
        
        _importedPackages = [NSMutableDictionary dictionary];
        _importQueue = [[NSOperationQueue alloc] init];
        _importQueue.maxConcurrentOperationCount = 1;
        
        [self __initWorkspace];
        [self __refreshImportedPackages];
    }
    return self;
}

- (void)__initWorkspace {
    _rootDirectory = _configuration.rootDirectory;
    [_rootDirectory createDirectoryWithCleanContents:YES];
    
    _packagesDirectory = [_rootDirectory subpathWithComponent:@"packages"];
    [_packagesDirectory createDirectoryWithCleanContents:NO];
}

- (void)__refreshImportedPackages {
    [self.importQueue addOperationWithBlock:^{
        MUPath *root = self.packagesDirectory;
        [self.importedPackages removeAllObjects];
        [root enumerateContentsUsingBlock:^(MUPath *content, BOOL *stop) {
            if (!content.isDirectory || content.lastPathComponent.length != 32) {
                return ;
            }
            IPAServerPackage *package = [[IPAServerPackage alloc] initWithRootDirectory:content];
            self.importedPackages[content.lastPathComponent] = package;
            IPAServerManifest *manifest = [self manifestWithPackage:package];
            [self.manifestManager setManifest:manifest forKey:package.MD5];
        }];
    }];
}

- (void)__initHTTPHandlers {
    IPAServerType serverType = _configuration.serverType;
    @weakify(self)
    [self.webServer addHandlerForMethod:@"GET"
                                   path:@"/CA.cer"
                           requestClass:[GCDWebServerRequest class]
                      asyncProcessBlock:^(GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        @try {
            MUPath *path = [IPASecurity rootCerPath];
            GCDWebServerFileResponse *response = [GCDWebServerFileResponse responseWithFile:path.string];
            completionBlock(response);
        } @catch (NSException *exception) {
            completionBlock([GCDWebServerResponse responseWithStatusCode:404]);
        } @finally {}
    }];
    if (serverType == IPAServerTypeLocal) {
        [self.webServer addHandlerForMethod:@"GET"
                                       path:@"/download"
                               requestClass:[GCDWebServerRequest class]
                          asyncProcessBlock:^(GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
            @strongify(self);
            @try {
                NSString *target = request.query[@"target"];
                
                NSString *url = [NSString stringWithFormat:@"%@/download/%@", self.tlsBaseURL, target];
                url = [@"itms-services://?action=download-manifest&url=" stringByAppendingString:url];
                GCDWebServerResponse *response = [GCDWebServerResponse responseWithRedirect:[NSURL URLWithString:url]
                                                                                  permanent:YES];
                completionBlock(response);
            } @catch (NSException *exception) {
                completionBlock([GCDWebServerResponse responseWithStatusCode:404]);
            } @finally {}
        }];
    } else {
        [self.webServer addHandlerForMethod:@"GET"
                                       path:@"/download"
                               requestClass:[GCDWebServerRequest class]
                          asyncProcessBlock:^(GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
            @strongify(self);
            @try {
                NSString *target = request.query[@"target"];
                [self.manifestManager getDownloadURLForKey:target completed:^(NSString *url) {
                    if (url) {
                        NSString *_manifest = [@"itms-services://?action=download-manifest&url=" stringByAppendingString:url];
                        GCDWebServerResponse *response = [GCDWebServerResponse responseWithRedirect:[NSURL URLWithString:_manifest]
                                                                                          permanent:YES];
                        completionBlock(response);
                    } else {
                        completionBlock([GCDWebServerResponse responseWithStatusCode:404]);
                    }
                }];
            } @catch (NSException *exception) {
                completionBlock([GCDWebServerResponse responseWithStatusCode:404]);
            } @finally {}
        }];
    }
    [self.webServer addHandlerForMethod:@"GET"
                                   path:@"/icon"
                           requestClass:[GCDWebServerRequest class]
                      asyncProcessBlock:^(GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        @strongify(self);
        @try {
            NSString *target = request.query[@"target"];
            IPAServerPackage *package = self.importedPackages[target];
            MUPath *path = package.rootDirectory;
            path = [path subpathWithComponent:@"icon.png"];
            if (!path.isFile) {
                [IPAServerUtils saveDefaultIcon:path];
            }
            GCDWebServerFileResponse *response = [GCDWebServerFileResponse responseWithFile:path.string];
            completionBlock(response);
        } @catch (NSException *exception) {
            completionBlock([GCDWebServerResponse responseWithStatusCode:404]);
        } @finally {}
    }];
    [self.webServer addHandlerForMethod:@"GET"
                                   path:@"/package"
                           requestClass:[GCDWebServerRequest class]
                      asyncProcessBlock:^(GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        @strongify(self);
        @try {
            NSString *target = request.query[@"target"];
            IPAServerPackage *package = self.importedPackages[target];
            MUPath *path = package.rootDirectory;
            path = [path subpathWithComponent:@"package.ipa"];
            if (path.isFile) {
                GCDWebServerFileResponse *response = [GCDWebServerFileResponse responseWithFile:path.string];
                completionBlock(response);
            } else {
                GCDWebServerResponse *response = [GCDWebServerResponse responseWithStatusCode:404];
                completionBlock(response);
            }
        } @catch (NSException *exception) {
            completionBlock([GCDWebServerResponse responseWithStatusCode:404]);
        } @finally {}
    }];
}

- (void)import:(MUPath *)ipaPath
           key:(NSString *)key
       success:(void (^)(IPAServerPackage *))success
       failure:(void (^)(NSError *))failure {
    [self.importQueue addOperationWithBlock:^{
        NSError *error = nil;
        IPAServerPackage *package = nil;
        
        MUPath *tempPath = [self.rootDirectory subpathWithComponent:@".temp"];
        [tempPath createDirectoryWithCleanContents:YES];
        
        do {
            
            MUPath *packageDirectory = [self.packagesDirectory subpathWithComponent:key];
            if (packageDirectory.isDirectory) {
                package = self.importedPackages[key];
                break;
            }
            [packageDirectory createDirectoryWithCleanContents:YES];
            
            CLInfo(@"Unzip %@", ipaPath.lastPathComponent);
            BOOL unzip = [SSZipArchive unzipFileAtPath:ipaPath.string
                                         toDestination:tempPath.string
                                              delegate:nil];
            if (!unzip) {
                CLError(@"Unzip failed.");
                break;
            }
            
            [ipaPath copyTo:[packageDirectory subpathWithComponent:@"package.ipa"] autoCover:YES];
            
            MUPath *app = ({
                MUPath *app = nil;
                MUPath *Payload = [tempPath subpathWithComponent:@"Payload"];
                if (Payload.isDirectory) {
                    app = [Payload contentsWithFilter:^BOOL(MUPath *content) {
                        return content.isDirectory && [content isA:@"app"];
                    }].firstObject;
                }
                app;
            });
            if (!app) {
                CLError(@"Can not found app directory.");
                break;
            }
            CLInfo(@"Found %@", app.lastPathComponent);
            
            
            MUPath *InfoPlistPath = [app subpathWithComponent:@"Info.plist"];
            [InfoPlistPath copyInto:packageDirectory autoCover:YES];
            
            MUPath *AppIconPath = [app subpathWithComponent:@"AppIcon60x60@2x.png"];
            [AppIconPath copyTo:[packageDirectory subpathWithComponent:@"icon.png"] autoCover:YES];
            
            package = [[IPAServerPackage alloc] initWithRootDirectory:packageDirectory];
            self.importedPackages[key] = package;
        } while (NO);
        
        [tempPath remove];
        
        if (error) {
            !failure?:failure(error);
        } else {
            !success?:success(package);
        }
    }];
}

- (BOOL)start {
    return [self _startWebServer] && [self _startHTTPServer];
}

- (BOOL)_startWebServer {
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    options[GCDWebServerOption_Port] = @(_configuration.port);
    NSError *error = nil;
    [self.webServer startWithOptions:options error:&error];
    if (error) {
        return NO;
    }
    return YES;
}

- (BOOL)_startHTTPServer {
    NSError *error = nil;
    self.httpServer.port = _configuration.port + 1;
    [self.httpServer start:&error];
    if (error) {
        return NO;
    }
    return YES;
}

- (void)stop {
    [self.webServer stop];
}

- (NSString *)downloadURLWithPackage:(IPAServerPackage *)package {
    return [NSString stringWithFormat:@"%@/download?target=%@", self.cdnBaseURL, package.MD5];
}

- (NSString *)rootCerURL {
    return [self.cdnBaseURL stringByAppendingFormat:@"/CA.cer"];
}

- (IPAServerPackage *)packageForKey:(NSString *)key {
    return self.importedPackages[key];
}

- (IPAServerManifest *)manifestWithPackage:(IPAServerPackage *)package {
    IPAServerManifest *manifest = [[IPAServerManifest alloc] init];
    NSString *baseURL = self.tlsBaseURL;
    NSString *identifier = package.MD5;
    
    NSString *software = [baseURL stringByAppendingFormat:@"/package/%@", identifier];
    NSString *icon = [baseURL stringByAppendingFormat:@"/icon/%@", identifier];
    
    manifest.fullSizeImage = icon;
    manifest.displayImage = icon;
    manifest.softwarePackage = software;
    manifest.bundleIdentifier = package.bundleIdentifier;
    manifest.bundleVersion = package.bundleVersion;
    manifest.title = package.displayName;
    return manifest;
}

@synthesize webServer = _webServer;
- (GCDWebServer *)webServer {
    if (!_webServer) {
        _webServer = [[GCDWebServer alloc] init];
        [self __initHTTPHandlers];
    }
    return _webServer;
}

@synthesize httpServer = _httpServer;
- (HTTPServer *)httpServer {
    if (!_httpServer) {
        _httpServer = [[HTTPServer alloc] init];
        _httpServer.connectionClass = [IPAConnection class];
        _httpServer.documentRoot = self.rootDirectory.string;
        _httpServer.mainServer = self;
    }
    return _httpServer;
}

@synthesize sessionManager = _sessionManager;
- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
    }
    return _sessionManager;
}

@synthesize manifestManager = _manifestManager;
- (IPAServerManifestManager *)manifestManager {
    if (!_manifestManager) {
        _manifestManager = [[IPAServerManifestManager alloc] initWithPolicy:_configuration.manifestUploadPolicy
                                                             sessionManager:self.sessionManager];
    }
    return _manifestManager;
}

- (NSString *)cdnBaseURL {
    return [NSString stringWithFormat:@"http://%@:%@", [IPAServerUtils LANAddress], @(self.webServer.port)];
}

- (NSString *)tlsBaseURL {
    NSString *url = [NSString stringWithFormat:@"https://%@:%@", [IPAServerUtils LANAddress], @(self.httpServer.listeningPort)];
    return url;
}

@end
