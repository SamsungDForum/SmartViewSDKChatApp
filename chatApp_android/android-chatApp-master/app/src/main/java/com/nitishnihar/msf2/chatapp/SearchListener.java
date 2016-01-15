package com.nitishnihar.msf2.chatapp;

/**
 * Created by abhinaw.t on 10-06-2015.
 */
import com.samsung.multiscreen.Search.OnServiceFoundListener;
import com.samsung.multiscreen.Search.OnServiceLostListener;
import com.samsung.multiscreen.Search.OnStartListener;
import com.samsung.multiscreen.Search.OnStopListener;

public interface SearchListener extends OnStartListener, OnStopListener, OnServiceFoundListener, OnServiceLostListener
{
}
