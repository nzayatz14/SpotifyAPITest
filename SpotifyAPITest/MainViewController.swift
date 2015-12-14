//
//  MainViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 11/13/15.
//  Copyright © 2015 Nick Zayatz. All rights reserved.
//

import UIKit
//import Soundcloud
import Spotify

class MainViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /*let session = Soundcloud.session
        session?.me({result in
        print("\(result)")
        })*/
        
        
        let userDefault = NSUserDefaults()
        
        //decode current session
        let sessionData = userDefault.objectForKey("currentSession") as! NSData
        let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionData) as! SPTSession
        
        //get user information for session
        SPTRequest.userInformationForUserInSession(session, callback: { (error, user) in
            
            if error != nil {
                print("Me Error: \(error)")
                return
            }
            
            print("\(user.displayName)")
            
            })
        
    }
    
    
}
