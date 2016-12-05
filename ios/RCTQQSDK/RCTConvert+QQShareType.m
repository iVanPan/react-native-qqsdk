//
//  RCTConvert+QQShareType.m
//  RCTQQSDK
//
//  Created by Van on 2016/12/5.
//  Copyright © 2016年 Van. All rights reserved.
//

#import "RCTConvert+QQShareType.h"

@implementation RCTConvert(QQShareType)

RCT_ENUM_CONVERTER(QQShareType, (@{@"TextMessage": @(TextMessage),
                                @"ImageMesssage": @(ImageMesssage),
                                @"NewsMessageWithNetworkImage": @(NewsMessageWithNetworkImage),
                                @"NewsMessageWithLocalImage": @(NewsMessageWithLocalImage),
                                }), TextMessage, integerValue)
RCT_ENUM_CONVERTER(QQShareScene, (@{@"QQ": @(QQ),
                                   @"QQZONE": @(QQZONE),
                                   @"Favrites": @(Favrites),
                                   @"DataLine": @(DataLine),
                                   }), QQ, integerValue)
@end
