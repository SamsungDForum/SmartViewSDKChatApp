package com.nitishnihar.msf2.chatapp;

import android.app.Application;
import android.os.Looper;
import android.util.Log;
import com.samsung.multiscreen.Service;
import com.samsung.multiscreen.util.RunUtil;

/**
 * @file 		App.java
 * @author		Nitish Nihar Dora/Abhinaw Tripathi
 * @author_id 	n.dora@samsung.com
 * @date		24 April, 2015
 * @modified date 09-06-2015
 *
 * Copyright 2014 Samsung Electronics Co., Ltd. All rights reserved.
 * This software is the confidential and proprietary information
 * of Samsung Electronics, Inc. ("Confidential Information").  You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Samsung.
 */

public class App extends Application
{

    public static final String TAG = "ANKIT-CHATAPP";

    private static App instance;
    private static Config config;
    //private PhotoShareWebApplicationHelper photoShare;
    /**
     * The device to connect to;
     */
    public Service service = null;

    public static App getInstance() {
        return instance;
    }

    public App()
    {
        instance = this;
    }

    ///////////////////////////////////added for the Image to load @Author Abhinaw////////////////
    @Override
    public void onCreate()
    {
        super.onCreate();
        RunUtil.runInBackground(new Runnable() {

            @Override
            public void run() {
                long startTime = System.nanoTime();
                Looper.prepare();
                ImageInfoUtils.getImageInfos(getApplicationContext());
                long endTime = System.nanoTime();
                Log.d(TAG, "getImageInfos execution in " + ((float) (endTime - startTime) / 1000000f) + " ms");
            }
        });

        config = Config.newInstance(this);

      //  photoShare = PhotoShareWebApplicationHelper.getInstance(this);

    }

  /*  public PhotoShareWebApplicationHelper getPhotoShare() {
        return photoShare;
    }*/
    public Config getConfig() {
        return config;
    }

    public static String str_deviceName;
    public static String str_userImagePath;
    public static String str_userName;
}