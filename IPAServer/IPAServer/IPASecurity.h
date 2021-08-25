//
//  IPASecurity.h
//  IPAServer
//
//  Created by 冷秋 on 2020/7/7.
//  Copyright © 2020 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 ==========================================================================================================
 1. Create CA certificate

 1.1 Create key
 $ openssl genrsa -out IPAServerCA.pem 2048

 1.2 Create certificate
 $ openssl req -x509 -new -key IPAServerCA.pem -out IPAServerCA.cer -days 3650 -subj /CN="IPAServer CA"

 ==========================================================================================================
 
 1.3 Install CA certificate into iOS device
 $ ipainstaller ssl

 2. Create domain(LAN IP) certificate

 2.1 Create key
 $ openssl genrsa -out http.pem 2048

 2.2 Create req
 $ openssl req -new -out http.req -key http.pem -subj /CN="192.148.1.1"

 2.3 Issue
 $ openssl x509 -req -in http.req -out http.cer -CAkey CA.pem -CA CA.cer -days 3650
 
 2.4 Convert CER to DER
 $ openssl x509 -in http.cer -inform CER -out http.der -outform DER
 
 ==========================================================================================================
 3. Import p12 into Mac

 3.1 Create pkcs12
 $ openssl pkcs12 -export -inkey http.pem -in http.cer -out http.p12 -name "IPAServer Server" -password 1

 3.2 Import pkcs12
 $ security import http.p12 -P 1
 
 ==========================================================================================================
 */

@interface IPASecurity : NSObject

@property (nonatomic, strong, readonly) MUPath *rootDirectory;

- (instancetype)initWithRootDirectory:(MUPath *)rootDirectory;

- (SecIdentityRef)identityForCommonName:(NSString *)commonName;

- (MUPath *)rootCerPath;

@end
