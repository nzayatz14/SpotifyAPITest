//
//  SongPlayer.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/15/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Soundcloud


var sharedSongPlayer = SongPlayer()

class SongPlayer: NSObject {
    
     var audioStreamer: AVQueuePlayer?
    var currentlyPlaying: Track?
    var nextPlaying: Track?
    
    
    /**
     Function called to init the audioStreamer with a new song
     
     - parameter url: the track that should be streamed
     - returns: void
    */
    func initPlayerWithTrack(track: Track){
        
        currentlyPlaying = track
        
        audioStreamer = AVQueuePlayer(URL: track.streamURL!)
        audioStreamer?.play()
        audioStreamer?.actionAtItemEnd = AVPlayerActionAtItemEnd.Advance
        
        loadNextSong()
        
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: audioStreamer?.currentItem)
    }
    
    
    /**
     Function called to wipe the current audio streamer
     
     - parameter void:
     - returns: void
    */
    func clearStreamer(){
        audioStreamer?.pause()
        audioStreamer = nil
    }
    
    
    /**
     Function called to add the next song to the queue
     
     - parameter: void
     - returns: void
     */
    func loadNextSong(){
        
        //select a song at random
        srand(UInt32(time(nil)))
        let randomSong = rand() % Int32(sharedSoundcloudAPIAccess.songs.count)
        
        nextPlaying = sharedSoundcloudAPIAccess.songs[Int(randomSong)]
        
        //add random song to the queue
        if let nextURL = sharedSoundcloudAPIAccess.songs[Int(randomSong)].streamURL {
            let streamAsset = AVURLAsset(URL: nextURL)
            
            let keys = ["playable"]
            
            streamAsset.loadValuesAsynchronouslyForKeys(keys) { () -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    let playerItem = AVPlayerItem(asset: streamAsset)
                    self.audioStreamer?.insertItem(playerItem, afterItem: self.audioStreamer?.currentItem)
                }
            }
        }
    }
    
    
    /**
     Function called when the audio player has finished playing a song
     
     - parameter note: the NSNotification sent out that the player has finished playing a song
     - returns: void
    */
    func playerDidFinishPlaying(note: NSNotification) {
        //do anything whenever
    }
}
