//
//  RCTConvert+QQShareScene.m
//  RCTQQSDK
//
//  Created by Van on 2016/12/5.
//  Copyright © 2016年 Van. All rights reserved.
//

#import "RCTConvert+QQShareScene.h"

@implementation RCTConvert(QQShareScene)
RCT_ENUM_CONVERTER(QQShareScene, (@{@"QQ": @(QQ),
                                    @"QQZONE": @(QQZONE),
                                    @"Favrites": @(Favrites),
                                    @"DataLine": @(DataLine),
                                    }), QQ, integerValue)
@end
