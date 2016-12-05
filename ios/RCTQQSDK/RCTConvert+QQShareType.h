//
//  RCTConvert+QQShareType.h
//  RCTQQSDK
//
//  Created by Van on 2016/12/5.
//  Copyright © 2016年 Van. All rights reserved.
//

#import <RCTConvert.h>
typedef NS_ENUM(NSInteger, QQShareType) {
    TextMessage,
    ImageMesssage,
    NewsMessageWithNetworkImage,
    NewsMessageWithLocalImage,
    AudioMessage,
};
typedef NS_ENUM(NSInteger, QQShareScene) {
    QQ,
    QQZONE,
    Favrites,
    DataLine,
};
@interface RCTConvert(QQShareType)
+ (QQShareType)QQShareType:(id)json;
+ (QQShareScene)QQShareScene:(id)json;
@end
