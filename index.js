'use strict'
import {
  NativeModules, 
  NativeEventEmitter
} from 'react-native';

const {QQSDK} =  NativeModules;
export const isQQClientInstalled = QQSDK.checkClientInstalled;
export const ssoLogin = QQSDK.ssoLogin;
export const logout = QQSDK.logout;
export const shareType = {'TextMessage': QQSDK.TextMessage,'ImageMesssage': QQSDK.ImageMesssage, 'NewsMessageWithNetworkImage': QQSDK.NewsMessageWithNetworkImage,'NewsMessageWithLocalImage': QQSDK.NewsMessageWithLocalImage,'AudioMessage': QQSDK.AudioMessage};
export const shareScene = {'QQ': QQSDK.QQ, 'QQZONE': QQSDK.QQZONE, 'Favrites', QQSDK.Favrites, 'DataLine': QQSDK.DataLine};
