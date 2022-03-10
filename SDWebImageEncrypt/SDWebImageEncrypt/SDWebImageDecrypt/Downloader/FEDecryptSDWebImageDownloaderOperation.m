//
//  FEDecryptSDWebImageDownloaderOperation.m
//  SDWebImageEncrypt
//
//  Created by lonelyEye on 3/10/22.
//

#import "FEDecryptSDWebImageDownloaderOperation.h"
#import <SDWebImage/SDImageCodersManager.h>
#import "AESKeyHeader.h"
#import "NSData+FE.h"

@implementation FEDecryptSDWebImageDownloaderOperation
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
#pragma clang diagnostic push
//"-Wunused-variable"这里就是警告的类型
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(imageData)]) {
#pragma clang diagnostic pop
        NSMutableData *imageData = (NSMutableData *)[self valueForKeyPath:@"imageData"];
        
        // 默认对所有数据进行解密尝试
        __block NSData *decodeData = [imageData fe_aesDecryptWithKey:kAESKey];
        // 如果解密后的数据不支持解码，则说明不需要解密
        if (![[SDImageCodersManager sharedManager] canDecodeFromData:decodeData]) {
            [super URLSession:session task:task didCompleteWithError:error];
            return;
        }
        // 对解密的数据解码成图片，如果解码失败，则说明不需要解密
        UIImage *image = [[SDImageCodersManager sharedManager] decodedImageWithData:decodeData options:nil];
        if (image == nil) {
            [super URLSession:session task:task didCompleteWithError:error];
            return;
        }
        // 如果解密后的数据能完整解码成图片，说明该图片需要加密，且能正常解码成功，则将解密后的数据继续交由后续流程处理
        NSMutableData *decodeDataM = [decodeData mutableCopy];
        if (decodeDataM != nil) {
            [self setValue:decodeDataM forKeyPath:@"imageData"];
        }
        
    }
    [super URLSession:session task:task didCompleteWithError:error];
    
}

@end
