//
//  ServerClientDecisionViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/25/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit

class ServerClientDecisionViewController: UIViewController {
    
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var btnHost: UIButton!
    @IBOutlet weak var btnClient: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarHidden = true
        self.navigationController?.navigationBarHidden = true
    }
    
    
    /**
     Function called when the user opts to host a playlist
     
     - parameter sender: the button pressed
     - returns: void
    */
    @IBAction func btnHostPressed(sender: AnyObject) {
        let nextVC = storyboard?.instantiateViewControllerWithIdentifier("CreateSession") as! CreateBluetoothSessionViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    /**
     Function called when the user opts not to host a playlist
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnClientPressed(sender: AnyObject) {
        let nextVC = storyboard?.instantiateViewControllerWithIdentifier("ConnectToSession") as! ConnectToBluetoothSessionViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
}
