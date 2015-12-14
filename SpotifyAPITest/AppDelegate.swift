//
//  AppDelegate.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 11/13/15.
//  Copyright © 2015 Nick Zayatz. All rights reserved.
//

import UIKit
//import Soundcloud
import Spotify

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let spotifyClientID = "173e2d7724a74fadb4e54946c0e180d1"
    let spotifyCallbackURL = "spotifyAPITest://loginCallback"
    let spotifyTokenSwapURL = "http://localhost:1234/swap"
    let spotifyTokenRefreshServiceURL = "http://localhost:1234/refresh"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        /*Soundcloud.clientIdentifier = "6c9090264a265d91bba9b915ec9cc0c5"
        Soundcloud.clientSecret  = "179c12371d2f76e030bfb689d3e73582"
        Soundcloud.redirectURI = "http://www.zipsyapp.com/"*/
        
        SPTAuth.defaultInstance().clientID = spotifyClientID
        SPTAuth.defaultInstance().redirectURL = NSURL(string: spotifyCallbackURL)
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthPlaylistModifyPublicScope]
        
        
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if SPTAuth.defaultInstance().canHandleURL(url) {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { (error: NSError!, Session: SPTSession!) in
                
                if error != nil {
                    print("Error logging in: \(error)")
                    return
                }
                
                
                //save current session
                let sessionData = NSKeyedArchiver.archivedDataWithRootObject(Session)
                
                let userDefault = NSUserDefaults.standardUserDefaults()
                
                userDefault.setObject(sessionData, forKey: "currentSession")
                userDefault.synchronize()
                
                NSNotificationCenter.defaultCenter().postNotificationName("loginDone", object: nil)
                
                
                
            })
            
            return true
        }else {
            
            print("Not a spotify thing")
            return false
        }
    }
}

