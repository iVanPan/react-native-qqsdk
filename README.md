# react-native-qqsdk
[![version](https://img.shields.io/badge/version-0.6.0-blue.svg?style=flat)](https://github.com/iVanPan/react-native-qqsdk)
[![platform](https://img.shields.io/badge/platform-iOS%2FAndroid-lightgrey.svg?style=flat)](https://github.com/iVanPan/react-native-qqsdk)
[![GitHub license](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat)](https://github.com/iVanPan/react-native-qqsdk/blob/master/LICENSE)
[![Contact](https://img.shields.io/badge/contact-Van-green.svg?style=flat)](http://VanPan.me)	
A React Native wrapper around the Tencent QQ SDK for Android and iOS. Provides access to QQ ssoLogin, QQ Sharing, QQ Zone Sharing etc.
## Table of Contents

- [Feature](#feature)
- [Installation](#installation)
  - [RNPM](#rnmp)
  - [Manual](#manual)
  	- [iOS Setup](#ios-setup)
  	- [Android Setup](#android-setup)
- [Documentation](#documentation)
  - [Support API](#support-api)



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

7. Under the "Build Settings" tab of your project configuration, find the "Header Search Paths" section and edit the value.
Add a new value, `$(SRCROOT)/../node_modules/react-native-qqsdk/ios/RCTQQSDK` and select "recursive" in the dropdown.

8. Under the "Info" tab of your project configuration, find the "URL Types" section and add your app Id.

9. Under the "Info" tab of your project configuration, add LSApplicationQueriesSchemes For QQ SDK.
	![Add LSApplicationQueriesSchemes](https://github.com/iVanPan/react-native-qqsdk/blob/master/asset/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202016-12-13%2013.47.15.png)
10. add following code to your AppDelegate.m 
```objectiv-c
...
#import "RCTLinkingManager.h"

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

|      Platform      |             iOS                   |            Android                 |
|      ShareScene    |   QQ   |   QQZone  | QQ Favorite  |    QQ   |   QQZone  | QQ Favorite  |
|--------------------|-----------------------------------|------------------------------------|
|      Text 	     |    √   |     √     |      √       |    ✕    |     √     |      √       |
|      Image         |    √   |     √     |      √       |    √    |     √     |      √       |
|      News 	     |    √   |     √     |      √       |    √    |     √     |      √       |
|      Audio         |    √   |     √     |      √       |    √    |     √     |      √       |
