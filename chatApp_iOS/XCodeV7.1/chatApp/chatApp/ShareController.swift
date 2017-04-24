

//
//  ShareController.swift
//  chatApp
//
//  Created by CHIRAG BAHETI on 09/07/15.
//  Copyright (c) 2015 CHIRAG BAHETI. All rights reserved.
//

import Foundation
import AssetsLibrary
import SmartView
import Darwin

class ShareController : ServiceSearchDelegate, ChannelDelegate
{
    static let sharedInstance = ShareController()
    
    let search = Service.search()
    var app: Application?
    var appURL: String = "http://prod-multiscreen-examples.s3-website-us-west-1.amazonaws.com/examples/photoshare/tv/"
    //var appURL: String = "http://www.google.com"
    var channelId: String = "com.samsung.multiscreen.chatApp"
    var isConnecting: Bool = false
    var services = [Service]()
    var connectionType:Bool = false
    var imageByte:Data?
    var userNameText : String = ""
    var defaultImage:Data?
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
    
    init () {
        search.delegate = self
    }
    
    func searchServices() {
        search.start()
        //   updateCastStatus()
    }
    
    func connect(_ service: Service) {
        search.stop()
        
        if (app != nil)
        {
            app?.disconnect()
        }
        
        app = service.createApplication(URL(string: appURL)! as AnyObject,channelURI: channelId, args: nil)
        app!.delegate = self
      //  app!.connectionTimeout = 5
        self.isConnecting = true
        //  self.updateCastStatus()
        app!.connect()
    }
    
    func stopSearch(_ status: Int)
    {
        refreshOrStop = status
        search.stop()
    }
    
   @objc func onClientConnect(_ client: ChannelClient)
    {
        // post a notification if a new client connects
        NotificationCenter.default.post(name: Notification.Name(rawValue: "clientGetsConnected"), object: self, userInfo: ["addClient":client])
    }
    
    ///  :param: client: The Client that just disconnected from the Channel
    @objc func onClientDisconnect(_ client: ChannelClient)
    {
        //post a notification if a client disconnects
        NotificationCenter.default.post(name: Notification.Name(rawValue: "clientGetsDisconnected"), object: self, userInfo: ["removeClient":client])
        
        //post a notification if a client disconnects during chat
        NotificationCenter.default.post(name: Notification.Name(rawValue: "clientDisconnectedDuringChat"), object: self, userInfo: ["clientdisconnect":client])
    }
    
    @objc func onConnect(_ client: ChannelClient?, error: NSError?) {
         NSLog("CONNECTED!!!!!!!!!!!!!!!!!!!!!")
        if (error != nil) {
            search.start()
            print(error?.localizedDescription)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "channelGetsConnectedWithError"), object: self, userInfo: nil)
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: "channelGetsConnected"), object: self, userInfo: nil)
        print("error is nil 4")
        }
        //    updateCastStatus()
    }
    
    @objc func onDisconnect(_ client: ChannelClient?, error: NSError?) {
        print(error)
        chatContent1.removeAll(keepingCapacity: true)
        NSLog("DISCONNECTED!!!!!!!!!!!!!!!!!!!!!")
        search.start()
        app = nil
        isConnecting = false

        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "channelGetsDisconnected"), object: self, userInfo: nil)
        
              //   updateCastStatus()
    }
    
     @objc func onMessage(_ message: Message)
    {
        NSLog("Message Received")
        print("message is \(message.data) from \(message.from)")
        let item:NSString = message.data as! NSString
        msgString = item
        let jsonData = item.data(using: String.Encoding.utf8.rawValue)
        
        do {
        let json = try JSONSerialization.jsonObject(with: jsonData!, options:JSONSerialization.ReadingOptions.mutableContainers)
        
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
          
                NotificationCenter.default.post(name: Notification.Name(rawValue: "messageWhileChatting"), object: self, userInfo: nil)
                
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
    
    @objc func onData(_ message: Message, payload: Data)
    {
        NSLog("Message Received")
    }
    
    
    @objc func onReady()
    {
        
    }


    @objc func onServiceFound(_ service: Service) {
        services.append(service)
        //    updateCastStatus()
    }
    
    @objc func onServiceLost(_ service: Service) {
        removeObject(&services,object: service)
        //  updateCastStatus()
    }
    
    @objc func onStop() {
         NotificationCenter.default.post(name: Notification.Name(rawValue: "stopSearchonback"), object: self, userInfo: nil)
        if(connectionType == true)
        {
            searchServices()
            connectionType = false
        }
        if (refreshOrStop == 1)
        {
            services.removeAll(keepingCapacity: false)
        }
    }
    
    func removeObject<T:Equatable>(_ arr:inout Array<T>, object:T) -> T? {
        
        if let found = arr.index(of: object) {
            return arr.remove(at: found)
        }
        return nil
    }
    
    func launchApp(_ appId: String, index: Int)
    {
        let tempService = services[index] as Service
        
        
        app = tempService.createApplication(appId as AnyObject, channelURI: channelId, args:nil)
        NSLog(channelId)
        app?.delegate = self
        self.isConnecting = true
        //connect with TV using username text as attribute
        app!.connect( ["name":userNameText])
    
    }
    
    func launchAppWithURL(_ appURL: String, index:Int, timeOut: Int)
    {
        let tempService = services[index] as Service
        
        app = tempService.createApplication(URL(string: appURL)! as AnyObject, channelURI: channelId, args: nil)
        
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
    
    func SendToHost(_ msgText: String)
    {
        if(app != nil)
        {
            if(imageByte != nil)
            {
                NSLog("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
                app!.publish(event: "say", message: "" as AnyObject?, data: imageByte! ,target: MessageTarget.Host.rawValue as AnyObject)
            }
            else
            {
                if(defaultImage != nil)
                {

                    app!.publish(event: "say", message: "" as AnyObject? ,data: defaultImage!, target: MessageTarget.Host.rawValue as AnyObject)
                }
            }
        }
    }
    
    func SendToAll(_ msgText: String)
    {
        if(app != nil)
        {
            app?.publish(event: msgText, message: "hello" as AnyObject?)
        }
    }
    
    func SendBroadcast(_ msgText: String)
    {
        if(app != nil)
        {
            app!.publish(event: "say", message: "Hello All of you" as AnyObject?, target: MessageTarget.Broadcast.rawValue as AnyObject)
        }
    }
    
    func SendToClient(_ msgText: String, clientID :String)
    {
        if(app != nil)
        {
            
            let  dic:NSDictionary  = ["Message":msgText, "ClientID":clientID]
            
            do {
            let data =  try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions(rawValue: 0))
            
            let dataString = NSString( data: data, encoding: String.Encoding.utf8.rawValue )

            print("data is \(dataString)")
            
            app!.publish(event: "say", message: dataString , target: MessageTarget.Host.rawValue as AnyObject)
            
            }
            catch let error as NSError
            {
                print("error \(error)")
            }
          
        }
    }
    
    
    func SendToManyClients(_ msgText: String)
    {
        if(app != nil)
        {
            app!.publish(event: msgText, message: "Hello Client 1" as AnyObject?, target: app!.getClients() as AnyObject)
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
    
    func getImageData(_ dataofimage : Data)
    {
        imageByte = dataofimage
        
    }
    func setUserName(_ userName : String)
    {
        userNameText = userName
        
    }
    
    func disconnect()
    {
        search.stop()
        
        if (app != nil)
        {
            app?.disconnect()
            
            services.removeAll(keepingCapacity: false)
        }

    }
    
    func disconnect(_ connectiontype :Bool)
    {
        connectionType = connectiontype
        search.stop()
        
        if (app != nil)
        {
            app?.disconnect()
            
            services.removeAll(keepingCapacity: false)
        }
        
    }
    
    @objc func clearServices()
    {
        services.removeAll(keepingCapacity: false)
        
    }
    
    func  getMessageData() ->NSString
    {
        
        return msgString
    }
    
    func setClientName(_ clientName :String)
    {
        clientname = clientName
    }
    
    func getClientName() ->String{
        return clientname
    }
    
    func setClientID(_ clientID :String)
    {
        clientId = clientID
        
    }
    
    func getClientID() ->String{
        return clientId
    }
    func setChatViewStatus(_ chatViewstatus: Bool)
    {
       chatViewOpen = chatViewstatus
    }
    
    func getChatViewStatus()->Bool{
        return chatViewOpen
    }
    func clientFound(_ clientid:String)
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
    
    func messageSent(_ clientid: String, msg :String){
        
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
    
    func setSenderid(_ clientid: String)
    {
        senderID = clientid
    }
    
    func getSenderID()->String
    {
        return senderID
    }
    
    
    func setSenderName(_ clientName : String)
    {
        var chat:String = clientName
        chat = chat + ":"
        let temp = getMessageData()
        let jsonData = temp.data(using: String.Encoding.utf8.rawValue)
        
        do
        {
           // let json: AnyObject = try JSONSerialization.jsonObject( with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as AnyObject

            let json: AnyObject = try JSONSerialization.jsonObject(with: jsonData!, options:JSONSerialization.ReadingOptions(rawValue: 0)) as AnyObject
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
    
    func getnamebyID(_ id:String) -> String
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
    
    func updateChatContent(_ clientid :String, msg:String)
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
    
    func setClientIDs(_ clientids: [String])
    {
        for index in 0 ..< clientids.count
        {
          print(clientids[index])
            allIds.append(clientids[index])
    
        }
        print(allIds.count)
    }
    
    func setClientNames(_ clientnames: [String])
    {
        for index in 0 ..< clientnames.count
        {
            allNames.append(clientnames[index])
        }
        
        print(allNames.count)
    }
    
}
