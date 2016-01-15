	//
//  AllTVNetworkViewController.swift
//  chatApp
//
//  Created by CHIRAG BAHETI on 24/07/15.
//  Copyright (c) 2015 CHIRAG BAHETI. All rights reserved.
//

import Foundation
import UIKit

import MSF

class AllTVNetworkViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var didFindServiceObserver: AnyObject? = nil
    var didRemoveServiceObserver: AnyObject? = nil
    
    var selectedTVName:String?
    let activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    @IBOutlet weak var allTVNetworkView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        activityIndicatorView.frame = CGRectMake(50, 300, 10, 10)
        activityIndicatorView.center = self.view.center
        self.view.addSubview(activityIndicatorView)

        allTVNetworkView.delegate = self
        allTVNetworkView.dataSource = self
   
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "channelConnected:", name: "channelGetsConnected", object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "channelConnectedwithError:", name: "channelGetsConnectedWithError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backbuttonpressed:", name: "stopSearchonback", object: nil)
        self.navigationItem.title = "Chat App"
        
        let buttonBack: UIButton = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(5, 5, 30, 30)
        buttonBack.setImage(UIImage(named:"backImage.png"), forState:UIControlState.Normal)
        buttonBack.addTarget(self, action: "leftNavButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let buttonRefresh: UIButton = UIButton(type: UIButtonType.Custom)
        buttonRefresh.frame = CGRectMake(300, 5, 30, 30)
        buttonRefresh.setImage(UIImage(named:"refresh_Image.png"), forState:UIControlState.Normal)
        buttonRefresh.addTarget(self, action: "rightNavButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonBack)
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: true)
        allTVNetworkView.backgroundView = UIImageView(image: UIImage(named:"grunge_1920_hd.jpg"))
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonRefresh)
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: true)
    }
    
    func leftNavButtonClick(sender:UIButton!)
    {
        ShareController.sharedInstance.stopSearch(1)
        if let viewController = self.navigationController?.viewControllers.first
        {
            self.navigationController?.popToViewController(viewController, animated: true)
        }
    }
    
    func rightNavButtonClick(sender:UIButton!)
    {
        if (ShareController.sharedInstance.services.count != 0)
        {
            ShareController.sharedInstance.stopSearch(1)
        }
        else
        {
            ShareController.sharedInstance.searchServices()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
     
        didFindServiceObserver =  ShareController.sharedInstance.search.on(MSDidFindService) { [unowned self] notification in
            self.allTVNetworkView.reloadData()
        }
        
        didRemoveServiceObserver = ShareController.sharedInstance.search.on(MSDidRemoveService) {[unowned self] notification in
            self.allTVNetworkView.reloadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        ShareController.sharedInstance.search.off(didFindServiceObserver!)
        ShareController.sharedInstance.search.off(didRemoveServiceObserver!)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "stopSearchonback", object: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
              NSLog("count is %d", ShareController.sharedInstance.services.count)
        
        return ShareController.sharedInstance.services.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DeviceCell", forIndexPath: indexPath)
        cell.textLabel?.text = ShareController.sharedInstance.services[indexPath.row].name
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundView = UIImageView(image: UIImage(named:"grunge_1920_hd.jpg"))
        selectedTVName = ShareController.sharedInstance.services[indexPath.row].name
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        NSLog("Hello %@!", ShareController.sharedInstance.services[indexPath.row].name)
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Connect to TV"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if ShareController.sharedInstance.search.isSearching {
            // set "chatApp" as app ID and launch and connect the application on TV
            ShareController.sharedInstance.launchApp("chatApp", index: indexPath.row)
             self.activityIndicatorView.startAnimating()
        }
    }
    
    
   
    
    func channelConnected(notification: NSNotification!) {
          self.activityIndicatorView.stopAnimating()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let clientListViewController = storyBoard.instantiateViewControllerWithIdentifier("ClientListView") as! ClientListViewController
        self.navigationController?.pushViewController(clientListViewController, animated: true)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    }
    
    func backbuttonpressed(notification: NSNotification!) {
        if let viewController = self.navigationController?.viewControllers.first
        {
            self.navigationController?.popToViewController(viewController, animated: true)
        }
    }
    
   
    func channelConnectedwithError(notification: NSNotification!)
    {
        self.activityIndicatorView.stopAnimating()
        let alertView = UIAlertController(title: "ChatApp", message: "App not installed on TV. Please select another Device", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default){
            UIAlertAction in
            NSLog("OK Pressed")
            
        }
        alertView.addAction(okAction)
        presentViewController(alertView, animated: true, completion: nil)
          self.allTVNetworkView.reloadData()
    }
  
}