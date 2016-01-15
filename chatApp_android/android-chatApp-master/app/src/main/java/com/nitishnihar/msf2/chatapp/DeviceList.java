package com.nitishnihar.msf2.chatapp;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Toast;
import com.samsung.multiscreen.Search;
import com.samsung.multiscreen.Service;
import java.util.List;

public class DeviceList extends Activity
{
    private enum Type
    {
        DEFAULT,
        REFRESH,
        BACK
    }
    private Button btnRefresh = null;
    Handler handler = new Handler();
    TVListAdapter adapter;
    ListView deviceList;
    Search search = null;
    List<Service> list;
    private Intent intent;
    private ProgressDialog progress1,progress2;
    private Type type;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.device_list);
        deviceList = (ListView) findViewById(R.id.lvDeviceList);
        btnRefresh = (Button) findViewById(R.id.btnRefresh);
        mAdapterCall();
    }


    private void mAdapterCall()
    {
        Log.d(App.TAG, "Inside mAdapterCall");
        adapter = new TVListAdapter(getApplicationContext(), R.layout.listview_item);
        deviceList.setAdapter(adapter);
        startDiscovery();

        deviceList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

                Service service = (Service) parent.getItemAtPosition(position);
                if (App.getInstance() == null) {
                    Log.e(App.TAG, "app get instance is null");
                } else {
                    Log.e(App.TAG, "app get instance is NOT null");
                    App.getInstance().service = service;
                    Intent intent = new Intent(getApplicationContext(), ClientChatActivity.class);
                    Log.e(App.TAG, "*********SERVICE NAME*******" + service.getName());
                    String hostName = service.getName();
                    intent.putExtra("com.nitishnihar.deviceList.MESSAGE", hostName);
                    startActivity(intent);
                    stopDiscovery();
                    //finish();
                }
            }
        });


    }

    public void onStart() {
        Log.d(App.TAG, "DeviceList onStart() Called");
        super.onStart();
    }

    public void onStop() {
        Log.d(App.TAG, "DeviceList onStop() Called");
        super.onStop();
    }

    public void onDestroy() {
        Log.d(App.TAG, "DeviceList onDestroy() Called");
        super.onDestroy();
    }

    @Override
    public void onPause() {
        Log.d(App.TAG, "DeviceList onPause() Called");
        super.onPause();

    }

    private void startDiscovery() {

        Log.d(App.TAG, "DeviceList startDiscovery() Called");
        if (search == null) {
            search = Service.search(getApplicationContext());
            Log.d(App.TAG, "DeviceList search instantiated " + search);
            search.setOnServiceFoundListener(new Search.OnServiceFoundListener()
            {
                @Override
                public void onFound(Service service) {
                    Log.d(App.TAG, "ServiceDiscovery onAdded() " + service);
                    updateTVList(service);


                }
            });

            search.setOnServiceLostListener(new Search.OnServiceLostListener()
            {

                @Override
                public void onLost(Service service)
                {
                    Log.d(App.TAG, "ServiceDiscovery onRemoved() " + service);

                    // Remove this service from the display list
                    removeTV(service);
                }
            });

            search.setOnStartListener(new Search.OnStartListener()
            {
                @Override
                public void onStart()
                {
                    Toast.makeText(getApplicationContext(), "Start to search TVs",
                            Toast.LENGTH_SHORT).show();
                }
            });

            search.setOnStopListener(new Search.OnStopListener()
            {
                @Override
                public void onStop()
                {
                    Toast.makeText(getApplicationContext(), "Stop discoverying.",Toast.LENGTH_SHORT).show();
                    if(type == Type.BACK)
                    {
                        type = Type.DEFAULT;
                        mainActivityCallback();
                    }
                    else if(type == Type.REFRESH)
                    {
                       type = Type.DEFAULT;
                        if(progress2 != null)
                            progress2.dismiss();
                        startDiscovery();
                    }
                    else
                    {
                        type = Type.DEFAULT;
                        Log.d(App.TAG,"DEFAULT Stop Discovery");
                    }

                }
            });
        }
      else
        {
            Log.d(App.TAG, "NOT NULL SEARCH");
        }

        boolean b = search.start();

        if( false == b)
        {
            Log.d(App.TAG,"Already Searching");
        }
        else
            Log.d(App.TAG,"New  Searching");
    }

    private void stopDiscovery() {
        if (search != null) {
            search.stop();
           // search = null;
            Log.d(App.TAG, "DeviceList stopDiscovery() called " + search);
        }
    }


    private void removeTV(Service service) {
        if (service == null) {
            return;
        }

        adapter.remove(service);
        notifyDataChange();
    }


    private void updateTVList(Service service) {
        if (service == null) {
            Log.d(App.TAG, "SERVICE NULL");
            return;
        }
        else
        {
            Log.d(App.TAG, "SERVICE NOT  NULL");
        }

        //Ignore the device if it already exists.
        if (!adapter.contains(service)) {
            adapter.add(service);
            Log.d(App.TAG, "Inside updateTVList IF");
            notifyDataChange();
        }
        else
        {
            Log.d(App.TAG, "Inside updateTVList ELSE");
        }
    }

    private void notifyDataChange()
    {
        handler.post(new Runnable() {
            @Override
            public void run() {
                adapter.notifyDataSetChanged();
            }
        });
    }


    public void onClick(View v) {

        Log.d(App.TAG, "***********Inside OnClick DeviceList*********");

        switch (v.getId()) {

            case R.id.btnRefresh:

                adapter.clear();
                adapter.notifyDataSetChanged();
                onRefreshPressed();
                break;


        }

    }

    @Override
    public void onBackPressed() {
        if (search.isSearching()) {
            type = Type.BACK;
            progress1 = new ProgressDialog(this);
            progress1.setTitle("Stop Discovery and Go Back");
            progress1.setMessage("Please wait while stopping Discovery");
            progress1.show();
            stopDiscovery();
        }
        else
        {
            finish();
        }
    }
    public void onRefreshPressed()
    {
        if (search.isSearching()) {
        type = Type.REFRESH;
        progress2 = new ProgressDialog(this);
        progress2.setTitle("Updating the Device List");
        progress2.setMessage("Please wait while refreshing");
        progress2.show();
        stopDiscovery();
    }
    else {
            startDiscovery();
        }

    }

    public void mainActivityCallback()
    {
      if(progress1 != null)
       progress1.dismiss();
      finish();
    }

}

