//
//  QRCode.m
//  qrencode
//
//  Created by 冷秋 on 2019/6/3.
//  Copyright © 2019 Magic-Unique All rights reserved.
//

#import "QRCode.h"
#import "libqrencode/qrencode.h"


@implementation QRCodeMap

- (BOOL)dataInRow:(NSUInteger)row col:(NSUInteger)col {
    return (self.datas[row][col]).boolValue;
}

- (instancetype)initWithQRCode:(QRcode *)code {
    self = [super init];
    if (self) {
        _size = code->width;
        NSMutableArray *datas = [NSMutableArray arrayWithCapacity:_size];
        for (NSUInteger row = 0; row < _size; row++) {
            NSMutableArray *currentRow = [NSMutableArray arrayWithCapacity:_size];
            for (NSUInteger col = 0; col < _size; col++) {
                NSUInteger index = row*_size+col;
                unsigned char data = code->data[index];
                if (data & 1) {
                    [currentRow addObject:@YES];
                } else {
                    [currentRow addObject:@NO];
                }
            }
            [datas addObject:currentRow];
        }
        _datas = [datas copy];
    }
    return self;
}

@end

@implementation QRCode

+ (instancetype)codeWithString:(NSString *)string version:(NSUInteger)version level:(QRCodeLevel)level mode:(QRCodeMode)mode {
    QRcode *_qrcode = QRcode_encodeString(string.UTF8String, version, (QRecLevel)level, (QRencodeMode)mode, 1);
    if (!_qrcode) {
        return nil;
    }
    QRCodeMap *map = [[QRCodeMap alloc] initWithQRCode:_qrcode];
    QRCode *code = [[self alloc] init];
    code->_version = _qrcode->version;
    code->_map = map;
    code->_string = [string copy];
    QRcode_free(_qrcode);
    return code;
}

@end
