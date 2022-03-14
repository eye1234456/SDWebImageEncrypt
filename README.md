#前言
> 日常开发中调试中，偶尔去其他网站上复制一个图片地址到自己的项目里调试使用，但是有些时候图片做了防盗链处理导致加载不出来，这种情况一般都是添加一个`Referer`解决，还有一些时图片加载了，但是展示不了，这可能是对图片进行了加密处理，这种就需要在下载好图片或者解码图片时进行解密处理，特对两种情况做下记录

一、图片防盗链`Referer `
在下载图片时的header里增加正确的`Referer`即可

二、图片加解密
----
###SDWebImage 5.x
podfile
```
  pod 'SDWebImage', '~> 5.0'
  pod 'SDWebImageWebPCoder'
```
>解密图片由2个时机，分别是下载时和解码时，可以选择任何
>种，也可以两种同时存在，但是同时存在会更耗性能

#####> 2.1、解密时机一：服务器图片加密后，在下载后解密展示与缓存解密后的图片
创建一个`SDWebImageDownloaderOperation`的子类,重写`- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error`方法，对图片进行解密，具体如下

```
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

```

将自定义的下载解密类配置给SDWebImage

```
- (void)configDecryptSDWebImageAtDownloadTime {
    // 配置支持webp图片
    SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:webPCoder];
    // 配置图片下载时解密，并将解密的图片缓存到本地
    SDWebImageDownloaderConfig.defaultDownloaderConfig.operationClass = FEDecryptSDWebImageDownloaderOperation.class;;

}

```

----
#####> 2.2、解密时机二：、服务器图片加密后，在下载后将NSData解码成图片成解密，缓存的数据是加密的数据，每次从硬盘获取图片时都要先解密然后再解码

创造各种默认ImageCoder的子类，包含：`SDImageIOCoder`、`SDImageGIFCoder`、`SDImageAPNGCoder`、`SDImageWebPCoder`的子类，并重写`- (BOOL)canDecodeFromData:(nullable NSData *)data`和`- (UIImage *)decodedImageWithData:(NSData *)data options:(nullable SDImageCoderOptions *)options`两个方法，具体实现如下（以gif为例）：

```

#import "FESDImageGIFCoder.h"

#import "AESKeyHeader.h"
#import "NSData+FE.h"

@implementation FESDImageGIFCoder

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
```

初始化时调用

```
- (void)configDecrptyAtDecodeTime {
    // 配置图片解码时解密，由于SDWebImage在使用时是逆序，所以这里的顺序不能乱
    // 普通图片
    [SDImageCodersManager.sharedManager addCoder:FEDecryptSDImageIOCoder.new];
    // gif图片
    [SDImageCodersManager.sharedManager addCoder:FESDImageGIFCoder.new];
    // apng图片
    [SDImageCodersManager.sharedManager addCoder:FESDImageAPNGCoder.new];
    // webp图片
    [SDImageCodersManager.sharedManager addCoder:FESDImageWebPCoder.new];
}

```

还有一种使用分类的方式，将codermanager进行统一处理

```
- (void)configDecrptyAtDecodeTime2 {
    // 使用分类的方式，对所有的coder进行统一解密处理
    // SDImageCodersManager+FEAllLoader
    // webp图片
    [SDImageCodersManager.sharedManager addCoder:[SDImageWebPCoder sharedCoder]];
}
```

```
#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDImageCodersManager (FEAllLoader)

@end

NS_ASSUME_NONNULL_END
```

解密分类

```
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
```
----
###SDWebImage 4.x
大同小异，只是一些类名和方法不一致