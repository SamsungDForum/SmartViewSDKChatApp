

//
//  ShareController.swift
//  chatApp
//
//  Created by CHIRAG BAHETI on 09/07/15.
//  Copyright (c) 2015 CHIRAG BAHETI. All rights reserved.
//

import Foundation
import AssetsLibrary
import MSF
import Darwin

class ShareController : ServiceSearchDelegate, ChannelDelegate
{
    let search = Service.search()
    var app: Application?
    var appURL: String = "http://prod-multiscreen-examples.s3-website-us-west-1.amazonaws.com/examples/photoshare/tv/"
    //var appURL: String = "http://www.google.com"
    var channelId: String = "com.samsung.multiscreen.chatApp"
    var isConnecting: Bool = false
    var services = [Service]()
    var connectionType:Bool = false
    var imageByte:NSData?
    var userNameText : String = ""
    var defaultImage:NSData?
    var refreshOrStop:Int?
    var msgString:NSString = ""
    var clientname:String = ""
    var clientId:String = ""
    var chatViewOpen:Bool = false
  
    var chatContent1 = Dictionary<String,Array<String>>()
    var temp = [[String:String]]()
    var count:NSInteger = 1
    var senderID:String = ""
    var allIds:[String] = []
    var allNames: [String] = []
    class var sharedInstance : ShareController {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : ShareController? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = ShareController()
        }
        return Static.instance!
    }
    
    init () {
        search.delegate = self
       
    }
    
    func searchServices() {
        search.start()
        //   updateCastStatus()
    }
    
    func connect(service: Service) {
        search.stop()
        
        if (app != nil)
        {
            app?.disconnect()
           
        }
        
        app = service.createApplication(NSURL(string: appURL)!,channelURI: channelId, args: nil)
        app!.delegate = self
      //  app!.connectionTimeout = 5
        self.isConnecting = true
        //  self.updateCastStatus()
        app!.connect()
    }
    
    func stopSearch(status: Int)
    {
        refreshOrStop = status
        search.stop()
    }
    
   @objc func onClientConnect(client: ChannelClient)
    {
        //post a notification if a new client connects
                NSNotificationCenter.defaultCenter().postNotificationName("clientGetsConnected", object: self, userInfo: ["addClient":client])
        
    }
    
    ///  :param: client: The Client that just disconnected from the Channel
    @objc func onClientDisconnect(client: ChannelClient)
    {
        
        //post a notification if a client disconnects
          NSNotificationCenter.defaultCenter().postNotificationName("clientGetsDisconnected", object: self, userInfo: ["removeClient":client])
        //post a notification if a client disconnects during chat
          NSNotificationCenter.defaultCenter().postNotificationName("clientDisconnectedDuringChat", object: self, userInfo: ["clientdisconnect":client])
        
    }
    
    @objc func onConnect(client: ChannelClient?, error: NSError?) {
         NSLog("CONNECTED!!!!!!!!!!!!!!!!!!!!!")
        if (error != nil) {
            search.start()
            print(error?.localizedDescription)
            NSNotificationCenter.defaultCenter().postNotificationName("channelGetsConnectedWithError", object: self, userInfo: nil)
        }
        else{
        isConnecting = false
        let imageName = "person.jpg"
        let image = UIImage(named: imageName)
        if(defaultImage == nil)
        {
            defaultImage = UIImageJPEGRepresentation(image!, 1.0)
        }
         SendToHost("") //send userimage to TV
         NSNotificationCenter.defaultCenter().postNotificationName("channelGetsConnected", object: self, userInfo: nil)
        }
        //    updateCastStatus()
    }
    
    @objc func onDisconnect(client: ChannelClient?, error: NSError?) {
        print(error)
        chatContent1.removeAll(keepCapacity: true)
        NSLog("DISCONNECTED!!!!!!!!!!!!!!!!!!!!!")
        search.start()
        app = nil
        isConnecting = false

        
        NSNotificationCenter.defaultCenter().postNotificationName("channelGetsDisconnected", object: self, userInfo: nil)
        
              //   updateCastStatus()
    }
    
     @objc func onMessage(message: Message)
    {
        NSLog("Message Received")
        print("message is \(message.data) from \(message.from)")
        let item:NSString = message.data as! NSString
        msgString = item
        let jsonData = item.dataUsingEncoding(NSUTF8StringEncoding)
        
        do {
        let json = try NSJSONSerialization.JSONObjectWithData(jsonData!, options:NSJSONReadingOptions.MutableContainers)
        
        if let jsonDict = json as? NSDictionary{
            
            if(jsonDict["message"] != nil)
            {
                let clientid = jsonDict["sender"] as? String
                let messagecontent = jsonDict["message"] as? String
                self.setSenderid(clientid!)
                var name = getnamebyID(clientid!)
                name = name + ":"
                name = name + messagecontent!
                for (id, _) in chatContent1
                {
                    if (id == clientid)
                    {
                        chatContent1[id]?.append(name)
                    }
                }
          
                NSNotificationCenter.defaultCenter().postNotificationName("messageWhileChatting", object: self, userInfo: nil)
                
            }
            
        }
        print("*****&&&&&&&&&&&&*****")
        print(chatContent1)
        }
        catch let error as NSError
        {
            print("error \(error)")
        }
    }
    
    @objc func onData(message: Message, payload: NSData)
    {
        NSLog("Message Received")
    }
    
    
    @objc func onReady()
    {
        
    }


    @objc func onServiceFound(service: Service) {
        services.append(service)
        //    updateCastStatus()
    }
    
    @objc func onServiceLost(service: Service) {
        removeObject(&services,object: service)
        //  updateCastStatus()
    }
    
    @objc func onStop() {
         NSNotificationCenter.defaultCenter().postNotificationName("stopSearchonback", object: self, userInfo: nil)
        if(connectionType == true)
        {
            searchServices()
            connectionType = false
        }
        if (refreshOrStop == 1)
        {
            services.removeAll(keepCapacity: false)
        }
    }
    
    func removeObject<T:Equatable>(inout arr:Array<T>, object:T) -> T? {
        
        if let found = arr.indexOf(object) {
            return arr.removeAtIndex(found)
        }
        return nil
    }
    
    func launchApp(appId: String, index: Int)
    {
        let tempService = services[index] as Service
        
        
        app = tempService.createApplication(appId, channelURI: channelId, args:nil)
        NSLog(channelId)
        app?.delegate = self
        self.isConnecting = true
        //connect with TV using username text as attribute
        app!.connect( ["name":userNameText])
    
    }
    
    func launchAppWithURL(appURL: String, index:Int, timeOut: Int)
    {
        let tempService = services[index] as Service
        
        app = tempService.createApplication(NSURL(string: appURL)!, channelURI: channelId, args: nil)
        
        app!.delegate = self
        
     
        self.isConnecting = true
        
        app!.connect()
        
    }
    
    func TerminateApp() -> Int
    {
        var running = 0;
        
        if (app != nil)
        {
            app?.disconnect()
            running = 1
        }
        
        return running
    }
    
    func SendToHost(msgText: String)
    {
        if(app != nil)
        {
            if(imageByte != nil)
            {
                NSLog("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
                app!.publish(event: "say", message: "", data: imageByte! ,target: MessageTarget.Host.rawValue)
            }
            else
            {
                if(defaultImage != nil)
                {

                    app!.publish(event: "say", message: "" ,data: defaultImage!, target: MessageTarget.Host.rawValue)
                }
            }
        }
    }
    
    func SendToAll(msgText: String)
    {
        if(app != nil)
        {
            app?.publish(event: msgText, message: "hello")
        }
    }
    
    func SendBroadcast(msgText: String)
    {
        if(app != nil)
        {
            app!.publish(event: "say", message: "Hello All of you", target: MessageTarget.Broadcast.rawValue)
        }
    }
    
    func SendToClient(msgText: String, clientID :String)
    {
        if(app != nil)
        {
            
            let  dic:NSDictionary  = ["Message":msgText, "ClientID":clientID]
            
            do {
            let data =  try NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions(rawValue: 0))
            
            let dataString = NSString( data: data, encoding: NSUTF8StringEncoding )

            print("data is \(dataString)")
            
            app!.publish(event: "say", message: dataString , target: MessageTarget.Host.rawValue)
            
            }
            catch let error as NSError
            {
                print("error \(error)")
            }
          
        }
    }
    
    
    func SendToManyClients(msgText: String)
    {
        if(app != nil)
        {
            app!.publish(event: msgText, message: "Hello Client 1", target: app!.getClients())
        }
    }
    
    func checkConnect() ->Int
    {
        var check = 0
        
        if(app != nil)
        {
            check = 1
        }
        else
        {
            check = 0
        }
        
        return check
    }
    
    func  getAllConnectedClients() ->[ChannelClient]
    {
        
        var test:[ChannelClient] = []
        
        if(app != nil)
        {
            NSLog("real count is %d",app!.getClients().count)
            
           test =  app!.getClients()
        }
        
         NSLog("client list count in ShareController is : %d", test.count)
        return test
    }
    
    func getImageData(dataofimage : NSData)
    {
        imageByte = dataofimage
        
    }
    func setUserName(userName : String)
    {
        userNameText = userName
        
    }
    
    func disconnect()
    {
        search.stop()
        
        if (app != nil)
        {
            app?.disconnect()
            
            services.removeAll(keepCapacity: false)
        }

    }
    
    func disconnect(connectiontype :Bool)
    {
        connectionType = connectiontype
        search.stop()
        
        if (app != nil)
        {
            app?.disconnect()
            
            services.removeAll(keepCapacity: false)
        }
        
    }
    
    @objc func clearServices()
    {
        services.removeAll(keepCapacity: false)
        
    }
    
    func  getMessageData() ->NSString
    {
        
        return msgString
    }
    
    func setClientName(clientName :String)
    {
        clientname = clientName
    }
    
    func getClientName() ->String{
        return clientname
    }
    
    func setClientID(clientID :String)
    {
        clientId = clientID
        
    }
    
    func getClientID() ->String{
        return clientId
    }
    func setChatViewStatus(chatViewstatus: Bool)
    {
       chatViewOpen = chatViewstatus
    }
    
    func getChatViewStatus()->Bool{
        return chatViewOpen
    }
    func clientFound(clientid:String)
    {
        var flag:Bool = true
        for (index,_) in chatContent1
        {
            if (index == clientid)
            {
                flag = false
            }
        }
        if (flag == true)
        {
            chatContent1[clientid] = [""]
        }
    }
    
    func messageSent(clientid: String, msg :String){
        
        for (id, _) in chatContent1
        {
            print(id)
            
           if (id == clientid)
            {
                var chat:String = "Me :"
                chat = chat + msg
                chatContent1[id]!.append(chat)
            }
        }
        print("%%%%%%%")
        print(chatContent1)
        


    }
    
    func getChatContent() ->[String:Array<String>]
    {
        return chatContent1
    }
    
    func setSenderid(clientid: String)
    {
        senderID = clientid
    }
    
    func getSenderID()->String
    {
        return senderID
    }
    
    
    func setSenderName(clientName : String)
    {
        var chat:String = clientName
        chat = chat + ":"
        let temp = getMessageData()
        let jsonData = temp.dataUsingEncoding(NSUTF8StringEncoding)
        
        do
        {
            let json: AnyObject? = try NSJSONSerialization.JSONObjectWithData(jsonData!, options:NSJSONReadingOptions.MutableContainers)
            let jsonDict = json as? NSDictionary
          
            if let jsonDict = jsonDict
            {
                let msg: String = jsonDict["message"] as! String

                chat = chat + msg
                chatContent1[senderID]!.append(chat)
            }
        }
        catch let error as NSError
        {
            print("error \(error)")
        }

    }
    
    func getnamebyID(id:String) -> String
    {
        for index in 0 ..< allIds.count
        {
            if (id == allIds[index])
            {
               return allNames[index]
                
            }
        }
        return ""
    }
    
    func updateChatContent(clientid :String, msg:String)
    {
        for (id, _) in chatContent1
        {
            if(id == clientid)
            {
                var name = getnamebyID(id)
                name = name + ":"
                name = name + msg
                chatContent1[id]!.append(name)
            }
        }
        
        print(chatContent1)
    }
    
    func setClientIDs(clientids: [String])
    {
        for var index=0;index < clientids.count;++index
        {
          print(clientids[index])
            allIds.append(clientids[index])
    
        }
        print(allIds.count)
    }
    
    func setClientNames(clientnames: [String])
    {
        for var index=0;index < clientnames.count;++index
        {
            allNames.append(clientnames[index])
        }
        
        print(allNames.count)
    }
    
}
