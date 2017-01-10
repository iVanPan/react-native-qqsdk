'use strict'
import {
  NativeModules, 
  NativeEventEmitter
} from 'react-native';

const {QQSDK} =  NativeModules;
export const isQQClientInstalled = QQSDK.checkClientInstalled;
export const ssoLogin = QQSDK.ssoLogin;
export const logout = QQSDK.logout;
export const shareScene = {'QQ': QQSDK.QQ, 'QQZone': QQSDK.QQZone, 'Favorite': QQSDK.Favorite};

export function shareText(text,shareScene) {
	return QQSDK.shareText(text,shareScene);
}
export function shareImage(image,title,description,shareScene) {
	return QQSDK.shareImage(image,title,description,shareScene)
}
export function shareNews(url,image,title,description,shareScene) {
	return QQSDK.shareNews(url,image,title,description,shareScene);
}
export function shareAudio(url,flashUrl,image,title,description,shareScene) {
	return QQSDK.shareAudio(url,flashUrl,image,title,description,shareScene);
}
// export function shareVideo(url,flashUrl,image,title,description,shareScene) {
// 	return QQSDK.shareVideo(url,flashUrl,image,title,description,shareScene);
// }
