//
//  SongPlayerViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/12/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import MarqueeLabel
import Soundcloud
import AVFoundation

class SongPlayerViewController: UIViewController {
    
    
    @IBOutlet weak var lblSongTitle: MarqueeLabel!
    @IBOutlet weak var lblArtistName: MarqueeLabel!
    
    var audioPlayer: AVAudioPlayer?
    var audioStreamer: AVQueuePlayer?
    
    var trackInArray: Int!
    var track: Track!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblSongTitle.text = track.title
        lblArtistName.text = track.createdBy.fullname
        
        audioStreamer = AVQueuePlayer(URL: track.streamURL!)
        audioStreamer?.play()
        audioStreamer?.actionAtItemEnd = AVPlayerActionAtItemEnd.Advance
        
        loadNextSong()
        /*let item = AVPlayerItem(URL: NSURL(string:"https://api.soundcloud.com/tracks/149392650/stream?client_id=6c9090264a265d91bba9b915ec9cc0c5")!)
        audioStreamer?.insertItem(item, afterItem: audioStreamer?.currentItem)*/
        
        //let asset = AVURLAsset(URL: track.streamURL!)
        //asset.loa
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidReadSong", name: AVPlayerItemDidPlayToEndTimeNotification, object: audioStreamer?.currentItem)
        //self.audioStreamer?.addObserver(self, forKeyPath: "status", options: nil, context: nil)
        
        //get the song data from AFNetworking
        /*sharedSoundcloudAPIAccess.getSongFromSavedSongs(trackInArray, success: { (songData) -> Void in
        
        self.trackData = songData
        
        dispatch_async(dispatch_get_main_queue()) {
        //update UI Things
        }
        
        }) { (error) -> Void in
        
        print(error)
        }*/
    }
    
    
    /**
     Function called when an audio player has finished playing
     
     - parameter player: the player that has finished playing
     - parameter flag: whether or not the finish was successful
     - returns: void
     */
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true{
            print("done")
        }else{
            print("did not finish properly")
        }
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
    
    
}
