//
//  SoundCloudTabViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/20/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit

class SoundCloudTabViewController: UITabBarController {
    
    var topLabel: UILabel!
    var btnSoundcloud: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
    }
    
    
    /**
     Function called to set up the nav bar scheme
     
     - parameter void:
     - returns: void
    */
    func setupNavBar(){
        let width = self.navigationController!.navigationBar.frame.width / 2.0
        let height = self.navigationController!.navigationBar.frame.height
        
        topLabel = UILabel(frame: CGRectMake(0, 0, width, height))
        topLabel.text = "Sven"
        topLabel.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        topLabel.textColor = UIColor(colorLiteralRed: 109/255.0, green: 101/255.0, blue: 1, alpha: 1)
        topLabel.textAlignment = .Center
        topLabel.adjustsFontSizeToFitWidth = true
        
        let rightButton = UIButton(frame: CGRectMake(0, 0, 36, 36))
        rightButton.setImage(UIImage(named: "poweredBySoundcloud.png"), forState: UIControlState.Normal)
        rightButton.addTarget(self, action: "btnSoundcloudPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnSoundcloud = UIBarButtonItem(customView: rightButton)
        self.navigationItem.leftBarButtonItem = btnSoundcloud
        
        self.navigationController?.navigationBar.addSubview(topLabel)
        self.navigationController?.navigationBar.translucent = false
        topLabel.center.x = self.navigationController!.navigationBar.center.x
        topLabel.center.y = self.navigationController!.navigationBar.frame.minY
    }
    
    
    /**
     Function called when the Soundcloud button is pressed
     
     - parameter sender: the button pressed
     - returns: void
    */
    func btnSoundcloudPressed(sender: AnyObject){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://soundcloud.com/")!)
    }
}