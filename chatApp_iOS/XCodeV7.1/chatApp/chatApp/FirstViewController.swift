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
        
        chatBtn.setTitleColor(UIColor.white, for: UIControlState())
        chatBtn.backgroundColor = UIColor.black
        chatBtn.layer.cornerRadius = 8
        
        aboutBtn.setTitleColor(UIColor.white, for: UIControlState())
        aboutBtn.backgroundColor = UIColor.black
        aboutBtn.layer.cornerRadius = 8
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FirstViewController.imageTapped(_:)))
        imageWindow.addGestureRecognizer(tapGesture)
        imageWindow.isUserInteractionEnabled = true
        
        self.userNameValue.delegate = self
        userNameText.textColor = UIColor.white
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "grunge_1920_hd.jpg")!)
        self.navigationItem.title = "Chat App"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ShowCamera(_ sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.front
                self.present(imagePicker, animated: true,
                    completion: nil)
                newMedia = true
                
        }
    }
    
    @IBAction func LoginButtonAction(_ sender: AnyObject) {
        
       // start searching the services
        ShareController.sharedInstance.searchServices()
       if(userNameValue.text!.isEmpty != true)
        {
            NSLog("Username is %@",userNameValue.text!)
            
            ShareController.sharedInstance.setUserName(userNameValue.text!)
        }
        else
       {
            let alertView = UIAlertController(title: "ChatApp", message: "Please enter your name to login!!", preferredStyle: .alert)
        
            alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
            present(alertView, animated: true, completion: nil)
       }
        
    }
    
    @IBAction func AboutBtnAction(_ sender: AnyObject) {
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        self.dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage]
            as! UIImage
        
        ShareController.sharedInstance.getImageData(UIImageJPEGRepresentation(image, 1.0)!)
        imageWindow.image = image
        if (newMedia == true) {
            UIImageWriteToSavedPhotosAlbum(image, self,
                "image:didFinishSavingWithError:contextInfo:", nil)
            
          //  UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            
         //   UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
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
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

//     func image(_ image: UIImage, didFinishSavingWithError error: NSErrorPointer?, contextInfo:UnsafeRawPointer) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                message: "Failed to save image",
                preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true,
                completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       
        
    }
    
    func imageTapped(_ gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if gesture.view is UIImageView {
            print("Image Tapped")
            ShowCamera(self)
        }
    }
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        userNameValue.becomeFirstResponder()
        userNameValue.resignFirstResponder()
        
        return true
    }
}
