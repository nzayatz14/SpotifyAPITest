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


let sharedSongPlayer = SongPlayer()

protocol SongPlayerDelegate {
    func updateUI()
    func allowForwardAndBack()
}

class SongPlayer: NSObject {
    
    var audioStreamer: AVQueuePlayer?
    
    var tracks = [Track]()
    var currentTrack = 0
    var canChange = true
    var paused = true
    
    var delegate: SongPlayerDelegate?
    var trackTimer: NSTimer?
    
    
    /**
     Function called to init the audioStreamer with a new song
     
     - parameter url: the track that should be streamed
     - returns: void
     */
    func initPlayerWithTrack(track: Track){
        
        clearStreamer()
        tracks.removeAll()
        tracks = sharedSoundcloudAPIAccess.userSongs
        tracks = tracks.filter({$0.identifier != track.identifier})
        tracks.shuffle()
        tracks.insert(track, atIndex: 0)
        currentTrack = 0
        
        audioStreamer = AVQueuePlayer(URL: track.streamURL!)
        audioStreamer?.play()
        audioStreamer?.actionAtItemEnd = AVPlayerActionAtItemEnd.Advance
        paused = false
        
        trackTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("canResume"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: sharedSongPlayer.audioStreamer?.currentItem)
        
        loadNextSong()
        
    }
    
    
    /**
     Function called to wipe the current audio streamer
     
     - parameter void:
     - returns: void
     */
    func clearStreamer(){
        
        trackTimer?.invalidate()
        trackTimer = nil
        
        audioStreamer?.pause()
        audioStreamer?.removeAllItems()
        audioStreamer = nil
        
        tracks.removeAll()
    }
    
    
    /**
     Function called to add the next song to the queue
     
     - parameter: void
     - returns: void
     */
    func loadNextSong(){
        
        
        //add random song to the queue
        if tracks.count > currentTrack+1 {
            if let nextURL = tracks[currentTrack+1].streamURL {
                let streamAsset = AVURLAsset(URL: nextURL)
                
                let keys = ["playable"]
                
                print("starting to fetch")
                
                streamAsset.loadValuesAsynchronouslyForKeys(keys) { () -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        let playerItem = AVPlayerItem(asset: streamAsset)
                        
                        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
                        
                        print("Done fetching")
                        
                        self.audioStreamer?.insertItem(playerItem, afterItem: self.audioStreamer?.currentItem)
                        self.canChange = true
                        self.delegate?.allowForwardAndBack()
                    }
                }
            }
        }else{
            canChange = true
            self.delegate?.allowForwardAndBack()
        }
    }
    
    
    /**
     Function called to add the previous song to the queue
     
     - parameter: void
     - returns: void
     */
    func loadPreviousSong(){
        
        //add random song to the queue
        if let nextURL = tracks[currentTrack].streamURL {
            let streamAsset = AVURLAsset(URL: nextURL)
            
            let keys = ["playable"]
            
            streamAsset.loadValuesAsynchronouslyForKeys(keys) { () -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    let playerItem = AVPlayerItem(asset: streamAsset)
                    
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
                    
                    self.audioStreamer?.insertItem(playerItem, afterItem: self.audioStreamer?.currentItem)
                    self.audioStreamer?.play()
                    self.loadNextSong()
                }
            }
        }
    }
    
    
    /**
     Function called to play the previous song
     
     - parameter void:
     - returns: void
     */
    func playPreviousSong(){
        
        audioStreamer?.pause()
        audioStreamer?.removeAllItems()
        
        currentTrack--
        loadPreviousSong()
    }
    
    
    /**
     Function called when the audio player has finished playing a song
     
     - parameter note: the NSNotification sent out that the player has finished playing a song
     - returns: void
     */
    func playerDidFinishPlaying(note: NSNotification) {
        print("called from player")
        
        delegate?.updateUI()
    }
    
    
    /**
     Function called on a timer to see if the buffer can resume playing
     
     - parameter void:
     - returns: void
    */
    func canResume(){
        
        guard let currentTime = audioStreamer?.currentTime(), let currentDuration = audioStreamer?.currentItem?.duration, let rate = audioStreamer?.rate, let keepUp = audioStreamer?.currentItem?.playbackLikelyToKeepUp else {
            return
        }
        
        let duration = CMTimeGetSeconds(currentDuration)
        let time = CMTimeGetSeconds(currentTime)
        
        print("\(keepUp)")
        
        if  rate == 0 && duration != time && !paused && keepUp {
            audioStreamer?.play()
        }
        
    }
}
