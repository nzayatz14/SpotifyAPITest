//
//  ViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 11/13/15.
//  Copyright © 2015 Nick Zayatz. All rights reserved.
//

import UIKit
import Soundcloud
import Spotify

class LoginViewController: UIViewController {
    
    
    let spotifyClientID = "173e2d7724a74fadb4e54946c0e180d1"
    let spotifyCallbackURL = "spotifyAPITest://loginCallback"
    let spotifyTokenSwapURL = "http://localhost:1234/swap"
    let spotifyTokenRefreshServiceURL = "http://localhost:1234/refresh"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        if (Soundcloud.session != nil) {
        
        }
        
        let auth = SPTAuth.defaultInstance()
        
        //if there is a session saved in userDefaults, get it
        let userDefault = NSUserDefaults()
        
        if let sessionData = userDefault.objectForKey("currentSession") as? NSData {
            if let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionData) as? SPTSession {
                auth.session = session
                auth.tokenSwapURL = NSURL(string: spotifyTokenSwapURL)
                auth.tokenRefreshURL = NSURL(string: spotifyTokenRefreshServiceURL)
            }
        }
        
        
        //if there is no session, begin checking for a login
        if auth.session == nil {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishedLogin", name: "loginDone", object: nil)
            return
        }
        
        /*//if there is a valid session, continue to next VC
        if auth.session.isValid() {
        self.presentViewController(self.storyboard!.instantiateViewControllerWithIdentifier("Main"), animated: true, completion: nil)
        }*/
        
        //if the session needs refreshing, refresh it then continue to next VC
        if auth.hasTokenRefreshService {
            print("attempted renew")
            
            if !auth.session.isValid() {
                auth.renewSession(auth.session, callback: { (error, session) in
                    
                    if (error != nil) {
                        print("Error renewing token: \(error)")
                        return
                    }
                    
                    auth.session = session
                    
                    print("Renew")
                    self.presentViewController(self.storyboard!.instantiateViewControllerWithIdentifier("Main"), animated: true, completion: nil)
                })
            }
        }else{
            print("No Renew")
        }
    }
    
    
    /**
     Function called when the user has finished a new login
     
     - parameter void:
     - returns: void
     */
    func finishedLogin(){
        
        print("finished login")
        let userDefault = NSUserDefaults()
        
        let sessionData = userDefault.objectForKey("currentSession")
        
        if sessionData != nil {
            self.presentViewController(self.storyboard!.instantiateViewControllerWithIdentifier("Main"), animated: true, completion: nil)
        }else{
            print("session is nil")
        }
    }
    
    
    /**
     Function called when the login button is pressed
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnLoginPressed(sender: AnyObject) {
        
        let spotAuth = SPTAuth.defaultInstance()
        let loginURL = spotAuth.loginURL
        
        //let loginURL = SPTAuth.loginURLForClientId(spotifyClientID, withRedirectURL: NSURL(string: spotifyCallbackURL), scopes: [SPTAuthPlaylistModifyPublicScope, SPTAuthUserLibraryReadScope], responseType: "code")
        
        UIApplication.sharedApplication().openURL(loginURL)
        
    }
    
    
    /**
     Function called when the soundcloud login button is pressed
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnSoundCloudLoginPressed(sender: AnyObject) {
        Session.login(self, completion: { response in
            if response.response.isSuccessful {
                self.navigationController?.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("ServerClientDecision"), animated: true)
            }else{
                print(response.response.error)
            }
        })
    }
    
    
}

