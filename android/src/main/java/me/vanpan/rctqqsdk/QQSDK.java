package me.vanpan.rctqqsdk;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.text.TextUtils;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.tencent.connect.common.Constants;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;

import org.json.JSONObject;

public class QQSDK extends ReactContextBaseJavaModule {

    private static Tencent mTencent;
    private String APP_ID;
    private Promise mPromise;
    private static final String ACTIVITY_DOES_NOT_EXIST = "ACTIVITY_DOES_NOT_EXIST";
    private static final String QQ_Client_NOT_INSYALLED_ERROR = "QQ client is not installed";
    private static final String QQ_RESPONSE_ERROR = "QQ response is error";
    private static final String QQ_CANCEL_BY_USER = "cancelled by user";
    private static final String QZONE_SHARE_CANCEL = "QZone share is cancelled";
    private static final String QQFAVORITES_CANCEL = "QQ Favorites is cancelled";


    private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {

        @Override
        public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent intent) {
            mTencent.onActivityResultData(requestCode,resultCode,intent,loginListener);
            if (requestCode == Constants.REQUEST_API) {
                if (resultCode == Constants.REQUEST_LOGIN) {
                    Tencent.handleResultData(intent, loginListener);
                }
            }
            if (requestCode == Constants.REQUEST_QQ_SHARE) {
                if (resultCode == Constants.ACTIVITY_OK) {
                    Tencent.handleResultData(intent, qqShareListener);
                }
            }
            if (requestCode == Constants.REQUEST_QZONE_SHARE) {
                if (resultCode == Constants.ACTIVITY_OK) {
                    Tencent.handleResultData(intent, qZoneShareListener);
                }
            }
            super.onActivityResult(activity, requestCode, resultCode, intent);
        }
    };

    public QQSDK(ReactApplicationContext reactContext) {
        super(reactContext);
        reactContext.addActivityEventListener(mActivityEventListener);
        APP_ID = this.getAppID(reactContext);
        if (null == mTencent) {
            mTencent = Tencent.createInstance(APP_ID, reactContext);
        }
    }

    @Override
    public void initialize() {
        super.initialize();
    }

    @Override
    public String getName() {
        return "QQSDK";
    }

    @Override
    public void onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy();
        if (mTencent != null) {
            mTencent.releaseResource();
            mTencent = null;
        }
        APP_ID = null;
        mPromise = null;
    }

    @ReactMethod
    public void checkClientInstalled(final Promise promise) {
        Activity currentActivity = getCurrentActivity();
        if (null == currentActivity) {
            promise.reject("405",ACTIVITY_DOES_NOT_EXIST);
            return;
        }
        Boolean installed = mTencent.isSupportSSOLogin(currentActivity);
        if (installed) {
            promise.resolve(true);
        } else {
            promise.reject("404", QQ_Client_NOT_INSYALLED_ERROR);
        }
    }

    @ReactMethod
    public void logout(Promise promise) {
        Activity currentActivity = getCurrentActivity();
        if (null == currentActivity) {
            promise.reject("405",ACTIVITY_DOES_NOT_EXIST);
            return;
        }
        mTencent.logout(currentActivity);
        promise.resolve(true);
    }

    @ReactMethod
    public void ssoLogin(final Promise promise) {
        if (mTencent.isSessionValid()) {
            WritableMap map = Arguments.createMap();
            map.putString("userid", mTencent.getOpenId());
            map.putString("access_token", mTencent.getAccessToken());
            map.putDouble("expires_time", mTencent.getExpiresIn());
            promise.resolve(map);
        } else {
            final Activity currentActivity = getCurrentActivity();
            if (null == currentActivity) {
                promise.reject("405",ACTIVITY_DOES_NOT_EXIST);
                return;
            }
            Runnable runnable = new Runnable() {

                @Override
                public void run() {
                    mPromise = promise;
                    mTencent.login(currentActivity, "all",
                            loginListener);
                }
            };
            UiThreadUtil.runOnUiThread(runnable);
        }
    }

    /**
     * 获取Tencent SDK App ID
     * @param reactContext
     * @return
     */
    private String getAppID(ReactApplicationContext reactContext) {
        try {
            ApplicationInfo appInfo = reactContext.getPackageManager()
                    .getApplicationInfo(reactContext.getPackageName(),
                            PackageManager.GET_META_DATA);
            String key = appInfo.metaData.get("QQ_APP_ID").toString();
            return key;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 保存token 和 openid
     *
     * @param jsonObject
     */
    public static void initOpenidAndToken(JSONObject jsonObject) {
        try {
            String token = jsonObject.getString(Constants.PARAM_ACCESS_TOKEN);
            String expires = jsonObject.getString(Constants.PARAM_EXPIRES_IN);
            String openId = jsonObject.getString(Constants.PARAM_OPEN_ID);
            if (!TextUtils.isEmpty(token) && !TextUtils.isEmpty(expires)
                    && !TextUtils.isEmpty(openId)) {
                mTencent.setAccessToken(token, expires);
                mTencent.setOpenId(openId);
            }
        } catch (Exception e) {
        }
    }

    /**
     * 登录监听
     */
    IUiListener loginListener = new IUiListener() {
        @Override
        public void onComplete(Object response) {
            if (null == response) {
                mPromise.reject("403",QQ_RESPONSE_ERROR);
                return;
            }
            JSONObject jsonResponse = (JSONObject) response;
            if (null != jsonResponse && jsonResponse.length() == 0) {
                mPromise.reject("403",QQ_RESPONSE_ERROR);
                return;
            }
            initOpenidAndToken(jsonResponse);
            WritableMap map = Arguments.createMap();
            map.putString("userid", mTencent.getOpenId());
            map.putString("access_token", mTencent.getAccessToken());
            map.putDouble("expires_time", mTencent.getExpiresIn());
            mPromise.resolve(map);

        }

        @Override
        public void onError(UiError e) {
            String msg = String.format("[%1$d]%2$s: %3$s", e.errorCode, e.errorMessage, e.errorDetail);
            mPromise.reject("500",msg);
        }

        @Override
        public void onCancel() {
            mPromise.reject("500",QQ_CANCEL_BY_USER);
        }
    };

    /**
     * QQ分享监听
     */
    IUiListener qqShareListener = new IUiListener() {
        @Override
        public void onCancel() {
            mPromise.reject("500",QQ_CANCEL_BY_USER);
        }

        @Override
        public void onComplete(Object response) {
            mPromise.resolve(true);
        }

        @Override
        public void onError(UiError e) {
            String msg = String.format("[%1$d]%2$s: %3$s", e.errorCode, e.errorMessage, e.errorDetail);
            mPromise.reject("500",msg);
        }

    };
    /**
     * QQZONE 分享监听
     */
    IUiListener qZoneShareListener = new IUiListener() {

        @Override
        public void onCancel() {
            mPromise.reject("500",QZONE_SHARE_CANCEL);
        }

        @Override
        public void onError(UiError e) {
            String msg = String.format("[%1$d]%2$s: %3$s", e.errorCode, e.errorMessage, e.errorDetail);
            mPromise.reject("500",msg);
        }

        @Override
        public void onComplete(Object response) {
            mPromise.resolve(true);
        }

    };
    /**
     * 添加到QQ收藏监听
     */
    IUiListener addToQQFavoritesListener = new IUiListener() {
        @Override
        public void onCancel() {
            mPromise.reject("500",QQFAVORITES_CANCEL);
        }

        @Override
        public void onComplete(Object response) {
            mPromise.resolve(true);
        }

        @Override
        public void onError(UiError e) {
            String msg = String.format("[%1$d]%2$s: %3$s", e.errorCode, e.errorMessage, e.errorDetail);
            mPromise.reject("500",msg);
        }
    };
}
