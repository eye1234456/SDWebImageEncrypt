//
//  SDImageCodersManager+FEAllLoader.m
//  SDWebImageEncrypt
//
//  Created by eye on 3/14/22.
//

#import "SDImageCodersManager+FEAllLoader.h"
#import <objc/runtime.h>
#import "AESKeyHeader.h"
#import "NSData+FE.h"

@implementation SDImageCodersManager (FEAllLoader)
+ (void)load {
    
    Method canDecodeMethod = class_getInstanceMethod(self, @selector(canDecodeFromData:));
    Method feCanDecodeMethodMethod = class_getInstanceMethod(self, @selector(fe_canDecodeFromData:));
    method_exchangeImplementations(canDecodeMethod, feCanDecodeMethodMethod);
    
    Method decodeMethod = class_getInstanceMethod(self, @selector(decodedImageWithData:options:));
    Method feDecodeMethodMethod = class_getInstanceMethod(self, @selector(fe_decodedImageWithData:options:));
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

- (UIImage *)fe_decodedImageWithData:(NSData *)data options:(nullable SDImageCoderOptions *)options {
    if (!data) {
        return nil;
    }
    UIImage *image;
    NSArray<id<SDImageCoder>> *coders = self.coders;
    for (id<SDImageCoder> coder in coders.reverseObjectEnumerator) {
        if ([coder canDecodeFromData:data]) {
            image = [coder decodedImageWithData:data options:options];
            if (image == nil) {
                NSData *decodeData = [data fe_aesDecryptWithKey:kAESKey];
                if ([coder canDecodeFromData:decodeData]) {
                    image = [coder decodedImageWithData:decodeData options:options];
                    break;
                }
            }
            break;
        }else{
            NSData *decodeData = [data fe_aesDecryptWithKey:kAESKey];
            if ([coder canDecodeFromData:decodeData]) {
                image = [coder decodedImageWithData:decodeData options:options];
                break;
            }
        }
    }
    
    return image;
}
@end
