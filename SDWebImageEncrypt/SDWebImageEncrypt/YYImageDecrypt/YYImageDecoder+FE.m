//
//  YYImageDecoder+FE.m
//  SDWebImageEncrypt
//
//  Created by Flow on 3/24/22.
//

#import "YYImageDecoder+FE.h"
#import <objc/runtime.h>
#import "AESKeyHeader.h"
#import "NSData+FE.h"

@implementation YYImageDecoder (FE)
+ (void)load {
    
    static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // 交换类方法
            [self swizzleMethod:object_getClass((id)self) orgSel:@selector(decoderWithData:scale:) swizzSel:@selector(fe_decoderWithData:scale:)];
        });
}

/// 交换方法
+ (BOOL)swizzleMethod:(Class)class orgSel:(SEL)origSel swizzSel:(SEL)altSel {
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method altMethod = class_getInstanceMethod(class, altSel);
    if (!origMethod || !altMethod) {
        return NO;
    }
    BOOL didAddMethod = class_addMethod(class,origSel,
                                        method_getImplementation(altMethod),
                                        method_getTypeEncoding(altMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,altSel,
                            method_getImplementation(origMethod),
                            method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, altMethod);
    }
    
    return YES;
}

/// AES解密图片
+ (instancetype)fe_decoderWithData:(NSData *)data scale:(CGFloat)scale {
    YYImageDecoder *decoder = [self fe_decoderWithData:data scale:scale];
    if (decoder == nil) {
        NSData *decodeData = [data fe_aesDecryptWithKey:kAESKey];
        decoder = [self fe_decoderWithData:decodeData scale:scale];
    }
    return decoder;
}
@end
