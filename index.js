'use strict'
import {
  NativeModules, 
  NativeEventEmitter
} from 'react-native';

const {QQSDK} =  NativeModules;
export const isQQClientInstalled = QQSDK.checkClientInstalled;
export const ssoLogin = QQSDK.ssoLogin;
export const logout = QQSDK.logout;
export const imageType = {'Local': QQSDK.Local,'Base64': QQSDK.Base64, 'Network': QQSDK.Network};
export const shareScene = {'QQ': QQSDK.QQ, 'QQZone': QQSDK.QQZone, 'Favorite': QQSDK.Favorite};

export function shareText(text,shareScene) {
	return QQSDK.shareText(text,shareScene);
}
export function shareImage(image,imageType,title,description,shareScene) {
	return QQSDK.shareImage(image,imageType,title,description,shareScene)
}
export function shareNews(url,image,imageType,title,description,shareScene) {
	return QQSDK.shareNews(url,image,imageType,title,description,shareScene);
}
export function shareAudio(url,flashUrl,image,imageType,title,description,shareScene) {
	return QQSDK.shareAudio(url,flashUrl,image,imageType,title,description,shareScene);
}

export function shareVideo(url,flashUrl,image,imageType,title,description,shareScene) {
	return QQSDK.shareVideo(url,flashUrl,image,imageType,title,description,shareScene);
}
