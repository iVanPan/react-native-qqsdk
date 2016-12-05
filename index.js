'use strict'
import {
  NativeModules, 
  NativeEventEmitter
} from 'react-native';

const {QQSDK} =  NativeModules;
export const isQQClientInstalled = QQSDK.checkClientInstalled;
export const ssoLogin = QQSDK.ssoLogin;
export const logout = QQSDK.logout;

