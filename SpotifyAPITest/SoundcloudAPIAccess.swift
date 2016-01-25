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
    
    var userSongs = [Track]()
    var svennedSongs = [Track]()
    var songDatas = [String : NSData]()
    var userData: User?
    
    
    /**
     Function called to get the user profile of the soundcloud user
     
     - parameter: void
     - returns: void
     */
    func getUser(completion: (user: User) -> Void){
        let session = Soundcloud.session
        session?.me({result in
            print("got me: \(result.response.result)\n\n")
            
            self.userData = result.response.result
            completion(user: self.userData!)
        })
    }
    
    
    /**
     Function called to get the users saved songs
     
     - parameter void:
     - returns: void
     */
    func getUserSongs(completion: (songlist: [Track]) -> Void){
        
        //if we already have the users information, use it
        if let currentUser = userData {
            currentUser.favorites({ tracklist in
                
                self.userSongs = (tracklist.response.result?.filter({$0.streamable == true}))!
                
                //call completion once the list has finished fetching
                completion(songlist: self.userSongs)
                
                //get related tracks example
                Track.relatedTracks(self.userSongs[0].identifier, completion: { result in
                    //print("\(self.songs[0]) \n\n \(result)")
                })
                
            })
            
        } else {
            
            let session = Soundcloud.session
            session?.me({result in
                print("got me: \(result.response.result)\n\n")
                
                result.response.result?.favorites({ tracklist in
                    //print("Tracklist count: \(tracklist.response.result?.count)")
                    
                    self.userSongs = (tracklist.response.result?.filter({$0.streamable == true}))!
                    
                    //call completion once the list has finished fetching
                    completion(songlist: self.userSongs)
                    
                    //get related tracks example
                    Track.relatedTracks(self.userSongs[0].identifier, completion: { result in
                        //print("\(self.songs[0]) \n\n \(result)")
                    })
                    
                })
            })
        }
    }
    
    
    /**
     Function called to get the svenned songs from the IDs
     
     - parameter void:
     - returns: void
     */
    func getSvennedSongs(trackIDs: [Int], completion: (songlist: [Track]) -> Void){
        Track.tracks(trackIDs, completion: { (result) -> Void in
            
            if result.response.isSuccessful {
                if let myResult = result.response.result {
                    self.svennedSongs = myResult
                }else{
                    print("Nothing in result")
                }
            } else {
                print(result.response.error)
            }
            
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
        if songDatas["\(self.userSongs[arrayVal].identifier)"] == nil {
            
            //AFNetworking session manager and serialization
            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFHTTPResponseSerializer()
            
            //get the song data using AFNetworking
            manager.GET(userSongs[arrayVal].streamURL!.absoluteString , parameters: nil, success: { (theOperation, responseObject) -> Void in
                
                guard let data = responseObject as? NSData else {
                    failure(error: "Bad data fetched")
                    return
                }
                
                //cache the song data
                self.songDatas["\(self.userSongs[arrayVal].identifier)"] = data
                success(songData: data)
                
                }) { (theOperation, error) -> Void in
                    
                    failure(error: error)
                    
            }
        } else {
            
            //if the song is already saved, return the data
            if let data = songDatas["\(self.userSongs[arrayVal].identifier)"] {
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
    
    
    /**
     Function called to get the image data of a song
     
     - parameter track: the track to get the image data of
     - parameter success: code block executed when the fetch has succeeded
     - parameter failure: code block executed when the fetch has failed
     - returns: void
     */
    func getSongArt(track: Track, success: (songData: NSData) -> Void, failure: (error: AnyObject) -> Void){
        if let url = track.artworkImageURL.highURL {
            
            //AFNetworking session manager and serialization
            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFHTTPResponseSerializer()
            
            //get the song data using AFNetworking
            manager.GET(url.absoluteString , parameters: nil, success: { (theOperation, responseObject) -> Void in
                
                guard let data = responseObject as? NSData else {
                    failure(error: "Bad data fetched")
                    return
                }
                
                success(songData: data)
                
                }) { (theOperation, error) -> Void in
                    
                    failure(error: error)
                    
            }
        }else{
            failure(error: "No Image URL")
        }
    }
}