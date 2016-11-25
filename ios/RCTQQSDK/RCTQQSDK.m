//
//  RCTQQSDK.m
//  RCTQQSDK
//
//  Created by Van on 2016/11/24.
//  Copyright © 2016年 Van. All rights reserved.
//

#import "RCTQQSDK.h"

NSString *QQ_NOT_INSTALLED = @"QQ Client is not installed";
NSString *QQ_PARAM_NOT_FOUND = @"param is not found";
NSString *QQ_LOGIN_ERROR = @"QQ login error";
NSString *QQ_LOGIN_CANCEL = @"QQ login cancelled";
NSString *QQ_LOGIN_NETWORK_ERROR = @"QQ login network error";
NSString *QQ_SHARE_CANCEL = @"QQ share cancelled by user";
NSString *QQ_OTHER_ERROR = @"other error happened";
NSString *appId=@"";
NSString *const RCTOpenURLNotification = @"RCTOpenURLNotification";

@implementation RCTQQSDK

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(RCTQQ);

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleOpenURLNotification:)
                                                     name:RCTOpenURLNotification
                                                   object:nil];
        NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
        for (id type in urlTypes) {
            NSArray *urlSchemes = [type objectForKey:@"CFBundleURLSchemes"];
            for (id scheme in urlSchemes) {
                if([scheme isKindOfClass:[NSString class]]) {
                    NSString* value = (NSString*)scheme;
                    if ([value hasPrefix:@"tencent"] && (nil == self.tencentOAuth)) {
                        appId = [value substringFromIndex:7];
                        self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];
                        break;
                    }
                }
            }
        }
    }
    return self;
}

- (void)handleOpenURLNotification:(NSNotification *)notification {
    NSURL *url = [NSURL URLWithString: [notification userInfo][@"url"]];
    NSString *schemaPrefix = [@"tencent" stringByAppendingString:appId];
    if ([url isKindOfClass:[NSURL class]] && [[url absoluteString] hasPrefix:[schemaPrefix stringByAppendingString:@"://response_from_qq"]]) {
        [QQApiInterface handleOpenURL:url delegate:self];
    } else {
        [TencentOAuth HandleOpenURL:url];
    }
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"LoginResponse", @"ShareResponse", @"LoginOutResponse"];
}

RCT_EXPORT_METHOD(checkClientInstalled:
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    if ([TencentOAuth iphoneQQInstalled] && [TencentOAuth iphoneQQSupportSSOLogin]) {
        resolve(@YES);
    } else {
        reject(QQ_NOT_INSTALLED, QQ_NOT_INSTALLED, nil);
    }
}

RCT_EXPORT_METHOD(ssoLogin: (BOOL)checkQQInstalled) {
    if (checkQQInstalled) {
        if ([TencentOAuth iphoneQQInstalled] && [TencentOAuth iphoneQQSupportSSOLogin]) {
            [self qqLogin];
        } else {
            [self sendEventWithName:@"LoginResponse" body: @{@"error": QQ_NOT_INSTALLED}];
        }
    } else {
        [self qqLogin];
    }
}

RCT_EXPORT_METHOD(logout) {
    [self.tencentOAuth logout:self];
}

- (void)qqLogin{
    self.permissions = [NSArray arrayWithObjects:
                        kOPEN_PERMISSION_GET_USER_INFO,
                        kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                        kOPEN_PERMISSION_ADD_ALBUM,
                        kOPEN_PERMISSION_ADD_ONE_BLOG,
                        kOPEN_PERMISSION_ADD_SHARE,
                        kOPEN_PERMISSION_ADD_TOPIC,
                        kOPEN_PERMISSION_CHECK_PAGE_FANS,
                        kOPEN_PERMISSION_GET_INFO,
                        kOPEN_PERMISSION_GET_OTHER_INFO,
                        kOPEN_PERMISSION_LIST_ALBUM,
                        kOPEN_PERMISSION_UPLOAD_PIC,
                        kOPEN_PERMISSION_GET_VIP_INFO,
                        kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                        nil];
    if (self.tencentOAuth.isSessionValid) {
        [self sendEventWithName:@"LoginResponse" body:@{@"userid" : self.tencentOAuth.openId,
                                                        @"access_token" : self.tencentOAuth.accessToken,
                                                        @"expires_time" : [NSString stringWithFormat:@"%f",[self.tencentOAuth.expirationDate timeIntervalSince1970] * 1000]}];
    } else {
        [self.tencentOAuth authorize:self.permissions inSafari:NO];
    }
}

#pragma mark - QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req {
    NSLog(@"req is %@",req);
}

- (void)onResp:(QQBaseResp *)resp {
    NSLog(@" ----resp %@",resp.result);
    switch ([resp.result integerValue]) {
        case 0: {
            [self sendEventWithName:@"ShareResponse" body: @{@"code": @"200"}];
            break;
        }
        case -4: {
            [self sendEventWithName:@"ShareResponse" body: @{@"error": QQ_SHARE_CANCEL}];
            break;
        }
        default:{
            [self sendEventWithName:@"ShareResponse" body: @{@"error": QQ_OTHER_ERROR}];
            break;
        }
    }
}

- (void)isOnlineResponse:(NSDictionary *)response {
    NSLog(@"response is %@",response);
}

#pragma mark - TencentSessionDelegate
- (void)tencentDidLogin {
    if (self.tencentOAuth.accessToken && 0 != [self.tencentOAuth.accessToken length]) {
        [self sendEventWithName:@"LoginResponse" body:@{@"userid" : self.tencentOAuth.openId,
                                                        @"access_token" : self.tencentOAuth.accessToken,
                                                        @"expires_time" : [NSString stringWithFormat:@"%f",[self.tencentOAuth.expirationDate timeIntervalSince1970] * 1000]}];
    } else {
        [self sendEventWithName:@"LoginResponse" body: @{@"error": QQ_LOGIN_ERROR}];
    }
}

- (void)tencentDidLogout {
    [self sendEventWithName:@"LoginOutResponse" body: @{@"code": @"200"}];
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        [self sendEventWithName:@"LogininResponse" body: @{@"error": QQ_LOGIN_CANCEL}];
    }
}

- (void)tencentDidNotNetWork {
    [self sendEventWithName:@"LogininResponse" body: @{@"error": QQ_LOGIN_NETWORK_ERROR}];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
