//
//  FirstViewController.swift
//  chatApp
//
//  Created by CHIRAG BAHETI on 09/07/15.
//  Copyright (c) 2015 CHIRAG BAHETI. All rights reserved.
//

import Foundation
import MobileCoreServices
import UIKit

class FirstViewController : UIViewController , UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    @IBOutlet weak var chatBtn: UIButton!
    
    @IBOutlet weak var aboutBtn: UIButton!
    
    @IBOutlet weak var userNameText: UILabel!
    @IBOutlet weak var userNameValue: UITextField!
    @IBOutlet weak var imageWindow: UIImageView!
    @IBOutlet weak var UploadImage: UIButton!
  
    @IBOutlet var dpImageView: UIImageView!
    var newMedia: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        chatBtn.backgroundColor = UIColor.blackColor()
        chatBtn.layer.cornerRadius = 8
        
        aboutBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        aboutBtn.backgroundColor = UIColor.blackColor()
        aboutBtn.layer.cornerRadius = 8
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "imageTapped:")
        imageWindow.addGestureRecognizer(tapGesture)
        imageWindow.userInteractionEnabled = true
        
        self.userNameValue.delegate = self
        userNameText.textColor = UIColor.whiteColor()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        self.navigationItem.title = "Chat App"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ShowCamera(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
                self.presentViewController(imagePicker, animated: true,
                    completion: nil)
                newMedia = true
                
        }
    }
    
    @IBAction func LoginButtonAction(sender: AnyObject) {
        
       // start searching the services
        ShareController.sharedInstance.searchServices()
       if(userNameValue.text!.isEmpty != true)
        {
            NSLog("Username is %@",userNameValue.text!)
            
            ShareController.sharedInstance.setUserName(userNameValue.text!)
        }
        else
       {
            let alertView = UIAlertController(title: "ChatApp", message: "Please enter your name to login!!", preferredStyle: .Alert)
        
            alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
            presentViewController(alertView, animated: true, completion: nil)
       }
        
    }
    
    @IBAction func AboutBtnAction(sender: AnyObject) {
    
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage]
            as! UIImage
        
        ShareController.sharedInstance.getImageData(UIImageJPEGRepresentation(image, 1.0)!)
        imageWindow.image = image
        if (newMedia == true) {
            UIImageWriteToSavedPhotosAlbum(image, self,
                "image:didFinishSavingWithError:contextInfo:", nil)
        }

    
    }
    
  /*  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        //let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage]
            as! UIImage
        
        ShareController.sharedInstance.getImageData(UIImageJPEGRepresentation(image, 1.0)!)
            imageWindow.image = image
        if (newMedia == true) {
            UIImageWriteToSavedPhotosAlbum(image, self,
                "image:didFinishSavingWithError:contextInfo:", nil)
        }
    }
*/
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                message: "Failed to save image",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true,
                completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
       
        
    }
    
    func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if gesture.view is UIImageView {
            print("Image Tapped")
            ShowCamera(self)
        }
    }
    
     func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        userNameValue.becomeFirstResponder()
        userNameValue.resignFirstResponder()
        
        return true
    }
}