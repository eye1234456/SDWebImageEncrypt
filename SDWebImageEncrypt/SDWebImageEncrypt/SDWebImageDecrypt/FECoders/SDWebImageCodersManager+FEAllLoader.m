//
//  SDWebImageCodersManager+FEAllLoader.m
//  SDWebImageEncrypt
//
//  Created by Flow on 3/14/22.
//

#import "SDWebImageCodersManager+FEAllLoader.h"
#import <objc/runtime.h>
#import "AESKeyHeader.h"
#import "NSData+FE.h"

@implementation SDWebImageCodersManager (FEAllLoader)
+ (void)load {
    
    Method canDecodeMethod = class_getInstanceMethod(self, @selector(canDecodeFromData:));
    Method feCanDecodeMethodMethod = class_getInstanceMethod(self, @selector(fe_canDecodeFromData:));
    method_exchangeImplementations(canDecodeMethod, feCanDecodeMethodMethod);
    
    Method decodeMethod = class_getInstanceMethod(self, @selector(decodedImageWithData:));
    Method feDecodeMethodMethod = class_getInstanceMethod(self, @selector(fe_decodedImageWithData:));
    method_exchangeImplementations(decodeMethod, feDecodeMethodMethod);
}

- (BOOL)fe_canDecodeFromData:(NSData *)data {
    BOOL canDecode = [self fe_canDecodeFromData:data];
    if (!canDecode) {
        NSData *decodeData = [data fe_aesDecryptWithKey:kAESKey];
        canDecode = [self fe_canDecodeFromData:decodeData];
    }
    return canDecode;
}

- (UIImage *)fe_decodedImageWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    UIImage *image = [self fe_decodedImageWithData:data];
    if (image == nil) {
        NSData *decodeData = [data fe_aesDecryptWithKey:kAESKey];
        image = [self fe_decodedImageWithData:decodeData];
    }
    return image;
}

@end
