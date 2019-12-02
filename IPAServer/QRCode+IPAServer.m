//
//  QRCode+IPAServer.m
//  IPAServer
//
//  Created by 冷秋 on 2019/11/21.
//  Copyright © 2019 Magic-Unique All rights reserved.
//

#import "QRCode+IPAServer.h"

@implementation QRCode (IPAServer)

static void _PrintBackground(void) {
    if (CLProcessIsAttached()) {
        CCPrintf(CCStyleForegroundColorWhite, @"██");
    } else {
        CCPrintf(CCStyleBackgroundColorWhite, @"  ");
    }
}

static void _PrintForeground(void) {
    CCPrintf(CCStyleForegroundColorBlack, @"  ");
}

static void PrintQRCode(QRCode *code) {
    for (NSUInteger i = 0; i < code.map.size + 2; i++) {
        _PrintBackground();
    }
    printf("\n");
    for (NSUInteger col = 0; col < code.map.size; col++) {
        _PrintBackground();
        for (NSUInteger row = 0; row < code.map.size; row++) {
            if ([code.map dataInRow:row col:col]) {
                _PrintForeground();
            } else {
                _PrintBackground();
            }
        }
        _PrintBackground();
        printf("\n");
    }
    for (NSUInteger i = 0; i < code.map.size + 2; i++) {
        _PrintBackground();
    }
    printf("\n");
}

- (void)print {
    PrintQRCode(self);
}

@end
