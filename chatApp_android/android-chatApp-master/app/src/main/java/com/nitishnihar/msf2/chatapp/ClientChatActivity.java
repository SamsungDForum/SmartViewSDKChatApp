package com.nitishnihar.msf2.chatapp;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import com.samsung.multiscreen.Application;
import com.samsung.multiscreen.Channel;
import com.samsung.multiscreen.Client;
import com.samsung.multiscreen.Message;
import com.samsung.multiscreen.Result;
import com.samsung.multiscreen.Service;

import org.json.JSONException;
import org.json.JSONObject;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by Abhinaw on 07-07-2015.
 */
public class ClientChatActivity extends Activity {
    private Intent intent;
    private Bundle extras;
    private String hostDevice;
    private static Application application = null;
    private Service service;
    private String deviceName = null;
    private String channelID;
    // private BluetoothAdapter bluetoothAdapter = null;
    protected Map<String, String> attribute = new ConcurrentHashMap();
    private ListView listViewClent;
    private TextView tv_userName;
    private ImageView iv_userImage;
    private EditText edt_typeMessage;
    private Button btnEnter;
    private ArrayList<String> clientList;
    private int selectedValue;
    private View row;
    private String name;
    private Map<String, Object> messagerList;
    private ArrayList<String> dispmessageList;
    private ListView lv_chatDisplay;
    private ArrayList<String> clientId;
    private CustomClientAdapter mListadapter;
    private RelativeLayout relativeLayout, firtLayout;
    private ImageView iv_showMessage;
    //  private ArrayList<String> messageList;
    private TextView tv_message;
    private int counter = 0;
    Handler handler = new Handler();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
        setContentView(R.layout.activity_client_chat);

        service = App.getInstance().service;
        extras = getIntent().getExtras();
        hostDevice = extras.getString("com.nitishnihar.deviceList.MESSAGE");
        listViewClent = (ListView) findViewById(R.id.listViewClient);
        tv_userName = (TextView) findViewById(R.id.txt_ClientChatTitle);
        iv_userImage = (ImageView) findViewById(R.id.iv_userImage);
        edt_typeMessage = (EditText) findViewById(R.id.edtTypeMessage);
        btnEnter = (Button) findViewById(R.id.btn_enter);
        tv_message = (TextView) findViewById(R.id.counterText);
        lv_chatDisplay = (ListView) findViewById(R.id.listViewChat);
        clientId = new ArrayList<>();
        relativeLayout = (RelativeLayout) findViewById(R.id.layoutChat);
        firtLayout = (RelativeLayout) findViewById(R.id.layout_Hadder);
        iv_showMessage = (ImageView) findViewById(R.id.imageView_Message);
        dispmessageList = new ArrayList<String>();
        selectedValue = -1;
        messagerList = new HashMap<String, Object>();
        initializeAppAPI();
    }


    private void initializeAppAPI() {
        application = service.createApplication(Uri.parse("chatApp"), "com.samsung.multiscreen.chatApp");
        application.addOnMessageListener("say", new Channel.OnMessageListener() {

            @Override
            public void onMessage(Message message) {
                if (message.getData().toString() != null) {

                    Log.v(App.TAG, message.getData().toString());
                    try {
                        JSONObject json = new JSONObject(message.getData().toString());
                        try {
                            String aJsonString  = json.getString("message");
                            String senderID     = json.getString("sender");
                            String clientName   = clientList.get(clientId.indexOf(senderID));
                            ArrayList<String>  messageList = new ArrayList<String>((ArrayList<String>)messagerList.get(senderID));
                            messageList.add(clientName.replaceAll("\\p{P}", "").replace("name=TV", "").replace("name=", "").replace("P= = ", "") + ": " + aJsonString);
                            messagerList.put(senderID, messageList);
                            if(selectedValue != -1)
                            { if(!clientId.get(selectedValue).equals(senderID) ) {
                                dispmessageList.add(clientName.replaceAll("\\p{P}", "").replace("name=TV", "").replace("name=", "").replace("P= = ", "") + ": " + aJsonString);
                                counter++;
                            }
                                else{
                                setChatAdapterMessage();
                            }
                            }
                            else {
                                dispmessageList.add(clientName.replaceAll("\\p{P}", "").replace("name=TV", "").replace("name=", "").replace("P= = ", "") + ": " + aJsonString);
                                counter++;
                            }
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    } catch (JSONException e) {
                    }

                } else {
                    Log.v(App.TAG, "No message received");
                }
            }
        });

        counterMessage();
        application.setOnReadyListener(new Channel.OnReadyListener() {
            @Override
            public void onReady() {
                Log.d(App.TAG, "application onReady()");

                if (App.str_userImagePath != null) {
                    sendRawBitmap(App.str_userImagePath);
                } else {
                    //do nothing
                }

            }
        });

        application.setOnClientConnectListener(new Channel.OnClientConnectListener() {

            @Override
            public void onClientConnect(Client client) {
                getClientList();
            }
        });
        application.setOnClientDisconnectListener(new Channel.OnClientDisconnectListener() {

            @Override
            public void onClientDisconnect(Client client) {
                getClientList();
            }
        });
        application.setOnDisconnectListener(new Channel.OnDisconnectListener() {
            @Override
            public void onDisconnect(Client client) {

                Log.d(App.TAG, "application.onDisconnect()" + client.getId());
                application.disconnect();

            }
        });

        // bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        //   deviceName = bluetoothAdapter.getName();
        attribute.put("name", "" + App.str_deviceName);

        application.connect(attribute, new Result<Client>() {
            @Override
            public void onSuccess(Client client) {
                channelID = client.getId();
                getClientList();
            }

            @Override
            public void onError(com.samsung.multiscreen.Error error) {
                Toast.makeText(ClientChatActivity.this, "Please Re-start application!!!!", Toast.LENGTH_LONG).show();
            }

        });
        setUserNameImage(); // setting image and name

    }

    private void getClientList() {
        if(!clientId.isEmpty())
        {
            clientId.clear();
        }
        clientList = new ArrayList<String>();
        for (int i = 0; i < application.getClients().size(); i++) {
            clientList.add("" + application.getClients().getChannel().getClients().list().get(i).getAttributes());
            clientId.add("" + application.getClients().getChannel().getClients().list().get(i).getId());

        }
        String[] arr = clientList.toArray(new String[clientList.size()]);
        ArrayList<String> cList = new ArrayList<>();
        for (int i = 0; i < arr.length; i++) {
            String cName = arr[i].replaceAll("\\p{P}", "").replace("name=TV", "").replace("name=", "").replace("= ", "").replace("\\p{Alpha}", "");
           if(!cName.isEmpty())
            {
                cList.add(cName);
             if(!messagerList.containsKey(clientId.get(i))){
                    messagerList.put(clientId.get(i), new ArrayList<String>());
           }}
            else {
                clientList.remove(i);
               clientId.remove(i);
           }
        }

        mListadapter = new CustomClientAdapter(ClientChatActivity.this, cList);
        listViewClent.setAdapter(mListadapter);
        mListadapter.notifyDataSetChanged();

        listViewClent.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
                selectedValue = arg2;
                row = arg1;
                //arg1.setBackgroundResource(R.drawable.some_row_background);
                name = clientList.get(arg2);
                App.str_userName = name.replaceAll("\\p{P}", "").replace("name=TV", "").replace("name=", "").replace("P= = ", "");
                tv_userName.setText("" + App.str_userName);
                relativeLayout.setVisibility(View.VISIBLE);
                firtLayout.setVisibility(View.GONE);
                setChatAdapterMessage();
            }
        });

    }

    private void setUserNameImage() {

        String img_path = App.str_userImagePath;
        if (img_path != null) {
            Bitmap bmp = BitmapFactory.decodeFile(img_path);
            iv_userImage.setImageBitmap(bmp);
        } else {
            Toast.makeText(getApplicationContext(), "Picture not taken by Camera!!", Toast.LENGTH_LONG).show();
            Resources res = getResources();
            String mDrawableName = "person";
            int resID = res.getIdentifier(mDrawableName, "drawable", getPackageName());
            Drawable drawable = res.getDrawable(resID);
            iv_userImage.setImageDrawable(drawable);

            String path = "/storage/emulated/0/person.jpg";
            App.str_userImagePath = path.toString();
            Log.v(App.TAG, App.str_userImagePath);
        }

    }

    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btn_enter:

                sendMessageToTv();
                //edt_typeMessage.setText("");
                break;

            case R.id.imageView_Message:

                showMessage();

            case R.id.counterText:
                showMessage();
        }
    }

    private void sendMessageToTv() {
        JSONObject jsonObj = null;
        String message = edt_typeMessage.getText().toString();
        String client_Id = clientId.get(selectedValue);

        Log.v(App.TAG, message + ":Client ID" + client_Id);
        try {
            jsonObj = new JSONObject();
            jsonObj.put("ClientID", client_Id);
            jsonObj.put("Message", message);
            jsonObj.put("Sender", channelID);
        } catch (Exception e) {
            e.printStackTrace();
        }
        ArrayList<String>  messageList = new ArrayList<String>((ArrayList<String>)messagerList.get(client_Id));
        String messageSend = jsonObj.toString();
        Log.v(App.TAG, messageSend);
        application.publish("say", messageSend, Message.TARGET_HOST);
        messageList.add("Me:" + message);
        messagerList.put(client_Id, messageList);
        edt_typeMessage.setText("");
        setChatAdapterMessage();
    }

    private void setChatAdapterMessage() {
        lv_chatDisplay.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1,(ArrayList<String> )messagerList.get(clientId.get(selectedValue))));
    }


    @Override
    public void onBackPressed()
    {

  if(relativeLayout.getVisibility() == View.VISIBLE)
    {
    firtLayout.setVisibility(View.VISIBLE);
    relativeLayout.setVisibility(View.GONE);
        selectedValue = -1;
    }
        else
  {
      application.disconnect();
      finish();
  }

    }
    private void sendRawBitmap(String realPath) {
        final File file = new File(realPath);

        if (file.exists()) {
            new Thread() {
                public void run() {
                    try {
                        int fileSize = (int) file.length();
                        byte[] bytes = new byte[fileSize];
                        InputStream is = new BufferedInputStream(new FileInputStream(file));
                        is.read(bytes, 0, fileSize);
                        is.close();
                        ClientChatActivity.application.publish("say", "", Message.TARGET_HOST, bytes);
                    } catch (IOException e) {
                        e.printStackTrace();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                }
            }.start();
        } else {
            Toast.makeText(ClientChatActivity.this, "Default Picture Sent!!", Toast.LENGTH_SHORT).show();
        }
    }


    public void showMessage() {
        counter = 0;
        AlertDialog.Builder alertDialog = new AlertDialog.Builder(ClientChatActivity.this);
        LayoutInflater inflater = getLayoutInflater();
        View convertView = (View) inflater.inflate(R.layout.dialog_listclients, null);
        alertDialog.setView(convertView);
        alertDialog.setTitle("Message List");
        alertDialog.setNegativeButton(android.R.string.cancel, null);

        ListView lv = (ListView) convertView.findViewById(R.id.dialogList);
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, dispmessageList);
        lv.setAdapter(adapter);
        alertDialog.show();

    }

    public void counterMessage() {
        final Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                tv_message.setText(String.valueOf(counter));
                handler.postDelayed(this, 2000);

            }
        }, 1000);
    }
}
