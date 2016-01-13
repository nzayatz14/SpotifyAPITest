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

class SongPlayerViewController: UIViewController, AVAudioPlayerDelegate {
    
    
    @IBOutlet weak var lblSongTitle: MarqueeLabel!
    @IBOutlet weak var lblArtistName: MarqueeLabel!
    
    var audioPlayer: AVAudioPlayer?
    
    var trackInArray: Int!
    
    var track: Track!
    var trackData = NSData() {
        didSet {
            do {
                print("do play")
                self.audioPlayer = try AVAudioPlayer(data: trackData)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch let error1 as NSError {
                self.audioPlayer = nil
                print("\(error1)")
            }catch{
                self.audioPlayer = nil
                print("other error")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblSongTitle.text = track.title
        lblArtistName.text = track.createdBy.fullname
        
        //get the song data from AFNetworking
        sharedSoundcloudAPIAccess.getSongFromSavedSongs(trackInArray, success: { (songData) -> Void in
            
            self.trackData = songData
            
            dispatch_async(dispatch_get_main_queue()) {
                //update UI Things
            }
            
            }) { (error) -> Void in
                
                print(error)
        }
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
    
    
}
