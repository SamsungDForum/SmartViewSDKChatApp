package com.nitishnihar.msf2.chatapp;

import android.app.Activity;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.bluetooth.BluetoothAdapter;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;

public class MainActivity extends Activity
{

    private FragmentTransaction ft;
    private ImageView takePic;
    private Button discovery, btnAbout;
    private FragmentManager manager;
    private Intent intent;
    private static final int CAMERA_REQUEST = 1888;
    private EditText edtUserName;
    private BluetoothAdapter bluetoothAdapter = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);
        discovery = (Button) findViewById(R.id.btn_Discovery);
        takePic = (ImageView) findViewById(R.id.iv_icon);
        discovery = (Button) findViewById(R.id.btn_Discovery);
        edtUserName = (EditText) findViewById(R.id.edt_userName);
        btnAbout = (Button) findViewById(R.id.btn_About);

        getDevicename();
    }

    @Override
    protected void onResume()
    {
        super.onResume();
        App.str_deviceName=edtUserName.getText().toString();
    }

    public void onClick(View v) {

        switch (v.getId()) {

            case R.id.btn_Discovery:

                App.str_userName = edtUserName.getText().toString();
                Log.v(App.TAG, App.str_userName);

                intent = new Intent(this, DeviceList.class);
                startActivity(intent);
                break;

            case R.id.iv_icon:

                Intent cameraIntent = new Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
                startActivityForResult(cameraIntent, CAMERA_REQUEST);

                break;

            case R.id.btn_About:

                Intent in = new Intent(MainActivity.this, AboutActivity.class);
                startActivity(in);
                break;

        }

    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        if (requestCode == CAMERA_REQUEST && resultCode == RESULT_OK)
        {
            final Uri contentUri = data.getData();
            final String[] proj = {MediaStore.Images.Media.DATA};
            final Cursor cursor = managedQuery(contentUri, proj, null, null, null);
            final int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
            cursor.moveToLast();
            final String path = cursor.getString(column_index);
            App.str_userImagePath = path;
            Log.v(App.TAG, App.str_userImagePath);
            Bitmap photo = (Bitmap) data.getExtras().get("data");
            takePic.setImageBitmap(photo);
        }

    }


    @Override
    public void onStop() {
        super.onStop();
    }


    @Override
    public void onPause() {
        super.onPause();
    }


    @Override
    public void onDestroy() {
        System.exit(0);
        super.onDestroy();

    }

    private void getDevicename()
    {
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        App.str_deviceName = bluetoothAdapter.getName();
        Log.d(App.TAG, "deviceName: " + App.str_deviceName);
        edtUserName.setText(App.str_deviceName);

    }


}
