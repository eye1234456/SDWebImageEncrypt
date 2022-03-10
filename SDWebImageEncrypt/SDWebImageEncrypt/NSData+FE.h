//
//  NSData+FE.h
//  SDWebImageEncrypt
//
//  Created by Flow on 3/10/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (FE)
- (NSData *)fe_aesEncryptWithKey:(NSString *)aesKey;
- (NSData *)fe_aesDecryptWithKey:(NSString *)aesKey;
@end

NS_ASSUME_NONNULL_END
