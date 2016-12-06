//
//  RCTQQSDK.h
//  RCTQQSDK
//
//  Created by Van on 2016/11/24.
//  Copyright © 2016年 Van. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "RCTBridge.h"
#import "RCTEventEmitter.h"

typedef NS_ENUM(NSInteger, QQShareScene) {
    QQ,
    QQZone,
    Favrites,
    DataLine,
};

typedef NS_ENUM(NSInteger, QQShareType) {
    TextMessage,
    ImageMesssage,
    NewsMessageWithNetworkImage,
    NewsMessageWithLocalImage,
    AudioMessage,
};


@interface RCTQQSDK : RCTEventEmitter <TencentSessionDelegate,QQApiInterfaceDelegate>
@end
