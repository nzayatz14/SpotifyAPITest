//
//  GeneralSettingsViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/25/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import Soundcloud

class GeneralSettingsViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    /**
     Function called when the exit button is pressed
     
     - parameter sender: the button pressed
     - returns: void
    */
    @IBAction func btnExitPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /**
     Function called when the logout button is pressed
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnLogoutPressed(sender: AnyObject) {
        
        //logout
        let session = Soundcloud.session
        session?.destroy()
        
        let navController = UIApplication.sharedApplication().windows[0].rootViewController as! UINavigationController
        let initialViewController: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("Login")
        
        navController.popToRootViewControllerAnimated(false)
        navController.pushViewController(initialViewController, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
