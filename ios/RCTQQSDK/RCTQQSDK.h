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

@interface RCTQQSDK : RCTEventEmitter <RCTBridgeModule,TencentSessionDelegate,QQApiInterfaceDelegate>
@property(nonatomic) TencentOAuth *tencentOAuth;
@property(nonatomic, copy) NSArray *permissions;
@end
