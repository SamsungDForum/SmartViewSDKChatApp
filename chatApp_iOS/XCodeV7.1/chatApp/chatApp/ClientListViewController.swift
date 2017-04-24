//
//  ClientListViewController.swift
//  chatApp
//
//  Created by CHIRAG BAHETI on 27/07/15.
//  Copyright (c) 2015 CHIRAG BAHETI. All rights reserved.
//

import Foundation
import UIKit

import SmartView


class ClientListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var clientList:[ChannelClient] = []
    var selectedTVName:String?
    let activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var allIds:[String] = []
    var allNames: [String] = []
    var leftbuttonpressed:Bool = false
    @IBOutlet weak var allClientListView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allClientListView.delegate = self
        allClientListView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ClientListViewController.clientConnected(_:)), name: NSNotification.Name(rawValue: "clientGetsConnected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ClientListViewController.clientDisconnected(_:)), name: NSNotification.Name(rawValue: "clientGetsDisconnected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ClientListViewController.channelDisconnected(_:)), name: NSNotification.Name(rawValue: "channelGetsDisconnected"), object: nil)
        self.navigationItem.title = "Chat App"
        
        let buttonBack: UIButton = UIButton(type: UIButtonType.custom)
        buttonBack.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
        buttonBack.setImage(UIImage(named:"backImage.png"), for:UIControlState())
        buttonBack.addTarget(self, action: #selector(ClientListViewController.leftNavButtonClick(_:)), for: UIControlEvents.touchUpInside)
        
        let buttonRefresh: UIButton = UIButton(type: UIButtonType.custom)
        buttonRefresh.frame = CGRect(x: 300, y: 5, width: 30, height: 30)
        buttonRefresh.setImage(UIImage(named:"refresh_Image.png"), for:UIControlState())
        buttonRefresh.addTarget(self, action: #selector(ClientListViewController.rightNavButtonClick(_:)), for: UIControlEvents.touchUpInside)
        
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonBack)
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
        
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonRefresh)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
        
        activityIndicatorView.frame = CGRect(x: 50, y: 300, width: 10, height: 10)
        activityIndicatorView.center = self.view.center
        self.view.addSubview(activityIndicatorView)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        allClientListView.backgroundView = UIImageView(image: UIImage(named:"grunge_1920_hd.jpg"))
    }
   
    
    func leftNavButtonClick(_ sender:UIButton!)
    {
        
         leftbuttonpressed = true
        ShareController.sharedInstance.disconnect(true)
         self.activityIndicatorView.startAnimating()

    }
    
    func rightNavButtonClick(_ sender:UIButton!)
    {
        allNames.removeAll(keepingCapacity: false)
        allIds.removeAll(keepingCapacity: false)
        
        clientList = ShareController.sharedInstance.getAllConnectedClients()
        
        for index in 0 ..< clientList.count
        {
            var tempDict : [String:String] = (clientList[index].attributes as? [String : String])!
            let nameValue = tempDict["name"]
            
            print("name value is \(nameValue) and id is \(clientList[index].id)")
            
            if(nameValue != String(UIDevice.current.name) && clientList[index].isHost != true)
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
    override func viewWillDisappear(_ animated: Bool) {
      
        allClientListView.reloadData()
        
    }
     override func viewWillAppear(_ animated: Bool) {
        
        clientList = ShareController.sharedInstance.getAllConnectedClients()
        
        if(allNames.count > 0)
        {
            allNames.removeAll(keepingCapacity: false)
        }
        
        if(allIds.count > 0)
        {
            allIds.removeAll(keepingCapacity: false)
        }
        
        for index in 0 ..< clientList.count
        {
             var tempDict : [String:String] = (clientList[index].attributes as? [String : String])!
             let nameValue = tempDict["name"]
            
             print("name value is \(nameValue) and id is \(clientList[index].id)")
            
            if(nameValue != ShareController.sharedInstance.userNameText/*String(UIDevice.currentDevice().name)*/ && clientList[index].isHost != true)
            {
                allNames.append(nameValue!)
                
                allIds.append(clientList[index].id)
            }
        }
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        ShareController.sharedInstance.setClientIDs(allIds)
        ShareController.sharedInstance.setClientNames(allNames)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        NSLog("client list count is %d", clientList.count)
        
        return allNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath) 
        
        cell.textLabel?.text = allNames[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
         cell.backgroundView = UIImageView(image: UIImage(named:"grunge_1920_hd.jpg"))
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        ShareController.sharedInstance.clientFound(allIds[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Connect to client"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let chatViewController = storyBoard.instantiateViewController(withIdentifier: "ChatMainView") as! ChatMainViewController
        
        chatViewController.selectedClientId = allIds[indexPath.row]
 
        chatViewController.selectedClientName = allNames[indexPath.row]
        
        ShareController.sharedInstance.setClientName(allNames[indexPath.row])
        ShareController.sharedInstance.setClientID(allIds[indexPath.row])
        
        print("selected client id is \(allIds[indexPath.row]) and client name is \(allNames[indexPath.row])")
        
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    func clientConnected(_ notification: Notification!) {
        
        let client = notification.userInfo?["addClient"] as! ChannelClient
        
        var tempDict : [String:String] = (client.attributes as? [String : String])!
        let nameValue = tempDict["name"]
        
        print("name value is \(nameValue) and id is \(client.id)")
        
        allNames.append(nameValue!)
        
        allIds.append(client.id)
        
        allClientListView.reloadData()
    }
    
    func clientDisconnected(_ notification: Notification!) {
        
        let client = notification.userInfo?["removeClient"] as! ChannelClient
        
        var tempDict : [String:String] = (client.attributes as? [String : String])!
        let nameValue = tempDict["name"]
        
        print("name value is \(nameValue) and id is \(client.id)")
        
        for index in 0 ..< allNames.count
        {
            if (client.id == allIds[index] )
            {
                allIds.remove(at: index)
                allNames.remove(at: index)
                
                allClientListView.reloadData()
            }
        }
    }
    

    func channelDisconnected(_ notification: Notification!) {
      
        self.activityIndicatorView.stopAnimating()
        leftbuttonpressed = false
        
        if let viewController = self.navigationController?.viewControllers.first
        {
            self.navigationController?.popToViewController(viewController, animated: true)
        }
    }
 
    
}
