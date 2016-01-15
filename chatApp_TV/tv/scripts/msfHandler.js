function msfHandler() {


    var instance = this,
    	ms = window.webapis.multiscreen,
        deviceListCallback,
        eventCallback,
        hostChannel,
        tvDevice,
        pinCode,
        deviceList = [],
        imageList = {},
        userName = "HostTV",
        device_ip = "127.0.0.1";
    	connectionState = false;
    	
    // Event types
    this.EVENT_CONNECT = 201;
    this.EVENT_DISCONNECT = 202;
    this.EVENT_CONNECT_NOTIFY = 203;
    this.EVENT_DISCONNECT_NOTIFY = 204;
    this.EVENT_MESSAGE = 205;
    this.EVENT_PIN_EXPIRE = 206;
    this.EVENT_PIN_OBTAINED = 207;
    this.EVENT_ERROR = 208;
    this.EVENT_DEVICE_OBTAINED = 209;
    this.EVENT_CHANNEL_OBTAINED = 210;

    //library namespace
    var _msf = undefined;

    // Device Constants
    var APP_ID = "msfTestWidget";
    // API constants
    var CHANNEL_CONNECT,
        CHANNEL_DISCONNECT,
        CHANNEL_CLIENT_CONNECT,
        CHANNEL_CLIENT_DISCONNECT,
        CHANNEL_MESSAGE,
        CHANNEL_ERROR;


    this.getDeviceList = function () {
        return deviceList;
    };
    this.getUserName = function () {
        return userName;
    };
    this.setUserName = function (name) {
        userName = name;
    };
    this.initialize = function(){
    	// start initializing
    	console.log("In initialise of msfHandler.js ");
    	try {
    		console.log(".......... window.msf  " + JSON.stringify(window.msf));
    	
    		if(window.msf) {
    			console.log(".......... window.msf  " + JSON.stringify(window.msf));
  //      		self=this;
        		_msf = window.msf;
        		CHANNEL_CONNECT = "connect";
                CHANNEL_DISCONNECT = "disconnect";
                CHANNEL_CLIENT_CONNECT = "clientConnect";
                CHANNEL_CLIENT_DISCONNECT = "clientDisconnect";
                CHANNEL_MESSAGE = "say";
                CHANNEL_ERROR = "error";

        		if(!this.isSessionStarted()) {
        	    	_msf.local(function(err, service) {
        	    		if(err) return log.error("[openChannel] Error opening channel" + err);
        	            var channel = service.channel('com.samsung.multiscreen.chatApp');
        	            console.log("Channel created :: ")
        	            console.log(channel)
        	            hostChannel = channel;
        	            instance.setUserName(service.device.name);
        	            registerHostCallbacks();
        	            instance.connectToChannel();	            
        	    	});
            	}
                
        	} else {
        		console.log("msf 2.0 is not loaded");
        	}
    	} 
    	catch(e) {
    		console.log("msf 2.0 is not loaded");
    	}    	
    };
    function registerHostCallbacks() {
        console.log("[registerHostCallbacks]");
        if (hostChannel) {
            hostChannel.on(CHANNEL_CONNECT, handleConnectEvent.bind(instance));
            hostChannel.on(CHANNEL_DISCONNECT, handleDisconnectEvent.bind(instance));
            hostChannel.on(CHANNEL_CLIENT_CONNECT, handleClientConnectEvent.bind(instance));
            hostChannel.on(CHANNEL_CLIENT_DISCONNECT, handleClientDisconnectEvent.bind(instance));
            hostChannel.on(CHANNEL_MESSAGE, handleMessageEvent.bind(instance));
            hostChannel.on(CHANNEL_ERROR, handleErrorEvent.bind(instance));
            document.addEventListener( 'keydown', handleKeyDown.bind(instance));
        }
    }   
    

    var unregister = function() {
    	 hostChannel.disconnect(function (){
             //success
         	console.log(userName + ": TV is Disconnected");
         },function (err) {
             handleErrorEvent("EVENT DISCONNECT >> "+JSON.stringify(err));
             console.log("[disconnectFromChannel] Error! > " + JSON.stringify(err));
         });
            document.removeEventListener( 'keydown', handleKeyDown);
            window.tizen.application.getCurrentApplication().exit();
    }
    
    function handleKeyDown(e){
    	switch(e.keyCode){
	        case TvKeyCode.KEY_UP:
	        	scrollChannelLogs(TvKeyCode.KEY_UP);
	        	break;
	        	
	        case TvKeyCode.KEY_RETURN:
	        	console.log("[in return key handlder]");
	        	unregister();
	        	break;
	        	

	        case TvKeyCode.KEY_DOWN:
	        	scrollChannelLogs(TvKeyCode.KEY_DOWN);
	        	break;
	        	
    	}
    }

    /**
     *
     * @returns {boolean} connection state
     */
    this.isSessionStarted = function(){
        return connectionState;
    };

    /**
     * Host connection status
     * @returns {boolean} Host status
     */
    this.isConnected = function () {
        var result = false;
        if (hostChannel) {
            result = hostChannel.isConnected;
        }
        return result;
    };
    
    
    //===================================================================
    //---------------------- API callback methods ---------------------
    //------------------- Host methods ----------------------------------
    /**
     *
     */
    this.destroyHost = function () {
        hostChannel = undefined;
        tvDevice = undefined;
    };

    /**
     * Connect to created Host channel
     */
    this.connectToChannel = function () {
    	var channelLogs = document.getElementById("channelLogs").innerHTML;
    	if (hostChannel) {
            var attributes = {
                name: userName
            };
            channelLogs += "<li>" + userName + " connected</li>";
            if (!this.isConnected()){
                //if connection is not established, trying to connect
                console.log(userName +": trying to connect...");
                document.getElementById("channelLogs").innerHTML = channelLogs;
                hostChannel.connect({name: userName}, function () {
	                console.log('[connectToChannel] channel connection success!');
	            }, function (err) {
                    //handleErrorEvent("EVENT CONNECT >> "+JSON.stringify(err));
	            	console.log("[establishHostConnection] Error! > " + JSON.stringify(err));
                });
            } else {
                //if connection is established
            	console.log(userName + " is already Connected");
            }
        } else {
        	console.log("Channel not created!");
        }
    };


    /**
     * Disconnect from Host channel
     */
    this.disconnectFromChannel = function () {
        if (hostChannel) {
            if (this.isConnected()) {
                //if connection is established, trying to disconnect
                console.log(userName+ ": trying to disconnect");
                hostChannel.disconnect(function (){
                    //success
                	console.log(userName + ": TV is Disconnected");
                },function (err) {
                    handleErrorEvent("EVENT DISCONNECT >> "+JSON.stringify(err));
                    console.log("[disconnectFromChannel] Error! > " + JSON.stringify(err));
                    //console.log(userName+ ": is Disconnected");
                });
            }else{
                //if connection is not established
                console.log(userName + ": is already Disconnected");
            }
        }else{
            console.log("Channel not created!");
        }
    };
    
    /**
     * Get all connections
     * @returns {}
     */
    this.getAllClients = function () {
        var clients;
        if (hostChannel) {
            if (this.isConnected()){
                clients = hostChannel.clients;
                console.log('getAllClients  ' + clients.length);
            }else{
                console.log("Error, not connected to channel");
            }
        }else{
            console.log("[getAllClients] Channel not created!");
        }
        return clients;
    };

    /**
     * Get base information about client
     * @param client given client
     */
    this.getClientInfo = function (client) {
        var result,
            clientObj;
        if (hostChannel){
            if (this.isConnected()){
                clientObj = getClientById(client.getId());
                if (clientObj) {
                    result ={};
                    result.name = clientObj.attributes.name;
                    result.id = clientObj.id;
                    result.isHost = clientObj.isHost;
                    //crash!
                    //result.isMe = clientObj.isMe;
                    result.connectTime = clientObj.connectTime;
                }
            }else{
                console.log("Error, not connected to channel");
            }
        }else{
            console.log("[getClientInfo] Channel not created!");
        }
        return result;
    };
    /**
     * Send message to Client by ID using Channel.publish()
     * @param clientId client ID
     * @param message  message
     */
    this.sendMessageById = function (clientId, message) {
        if (hostChannel) {
            if (this.isConnected()){
            	hostChannel.publish('say', message, clientId);
                console.log("[sendMessageById] '"+ userName +"' sent message: '" + message +"' to deviceID: " + clientId);
            }else{
                console.log("Error, not connected to channel");
            }
        }else{
            console.log("[sendMessageById] Channel not created!");
        }
    };

    /**
     * Send message to specified client using Client.send()
     * @param client Device.Model object
     * @param message message
     */
    this.sendMessageToClient = function (client, message) {
        var clientObj;
        if (hostChannel) {
            if (this.isConnected()){
                // Get needed Client object
                clientObj = getClientById(client.getId());
                if (clientObj) {
                	hostChannel.publish('say', message, clientObj);
                    console.log("[sendMessageToClient] '"+ userName +"' sent message: '" + message +"' to device: " + client.attributes.name);
                } else {
                    console.log("[sendMessageToClient] Client with ID= " + client.id + " not found");
                }
            }else{
                console.log("Error, not connected to channel");
            }
        }else{
            console.log("[sendMessageToClient] Channel not created!");
        }
    };

    function getClientById(id) {
        var allClients,
            client;
        console.log("Print Clients Object: " + id);
        if (hostChannel) {
            allClients = hostChannel.clients;
            console.log("Print Clients Object: " + allClients);
            if (allClients) {
                client = allClients.getById(id);
                console.log("Print Client Object: " + client);
            }
        }
        return client;
    }

    //===================================================================
    //---------------------- Outer callback methods --------------------------
    this.registerCallbackReady = function(){
        if (tvDevice){
            try{
                tvDevice.ready();
                console.log('[register callback] Success');
            }catch (error){
                log.error('[register callback] Error: '+JSON.stringify(error));
            }
        }else{
            console.log('[register callback] Not obtained Device instance');
        }
    };
    /**
     * Register callback for updating device list UI
     * @param listCallback callback
     */
    this.registerListCallback = function (listCallback) {
        if (typeof listCallback === "function") {
            deviceListCallback = listCallback;
        }
    };
    /**
     * Unregister callback for updating device list UI
     */
    this.unregisterListCallback = function () {
        deviceListCallback = undefined;
    };

    /**
     * Register callback for delivering API events
     * @param callback outer callback
     */
    this.registerEventCallback = function (callback) {
        if (typeof callback === "function") {
            eventCallback = callback;
        }

    };

    /**
     * Unregister callback for delivering API events
     */
    this.unregisterEventCallback = function () {
        eventCallback = undefined;
    };

    //===================================================================
    //---------------------- API callback methods ---------------------

    function sendEvent(eventType, eventData, extraData) {
        var event = {};
        if (eventCallback) {
            event.type = eventType;
            event.data = eventData;
            event.extraData = 'none';
            if (extraData) {
                event.extraData = extraData;
            }
            //console.log('event after sendEvent --->>>> '+event.type);
            eventCallback(event);
        }
    }

    //-----------------------------------------------------------------
    //----------------- SamsungConnect event callbacks ----------------
    // SConnect multiscreen.devices callbacks
    function handleDeviceObtained(device) {
        sendEvent(msfHandle.EVENT_DEVICE_OBTAINED, device);
    }

    function handleChannelObtained(channel) {
        sendEvent(msfHandle.EVENT_CHANNEL_OBTAINED, channel);
    }
    
    
  //------------------- Channel callbacks ----------------------------
    function handleConnectEvent(client) {
        //for checking of connection status
        connectionState = true;
        console.log("[handleConnectEvent] Host Connected!");
        var clients = hostChannel.clients;
        clients.forEach(function(client){
        	if(!client.isHost){
        		addDeviceToList(client);
        	}
        });
        sendEvent(msfHandle.EVENT_CONNECT, client);
    }

    function handleDisconnectEvent(client) {
        //for checking of connection status
        connectionState = false;
        console.log("[handleDisconnectEvent] Host disconnected!");
        sendEvent(msfHandle.EVENT_DISCONNECT, client);
    }

    function handleClientConnectEvent(client) {
        console.log("[handleClientConnectEvent] Connected Client attributes: " + JSON.stringify(client.attributes));
        addDeviceToList(client);
        sendEvent(msfHandle.EVENT_CONNECT_NOTIFY, client);
    }

    function handleClientDisconnectEvent(client) {
        console.log("[handleClientDisconnectEvent] Disconnected Client: ");
        removeDeviceFromList(client);
        sendEvent(msfHandle.EVENT_DISCONNECT_NOTIFY, client);
    }

    function handleMessageEvent(message, sender, payload) {
    	console.log(message);
    	if(payload){
    		imageList[sender.id] = payload;
    		showPhoto(payload,sender.id);
    	}
    	if(message)
        {
        	message = JSON.parse(message);
        	var data = {}, client;
        	data.message = message.Message;
        	data.sender = sender.id;
        	client = getClientById(message.ClientID);
	    	if(client)
	    	{
	    		hostChannel.publish('say', JSON.stringify(data), client.id);
	    	}
	        console.log("[handleMessageEvent] Message: " + JSON.stringify(message) + " From client: " + JSON.stringify(sender.attributes.name));
	        updateChannelLogs(JSON.stringify(sender.attributes.name) + " sent a message : "+JSON.stringify(message.Message) +" to :"+ JSON.stringify(client.attributes.name));
        }
        sendEvent(msfHandle.EVENT_MESSAGE, message, sender);
    }    
    
    function showPhoto(abPhoto, id){

        if(abPhoto){
	        var photoBlob = new Blob([abPhoto]);
	        var URL = window.URL || window.webkitURL;
	        var url = URL.createObjectURL(photoBlob);
	        
	        var img = $('#'+id);
	        img.attr('src', url);
        }
    }
    
    function handleErrorEvent(error) {
        sendEvent(msfHandle.EVENT_ERROR, error);
    }
    
    
  //===================================================================
    //--------------------- Device list methods -----------------------
    function addDeviceToList(device) {
        if (device) {
            var newDevice;
            console.log('new device, id= ' + device.id+" name= "+device.attributes.name);
            newDevice= new Device.Model(device.id, device.attributes.name);
            deviceList.push(newDevice);
            //document.getElementById("clientsList").
            updateDeviceList(deviceList);
            updateChannelLogs(device.attributes.name+" connected");
            console.log('Added new device! ID= ' + device.id + " name= " + device.attributes.name);
            if (deviceListCallback) {
                deviceListCallback(deviceList);
            }
        }
    }

    function removeDeviceFromList(device) {
        if(device){
            var id = device.id, newList = [];
            console.log('remove device, id= ' + id);
            if(deviceList){
		        deviceList.forEach(function (item) {
		            if (item.getId() != id) {
		                newList.push(item);
		            }
		            else{
		            	updateChannelLogs(item.getName()+" disconnected");
		            }
		        });
            }
            deviceList = newList;
            updateDeviceList(deviceList);

            console.log('Device removed! ID= ' + id);
            if (deviceListCallback) {
                deviceListCallback(deviceList);
            }
        }
    }
    
    function setScrollPosition(){
    	document.getElementById("clientsList").scrollTop = document.getElementById("clientsList").scrollHeight;
        document.getElementById("channelLogs").scrollTop = document.getElementById("channelLogs").scrollHeight;
    }
    

    
    function scrollChannelLogs(direction){
    	if(direction == TvKeyCode.KEY_UP){
	        document.getElementById("channelLogs").scrollTop = document.getElementById("channelLogs").scrollTop - 
    																parseInt(document.getElementById("logsContainer").style.height);
    	}
    	else{
    		document.getElementById("channelLogs").scrollTop = document.getElementById("channelLogs").scrollTop + 
																	parseInt(document.getElementById("logsContainer").style.height);
    	}
    }
    
    function updateDeviceList(deviceList){
    	 var listControllers="";
        if(deviceList){
            deviceList.forEach(function (item) {
            	listControllers += "<li><img id='"+item.getId()+"'></img> <span id='clientName'>" + item.getName() + "</span></li>";
            });
            document.getElementById("clientsList").innerHTML = listControllers;
            
            deviceList.forEach(function (item) {
        		if(imageList){
        		showPhoto(imageList[item.getId()],item.getId());
        		}
        	});
            setScrollPosition();
        }
    }
    
    function updateChannelLogs(logs){
    	var channelLogs = document.getElementById("channelLogs").innerHTML;
    	channelLogs += "<li>" + logs + "</li>";
    	document.getElementById("channelLogs").innerHTML = channelLogs;
    	setScrollPosition();
    }
    
}
msfHandle = new msfHandler();