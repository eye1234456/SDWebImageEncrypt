//
//  YYWebImageOperation+FE.m
//  SDWebImageEncrypt
//
//  Created by eye on 3/11/22.
//

#import "YYWebImageOperation+FE.h"
#import <objc/runtime.h>
#import "AESKeyHeader.h"
#import "NSData+FE.h"

@implementation YYWebImageOperation (FE)
+ (void)load {
#pragma clang diagnostic push
//"-Wunused-variable"这里就是警告的类型
#pragma clang diagnostic ignored "-Wundeclared-selector"
    Method originMethod = class_getInstanceMethod(self, @selector(_fe_connectionDidFinishLoading:));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(connectionDidFinishLoading:));
#pragma clang diagnostic pop
    method_exchangeImplementations(originMethod, swizzledMethod);
}
- (void)_fe_connectionDidFinishLoading:(NSURLConnection *)connection {
#pragma clang diagnostic push
//"-Wunused-variable"这里就是警告的类型
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(data)]) {
#pragma clang diagnostic pop
        NSMutableData *data = (NSMutableData *)[self valueForKeyPath:@"data"];
    // 默认对所有数据进行解密尝试
    NSData *decodeData = [data fe_aesDecryptWithKey:kAESKey];
    YYImageType originImageType = YYImageDetectType((__bridge CFDataRef)data);
    YYImageType decodeImageType = YYImageDetectType((__bridge CFDataRef)decodeData);
        if (originImageType == YYImageTypeUnknown && decodeImageType != YYImageTypeUnknown) {
            NSMutableData *decodeDataM = [decodeData mutableCopy];
            [self setValue:decodeDataM forKeyPath:@"data"];
        }
    }
    [self _fe_connectionDidFinishLoading:connection];
}
@end
