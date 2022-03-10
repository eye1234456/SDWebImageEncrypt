//
//  AppDelegate.m
//  SDWebImageEncrypt
//
//  Created by lonelyEye on 3/10/22.
//

#import "AppDelegate.h"
#import "NSData+FE.h"
#define kAESKey @"1234abcdABCD1234"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [self createEncryptImages];
    
    
    return YES;
}

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

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
