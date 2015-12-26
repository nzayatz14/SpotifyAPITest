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
        
        /*let session = Soundcloud.session
        session?.me({result in
        print("\(result)")
        })*/
        
        
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
    
    
    func getNextSongBatch(prevList: SPTListPage){
        
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
