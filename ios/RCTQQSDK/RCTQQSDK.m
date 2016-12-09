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

@implementation RCTQQSDK {
    TencentOAuth *tencentOAuth;
    RCTPromiseResolveBlock loginResolve;
    RCTPromiseRejectBlock loginReject;
    RCTPromiseResolveBlock logoutResolve;
    RCTPromiseRejectBlock logoutReject;
    RCTPromiseResolveBlock shareResolve;
    RCTPromiseRejectBlock shareReject;
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

- (NSArray<NSString *> *)supportedEvents {
    return @[];
}
- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport {
    return @{@"Local": @(Local),
             @"Base64": @(Base64),
             @"Network": @(Network),
             @"QQ": @(QQ),
             @"QQZone": @(QQZone),
             @"Favorite": @(Favorite),
             };
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
        NSDictionary *result = [self makeResultWithUserId:tencentOAuth.openId
                                              accessToken:tencentOAuth.accessToken
                                           expirationDate:tencentOAuth.expirationDate];
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
//必填，最长1536个字符
RCT_EXPORT_METHOD(shareText:(NSString *)text
                  shareScene:(QQShareScene)scene
                  :(RCTPromiseResolveBlock)resolve
                  :(RCTPromiseRejectBlock)reject) {
    shareReject = reject;
    shareResolve = resolve;
    [self shareObjectWithData:@{@"text":text} Type:TextMessage Scene:scene];
}

RCT_EXPORT_METHOD(shareImage:(NSString *)image withImageType:(NSInteger)type
                  title:(NSString *)title
                  description:(NSString *)description
                  shareScene:(QQShareScene)scene
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    shareReject = reject;
    shareResolve = resolve;
    switch (type) {
        case Local: {
            NSData* imageData = [NSData dataWithContentsOfFile:image];
            [self shareObjectWithData:@{@"image":imageData,
                                        @"title":title,
                                        @"description":description}
                                 Type:ImageMesssage
                                Scene:scene];
        }
            break;
        case Network:{
            NSURL* url = [NSURL URLWithString:[image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSData *data = [NSData dataWithContentsOfURL:url];
                [self shareObjectWithData:@{@"image":data,
                                            @"title":title,
                                            @"description":description}
                                     Type:ImageMesssage Scene:scene];
        }
            break;
        case Base64:{
            NSData* imageData = [[NSData alloc] initWithBase64EncodedString:image options:0];
            [self shareObjectWithData:@{@"image":imageData,
                                        @"title":title,
                                        @"description":description}
                                 Type:ImageMesssage Scene:scene];
        }
            break;
    }
}
RCT_EXPORT_METHOD(shareNews:(NSString *)url
                  image:(NSString *)image
                  withImageType:(NSInteger)type
                  title:(NSString *)title
                  description:(NSString *)description
                  shareScene:(QQShareScene)scene
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    shareReject = reject;
    shareResolve = resolve;
    switch (type) {
        case Local: {
            NSData* imageData = [NSData dataWithContentsOfFile:image];
            [self shareObjectWithData:@{@"url":url,
                                        @"image":imageData,
                                        @"title":title,
                                        @"description":description}
                                 Type:NewsMessageWithLocalImage
                                Scene:scene];
        }
            break;
        case Network:
            [self shareObjectWithData:@{@"url":url,
                                        @"image":image,
                                        @"title":title,
                                        @"description":description}
                                 Type:NewsMessageWithNetworkImage
                                Scene:scene];
            break;
        case Base64: {
            NSData* imageData =[[NSData alloc] initWithBase64EncodedString:image options:0];;
            [self shareObjectWithData:@{@"url":url,
                                        @"image":imageData,
                                        @"title":title,
                                        @"description":description}
                                 Type:NewsMessageWithLocalImage
                                Scene:scene];
        }
            break;
    }
}
RCT_EXPORT_METHOD(shareAudio:(NSString *)previewUrl
                  flashUrl:(NSString *)flashUrl
                  image:(NSString *)image
                  withImageType:(NSInteger)type
                  title:(NSString *)title
                  description:(NSString *)description
                  shareScene:(QQShareScene)scene
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    shareReject = reject;
    shareResolve = resolve;
    switch (type) {
        case Local: {
            NSData* imageData = [NSData dataWithContentsOfFile:image];
            NSLog(@"image dat is %@",imageData);
            [self shareObjectWithData:@{@"url":previewUrl,
                                        @"flashUrl":flashUrl,
                                        @"image":imageData,
                                        @"title":title,
                                        @"description":description}
                                 Type:AudioMessage
                                Scene:scene];
        }
            break;
        case Network:{
            NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            [self shareObjectWithData:@{@"url":previewUrl,
                                        @"flashUrl":flashUrl,
                                        @"image":imageData,
                                        @"title":title,
                                        @"description":description}
                                 Type:AudioMessage
                                Scene:scene];
        }
            break;
        case Base64: {
            NSData* imageData =[[NSData alloc] initWithBase64EncodedString:image options:0];;
            [self shareObjectWithData:@{@"url":previewUrl,
                                        @"flashUrl":flashUrl,
                                        @"image":imageData,
                                        @"title":title,
                                        @"description":description}
                                 Type:AudioMessage
                                Scene:scene];
        }
            break;
    }
}

RCT_EXPORT_METHOD(shareVideo:(NSString *)previewUrl
                  flashUrl:(NSString *)flashUrl
                  image:(NSString *)image
                  withImageType:(NSInteger)type
                  title:(NSString *)title
                  description:(NSString *)description
                  shareScene:(QQShareScene)scene
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    shareReject = reject;
    shareResolve = resolve;
    switch (type) {
        case Local: {
            NSData* imageData = [NSData dataWithContentsOfFile:image];
            NSLog(@"image dat is %@",imageData);
            [self shareObjectWithData:@{@"url":previewUrl,
                                        @"flashUrl":flashUrl,
                                        @"image":imageData,
                                        @"title":title,
                                        @"description":description}
                                 Type:VideoMessage
                                Scene:scene];
        }
            break;
        case Network:{
            NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            [self shareObjectWithData:@{@"url":previewUrl,
                                        @"flashUrl":flashUrl,
                                        @"image":imageData,
                                        @"title":title,
                                        @"description":description}
                                 Type:VideoMessage
                                Scene:scene];
        }
            break;
        case Base64: {
            NSData* imageData =[[NSData alloc] initWithBase64EncodedString:image options:0];;
            [self shareObjectWithData:@{@"url":previewUrl,
                                        @"flashUrl":flashUrl,
                                        @"image":imageData,
                                        @"title":title,
                                        @"description":description}
                                 Type:VideoMessage
                                Scene:scene];
        }
            break;
    }
}

-(void)shareTextToQQZone:(NSString *)text {
    QQApiImageArrayForQZoneObject * txtObj = [QQApiImageArrayForQZoneObject objectWithimageDataArray:nil title:text];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txtObj];
    QQApiSendResultCode sent =[QQApiInterface SendReqToQZone:req];
    [self handleSendResult:sent];
}

- (void)shareObjectWithData:(NSDictionary *)shareData Type:(QQShareType)type Scene:(QQShareScene) scene{
    switch (type) {
        case TextMessage: {
            NSString* msg = [shareData objectForKey:@"text"];
            QQApiTextObject* txtObj = [QQApiTextObject objectWithText:msg];
            [txtObj setCflag:kQQAPICtrlFlagQZoneShareOnStart];
            switch (scene) {
                case QQZone:
                    [self shareTextToQQZone:msg];
                    return;
                case Favorite:
                    [txtObj setCflag:kQQAPICtrlFlagQQShareFavorites];
                    break;
                default:
                    [txtObj setCflag:kQQAPICtrlFlagQQShare];
                    break;
            }
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txtObj];
            QQApiSendResultCode sent =[QQApiInterface sendReq:req];
            [self handleSendResult:sent];
        }
            break;
        case ImageMesssage:{
            NSData* data = [shareData objectForKey:@"image"];
            NSString* title = [shareData objectForKey:@"title"];
            NSString* description = [shareData objectForKey:@"description"];
            QQApiImageObject* imgObj = [QQApiImageObject objectWithData:data
                                                       previewImageData:data
                                                                  title:title
                                                            description:description];
            switch (scene) {
                case QQZone:
                    [imgObj setCflag:kQQAPICtrlFlagQZoneShareOnStart];
                    break;
                case Favorite:
                    [imgObj setCflag:kQQAPICtrlFlagQQShareFavorites];
                    break;
                default:
                    [imgObj setCflag:kQQAPICtrlFlagQQShare];
                    break;
            }
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:imgObj];
            QQApiSendResultCode sent =[QQApiInterface sendReq:req];
            [self handleSendResult:sent];
        }
            break;
        case NewsMessageWithLocalImage:{
            NSData* data = [shareData objectForKey:@"image"];
            NSURL* url = [NSURL URLWithString:[[shareData objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSString* title = [shareData objectForKey:@"title"];
            NSString* description = [shareData objectForKey:@"description"];
            QQApiNewsObject* newsObj = [QQApiNewsObject objectWithURL:url
                                                                title:title
                                                          description:description
                                                     previewImageData:data];
            switch (scene) {
                case QQZone:
                    [newsObj setCflag:kQQAPICtrlFlagQZoneShareOnStart];
                    break;
                case Favorite:
                    [newsObj setCflag:kQQAPICtrlFlagQQShareFavorites];
                    break;
                default:
                    [newsObj setCflag:kQQAPICtrlFlagQQShare];
                    break;
            }
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:newsObj];
            QQApiSendResultCode sent =[QQApiInterface sendReq:req];
            [self handleSendResult:sent];
        }
            break;
        case NewsMessageWithNetworkImage:{
            NSURL* previewURL = [NSURL URLWithString:[shareData objectForKey:@"image"]];
            NSURL* url = [NSURL URLWithString:[[shareData objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSString* title = [shareData objectForKey:@"title"];
            NSString* description = [shareData objectForKey:@"description"];
            QQApiNewsObject* newsObj = [QQApiNewsObject objectWithURL:url
                                                                title:title
                                                          description:description
                                                      previewImageURL:previewURL];
            switch (scene) {
                case QQZone:
                    [newsObj setCflag:kQQAPICtrlFlagQZoneShareOnStart];
                    break;
                case Favorite:
                    [newsObj setCflag:kQQAPICtrlFlagQQShareFavorites];
                    break;
                default:
                    [newsObj setCflag:kQQAPICtrlFlagQQShare];
                    break;
            }
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:newsObj];
            QQApiSendResultCode sent =[QQApiInterface sendReq:req];
            [self handleSendResult:sent];
        }
            break;
        case AudioMessage:{
            NSData* data = [shareData objectForKey:@"image"];
            NSURL* url = [NSURL URLWithString:[shareData objectForKey:@"url"]];
            NSString* title = [shareData objectForKey:@"title"];
            NSString* description = [shareData objectForKey:@"description"];
            NSURL* flashUrl = [NSURL URLWithString:[shareData objectForKey:@"url"]];
            QQApiAudioObject* audioObj = [QQApiAudioObject objectWithURL:url
                                                                   title:title
                                                             description:description
                                                        previewImageData:data];
            [audioObj setFlashURL:flashUrl];
            switch (scene) {
                case QQZone:
                    [audioObj setCflag:kQQAPICtrlFlagQZoneShareOnStart];
                    break;
                case Favorite:
                    [audioObj setCflag:kQQAPICtrlFlagQQShareFavorites];
                    break;
                default:
                    [audioObj setCflag:kQQAPICtrlFlagQQShare];
                    break;
            }
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:audioObj];
            QQApiSendResultCode sent =[QQApiInterface sendReq:req];
            [self handleSendResult:sent];
        }
            break;
        case VideoMessage:{
            NSData* data = [shareData objectForKey:@"image"];
            NSURL* url = [NSURL URLWithString:[shareData objectForKey:@"url"]];
            NSString* title = [shareData objectForKey:@"title"];
            NSString* description = [shareData objectForKey:@"description"];
            NSURL* flashUrl = [NSURL URLWithString:[shareData objectForKey:@"url"]];
            QQApiVideoObject* videoObj = [QQApiVideoObject objectWithURL:url
                                                                   title:title
                                                             description:description
                                                        previewImageData:data];
            [videoObj setFlashURL:flashUrl];
            switch (scene) {
                case QQZone:
                    [videoObj setCflag:kQQAPICtrlFlagQZoneShareOnStart];
                    break;
                case Favorite:
                    [videoObj setCflag:kQQAPICtrlFlagQQShareFavorites];
                    break;
                default:
                    [videoObj setCflag:kQQAPICtrlFlagQQShare];
                    break;
            }
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:videoObj];
            QQApiSendResultCode sent =[QQApiInterface sendReq:req];
            [self handleSendResult:sent];
        }
        default:
            break;
    }
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult {
    switch (sendResult) {
        case EQQAPISENDSUCESS:
            break;
        case EQQAPIAPPSHAREASYNC:
            break;
        case EQQAPIAPPNOTREGISTED: {
            NSLog(@"App未注册");
            if(shareReject) {
                shareReject(@"100",@"App未注册",nil);
                shareReject = nil;
                shareResolve = nil;
            }
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID: {
            NSLog(@"发送参数错误");
            if(shareReject) {
                shareReject(@"100",@"发送参数错误",nil);
                shareReject = nil;
                shareResolve = nil;
            }
            break;
        }
        case EQQAPIQQNOTINSTALLED: {
            NSLog(@"没有安装手机QQ");
            if(shareReject) {
                shareReject(@"100",@"没有安装手机QQ",nil);
                shareReject = nil;
                shareResolve = nil;
            }
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI: {
            NSLog(@"API接口不支持");
            if(shareReject) {
                shareReject(@"100",@"API接口不支持",nil);
                shareReject = nil;
                shareResolve = nil;
            }
            break;
        }
        case EQQAPISENDFAILD: {
            NSLog(@"发送失败");
            if(shareReject) {
                shareReject(@"100",@"发送失败",nil);
                shareReject = nil;
                shareResolve = nil;
            }
            break;
        }
        case EQQAPIVERSIONNEEDUPDATE: {
            NSLog(@"当前QQ版本太低");
            if(shareReject) {
                shareReject(@"100",@"当前QQ版本太低",nil);
                shareReject = nil;
                shareResolve = nil;
            }
            break;
        }
        case EQQAPIQZONENOTSUPPORTTEXT:{
            NSLog(@"QQZone不支持QQApiTextObject分享");
            if(shareReject) {
                shareReject(@"100",@"QQZone不支持QQApiTextObject分享",nil);
                shareReject = nil;
                shareResolve = nil;
            }
            break;
        }
        case EQQAPIQZONENOTSUPPORTIMAGE:{
            NSLog(@"QQZone不支持QQApiImageObject分享");
            if(shareReject) {
                shareReject(@"100",@"QQZone不支持QQApiImageObject分享",nil);
                shareReject = nil;
                shareResolve = nil;
            }
            break;
        }
        default: {
            NSLog(@"发生其他错误 is %ld",sendResult);
            if(shareReject) {
                shareReject(@"100",@"发生其他错误",nil);
                shareReject = nil;
                shareResolve = nil;
            }
            break;
        }
    }
}
- (NSDictionary*)makeResultWithUserId:(NSString*)userId
                          accessToken:(NSString*)accessToken
                       expirationDate:(NSDate*)expirationDate{
    NSDictionary *result = @{@"userid" : userId,
                             @"access_token" : accessToken,
                             @"expires_time" : [NSString stringWithFormat:@"%f",[expirationDate timeIntervalSince1970] * 1000]};
    return result;
}
- (void)handleOpenURLNotification:(NSNotification *)notification {
    NSURL *url = [NSURL URLWithString: [notification userInfo][@"url"]];
    NSLog(@"openUrl is %@",url);
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
#pragma mark - QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req {
}

- (void)onResp:(QQBaseResp *)resp {
    switch ([resp.result integerValue]) {
        case 0: {
            if(shareReject){
                shareResolve(@YES);
                shareResolve = nil;
                shareReject = nil;
            }
            break;
        }
        case -4: {
            if(shareReject) {
                shareReject(QQ_SHARE_CANCEL,QQ_SHARE_CANCEL,nil);
                shareResolve = nil;
            }
            break;
        }
        default:{
            if(shareReject) {
                shareReject(QQ_OTHER_ERROR,QQ_OTHER_ERROR,nil);
                shareReject = nil;
                shareResolve = nil;
            }
            break;
        }
    }
}

- (void)isOnlineResponse:(NSDictionary *)response {
}

#pragma mark - TencentSessionDelegate
- (void)tencentDidLogin {
    if (tencentOAuth.accessToken && 0 != [tencentOAuth.accessToken length] && loginResolve) {
        NSDictionary *result = [self makeResultWithUserId:tencentOAuth.openId
                                              accessToken:tencentOAuth.accessToken
                                           expirationDate:tencentOAuth.expirationDate];
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
    shareResolve = nil;
    shareReject = nil;
}

@end
