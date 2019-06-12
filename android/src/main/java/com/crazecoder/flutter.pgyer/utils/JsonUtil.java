package com.crazecoder.flutter.pgyer.utils;

import com.crazecoder.flutter.pgyer.BuildConfig;
import com.pgyersdk.update.javabean.AppBean;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

/**
 * Note of this class.
 *
 * @author crazecoder
 * @since 2018/12/28
 */
public class JsonUtil {
    public static String toJson(Map<String, Object> map) {
        JSONObject jsonObject = new JSONObject();
        try {
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                jsonObject.put(entry.getKey(), entry.getValue());
            }
        } catch (JSONException e) {
            if (BuildConfig.DEBUG)
                e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String toJson(AppBean appBean) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("versionName", appBean.getVersionName());
            jsonObject.put("downloadURL", appBean.getDownloadURL());
            jsonObject.put("versionCode", appBean.getVersionCode());
            jsonObject.put("releaseNote", appBean.getReleaseNote());
            jsonObject.put("shouldForceToUpdate", appBean.isShouldForceToUpdate());
        } catch (JSONException e) {
            if (BuildConfig.DEBUG)
                e.printStackTrace();
        }
        return jsonObject.toString();
    }
}
