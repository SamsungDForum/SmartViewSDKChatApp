package com.nitishnihar.msf2.chatapp;

/**
 * Created by abhinaw.t on 09-06-2015.
 */

import java.util.ArrayList;

import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.provider.MediaStore;
import android.support.v4.content.CursorLoader;

public class ImageInfoUtils
{

    public static final Uri sourceUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
    public static final Uri thumbUri = MediaStore.Images.Thumbnails.EXTERNAL_CONTENT_URI;
    public static final String thumb_DATA = MediaStore.Images.Thumbnails.DATA;
    public static final String thumb_IMAGE_ID = MediaStore.Images.Thumbnails.IMAGE_ID;

    public static final String IMAGE_INFOS_KEY = "image_infos_key";

    private static ArrayList<ImageInfo> imageInfos;

    static
    {
        imageInfos = new ArrayList<ImageInfo>();
    }

    public static ArrayList<ImageInfo> getImageInfos(Context context)
    {

        if ((imageInfos != null) && (imageInfos.size() > 0))
        {
            return imageInfos;
        }

        String[] imageColumns = { MediaStore.Images.Media._ID,
                MediaStore.Images.ImageColumns.DATA };
        String[] thumbColumns = { thumb_DATA };

        CursorLoader cursorLoader = new CursorLoader(
                context,
                ImageInfoUtils.sourceUri,
                imageColumns,
                null,
                null,
                MediaStore.Images.Media.DEFAULT_SORT_ORDER);

        Cursor imageCursor = cursorLoader.loadInBackground();

        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;

        while (imageCursor.moveToNext())
        {
            int myID = imageCursor.getInt(imageCursor.getColumnIndex(MediaStore.Images.Media._ID));
            Bitmap myBitmap = MediaStore.Images.Thumbnails.getThumbnail(context.getContentResolver(), myID, MediaStore.Images.Thumbnails.MICRO_KIND, options);
            if (myBitmap != null)
            {
                myBitmap.recycle();
                String imagePath = imageCursor.getString(imageCursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA));

                CursorLoader thumbCursorLoader = new CursorLoader(
                        context,
                        thumbUri,
                        thumbColumns,
                        thumb_IMAGE_ID + "=" + myID,
                        null,
                        null);
                Cursor thumbCursor = thumbCursorLoader.loadInBackground();

                if (thumbCursor.moveToFirst())
                {
                    String thumbPath = thumbCursor.getString(thumbCursor.getColumnIndex(thumb_DATA));
                    ImageInfo imageInfo = new ImageInfo(myID, imagePath, thumbPath);
                    imageInfos.add(imageInfo);
                }
                thumbCursor.close();
            }
        }

        imageCursor.close();

        return imageInfos;
    }
}
