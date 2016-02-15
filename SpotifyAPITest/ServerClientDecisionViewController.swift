//
//  ServerClientDecisionViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/25/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import Soundcloud
import FlowBarButtonItem

class ServerClientDecisionViewController: UIViewController {
    
    
    @IBOutlet weak var lblCurrentLogin: UILabel!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var btnHost: UIButton!
    @IBOutlet weak var btnClient: UIButton!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sharedSoundcloudAPIAccess.getUser { (user) -> Void in
            self.user = user
            self.lblCurrentLogin.text = "Currently logged in as: \(user.username)"
            self.lblCurrentLogin.hidden = false
        }
        
        //crop the background image
        let standardCrop = CGRect(x: (imgBackground.image!.size.width - UIScreen.mainScreen().bounds.width)/2.0 , y: fmax((imgBackground.image!.size.height - UIScreen.mainScreen().bounds.height), 0) , width: UIScreen.mainScreen().bounds.width, height: imgBackground.image!.size.height)
        
        logMsg("\(standardCrop)")
        
        if let standardThumb = CGImageCreateWithImageInRect(imgBackground.image!.CGImage, standardCrop) {
            let newImage = UIImage(CGImage: standardThumb, scale: 1.0, orientation: UIImageOrientation.Up)
            logMsg("\(newImage)")
            
            imgBackground.image = newImage
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    
    //make sure the view only goes into portrait mode
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    /**
     Function called when the user opts to host a playlist
     
     - parameter sender: the button pressed
     - returns: void
    */
    @IBAction func btnHostPressed(sender: AnyObject) {
        let nextVC = storyboard?.instantiateViewControllerWithIdentifier("PlaybackType") as! PlaybackTypeViewController
        nextVC.user = user
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    /**
     Function called when the user opts not to host a playlist
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnClientPressed(sender: AnyObject) {
        let nextVC = storyboard?.instantiateViewControllerWithIdentifier("ConnectToSession") as! ConnectToBluetoothSessionViewController
        nextVC.user = user
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
}
