//
//  RCTQQSDK.h
//  RCTQQSDK
//
//  Created by Van on 2016/11/24.
//  Copyright © 2016年 Van. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <React/RCTBridge.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTBridgeModule.h>

typedef NS_ENUM(NSInteger, QQShareScene) {
    QQ,
    QQZone,
    Favorite,
};

typedef NS_ENUM(NSInteger, QQShareType) {
    TextMessage,
    ImageMesssage,
    NewsMessageWithLocalImage,
    AudioMessage,
    VideoMessage,
};

@interface RCTQQSDK : RCTEventEmitter <TencentSessionDelegate, QQApiInterfaceDelegate>
@end
