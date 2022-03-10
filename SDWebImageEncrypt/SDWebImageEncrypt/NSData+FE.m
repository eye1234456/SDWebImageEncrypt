//
//  NSData+FE.m
//  SDWebImageEncrypt
//
//  Created by Flow on 3/10/22.
//

#import "NSData+FE.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (FE)

- (NSData *)fe_aesEncryptWithKey:(NSString *)aesKey{
    
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [aesKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
     
    NSData * sourceData = self;
    NSUInteger dataLength = [sourceData length];
    size_t buffersize = dataLength + kCCBlockSizeAES128;
    void * buffer = malloc(buffersize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, [sourceData bytes], dataLength, buffer, buffersize, &numBytesEncrypted);
     
    if (cryptStatus == kCCSuccess) {
        NSData * encryptData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return encryptData;
    } else {
        free(buffer);
        return nil;
    }
}
 
- (NSData *)fe_aesDecryptWithKey:(NSString *)aesKey {
     
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [aesKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
     
    NSData *decodeData = self;
    NSUInteger dataLength = [decodeData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void * buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, [decodeData bytes], dataLength, buffer, bufferSize, &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData * data = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        return data;
    } else {
        free(buffer);
        return nil;
    }
}
@end
