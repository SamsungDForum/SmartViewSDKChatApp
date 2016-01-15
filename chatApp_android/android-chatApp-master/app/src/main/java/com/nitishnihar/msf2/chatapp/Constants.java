package com.nitishnihar.msf2.chatapp;

import android.net.Uri;

/**
 * Created by abhinaw.t on 09-06-2015.
 */
public class Constants {

    static final String CORRUPT_IMAGE_TEXT = "Corrupt image";
    static final String MISSING_IMAGE_TEXT = "Missing image";
    static final String DRAWABLE_SCHEME = "drawable";

    static Uri drawableUri = new Uri.Builder().scheme(Constants.DRAWABLE_SCHEME).authority(String.valueOf(R.drawable.ic_launcher)).build();

    static final String FIRST_POS = "firstPos";
    static final String CONNECTING_MSG = "Connecting...";
    static final String CONNECTED_PREFIX = "Connected to ";
    static final String DISCONNECTED_MSG = "Not connected";
}
