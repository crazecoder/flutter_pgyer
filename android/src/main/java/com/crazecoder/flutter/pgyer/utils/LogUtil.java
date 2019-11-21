package com.crazecoder.flutter.pgyer.utils;

import android.util.Log;

import com.crazecoder.flutter.pgyer.BuildConfig;


/**
 * Note of this class.
 *
 * @author chendong
 * @since 2018/3/20
 */
public class LogUtil {
    public static void v(String tag, String msg) {
        if (BuildConfig.DEBUG)
            Log.v(tag, msg);
    }

    public static void v(String tag, String msg, Throwable t) {
        if (BuildConfig.DEBUG)
            Log.v(tag, msg, t);
    }

    public static void d(String tag, String msg) {
        if (BuildConfig.DEBUG)
            Log.d(tag, msg);
    }

    public static void d(String tag, String msg, Throwable t) {
        if (BuildConfig.DEBUG)
            Log.d(tag, msg, t);
    }

    public static void i(String tag, String msg) {
        if (BuildConfig.DEBUG)
            Log.i(tag, msg);
    }

    public static void i(String tag, String msg, Throwable t) {
        if (BuildConfig.DEBUG)
            Log.i(tag, msg, t);
    }

    public static void w(String tag, String msg) {
        if (BuildConfig.DEBUG)
            Log.w(tag, msg);
    }

    public static void w(String tag, String msg, Throwable t) {
        if (BuildConfig.DEBUG)
            Log.w(tag, msg, t);
    }

    public static void e(String tag, String msg) {
        if (BuildConfig.DEBUG)
            Log.e(tag, msg);
    }

    public static void e(String tag, String msg, Throwable t) {
        if (BuildConfig.DEBUG)
            Log.e(tag, msg, t);
    }

}
