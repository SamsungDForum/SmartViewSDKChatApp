//
//  ClientListViewController.swift
//  chatApp
//
//  Created by CHIRAG BAHETI on 27/07/15.
//  Copyright (c) 2015 CHIRAG BAHETI. All rights reserved.
//

import Foundation
import UIKit

import MSF


class ClientListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var clientList:[ChannelClient] = []
    var selectedTVName:String?
    let activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var allIds:[String] = []
    var allNames: [String] = []
    var leftbuttonpressed:Bool = false
    @IBOutlet weak var allClientListView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allClientListView.delegate = self
        allClientListView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clientConnected:", name: "clientGetsConnected", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clientDisconnected:", name: "clientGetsDisconnected", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "channelDisconnected:", name: "channelGetsDisconnected", object: nil)
        self.navigationItem.title = "Chat App"
        
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
        
        activityIndicatorView.frame = CGRectMake(50, 300, 10, 10)
        activityIndicatorView.center = self.view.center
        self.view.addSubview(activityIndicatorView)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        allClientListView.backgroundView = UIImageView(image: UIImage(named:"grunge_1920_hd.jpg"))
        
    }
   
    
    func leftNavButtonClick(sender:UIButton!)
    {
        
         leftbuttonpressed = true
        ShareController.sharedInstance.disconnect(true)
         self.activityIndicatorView.startAnimating()

    }
    
    func rightNavButtonClick(sender:UIButton!)
    {
        allNames.removeAll(keepCapacity: false)
        allIds.removeAll(keepCapacity: false)
        
        clientList = ShareController.sharedInstance.getAllConnectedClients()
        
        for var index=0;index < clientList.count;++index
        {
            var tempDict : [String:String] = (clientList[index].attributes as? [String : String])!
            var nameValue = tempDict["name"]
            
            println("name value is \(nameValue) and id is \(clientList[index].id)")
            
            if(nameValue != String(UIDevice.currentDevice().name) && clientList[index].isHost != true)
            {
                allNames.append(nameValue!)
                
                allIds.append(clientList[index].id)
            }
        }
        
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(animated: Bool) {
      
        allClientListView.reloadData()
        
    }
     override func viewWillAppear(animated: Bool) {
        
        clientList = ShareController.sharedInstance.getAllConnectedClients()
        
        if(allNames.count > 0)
        {
            allNames.removeAll(keepCapacity: false)
        }
        
        if(allIds.count > 0)
        {
            allIds.removeAll(keepCapacity: false)
        }
        
        for var index=0;index < clientList.count;++index
        {
             var tempDict : [String:String] = (clientList[index].attributes as? [String : String])!
             var nameValue = tempDict["name"]
            
             println("name value is \(nameValue) and id is \(clientList[index].id)")
            
            if(nameValue != ShareController.sharedInstance.userNameText/*String(UIDevice.currentDevice().name)*/ && clientList[index].isHost != true)
            {
                allNames.append(nameValue!)
                
                allIds.append(clientList[index].id)
            }
        }
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        ShareController.sharedInstance.setClientIDs(allIds)
        ShareController.sharedInstance.setClientNames(allNames)
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        NSLog("client list count is %d", clientList.count)
        
        return allNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ClientCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = allNames[indexPath.row]
        cell.textLabel?.textColor = UIColor.whiteColor()
         cell.backgroundView = UIImageView(image: UIImage(named:"grunge_1920_hd.jpg"))
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        ShareController.sharedInstance.clientFound(allIds[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Connect to client"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let chatViewController = storyBoard.instantiateViewControllerWithIdentifier("ChatMainView") as! ChatMainViewController
        
        chatViewController.selectedClientId = allIds[indexPath.row]
 
        chatViewController.selectedClientName = allNames[indexPath.row]
        
        ShareController.sharedInstance.setClientName(allNames[indexPath.row])
        ShareController.sharedInstance.setClientID(allIds[indexPath.row])
        
        println("selected client id is \(allIds[indexPath.row]) and client name is \(allNames[indexPath.row])")
        
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    func clientConnected(notification: NSNotification!) {
        
        let client = notification.userInfo?["addClient"] as! ChannelClient
        
        var tempDict : [String:String] = (client.attributes as? [String : String])!
        var nameValue = tempDict["name"]
        
        println("name value is \(nameValue) and id is \(client.id)")
        
        allNames.append(nameValue!)
        
        allIds.append(client.id)
        
        allClientListView.reloadData()
    }
    
    func clientDisconnected(notification: NSNotification!) {
        
        let client = notification.userInfo?["removeClient"] as! ChannelClient
        
        var tempDict : [String:String] = (client.attributes as? [String : String])!
        var nameValue = tempDict["name"]
        
        println("name value is \(nameValue) and id is \(client.id)")
        
        for var index = 0; index < allNames.count; index++
        {
            if (client.id == allIds[index] )
            {
                allIds.removeAtIndex(index)
                allNames.removeAtIndex(index)
                
                allClientListView.reloadData()
            }
        }
    }
    

    func channelDisconnected(notification: NSNotification!)
    {
      
         self.activityIndicatorView.stopAnimating()
        leftbuttonpressed = false
        let viewControllers:[UIViewController] = self.navigationController!.viewControllers as! [UIViewController]
        self.navigationController?.popToViewController(viewControllers[ 1], animated: true)//

        
    }
 
    
}