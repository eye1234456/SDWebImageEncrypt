//
//  FESDImageWebPCoder.m
//  SDWebImageEncrypt
//
//  Created by eye on 3/10/22.
//

#import "FESDImageWebPCoder.h"
#import "AESKeyHeader.h"
#import "NSData+FE.h"

@implementation FESDImageWebPCoder

- (BOOL)canDecodeFromData:(nullable NSData *)data {
    // 默认对所有数据进行解密尝试
    __block NSData *decodeData = [data fe_aesDecryptWithKey:kAESKey];
    // 判断解密的图片是否符合当前解码器，如果符合，直接返回yes
    BOOL canDecode = [super canDecodeFromData:decodeData];
    if (canDecode) {
        return canDecode;
    }
    // 不符合，则使用原始数据调用父类解码器
    return [super canDecodeFromData:data];
}

- (UIImage *)decodedImageWithData:(NSData *)data options:(nullable SDImageCoderOptions *)options {
    if (!data) {
        return nil;
    }
    // 默认对所有数据进行解密尝试
    __block NSData *decodeData = [data fe_aesDecryptWithKey:kAESKey];
    // 如果使用解密的数据解码成功，则表示图片是需要解密的，返回解密后的图片
    UIImage *image = [super decodedImageWithData:decodeData options:options];
    if (image != nil) {
        return image;
    }
    // 解密后的图片解码失败，则直接使用原始数据进行解码
    return [super decodedImageWithData:data options:options];
}
@end
