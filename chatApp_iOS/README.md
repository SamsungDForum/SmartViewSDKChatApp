# SmartViewSDK ChatApp Sample App #

##Prerequisite



###1. Library
1. Download library manually [SmartView SDK iOS framework](http://developer.samsung.com/tv/develop/tools/extension-libraries/smart-view-sdk-download):  iOS Package(Mobile)

	add smartview.framework
2. Download and install by [Cocoapods](https://cocoapods.org/pods/smart-view-sdk) (recommended)

		pod 'smart-view-sdk'
	**Note** Application project should be unlocked before fetching pod. To unlock open .xcodeproj in Xcode and click unlock and close. Refer [Cocoapods guide](https://cocoapods.org) for more.

###2. Build Environment
1. This sample app is developed using swift language.
2. Use 'smart-view-sdk' cocoapods. More information at "Install By Cocoapods" http://developer.samsung.com/tv/develop/extension-libraries/smart-view-sdk/sender-apps/ios-sender-app


###3. Recommendation for  iOS framework
1. This sample app includes Podfile with 'smart-view-sdk' as pod item
2. iphoneos+iphonesimulator library: works on devices and simulator( + i386,x86_64)

 **Note**: Apple App Store will reject your app  when you register your app with iphoneos+iphonesimulator framework.
 You need to run shell 'remove\_unused\_archs.sh' to remove unused architectures from the final binary. This script is in the iphoneos+iphonesimulator folder.
refer to: [Stripping Unwanted Architectures From Dynamic Libraries In Xcode](http://ikennd.ac/blog/2015/02/stripping-unwanted-architectures-from-dynamic-libraries-in-xcode/)
 
###4. Discover : Search devices around your mobile.
1. Pressing 'Cast' button in ActionBar, must start search API [search.start()].
2. Populate device list by overriding onFound() & onLost() listeners.
3. Stop device discovery, by calling stop search API [search.stop()].

#Search

As soon as the user clicks the login button, the app searches the devices with MSF service available on the same network. The start method of search class is called.

 
	@IBAction func LoginButtonAction(sender: AnyObject) {
	       // start searching the services
	        ShareController.sharedInstance.searchServices()
	       if(userNameValue.text.isEmpty != true){
	            NSLog("Username is %@",userNameValue.text)
	            ShareController.sharedInstance.setUserName(userNameValue.text)
	        }
	        else{
	            let alertView = UIAlertController(title: "ChatApp", message: "Please enter your name to login!!", preferredStyle: .Alert)
	           alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
	           presentViewController(alertView, animated: true, completion: nil)
	       }
	     }
 
 
	func searchServices() {
	        //start the search
	        search.start()
	        //   updateCastStatus()
	    }
 

#Connect to TV

To connect to the selected TV, connect  method of class Application  is called. “ChatApp” is set as the app ID, and the username is sent as attribute



	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
	        if ShareController.sharedInstance.search.isSearching {
	            let service = ShareController.sharedInstance.services[indexPath.row] as Service
	            // set "chatApp" as app ID and launch and connect the application on TV
	            ShareController.sharedInstance.launchApp("chatApp", index: indexPath.row)
	             self.activityIndicatorView.startAnimating()
	        }
	    }
	 
	
	 
	func launchApp(appId: String, index: Int){
	        let tempService = services[index] as Service
	        app = tempService.createApplication(appId, channelURI: channelId, args:nil)
	        app?.delegate = self
	        self.isConnecting = true
	        //connect with TV using username text as attribute
	        app!.connect( ["name":userNameText])
	    }

 

#Disconnect

If a user wants to choose another TV to act as a host or wants to chat with a different user name, he/she can disconnect from the channel as shown below



	func leftNavButtonClick(sender:UIButton!){
	        leftbuttonpressed = true
	        //disconnect from TV
	        ShareController.sharedInstance.disconnect(true)
	         self.activityIndicatorView.startAnimating()
	}
	 
	 
	func disconnect(connectiontype :Bool){
	        connectionType = connectiontype
	        search.stop()
	        if (app != nil){
	            app?.disconnect()
	            services.removeAll(keepCapacity: false)
	        }
	    }
 
#Client Connect & Disconnect

While you are connected to a TV, the clients connected to it might disconnect or new clients may connect to it. In order to handle the connection and disconnection of these clients we have methods onClientConnect  and onClientDisconnect


 
	@objc func onClientConnect(client: ChannelClient){
	      //post a notification if a new client connects
	      NSNotificationCenter.defaultCenter().postNotificationName("clientGetsConnected", object: self, userInfo: ["addClient":client])
	  }
	    
	    //  :param: client: The Client that just disconnected from the Channel
	    @objc func onClientDisconnect(client: ChannelClient) {
	         //post a notification if a client disconnects
	         NSNotificationCenter.defaultCenter().postNotificationName("clientGetsDisconnected", object: self, userInfo: ["removeClient":client])
	
	         //post a notification if a client disconnects during chat
	         NSNotificationCenter.defaultCenter().postNotificationName("clientDisconnectedDuringChat", object: self, userInfo: ["clientdisconnect":client])
	    }
 

#Client Disconnected during Chat

If you are in a chat with a client and the client disconnects, we will post a notification to let the user know about the status of the other client .

 
	func clientDisconnectedDuringChatAction(notification: NSNotification!){
	        let client = notification.userInfo?["clientdisconnect"] as! ChannelClient
	        var tempDict : [String:String] = (client.attributes as? [String : String])!
	        var nameValue = tempDict["name"]
	        if(client.id == ShareController.sharedInstance.getClientID()){
	            let alertView = UIAlertController(title: "ChatApp", message: "Client Disconnected!! Please try again later...", preferredStyle: .Alert)
	            var okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default){
	                UIAlertAction in
	                NSLog("OK Pressed")
	                let viewControllers:[UIViewController] = self.navigationController!.viewControllers as! [UIViewController]
	                self.navigationController?.popToViewController(viewControllers[ 2], animated: true)//
	            }
	            alertView.addAction(okAction)
	            presentViewController(alertView, animated: true, completion: nil)
	        }
	    }
 
