//
//  RCTConvert+QQShareType.m
//  RCTQQSDK
//
//  Created by Van on 2016/12/5.
//  Copyright © 2016年 Van. All rights reserved.
//

#import "RCTConvert+QQShareImageType.h"

@implementation RCTConvert(QQShareImageType)

RCT_ENUM_CONVERTER(QQShareImageType, (@{@"Local": @(Local),
                                        @"Base64": @(Base64),
                                        @"Network": @(Network),
                                        }), Local, integerValue)

@end
