package com.nitishnihar.msf2.chatapp;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.ArrayList;

/**
 * Created by samsung on 10-07-2015.
 */
public class CustomClientAdapter extends BaseAdapter {

    ArrayList<String> result=new ArrayList<String>();
    Context context;
    private static LayoutInflater inflater=null;

    public CustomClientAdapter(ClientChatActivity mainActivity, ArrayList<String> prgmNameList)
    {
        result=prgmNameList;
        context=mainActivity;
        inflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    @Override
    public int getCount()
    {
        return result.size();
    }

    @Override
    public Object getItem(int position)
    {
        return position;
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    public class Holder
    {
        TextView tv;
     //   CheckBox checkBox;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent)
    {
        final Holder holder=new Holder();
        View rowView;

        rowView = inflater.inflate(R.layout.inflate_clientlist, null);
        holder.tv=(TextView) rowView.findViewById(R.id.txt_clientName);
        holder.tv.setText(result.get(position));
        return rowView;
    }
}
