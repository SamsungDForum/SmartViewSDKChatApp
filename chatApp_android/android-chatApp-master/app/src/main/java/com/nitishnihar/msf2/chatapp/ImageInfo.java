package com.nitishnihar.msf2.chatapp;

/**
 * Created by abhinaw.t on 09-06-2015.
 */

 import android.os.Parcel;
 import android.os.Parcelable;

public class ImageInfo implements Parcelable {

    private int imageID;
    private String imagePath;
    private String thumbPath;

    public ImageInfo(int id, String imagePath, String thumbPath) {
        this.imageID = id;
        this.imagePath = imagePath;
        this.thumbPath = thumbPath;
    }

    public ImageInfo(Parcel source) {
        imageID = source.readInt();
        imagePath = source.readString();
        thumbPath = source.readString();
    }

    public int getImageID()
    {
        return imageID;
    }

    public void setImageID(int imageID)
    {
        this.imageID = imageID;
    }

    public String getImagePath()
    {
        return imagePath;
    }

    public void setImagePath(String imagePath)
    {
        this.imagePath = imagePath;
    }

    public String getThumbPath()
    {
        return thumbPath;
    }

    public void setThumbPath(String thumbPath)
    {
        this.thumbPath = thumbPath;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags)
    {
        dest.writeInt(imageID);
        dest.writeString(imagePath);
        dest.writeString(thumbPath);
    }

    public static final Parcelable.Creator CREATOR = new Parcelable.Creator()
    {
        public ImageInfo createFromParcel(Parcel in)
        {
            return new ImageInfo(in);
        }

        public ImageInfo[] newArray(int size)
        {
            return new ImageInfo[size];
        }
    };
}
