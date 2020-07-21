//
//  IPASecurity.m
//  IPAServer
//
//  Created by 冷秋 on 2020/7/7.
//  Copyright © 2020 Magic-Unique. All rights reserved.
//

#import "IPASecurity.h"

#define IPA_CONFIG_ROOT [[MUPath homePath] subpathWithComponent:@".IPAServer"]

@implementation IPASecurity

+ (MUPath *)rootCerPath {
    MUPath *config = IPA_CONFIG_ROOT;
    MUPath *rootCer = [config subpathWithComponent:@"CA.cer"];
    if (rootCer.isFile) {
        return rootCer;
    }
    [config createDirectoryWithCleanContents:NO];
    NSLog(@"Create CA.cer");
    [[self __CA_CER] writeToFile:rootCer.string atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return rootCer;
}

+ (SecIdentityRef)identityForCN:(NSString *)CN {
    return [self findIdentity:CN];
}

+ (MUPath *)rootPEMPath {
    MUPath *config = IPA_CONFIG_ROOT;
    MUPath *rootPEM = [config subpathWithComponent:@"CA.pem"];
    if (rootPEM.isFile) {
        return rootPEM;
    }
    [config createDirectoryWithCleanContents:NO];
    NSLog(@"Create CA.pem");
    [[self __CA_PEM] writeToFile:rootPEM.string atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return rootPEM;
}

+ (NSString *)__CA_CER {
    return [@"\
            -----BEGIN CERTIFICATE-----\n\
            MIICqjCCAZICCQD8Wm9AUx4EyzANBgkqhkiG9w0BAQsFADAXMRUwEwYDVQQDDAxJ\n\
            UEFTZXJ2ZXIgQ0EwHhcNMjAwNzA3MDkyNjUxWhcNMzAwNzA1MDkyNjUxWjAXMRUw\n\
            EwYDVQQDDAxJUEFTZXJ2ZXIgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK\n\
            AoIBAQDAtK1OKyraWWdxx+gUCHMyZ48jYcX/FGz5kB13DwS+cpWPC8JGu+0QXlpC\n\
            +mlfdUr3HkwfOqUivUeFvRFLSaYcD5THVa7F7MHUmhmOofOVJFJc1BPuisTVXxcI\n\
            Rj7Rn6tHdqrOiJgM8Bci2QU89Qqcf9LWPXVCoDaWbdb+Oz6uBM3v8FiCKXoFU8xX\n\
            zHa06NlZm/CR+ljzxWpfVDjDdPlqzhR9LV20cRPeISVLpcCycCLoY2yLJyjxHoe7\n\
            piA8VilFOwLhsbR0e2968u1At6lwTn1fsbNNHTNxOk9ze0NGmumui+QFNP+w18Gk\n\
            1MKH2GtkacyODZldPc0iw9ns75GTAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAF2w\n\
            yzPIbs7So1YQCKbNgHwGEmpQ07sQQrWhbNzblDmOEd6c7EvQVe1E0qe+O1zSHhlt\n\
            dm5l+5FefJLgMBYmaHeV/ocimcVPQzzbm0dr6zheq4oCf0yTsBvl9CG7CCY0xHDN\n\
            ur0vkdhADWQaF5RTxqMgXmTceBpEshtoo2T7nD5YBeXm/hhZHqcEY2miTXdOL8Dd\n\
            Li+lONsmxsLCIMOBxYFB1cD3m05COqHQz41i85NTTjwTrmsWq+7jxqTE3Gpvw4TA\n\
            NLz3LwcV9TCsFlV8FbuoTP2nGtmetPNZKgN3O+ZqdpnpKg55RCf0pvl7pgAHHUmo\n\
            yjO5EUpqmh+jc1vSIL0=\n\
            -----END CERTIFICATE-----\n\
            " stringByReplacingOccurrencesOfString:@"  " withString:@""];
}

+ (NSString *)__CA_PEM {
    return [@"\
            -----BEGIN RSA PRIVATE KEY-----\n\
            MIIEogIBAAKCAQEAwLStTisq2llnccfoFAhzMmePI2HF/xRs+ZAddw8EvnKVjwvC\n\
            RrvtEF5aQvppX3VK9x5MHzqlIr1Hhb0RS0mmHA+Ux1WuxezB1JoZjqHzlSRSXNQT\n\
            7orE1V8XCEY+0Z+rR3aqzoiYDPAXItkFPPUKnH/S1j11QqA2lm3W/js+rgTN7/BY\n\
            gil6BVPMV8x2tOjZWZvwkfpY88VqX1Q4w3T5as4UfS1dtHET3iElS6XAsnAi6GNs\n\
            iyco8R6Hu6YgPFYpRTsC4bG0dHtvevLtQLepcE59X7GzTR0zcTpPc3tDRprprovk\n\
            BTT/sNfBpNTCh9hrZGnMjg2ZXT3NIsPZ7O+RkwIDAQABAoIBAC1Dw1mTJjO3wGan\n\
            kEn0WirCzIqBEuMBxz8vrNwkePbLL3o0RuQajGrF3unQrCOyB3PYeAT134gzcbNm\n\
            X8ORfyUkO8w+whjXrgfkUpCAVhj4OSh44F2t1uJPvbdB2Mugd7kHlMOCrkSLuMOE\n\
            uohA/scX90w/j2WhAHGBR3jcLbLuIXqizlI0bnwRnrh2601StxB+/j4wl5a+tmI7\n\
            KdirGRdRDIOcsvdA0ZOUJU4mTHejuhCFDVIWUU/QPe9p2Mopf9cfsfDOEc+sGlfO\n\
            xNndidxpBo/Jdv01qWhdRgdF3F7ngxcCNS1zEsHpSt1LFlIcQ5M7ULutpg0rSdNx\n\
            xkYUSNECgYEA6mL8wnci+2qfhV0pdUhKpBxPTvDK7k867T8R7nerlZhzfCxZTAj0\n\
            fssn/qdiMZsof2yYK4fq8OmuWky9Zs7KUlhXAANhTgFVIa+QPIaTL51Q58osS2jV\n\
            +WpBqhs7znMX2DSjadHVRVObWqSAX1wohyv3n8Wlp1hhizb/M6QE2F8CgYEA0nnB\n\
            g6q52ksDH3cRO2zZvIUSpbvyBdf0mgvYUtA2DawR01c6MzJKtlPEjXnMPwCo9iE+\n\
            EbLJN36l/vEf3ZTBMCaan2FbbqLP7ZvfRTAbsyouyuLIccq5VJnvQpZpgKdpW82R\n\
            Znu+Lp+wIhxVymwRcowUUQ166G01AtkuwLIKo00CgYBqkr3JEnC2jsGf2z9pk4hU\n\
            3IZ3J2euOhpaG65klsdPCvWfxW6I8x1wtaEm2ib81UbxwYfjaza5eheL+Y65O1el\n\
            X4OXfvH0jQiPe4uC6dHs+YP7EONZGn8InHblCOMFuTFjXnPbPszRa/WcnmW8dmP7\n\
            KlO6sxziXX5k1Ynuiiql0wKBgEes6veZtjzeeqvGcnnYMbX/Y0BJZrwStNuY2Qwq\n\
            l53EUTW1aL5yi/rXQAIlziZOZTucSnTge6GIYaMWHhHpTHjHTLSmBOsCSujRwhDf\n\
            ty8mWFUDMdt+e+qRmWcFrdwAJuL6eF98GGHsQ6D6IUUT1EU76tdHTenE9t6Hc2Jv\n\
            vyupAoGAZYrkD8g0QIIlwRfIZTHU0Cxc33KgeHzfNnBbgh8V1BGideth33E/hdMt\n\
            yWIBZJl7qPekCvDD4jxpNXy3jSX8as86rB01oVaN/vf+CObVD5uVcu2kU/Ma7TE5\n\
            2fNyi1ixnSd2YiNtOB0J9pNMNhoNiDsAMTU9OUZNpRSOr9ReRSM=\n\
            -----END RSA PRIVATE KEY-----\n\
            " stringByReplacingOccurrencesOfString:@"  " withString:@""];
}

+ (BOOL)__makePKCS12ForCN:(NSString *)CN {
    MUPath *root = IPA_CONFIG_ROOT;
    
    __unused NSString *CA_PEM = [self rootPEMPath].lastPathComponent;
    __unused NSString *CA_CER = [self rootCerPath].lastPathComponent;
    
    __unused NSString *SERVER_PEM = [NSString stringWithFormat:@"%@.pem", CN];
    __unused NSString *SERVER_REQ = [NSString stringWithFormat:@"%@.req", CN];
    __unused NSString *SERVER_CER = [NSString stringWithFormat:@"%@.cer", CN];
    __unused NSString *SERVER_DER = [NSString stringWithFormat:@"%@.der", CN];
    __unused NSString *SERVER_P12 = [NSString stringWithFormat:@"%@.p12", CN];
    
    NSString *openssl = @"/usr/bin/openssl";
    
#define IPAOpenSSL(...) CLLaunch(root.string, openssl, __VA_ARGS__, nil)
    
    // 创建 HTTP 秘钥
    CLVerbose(@"Create %@", SERVER_PEM);
    if (!IPAOpenSSL(@"genrsa", @"-out", SERVER_PEM, @"2048", nil)) {
        return NO;
    }
    
    // 创建 HTTP 请求
    CLVerbose(@"Create %@", SERVER_REQ);
    if (!IPAOpenSSL(@"req", @"-new", @"-out", SERVER_REQ, @"-key", SERVER_PEM, @"-subj", [NSString stringWithFormat:@"/CN=%@", CN], nil)) {
        return NO;
    }
    
    // 颁发证书
    CLVerbose(@"Create %@", SERVER_CER);
    if (!IPAOpenSSL(@"x509", @"-req", @"-in", SERVER_REQ, @"-out", SERVER_CER, @"-CAkey", CA_PEM, @"-CA", CA_CER, @"-days", @"3650", @"-CAcreateserial", @"-CAserial", @"serial")) {
        return NO;
    }
    
    // 转 DER
    CLVerbose(@"Create %@", SERVER_DER);
    if (!IPAOpenSSL(@"x509", @"-in", SERVER_CER, @"-inform", @"PEM", @"-out", SERVER_DER, @"-outform", @"DER")) {
        return NO;
    }
    
    // 导出 p12 文件
    CLVerbose(@"Create %@", SERVER_P12);
    if (!IPAOpenSSL(@"pkcs12", @"-export", @"-inkey", SERVER_PEM, @"-in", SERVER_CER, @"-out", SERVER_P12, @"-name", @"IPAServer Server", @"-passout", @"pass:ipaserver")) {
        return NO;
    }
    
    // 导入 p12 文件
    CLVerbose(@"Import p12");
    if (!CLLaunch(root.string, @"/usr/bin/security", @"import", SERVER_P12, @"-P", @"ipaserver", nil)) {
        return NO;
    }
    
    return YES;
}

+ (SecIdentityRef)findIdentity:(NSString *)CN {
    MUPath *der = [IPA_CONFIG_ROOT subpathWithComponent:[NSString stringWithFormat:@"%@.der", CN]];
    if (!der.isFile) {
        [self __makePKCS12ForCN:CN];
    }
    if (!der.isFile) {
        CLVerbose(@"Can not found der");
        return NULL;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:der.string];
    CFDataRef cfData = (__bridge_retained CFDataRef)data;
    SecCertificateRef certificate = SecCertificateCreateWithData(NULL, cfData);
    SecIdentityRef identity = NULL;
    OSStatus status = SecIdentityCreateWithCertificate(NULL, certificate, &identity);
    if (status != 0) {
        CLVerbose(@"KeyChain Error");
        return NULL;
    }
    CFRelease(cfData);
    return identity;
}

@end
