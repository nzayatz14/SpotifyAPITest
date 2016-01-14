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
import CircleSlider
import MediaPlayer

class SongPlayerViewController: UIViewController {
    
    
    @IBOutlet weak var lblSongTitle: MarqueeLabel!
    @IBOutlet weak var lblArtistName: MarqueeLabel!
    @IBOutlet weak var sliderArea: UIView!
    
    
    var circleSlider: CircleSlider!
    var trackTimer: NSTimer?
    
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
        
        trackTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateCircle"), userInfo: nil, repeats: true)
        
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
    
    
    override func viewWillAppear(animated: Bool) {
        
        //show the player when the phone is locked
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        
        let mpic = MPNowPlayingInfoCenter.defaultCenter()
        mpic.nowPlayingInfo = [
            MPMediaItemPropertyTitle:track.title,
            MPMediaItemPropertyArtist:track.createdBy.fullname
        ]

    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        let length: Float = Float(track.duration)/1000.0
        
        print("Length: \(length)")
        //set the options of the slider
        let options = [
            CircleSliderOption.BarColor(UIColor.blackColor()),
            CircleSliderOption.ThumbColor(UIColor.darkGrayColor()),
            CircleSliderOption.TrackingColor(UIColor.orangeColor()),
            CircleSliderOption.BarWidth(3),
            CircleSliderOption.StartAngle(0),
            CircleSliderOption.MaxValue(length),
            CircleSliderOption.MinValue(0)
        ]
        
        self.audioStreamer?.currentTime()
        self.circleSlider = CircleSlider(frame: self.sliderArea.bounds, options: options)
        self.circleSlider?.addTarget(self, action: Selector("valueChange:"), forControlEvents: .AllTouchEvents)
        self.sliderArea.addSubview(self.circleSlider)
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
    
    
    /**
     Function called when the value of the slider is changed
     
     - parameter slider: the slider being changed
     - returns: void
     */
    func valueChange(slider: CircleSlider){
        
        let timeTo = CMTime(seconds: Double(slider.value), preferredTimescale: Int32(NSEC_PER_SEC))
        audioStreamer?.seekToTime(timeTo, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (succeed) -> Void in
            
        })
    }
    
    
    func updateCircle(){
        print(Float(audioStreamer!.currentTime().seconds))
        circleSlider.value = Float(audioStreamer!.currentTime().seconds)
    }
    
    
    /**
     Function called when the user controls music from the lock screen
     
     - parameter event: the event being triggered from the lock screen
     - returns: void
     */
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        
        if event?.type == .RemoteControl {
            
            switch (event!.subtype) {
            case UIEventSubtype.RemoteControlTogglePlayPause:
                print("Play/pause")
                break
            case UIEventSubtype.RemoteControlNextTrack:
                print("next track")
                break
            case UIEventSubtype.RemoteControlPreviousTrack:
                print("previous track")
                break
            default: break
                
                
            }
        }
    }
    
    
}
