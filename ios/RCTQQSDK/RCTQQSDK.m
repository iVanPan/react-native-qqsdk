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
typedef NS_ENUM(NSInteger, QQShareType) {
    TextMessage,
    ImageMesssage,
    NewsMessageWithNetworkImage,
    NewsMessageWithLocalImage,
    AudioMessage,
    VideoMessage,
};
typedef NS_ENUM(NSInteger, QQShareScene) {
    QQ,
    QQZONE,
    Favrites,
    DataLine,
};
@implementation RCTQQSDK {
    TencentOAuth *tencentOAuth;
    RCTPromiseResolveBlock loginResolve;
    RCTPromiseRejectBlock loginReject;
    RCTPromiseResolveBlock logoutResolve;
    RCTPromiseRejectBlock logoutReject;
}

RCT_EXPORT_MODULE()

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initTencentOAuth];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleOpenURLNotification:)
                                                     name:@"RCTOpenURLNotification"
                                                   object:nil];
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
- (void)initTencentOAuth {
    NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    for (id type in urlTypes) {
        NSArray *urlSchemes = [type objectForKey:@"CFBundleURLSchemes"];
        for (id scheme in urlSchemes) {
            if([scheme isKindOfClass:[NSString class]]) {
                NSString* value = (NSString*)scheme;
                if ([value hasPrefix:@"tencent"] && (nil == tencentOAuth)) {
                    appId = [value substringFromIndex:7];
                    tencentOAuth = [[TencentOAuth alloc] initWithAppId: appId andDelegate: self];
                    break;
                }
            }
        }
    }
}
- (void)shareObjectWithData:(NSDictionary *)shareData Type:(QQShareType)type Scene:(QQShareScene) scene{
    switch (type) {
        case TextMessage: {
            QQApiTextObject* txtObj = [QQApiTextObject objectWithText:@"Test Text"];
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txtObj];
            [QQApiInterface sendReq:req];
        }
            break;
        case ImageMesssage:{
            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"img.jpg"];
            NSData* data = [NSData dataWithContentsOfFile:path];
            QQApiImageObject* imgObj = [QQApiImageObject objectWithData:data previewImageData:data title:@"" description:@""];
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:imgObj];
            [QQApiInterface sendReq:req];
        }
            break;
        case NewsMessageWithLocalImage:{
            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"news.jpg"];
            NSData* data = [NSData dataWithContentsOfFile:path];
            NSURL* url = [NSURL URLWithString:@""];
            
            QQApiNewsObject* newsObj = [QQApiNewsObject objectWithURL:url title:@"" description:@"" previewImageData:data];
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:newsObj];
            [QQApiInterface sendReq:req];
        }
            break;
        case NewsMessageWithNetworkImage:{
            NSURL *previewURL = [NSURL URLWithString:@"http://img1.gtimg.com/sports/pics/hv1/87/16/1037/67435092.jpg"];
            NSURL* url = [NSURL URLWithString:@""];
            QQApiNewsObject* newsObj = [QQApiNewsObject objectWithURL:url title:@"" description:@"" previewImageURL:previewURL];
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:newsObj];
            [QQApiInterface sendReq:req];
        }
            break;
        case AudioMessage:{
            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"audio.jpg"];
            NSData* data = [NSData dataWithContentsOfFile:path];
            NSURL* url = [NSURL URLWithString:@""];
            QQApiAudioObject* audioObj = [QQApiAudioObject objectWithURL:url title:@"" description:@"" previewImageData:data];
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:audioObj];
            [QQApiInterface sendReq:req];
        }
            break;
        case VideoMessage: {
            
        }
            break;
        default:
            break;
    }
}
- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}


RCT_EXPORT_METHOD(checkClientInstalled
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    if ([TencentOAuth iphoneQQInstalled] && [TencentOAuth iphoneQQSupportSSOLogin]) {
        resolve(@YES);
    } else {
        reject(QQ_NOT_INSTALLED, QQ_NOT_INSTALLED, nil);
    }
}

RCT_EXPORT_METHOD(ssoLogin
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    if(nil == tencentOAuth) {
        [self initTencentOAuth];
    }
    if ([tencentOAuth isSessionValid]) {
        NSDictionary *result = @{@"userid" : tencentOAuth.openId,
                                 @"access_token" : tencentOAuth.accessToken,
                                 @"expires_time" : [NSString stringWithFormat:@"%f",[tencentOAuth.expirationDate timeIntervalSince1970] * 1000]};
        resolve(result);
    } else {
        loginResolve = resolve;
        loginReject = reject;
        NSArray *permissions = [NSArray arrayWithObjects:
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

        [tencentOAuth authorize: permissions];
    
    }
}

RCT_EXPORT_METHOD(logout
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    logoutResolve = resolve;
    logoutReject = reject;
    [tencentOAuth logout: self];
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
    if (tencentOAuth.accessToken && 0 != [tencentOAuth.accessToken length] && loginResolve) {
        NSDictionary *result = @{@"userid" : tencentOAuth.openId,
                                 @"access_token" : tencentOAuth.accessToken,
                                 @"expires_time" : [NSString stringWithFormat:@"%f",[tencentOAuth.expirationDate timeIntervalSince1970] * 1000]};
        loginResolve(result);
        loginReject = nil;
    } else {
        if(loginReject) {
            loginReject(QQ_LOGIN_ERROR,QQ_LOGIN_ERROR,nil);
            loginResolve = nil;
            logoutReject = nil;
        }
    }
}

- (void)tencentDidLogout {
    if (logoutResolve) {
        logoutResolve(@YES);
        logoutReject = nil;
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled && loginReject) {
        loginReject(QQ_LOGIN_CANCEL,QQ_LOGIN_CANCEL,nil);
        loginResolve = nil;
        loginReject = nil;
    }
}

- (void)tencentDidNotNetWork {
    NSLog(@"发生网络问题");
    if (loginReject) {
        loginReject(QQ_LOGIN_NETWORK_ERROR,QQ_LOGIN_NETWORK_ERROR,nil);
        loginResolve = nil;
        loginReject = nil;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    loginResolve = nil;
    loginReject = nil;
    logoutResolve = nil;
    logoutReject = nil;
}

@end
