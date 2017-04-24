
//
//  ChatMainViewController.swift
//  chatApp
//
//  Created by CHIRAG BAHETI on 31/07/15.
//  Copyright (c) 2015 CHIRAG BAHETI. All rights reserved.
//

import Foundation

import UIKit

import SmartView

class ChatMainViewController : UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var SendButton: UIButton!
  
    var selectedClientId:String?
    var selectedClientName:String?
    var chatView:Bool = false
    var allChat: [String] = []
    
    @IBOutlet weak var sendMsgText: UITextField!
    
    @IBOutlet weak var chatTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatView=true
        ShareController.sharedInstance.setChatViewStatus(chatView)
        self.navigationItem.title = "Chat App"
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        self.sendMsgText.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMainViewController.messageReceivedWhileChatting(_:)), name: NSNotification.Name(rawValue: "messageWhileChatting"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMainViewController.clientDisconnectedDuringChatAction(_:)), name: NSNotification.Name(rawValue: "clientDisconnectedDuringChat"), object: nil)
        let buttonBack: UIButton = UIButton(type: UIButtonType.custom)
        buttonBack.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
        buttonBack.setImage(UIImage(named:"backImage.png"), for:UIControlState())
        buttonBack.addTarget(self, action: #selector(ChatMainViewController.leftNavButtonClick(_:)), for: UIControlEvents.touchUpInside)
        
        let buttonRefresh: UIButton = UIButton(type: UIButtonType.custom)
        buttonRefresh.frame = CGRect(x: 300, y: 5, width: 30, height: 30)
        buttonRefresh.setImage(UIImage(named:"refresh_Image.png"), for:UIControlState())
        buttonRefresh.addTarget(self, action: #selector(ChatMainViewController.rightNavButtonClick(_:)), for: UIControlEvents.touchUpInside)
        
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonBack)
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
        
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonRefresh)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
        
        SendButton.setTitleColor(UIColor.white, for: UIControlState())
        SendButton.backgroundColor = UIColor.black
        SendButton.layer.cornerRadius = 8
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        let blackcolor : UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        sendMsgText.layer.borderColor = blackcolor.cgColor
        sendMsgText.layer.borderWidth = 1
        selectedClientName = ShareController.sharedInstance.getClientName()
        selectedClientId = ShareController.sharedInstance.getClientID()
        loadPreviousChat()
        chatTableView.backgroundView = UIImageView(image: UIImage(named:"grunge_1920_hd.jpg"))
    }
    
    func loadPreviousChat()
    {
        let chatData:[String:Array<String>] = ShareController.sharedInstance.getChatContent()
        
       // for val in chatData index,(val,message) )
            
        for (val, message) in chatData
        {
            print(val)
            print(message)
            if(val == selectedClientId)
            {
                for index in 0 ..< message.count
                {
                    if(message[index] != "")
                    {
                        allChat.append(message[index])
                        chatTableView.reloadData()
                    }
                }
            }
        }
        
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        animateViewMoving(true, moveValue : 255)
           }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(false, moveValue : 255)
    
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
      ShareController.sharedInstance.setChatViewStatus(false)
    }
    func animateViewMoving(_ up : Bool, moveValue: CGFloat)
    {
        let movementDuration:TimeInterval = 0.3
        let movement: CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
        
    }
    
    
    
    func leftNavButtonClick(_ sender:UIButton!)
    {
        let viewControllers:[UIViewController] = self.navigationController!.viewControllers
        self.navigationController?.popToViewController(viewControllers[ 2], animated: true)//
    }
    
    func rightNavButtonClick(_ sender:UIButton!)
    {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
   //     NSLog("client Name is %s", selectedClientName!)
        sendMsgText.borderStyle = UITextBorderStyle.roundedRect;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        chatView = false
    }
    
    @IBAction func SendButtonAction(_ sender: AnyObject) {
        
   
        
        if(sendMsgText.text!.isEmpty != true)
        {
            var curChat:String = "Me: "
            curChat += sendMsgText.text!
            
            allChat.append(curChat)
            chatTableView.reloadData()
            
            let sendMsg:String = sendMsgText.text!
            
            if (selectedClientId?.isEmpty != true)
            {
               // let intstring = String(selectedClientId!)
                ShareController.sharedInstance.SendToClient(sendMsg ,clientID : selectedClientId!)
            }
            ShareController.sharedInstance.messageSent(selectedClientId!, msg: sendMsgText.text!)
            
            
        }
        
        sendMsgText.text = ""
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        NSLog("all chat count is %d", allChat.count)
        
        var count:Int = 0
        
        if(allChat.count > 0)
        {
            count = allChat.count
        }
        else
        {
            count = 0
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
        cell.backgroundView = UIImageView(image: UIImage(named:"grunge_1920_hd.jpg"))
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        cell.textLabel?.text = allChat[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ShareController.sharedInstance.getClientName()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
   
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        sendMsgText.becomeFirstResponder()
        sendMsgText.resignFirstResponder()
        
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        return true
    }
    
    func clientDisconnectedDuringChatAction(_ notification: Notification!)
    {
        let client = notification.userInfo?["clientdisconnect"] as! ChannelClient
        
        var tempDict : [String:String] = (client.attributes as? [String : String])!
        let nameValue = tempDict["name"]
        
        print("name value is \(nameValue) and id is \(client.id)")
        if(client.id == ShareController.sharedInstance.getClientID())
        {
            let alertView = UIAlertController(title: "ChatApp", message: "Client Disconnected!! Please try again later...", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){
                UIAlertAction in
                NSLog("OK Pressed")
                let viewControllers:[UIViewController] = self.navigationController!.viewControllers
                self.navigationController?.popToViewController(viewControllers[ 2], animated: true)//
            }
            alertView.addAction(okAction)
            present(alertView, animated: true, completion: nil)
        }
    }
    
    func messageReceivedWhileChatting(_ notification :Notification!)
    {
        let msgData = ShareController.sharedInstance.getMessageData()
        let jsonData = msgData.data(using: String.Encoding.utf8.rawValue)
        
        do {
        //let json: AnyObject? = try JSONSerialization.jsonObject(with: jsonData!, options:JSONSerialization.ReadingOptions.mutableContainers)
        
        let json = try JSONSerialization.jsonObject(with: jsonData!, options:JSONSerialization.ReadingOptions.mutableContainers)    
            
        let jsonDict = json as? NSDictionary
        if let jsonDict = jsonDict
        {
            let temp = jsonDict["sender"] as? String
            if(temp == selectedClientId)
            {
                var chat = selectedClientName!
                chat = chat + ":"
                let message = jsonDict["message"] as? String
                chat = chat + message!
                allChat.append(chat)
                chatTableView.reloadData()
            }
        }
        } catch let error as NSError
        {
            print("error \(error)")
        }
    }
}
