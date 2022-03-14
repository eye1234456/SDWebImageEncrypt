//
//  AppDelegate.m
//  SDWebImageEncrypt
//
//  Created by lonelyEye on 3/10/22.
//

#import "AppDelegate.h"

#import "AESKeyHeader.h"
#import "NSData+FE.h"

#import <SDWebImage/SDWebImage.h>


#import "FEDecryptSDWebImageDownloaderOperation.h"
#import <SDWebImageWebPCoder/SDImageWebPCoder.h>

#import "FEDecryptSDImageIOCoder.h"
#import "FESDImageGIFCoder.h"
#import "FESDImageAPNGCoder.h"
#import "FESDImageWebPCoder.h"
#import <SDWebImage/SDImageCodersManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [self createEncryptImages];
//    [self configDecryptSDWebImageAtDownloadTime];
//    [self configDecrptyAtDecodeTime];
    [self configDecrptyAtDecodeTime2];
    
    return YES;
}

- (void)configDecryptSDWebImageAtDownloadTime {
    // 配置支持webp图片
    SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:webPCoder];
    // 配置图片下载时解密，并将解密的图片缓存到本地
    //SDWebImageDownloaderConfig.defaultDownloaderConfig.operationClass = FEDecryptSDWebImageDownloaderOperation.class;;

}

- (void)configDecrptyAtDecodeTime {
    // 配置图片解码时解密，由于SDWebImage在使用时是逆序，所以这里的顺序不能乱
    // 普通图片
//    [SDImageCodersManager.sharedManager addCoder:FEDecryptSDImageIOCoder.new];
//    // gif图片
//    [SDImageCodersManager.sharedManager addCoder:FESDImageGIFCoder.new];
//    // apng图片
//    [SDImageCodersManager.sharedManager addCoder:FESDImageAPNGCoder.new];
//    // webp图片
    [SDImageCodersManager.sharedManager addCoder:[FESDImageWebPCoder new]];
}

- (void)configDecrptyAtDecodeTime2 {
    // 使用分类的方式，对所有的coder进行统一解密处理
    // SDImageCodersManager+FEAllLoader
    // webp图片
    [SDImageCodersManager.sharedManager addCoder:[SDImageWebPCoder sharedCoder]];
}
/**
 准备图片资源，原始图片+加密图片
 */
- (void)createEncryptImages {
    NSString *projectSourcePath = @"/Users/xxx/xx/xx/SDWebImageEncrypt";
    NSString *originFolder = @"originImage";
    NSString *encrypthFolder = @"encryptImage";
    NSArray *originImages = @[@"1.jpeg",@"2.png",@"3.webp",@"4.webp",@"5.gif",];
    for (NSString *originName in originImages) {
        NSString *originImagePath = [NSString stringWithFormat:@"%@/%@/%@",projectSourcePath,originFolder,originName];
        NSString *encryptImagePath = [NSString stringWithFormat:@"%@/%@/%@",projectSourcePath,encrypthFolder,originName];
        NSData *data = [NSData dataWithContentsOfFile:originImagePath];
        NSData *encryptData = [data fe_aesEncryptWithKey:kAESKey];
        [encryptData writeToFile:encryptImagePath atomically:YES];
    }
}

@end
