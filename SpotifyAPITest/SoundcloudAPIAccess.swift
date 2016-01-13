//
//  SoundcloudAPIAccess.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/12/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import Foundation
import Soundcloud
import AFNetworking

var sharedSoundcloudAPIAccess = SoundcloudAPIAccess()

class SoundcloudAPIAccess: NSObject {
    
    var songs = [Track]()
    var songDatas = [String : NSData]()
    
    
    /**
     Function called to get the users saved songs
     
     - parameter void:
     - returns: void
     */
    func getSongs(completion: (songlist: [Track]) -> Void){
        let session = Soundcloud.session
        session?.me({result in
            result.response.result?.favorites({ tracklist in
                print("Tracklist count: \(tracklist.response.result?.count)")
                
                self.songs = (tracklist.response.result?.filter({$0.streamable == true}))!
                
                //call completion once the list has finished fetching
                completion(songlist: self.songs)
                
                //get related tracks example
                Track.relatedTracks(self.songs[0].identifier, completion: { result in
                    print("\(self.songs[0]) \n\n \(result)")
                })
                
            })
        })
    }
    
    
    /**
     Function called to get the data of one of the users saved songs in the songs array
     
     - parameter arrayVal: the index of the song in the array that needs to be accessed
     - parameter success: code block executed when the fetch has succeeded
     - parameter failure: code block executed when the fetch has failed
     - returns: void
     */
    func getSongFromSavedSongs(arrayVal: Int, success: (songData: NSData) -> Void, failure: (error: AnyObject) -> Void){
        
        //if the song is not already fetched, fetch it. If it is already fetched, return the saved data
        if songDatas["\(self.songs[arrayVal].identifier)"] == nil {
            
            //AFNetworking session manager and serialization
            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFHTTPResponseSerializer()
            
            //get the song data using AFNetworking
            manager.GET(songs[arrayVal].streamURL!.absoluteString , parameters: nil, success: { (theOperation, responseObject) -> Void in
                
                guard let data = responseObject as? NSData else {
                    failure(error: "Bad data fetched")
                    return
                }
                
                //cache the song data
                self.songDatas["\(self.songs[arrayVal].identifier)"] = data
                success(songData: data)
                
                }) { (theOperation, error) -> Void in
                    
                    failure(error: error)
                    
            }
        } else {
            
            //if the song is already saved, return the data
            if let data = songDatas["\(self.songs[arrayVal].identifier)"] {
                success(songData: data)
            }else{
                failure(error: "Bad saved data")
            }
        }
    }
    
    
    /**
     Function called to parse NSData into a JSON dictionary
     
     - parameter jsonData: the data object to be parsed
     - returns: the dictionary made out of that JSON data
    */
    func JSONParseDictionary(jsonData: NSData) -> [String: AnyObject]? {
        do {
            guard let dictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(rawValue: 0))  as? [String: AnyObject] else {
                return nil
            }
            return dictionary
        } catch let error as NSError {
            print(error)
            return nil
        }
        
    }
}