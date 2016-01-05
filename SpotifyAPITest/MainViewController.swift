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
    
    
    var session: SPTSession!
    var myTotalList: SPTListPage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let userDefault = NSUserDefaults()
        
        //decode current session
        let sessionData = userDefault.objectForKey("currentSession") as! NSData
        session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionData) as! SPTSession
        
        //get user information for session
        SPTRequest.userInformationForUserInSession(session, callback: { (error, user) in
            
            if error != nil {
                print("Me Error: \(error)")
                return
            }
            
            print("\(user.displayName)")
            
            self.getAllSongs()
        })
        
    }
    
    
    /**
     Function called to get all of the users songs
     
     - parameter void:
     - returns: void
    */
    func getAllSongs(){
        
        myTotalList = SPTListPage()
        
        SPTRequest.savedTracksForUserInSession(session, callback: { (error, songs) in
            
            if error != nil {
                print("Me Error: \(error)")
                return
            }
            
            if let myList = songs as? SPTListPage {
                self.myTotalList = self.myTotalList.pageByAppendingPage(myList)
                self.getNextSongBatch(myList)
            }
        })
    }
    
    
    /**
     Function called to get the next batch of songs in the users list
     
     - parameter prevList: the previous batch of songs
     - returns: void
    */
    func getNextSongBatch(prevList: SPTListPage){
        
        //if there is a next page
        if prevList.hasNextPage {
            prevList.requestNextPageWithSession(session, callback: { (error, nextList) in
                
                if error != nil {
                    print("Me Error: \(error)")
                    return
                }
                
                if let myList = nextList as? SPTListPage {
                    self.myTotalList = self.myTotalList.pageByAppendingPage(myList)
                    self.getNextSongBatch(myList)
                }
            })
        }else{
            print("Done!\n \(myTotalList.items)")
        }
    }
    
    
}
