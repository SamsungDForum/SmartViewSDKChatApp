
//
//  ChatMainViewController.swift
//  chatApp
//
//  Created by CHIRAG BAHETI on 31/07/15.
//  Copyright (c) 2015 CHIRAG BAHETI. All rights reserved.
//

import Foundation

import UIKit

import MSF

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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "messageReceivedWhileChatting:", name: "messageWhileChatting", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clientDisconnectedDuringChatAction:", name: "clientDisconnectedDuringChat", object: nil)
        let buttonBack: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        buttonBack.frame = CGRectMake(5, 5, 30, 30)
        buttonBack.setImage(UIImage(named:"backImage.png"), forState:UIControlState.Normal)
        buttonBack.addTarget(self, action: "leftNavButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonRefresh: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        buttonRefresh.frame = CGRectMake(300, 5, 30, 30)
        buttonRefresh.setImage(UIImage(named:"refresh_Image.png"), forState:UIControlState.Normal)
        buttonRefresh.addTarget(self, action: "rightNavButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonBack)
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
        
        var rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonRefresh)
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: true)
        
        SendButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        SendButton.backgroundColor = UIColor.blackColor()
        SendButton.layer.cornerRadius = 8
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        var blackcolor : UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        sendMsgText.layer.borderColor = blackcolor.CGColor
        sendMsgText.layer.borderWidth = 1
        selectedClientName = ShareController.sharedInstance.getClientName()
        selectedClientId = ShareController.sharedInstance.getClientID()
        loadPreviousChat()
        chatTableView.backgroundView = UIImageView(image: UIImage(named:"grunge_1920_hd.jpg"))
    }
    func loadPreviousChat()
    {
        var chatData:[String:Array<String>] = ShareController.sharedInstance.getChatContent()
        for( index,(val,message) ) in enumerate(chatData)
        {
            println(index)
            println(val)
            println(message)
            if(val == selectedClientId)
            {
                for var index = 0; index < message.count; index++
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
    
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        animateViewMoving(true, moveValue : 255)
           }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue : 255)
    
    }
    
    
    override func viewDidDisappear(animated: Bool) {
      ShareController.sharedInstance.setChatViewStatus(false)
    }
    func animateViewMoving(up : Bool, moveValue: CGFloat)
    {
        var movementDuration:NSTimeInterval = 0.3
        var movement: CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
        
    }
    
    
    
    func leftNavButtonClick(sender:UIButton!)
    {
        let viewControllers:[UIViewController] = self.navigationController!.viewControllers as! [UIViewController]
        self.navigationController?.popToViewController(viewControllers[ 2], animated: true)//
    }
    
    func rightNavButtonClick(sender:UIButton!)
    {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
   //     NSLog("client Name is %s", selectedClientName!)
        sendMsgText.borderStyle = UITextBorderStyle.RoundedRect;
    }
    
    override func viewWillDisappear(animated: Bool) {
        chatView = false
    }
    
    @IBAction func SendButtonAction(sender: AnyObject) {
        
   
        
        if(sendMsgText.text.isEmpty != true)
        {
            var curChat:String = "Me: "
            curChat += sendMsgText.text
            
            allChat.append(curChat)
            chatTableView.reloadData()
            
            var sendMsg:String = sendMsgText.text
            
            if (selectedClientId?.isEmpty != true)
            {
                let intstring = String(selectedClientId!)
                ShareController.sharedInstance.SendToClient(sendMsg ,clientID : selectedClientId!)
            }
            ShareController.sharedInstance.messageSent(selectedClientId!, msg: sendMsgText.text)
            
            
        }
        
        sendMsgText.text = ""
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath) as! UITableViewCell
        cell.backgroundView = UIImageView(image: UIImage(named:"grunge_1920_hd.jpg"))
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        cell.textLabel?.text = allChat[indexPath.row]
        cell.textLabel?.textColor = UIColor.whiteColor()
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ShareController.sharedInstance.getClientName()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
   
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        sendMsgText.becomeFirstResponder()
        sendMsgText.resignFirstResponder()
        
        return true
    }

    func textFieldShouldClear(textField: UITextField) -> Bool
    {
        return true
    }
    
    func clientDisconnectedDuringChatAction(notification: NSNotification!)
    {
        let client = notification.userInfo?["clientdisconnect"] as! ChannelClient
        
        var tempDict : [String:String] = (client.attributes as? [String : String])!
        var nameValue = tempDict["name"]
        
        println("name value is \(nameValue) and id is \(client.id)")
        if(client.id == ShareController.sharedInstance.getClientID())
        {
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
    
    
    func messageReceivedWhileChatting(notification :NSNotification!)
    {
        var msgData = ShareController.sharedInstance.getMessageData()
        let jsonData = msgData.dataUsingEncoding(NSUTF8StringEncoding)
        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonData!, options:NSJSONReadingOptions.MutableContainers, error: nil)
        let jsonDict = json as? NSDictionary
        if let jsonDict = jsonDict
        {
            var temp = jsonDict["sender"] as? String
            if(temp == selectedClientId)
            {
                var chat = selectedClientName!
                chat = chat + ":"
                var message = jsonDict["message"] as? String
                chat = chat + message!
                allChat.append(chat)
                chatTableView.reloadData()
            }
        }
    }
}