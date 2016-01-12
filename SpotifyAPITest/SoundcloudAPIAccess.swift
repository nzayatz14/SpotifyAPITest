//
//  SoundcloudAPIAccess.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/12/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import Foundation
import Soundcloud

var sharedSoundcloudAPIAccess = SoundcloudAPIAccess()

class SoundcloudAPIAccess: NSObject {
    
    var songs = [Track]()
    var songDatas = [String : NSData]()
    
    
    /**
     Function called to get the users saved songs
     
     - parameter void:
     - returns: void
    */
    func getSongs(){
        let session = Soundcloud.session
        session?.me({result in
            //print("\(result)")
            result.response.result?.favorites({ tracklist in
                print("Tracklist count: \(tracklist.response.result?.count)")
                
                self.songs = (tracklist.response.result?.filter({$0.streamable == true}))!
                
                Track.relatedTracks(self.songs[0].identifier, completion: { result in
                    print("\(self.songs[0]) \n\n \(result)")
                })
                
            })
        })
    }
    
    
    /**
     Function called to get the data of one of the users saved songs in the songs array
     
     - parameter arrayVal: the index of the song in the array that needs to be accessed
     - returns: the data to play the song
    */
    func getSongFromSavedSongs(arrayVal: Int) -> NSData{
        var songData: NSData!
        
        if songDatas["\(songs[arrayVal].identifier)"] == nil {
            songData = NSData(contentsOfURL: songs[arrayVal].streamURL!)
            songDatas["\(songs[arrayVal].identifier)"] = songData
        }else{
            songData = songDatas["\(songs[arrayVal].identifier)"]
        }
        
        return songData
    }
}