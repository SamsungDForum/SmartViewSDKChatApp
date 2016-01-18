#Search

Discovering the TV on the network is the first step.Service.search() will provide search instance which is used for TV discovery.


	search = Service.search(getApplicationContext( ));

 

To start & stop the search, search.start() &search.stop() methods are called, respectively.


	search.start( );
	search.stop( );




As soon as the service is found, onFound() callback will get called and  service is updated in the TV List.

 
	search.setOnServiceFoundListener ( new Search.OnServiceFoundListener( )
	{
	     @Override
	     public void onFound( Service service) {
	          updateTVList(service) ;
	     }
	});
 

#Connect to TV

Making a Connect call to TV widget launches ChatApp widget on the TV.

To connect to the selected TV, connect method of Application class is called. “ChatApp” is set as the app ID, and the username is sent as attribute.


	private static Application application = null ;
	application = service.createApplication(Uri.parse("chatApp"), "com.samsung.multiscreen.chatApp") ;
	application.connect(attribute, new Result<Client> ( )
	{
	     @Override
	     public void onSuccess(Client client)
	     {
	          getClientList( );
	     }
	     @Override
	     public void onError(com.samsung.multiscreen.Error error)
	     {
	          Toast.makeText(ClientChatActivity.this, " Please Re-Start Application", Toast.LENGTH_LONG.show( );
	     }
	});
 

#Disconnect from TV

 When any connected TV gets disconnected, onLost() callback will get called and TV list is updated


	search.setOnServiceLostListener( new Search.OnServiceLostListener ( )
	{
	     @Override
	     public void onLost(Service service)
	     {
	          // Remove this service from the display list
	          removeTV(service);
	     }
	});
 

#on Client Disconnect

As and when a client gets disconnected, onDisconnect() callback will get called.


	application.setOnDisconnectListener( new Channel.OnDisconnectListener ( )
	{
	     @Override
	     public void onDisconnect(Client client) {
	          application.disconnect( );
	     }
	});
 

#on Message Received

OnMessage() callback gets called whenever a message is received.

 
	application.addOnMessageListener("say", new Channel.OnMessageListener( ) {
	     @Override
	     public void onMessage(Message message)
	     {
	          if (message.getData().toString != null)
	          {
	               counter++;
	               messageList.add(" "+ message.getData( ) );
	               setChatAdapterMessage( );
	               counterMessage( );
	          }
	          else
	          {
	               Log.v(App.TAG, "No Message recieved") ;
	          }
	     }
	});
 
