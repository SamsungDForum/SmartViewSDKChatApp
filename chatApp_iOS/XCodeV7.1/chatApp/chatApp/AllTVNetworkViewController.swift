//
//  AllTVNetworkViewController.swift
//  chatApp
//
//  Created by CHIRAG BAHETI on 24/07/15.
//  Copyright (c) 2015 CHIRAG BAHETI. All rights reserved.
//

import Foundation
import UIKit

import SmartView

class AllTVNetworkViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var didFindServiceObserver: AnyObject? = nil
    var didRemoveServiceObserver: AnyObject? = nil
    
    var selectedTVName:String?
    let activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    @IBOutlet weak var allTVNetworkView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        activityIndicatorView.frame = CGRect(x: 50, y: 300, width: 10, height: 10)
        activityIndicatorView.center = self.view.center
        self.view.addSubview(activityIndicatorView)

        allTVNetworkView.delegate = self
        allTVNetworkView.dataSource = self
   
        NotificationCenter.default.addObserver(self, selector: #selector(AllTVNetworkViewController.channelConnected(_:)), name: NSNotification.Name(rawValue: "channelGetsConnected"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(AllTVNetworkViewController.channelConnectedwithError(_:)), name: NSNotification.Name(rawValue: "channelGetsConnectedWithError"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AllTVNetworkViewController.backbuttonpressed(_:)), name: NSNotification.Name(rawValue: "stopSearchonback"), object: nil)
        self.navigationItem.title = "Chat App"
        
        let buttonBack: UIButton = UIButton(type: UIButtonType.custom)
        buttonBack.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
        buttonBack.setImage(UIImage(named:"backImage.png"), for:UIControlState())
        buttonBack.addTarget(self, action: #selector(AllTVNetworkViewController.leftNavButtonClick(_:)), for: UIControlEvents.touchUpInside)
        
        let buttonRefresh: UIButton = UIButton(type: UIButtonType.custom)
        buttonRefresh.frame = CGRect(x: 300, y: 5, width: 30, height: 30)
        buttonRefresh.setImage(UIImage(named:"refresh_Image.png"), for:UIControlState())
        buttonRefresh.addTarget(self, action: #selector(AllTVNetworkViewController.rightNavButtonClick(_:)), for: UIControlEvents.touchUpInside)
        
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonBack)
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
        allTVNetworkView.backgroundView = UIImageView(image: UIImage(named:"grunge_1920_hd.jpg"))
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonRefresh)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
    }
    
    func leftNavButtonClick(_ sender:UIButton!)
    {
        ShareController.sharedInstance.stopSearch(1)
        if let viewController = self.navigationController?.viewControllers.first
        {
            self.navigationController?.popToViewController(viewController, animated: true)
        }
    }
    
    func rightNavButtonClick(_ sender:UIButton!)
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

    override func viewWillAppear(_ animated: Bool) {
     
        didFindServiceObserver =  ShareController.sharedInstance.search.on(MSDidFindService) { [unowned self] notification in
            self.allTVNetworkView.reloadData()
        }
        
        didRemoveServiceObserver = ShareController.sharedInstance.search.on(MSDidRemoveService) {[unowned self] notification in
            self.allTVNetworkView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ShareController.sharedInstance.search.off(didFindServiceObserver!)
        ShareController.sharedInstance.search.off(didRemoveServiceObserver!)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "stopSearchonback"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
              NSLog("count is %d", ShareController.sharedInstance.services.count)
        
        return ShareController.sharedInstance.services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        cell.textLabel?.text = ShareController.sharedInstance.services[indexPath.row].name
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundView = UIImageView(image: UIImage(named:"grunge_1920_hd.jpg"))
        selectedTVName = ShareController.sharedInstance.services[indexPath.row].name
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        NSLog("Hello %@!", ShareController.sharedInstance.services[indexPath.row].name)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Connect to TV"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if ShareController.sharedInstance.search.isSearching {
            // set "chatApp" as app ID and launch and connect the application on TV
            ShareController.sharedInstance.launchApp("chatApp.17", index: indexPath.row)
             self.activityIndicatorView.startAnimating()
        }
    }
    
    func channelConnected(_ notification: Notification!) {
        
        print("channelConnected success")
        self.activityIndicatorView.stopAnimating()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let clientListViewController = storyBoard.instantiateViewController(withIdentifier: "ClientListView") as! ClientListViewController
        self.navigationController?.pushViewController(clientListViewController, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    }
    
    func backbuttonpressed(_ notification: Notification!) {
        if let viewController = self.navigationController?.viewControllers.first
        {
            self.navigationController?.popToViewController(viewController, animated: true)
        }
    }
    
   
    func channelConnectedwithError(_ notification: Notification!)
    {
        self.activityIndicatorView.stopAnimating()
        let alertView = UIAlertController(title: "ChatApp", message: "App not installed on TV. Please select another Device", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){
            UIAlertAction in
            NSLog("OK Pressed")
            
        }
        alertView.addAction(okAction)
        present(alertView, animated: true, completion: nil)
          self.allTVNetworkView.reloadData()
    }
  
}
