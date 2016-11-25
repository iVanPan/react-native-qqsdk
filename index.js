'use strict'

const { NativeModules, NativeEventEmitter } = require('react-native');

export const isQQClientInstalled = NativeModules.RCTQQSDK.checkClientInstalled;

const qqsdk = new NativeEventEmitter(NativeModules.RCTQQSDK);
qqsdk.addListener('LoginResponse', (data) => console.log(data));
qqsdk.addListener('ShareResponse', (data) => console.log(data));
qqsdk.addListener('LoginOutResponse', (data) => console.log(data));
