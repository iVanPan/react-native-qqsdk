# react-native-qqsdk
[![npm version](https://badge.fury.io/js/react-native-qqsdk.svg?style=flat)](https://badge.fury.io/js/react-native-qqsdk)
[![platform](https://img.shields.io/badge/platform-iOS%2FAndroid-lightgrey.svg?style=flat)](https://github.com/iVanPan/react-native-qqsdk)
[![GitHub license](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat)](https://github.com/iVanPan/react-native-qqsdk/blob/master/LICENSE)
[![Contact](https://img.shields.io/badge/contact-Van-green.svg?style=flat)](http://VanPan.me)                  


A React Native wrapper around the Tencent QQ SDK for Android and iOS. Provides access to QQ ssoLogin, QQ Sharing, QQ Zone Sharing etc.


## Table of Contents

- [Feature](#feature)
- [Installation](#installation)
  - [RNPM](#rnpm)
  - [Manual](#manual)
    - [iOS Setup](#ios-setup)
    - [Android Setup](#android-setup)
- [Documentation](#documentation)     
  - [Support API](#support-api)
  - [Error Code](#error-code)
  - [Image](#image)  
  - [Usage](#usage)
    - [checkClientInstalled](#checkclientinstalled)
    - [ssoLogin](#ssologin)
    - [logout](#logout)
    - [shareText](#sharetext)
    - [shareImage](#shareimage)
    - [shareNews](#sharenews)
    - [shareAudio](#shareaudio)
    - [getUserInfo](#getuserinfo)
- [About SDK](#about-sdk) 
- [Contributing](#contributing) 
- [License](#license) 

  

## Feature
1. QQ SSO Login
2. QQ Logout 
3. QQ Share 
4. QZone Share
5. QQ Favorites
6. checkClientInstalled   

##Installation
```shell
npm install --save react-native-qqsdk@latest
```
###RNPM
```
 react-native link react-native-qqsdk
```
###Manual
```shell
npm install --save react-native-qqsdk@latest
```
####iOS Setup

1. Open your app's Xcode project

2. Find the `RCTQQSDK.xcodeproj` file within the `node_modules/react-native-qqsdk/ios` directory  and drag it into the `Libraries` node in Xcode

3. Select the project node in Xcode and select the "Build Phases" tab of your project configuration.

4. Drag `libRCTQQSDK.a` from `Libraries/RCTQQSDK.xcodeproj/Products` into the "Link Binary With Libraries" section of your project's "Build Phases" configuration.

5. Click the plus sign underneath the "Link Binary With Libraries" list and add the `libz.tbd,libiconv.tdb,libstdc++.tbd,libsqlite3.tbd,Security.framework,SystemConfiguration.framework,CoreTelephony.framework,CoreGraphics.framework` library .

6. Click the plus sign underneath the "Link Binary With Libraries" list and add the TencentOpenAPI.framework which locate in `../node_modules/react-native-qqsdk/ios/RCTQQSDK`. Then Under the "Build Settings" tab of your project configuration, find the "Framework Search Paths" section and edit the value. Add a new value, `$(SRCROOT)/../node_modules/react-native-qqsdk/ios/RCTQQSDK`.

7. Under the "Info" tab of your project configuration, find the "URL Types" section and add your app Id.

8. Under the "Info" tab of your project configuration, add LSApplicationQueriesSchemes For QQ SDK.
  ![Add LSApplicationQueriesSchemes](https://github.com/iVanPan/react-native-qqsdk/blob/master/asset/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202016-12-13%2013.47.15.png)
9. add following code to your AppDelegate.m 
```objectiv-c
...
#import <React/RCTLinkingManager.h>

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
  return [RCTLinkingManager application:application openURL:url
                      sourceApplication:sourceApplication annotation:annotation];
}
```

####Android Setup

1. In your `android/settings.gradle` file, make the following additions:

    ```gradle
    include ':app', ':react-native-qqsdk'
    project(':react-native-qqsdk').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-qqsdk/android')
    ```

2. In your `android/app/build.gradle` file, add the `:react-native-qqsdk` project as a compile-time dependency:

    ```gradle
    ...
    dependencies {
        ...
        compile project(':react-native-qqsdk')
    }
    ```
3. add App ID to `android/app/build.gradle` which locate in react-native-qqsdk node_modules folder

    ```gradle
    ...
  manifestPlaceholders = [
           QQ_APP_ID: ${QQ_APP_ID}, //在此替换你的APPKey
    ]
    ```
4.Update the `MainApplication.java` file to use react-native-qqsdk via the following changes:

```java
...
// 1. Import the plugin class.
import me.vanpan.rctqqsdk.QQSDKPackage;

public class MainApplication extends Application implements ReactApplication {

    private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
        ...

        @Override
        protected List<ReactPackage> getPackages() {
            return Arrays.<ReactPackage>asList(
                new MainReactPackage(),
                new QQSDKPackage()
            );
        }
    };
}
```
##Documentation

###Support API
1. ssoLogin
2. Logout
3. checkClientInstalled
4. Share(see form below)

|      Platform      |   iOS  |   iOS     |     iOS      | Android |  Android  |    Android   |
|        :---:       | :---:  |   :---:   |    :---:     |   :---: |    :---:  |     :---:    |
|      ShareScene    |   QQ   |   QQZone  |  QQ Favorite |    QQ   |   QQZone  |  QQ Favorite |
|      Text        |    √   |     √     |      √       |    ✕    |     √     |      √       |
|      Image         |    √   |     √     |      √       |    √    |     √     |      √       |
|      News        |    √   |     √     |      √       |    √    |     √     |      √       |
|      Audio         |    √   |     √     |      √       |    √    |     √     |      √       |



###Error Code

| code        |                        explanation                                   |
|-------------|----------------------------------------------------------------------|
|      404    |                        QQ client not found                           |
|      405    |                        Android Activity not found                    |
|      500    |             QQ share (QQSDKPackage,QQZone QQ Favorite) error         |
|      503    |             QQ share (QQSDKPackage,QQZone QQ Favorite) cancelled     |
|      600    |                        QQ ssoLogin error                             |
|      603    |                        ssoLogin cancelled                            |

###Image
 This plugin support three Image types:
  1. Network URL
  2. Base64
  3. Absolute file path
 also support resolveAssetSource,for example, resolveAssetSource(require('./news.jpg')).uri           
 
###Usage
#####checkClientInstalled
  ```js
import * as QQ from "react-native-qqsdk";
QQ.isQQClientInstalled()
  .then(()=>{console.log('Installed')})
  .catch(()=>{console.log('not installed')});

  ```
#####ssoLogin
  ```js
import * as QQ from "react-native-qqsdk";
QQ.ssoLogin()
  .then((result)=>{'result is', result})
  .catch((error)=>{console.log('error is', error)});

  ```
#####logout
  ```js
import * as QQ from "react-native-qqsdk";
QQ.logout()
  .then((result)=>{'result is', result})
  .catch((error)=>{console.log('error is', error)});

  ```
#####shareText
  ```js
import * as QQ from "react-native-qqsdk";
QQ.shareText("分享文字",QQ.shareScene.QQ)
  .then((result)=>{console.log('result is', result)})
  .catch((error)=>{console.log('error is', error)});

  ```
#####shareImage
  ```js
import * as QQ from "react-native-qqsdk";
const imgUrl = "https://y.gtimg.cn/music/photo_new/T001R300x300M000003Nz2So3XXYek.jpg";
QQ.shareImage(imgUrl,'分享标题','分享描述',QQ.shareScene.QQ)
  .then((result)=>{console.log('result is', result)})
  .catch((error)=>{console.log('error is', error)});

  ```
#####shareNews
  ```js
import * as QQ from "react-native-qqsdk";
import resolveAssetSource from 'resolveAssetSource';
QQ.shareNews('https://facebook.github.io/react-native/',resolveAssetSource(require('./news.jpg')).uri,'分享新闻标题','分享新闻描述',QQ.shareScene.QQ)
.then((result)=>{console.log('result is', result)})
.catch((error)=>{console.log('error is', error)});

  ```
#####shareAudio
  ```js
import * as QQ from "react-native-qqsdk";
const audioPreviewUrl = "https://y.qq.com/portal/song/001OyHbk2MSIi4.html";
const audioUrl = "http://stream20.qqmusic.qq.com/30577158.mp3";
const imgUrl = "https://y.gtimg.cn/music/photo_new/T001R300x300M000003Nz2So3XXYek.jpg";
QQ.shareAudio(audioPreviewUrl,audioUrl,imgUrl,'十年','陈奕迅',QQ.shareScene.QQ)
.then((result)=>{console.log('result is', result)})
.catch((error)=>{console.log('error is', error)});

  ```

#####getUserInfo
```js
var url = "https://graph.qq.com/user/get_user_info?access_token=" + accessToken + "&oauth_consumer_key= APPID &openid=" + userId;
http.get(url)
```


## About SDK 
This plugin use 3.1.3 version sdk for Android,3.1.3 version sdk for iOS. You can download lastest version sdk [here](http://wiki.open.qq.com/wiki/mobile/SDK%E4%B8%8B%E8%BD%BD)                        

## Contributing
Feel free to contribute
                
## License

**react-native-qqsdk** is released under the **MIT** license. See [LICENSE](https://github.com/iVanPan/react-native-qqsdk/blob/master/LICENSE) file for more information.

