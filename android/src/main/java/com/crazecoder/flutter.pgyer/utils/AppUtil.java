package com.crazecoder.flutter.pgyer.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.preference.PreferenceManager;

import com.crazecoder.flutter.pgyer.BuildConfig;
import com.pgyersdk.update.javabean.AppBean;

import org.json.JSONObject;

import java.util.Map;


public class AppUtil {
    private static SharedPreferences sp;
    private static final String SP_KEY = "appBean";

    public static int getAppVersionCode(Context context) {
        try {
            PackageManager pm = context.getPackageManager();
            PackageInfo pi = pm.getPackageInfo(context.getPackageName(), 0);
            return pi.versionCode;
        } catch (Exception e) {
            if (BuildConfig.DEBUG)
                e.printStackTrace();
            return -1;
        }
    }

    public static void saveAppBean(Context context, AppBean appBean) {
        if (sp == null)
            sp = PreferenceManager.getDefaultSharedPreferences(context.getApplicationContext());
        SharedPreferences.Editor editor = sp.edit();
        editor.putString(SP_KEY, JsonUtil.toJson(appBean));
        editor.apply();
    }

    public static String getAppBeanJson(Context context) {
        if (sp == null)
            sp = PreferenceManager.getDefaultSharedPreferences(context.getApplicationContext());
        return sp.getString(SP_KEY,"");
    }
}
