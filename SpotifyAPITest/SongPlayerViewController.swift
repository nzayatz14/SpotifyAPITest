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

class SongPlayerViewController: UIViewController, SongPlayerDelegate {
    
    
    @IBOutlet weak var lblSongTitle: MarqueeLabel!
    @IBOutlet weak var lblArtistName: MarqueeLabel!
    @IBOutlet weak var sliderArea: UIView!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet weak var btnPausePlay: UIButton!
    
    
    var circleSlider: CircleSlider!
    var trackTimer: NSTimer?
    
    var trackInArray: Int!
    var track: Track!
    
    var paused = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sharedSongPlayer.delegate = self
        
        trackTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateCircle"), userInfo: nil, repeats: true)
        
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
        
        lblSongTitle.text = track.title
        lblArtistName.text = track.createdBy.username
        
        if paused {
            btnPausePlay.setTitle("Play", forState: .Normal)
        }else{
            btnPausePlay.setTitle("Pause", forState: .Normal)
        }
        
        //show the player when the phone is locked
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        
        updateOutsidePlayer()
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        setUpTimer(track)
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
     Function called when the value of the slider is changed
     
     - parameter slider: the slider being changed
     - returns: void
     */
    func valueChange(slider: CircleSlider){
        
        let timeTo = CMTime(seconds: Double(slider.value), preferredTimescale: Int32(NSEC_PER_SEC))
        sharedSongPlayer.audioStreamer?.seekToTime(timeTo, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (succeed) -> Void in
            
        })
    }
    
    
    /**
     Function called to update the circle on the timer tick
     
     - parameter void:
     - returns: void
     */
    func updateCircle(){
        print(Float(sharedSongPlayer.audioStreamer!.currentTime().seconds))
        if !Float(sharedSongPlayer.audioStreamer!.currentTime().seconds).isNaN && circleSlider != nil {
            if let streamer = sharedSongPlayer.audioStreamer {
                circleSlider.value = Float(streamer.currentTime().seconds)
            }
        }else{
            circleSlider.value = 0
        }
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
                sharedSongPlayer.currentTrack++
                sharedSongPlayer.audioStreamer?.advanceToNextItem()
                
                setupNextSong()
                
                updateOutsidePlayer()
                
                break
            case UIEventSubtype.RemoteControlPreviousTrack:
                print("previous track")
                
                if btnBack.enabled {
                    setupPreviousSong()
                }
                
                break
            case UIEventSubtype.RemoteControlPlay:
                print("play")
                paused = false
                btnPausePlay.setTitle("Pause", forState: .Normal)
                sharedSongPlayer.audioStreamer?.play()
                
                updateOutsidePlayer()
                
                break
            case UIEventSubtype.RemoteControlPause:
                print("pause")
                paused = true
                btnPausePlay.setTitle("Play", forState: .Normal)
                sharedSongPlayer.audioStreamer?.pause()
                
                updateOutsidePlayer()
                
                break
            default:
                print("default")
            }
        }
    }
    
    
    /**
     Function called to update the UI after a song has finished playing
     
     - parameter void:
     - returns: void
     */
    func updateUI() {
        print("called from VC")
        
        updateOutsidePlayer()
        
        sharedSongPlayer.currentTrack++
        setupNextSong()
    }
    
    
    /**
     Function called to update the outside player
     
     - parameter void:
     - returns: void
    */
    func updateOutsidePlayer(){
        var currentTime: Float
        
        if let streamer = sharedSongPlayer.audioStreamer {
            currentTime = Float(streamer.currentTime().seconds)
        }else{
            currentTime = 0
        }
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
            MPMediaItemPropertyTitle:track.title,
            MPMediaItemPropertyArtist:track.createdBy.username,
            MPMediaItemPropertyPlaybackDuration:track.duration/1000,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate:1.0
        ]
    }
    
    
    /**
     Re-enables the forward and back buttons for song changing
     
     - parameter void:
     - returns: void
     */
    func allowForwardAndBack(){
        btnBack.enabled = true
        btnForward.enabled = true
        
        if circleSlider != nil {
            circleSlider.enabled = true
        }
        
        updateOutsidePlayer()
    }
    
    
    /**
     Function called to set up the timer with a new song
     
     - parameter thisTrack: the track that is currently being played
     - returns: void
     */
    func setUpTimer(thisTrack: Track){
        let length: Float = Float(thisTrack.duration)/1000.0
        
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
        
        //if the slider is not initialized, initialize it
        if circleSlider == nil {
            self.circleSlider = CircleSlider(frame: self.sliderArea.bounds, options: options)
            self.circleSlider?.addTarget(self, action: Selector("valueChange:"), forControlEvents: .AllTouchEvents)
            self.sliderArea.addSubview(self.circleSlider)
        }else{
            circleSlider.maxValue = length
            updateCircle()
        }
    }
    
    
    /**
     Function called when the pause/play button is pressed
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnPausePlayPressed(sender: AnyObject) {
        if !paused {
            paused = true
            btnPausePlay.setTitle("Play", forState: .Normal)
            sharedSongPlayer.audioStreamer?.pause()
            return
        }else{
            paused = false
            btnPausePlay.setTitle("Pause", forState: .Normal)
            sharedSongPlayer.audioStreamer?.play()
        }
        
        updateOutsidePlayer()
    }
    
    
    /**
     Function called when the back button is pressed
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnBackPressed(sender: AnyObject) {
        setupPreviousSong()
    }
    
    
    /**
     Function called when the forward button is pressed
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnForwardPressed(sender: AnyObject) {
        sharedSongPlayer.currentTrack++
        sharedSongPlayer.audioStreamer?.advanceToNextItem()
        
        setupNextSong()
    }
    
    
    /**
     Function called to set up the UI for the next song
     
     - parameter void:
     - returns: void
     */
    func setupNextSong(){
        
        if sharedSongPlayer.tracks.count > sharedSongPlayer.currentTrack {
            
            btnBack.enabled = false
            btnForward.enabled = false
            circleSlider.enabled = false
            
            track = sharedSongPlayer.tracks[sharedSongPlayer.currentTrack]
            setUpTimer(track)
            
            lblSongTitle.text = track.title
            lblArtistName.text = track.createdBy.username
            
            sharedSongPlayer.loadNextSong()
        }else{
            sharedSongPlayer.clearStreamer()
        }
    }
    
    
    /**
     Function called to set up the UI for the previous song
     
     - parameter void:
     - returns: void
     */
    func setupPreviousSong(){
        if sharedSongPlayer.currentTrack > 0 {
            
            btnBack.enabled = false
            btnForward.enabled = false
            circleSlider.enabled = false
            
            track = sharedSongPlayer.tracks[sharedSongPlayer.currentTrack-1]
            setUpTimer(track)
            
            lblSongTitle.text = track.title
            lblArtistName.text = track.createdBy.username
            
            sharedSongPlayer.playPreviousSong()
        }
    }
    
    
}
