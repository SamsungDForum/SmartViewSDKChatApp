package com.nitishnihar.msf2.chatapp;

/**
 * Created by abhinaw.t on 10-06-2015.
 */
import android.content.Context;
import android.content.res.Resources;
import android.net.Uri;

public class Config {

    private static Config instance = null;
    private Resources res = null;

    public static Config newInstance(Context context) {
        if (instance == null) {
            return new Config(context);
        }
        return instance;
    }

    private Config(Context context) {
        this.res = (context != null)?context.getResources():null;
    }

    public boolean isDebug()
    {
        return res.getBoolean(R.bool.debug);
    }

    public String getString(int resId) {
        return res.getString(resId);
    }

    public Uri getPhotoShareUri()
    {
        Uri uri = null;
        try {
            if (res != null)
            {
                boolean debug = isDebug();
                String url = res.getString(R.string.photoshare_dev_url);
                if (!debug)
                {
                    url = res.getString(R.string.photoshare_prod_url);
                }
                uri = Uri.parse(url);
            }
        } catch (Exception e) {
        }
        return uri;
    }

    public String getPhotoShareChannel()
    {
        String channelId = getString(R.string.photoshare_channel);
        return channelId;
    }
}
