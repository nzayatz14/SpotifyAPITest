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
    @IBOutlet weak var imgArtwork: UIImageView!
    @IBOutlet weak var circleView: UIView!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet weak var btnPausePlay: UIButton!
    
    
    var circleSlider: CircleSlider?
    var circleBufferSlider: CircleSlider?
    var trackTimer: NSTimer?
    var bufferTimer: NSTimer?
    
    var track: Track?
    
    var paused = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sharedSongPlayer.delegate = self
        
        lblArtistName.marqueeType = MarqueeType.MLContinuous
        lblSongTitle.marqueeType = MarqueeType.MLContinuous
        
        trackTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateCircle"), userInfo: nil, repeats: true)
        
        bufferTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateBufferCircle"), userInfo: nil, repeats: true)
        
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
        super.viewWillAppear(animated)
        
        imgArtwork.layer.cornerRadius = imgArtwork.frame.width/2
        imgArtwork.layer.masksToBounds = true
        
        if let currentTrack = track {
            lblSongTitle.text = currentTrack.title
            lblArtistName.text = currentTrack.createdBy.username
            getAlbumArt()
        }
        
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
        imgArtwork.layer.cornerRadius = imgArtwork.frame.width/2
        imgArtwork.layer.masksToBounds = true
        
        if let currentTrack = track {
            setUpTimer(currentTrack)
        }
    }
    
    
    //make sure the view only goes into portrait mode
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
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
            CircleSliderOption.BarColor(UIColor.clearColor()),
            CircleSliderOption.ThumbColor(UIColor.darkGrayColor()),
            CircleSliderOption.TrackingColor(UIColor.orangeColor()),
            CircleSliderOption.BarWidth(3),
            CircleSliderOption.StartAngle(0),
            CircleSliderOption.MaxValue(length),
            CircleSliderOption.MinValue(0)
        ]
        
        //set options for the buffer progress
        let bufferOptions = [
            CircleSliderOption.BarColor(UIColor.blackColor()),
            CircleSliderOption.ThumbColor(UIColor.darkGrayColor()),
            CircleSliderOption.TrackingColor(UIColor.lightGrayColor()),
            CircleSliderOption.BarWidth(3),
            CircleSliderOption.StartAngle(0),
            CircleSliderOption.MaxValue(length),
            CircleSliderOption.MinValue(0),
            CircleSliderOption.SliderEnabled(false)
        ]
        
        
        //if the buffer is not initialized, initialize it
        if circleBufferSlider == nil {
            self.circleBufferSlider = CircleSlider(frame: self.circleView.bounds, options: bufferOptions)
            
            /*if let transform = circleBufferSlider?.transform {
            circleBufferSlider?.transform = CGAffineTransformScale(transform, 0.9, 0.9)
            }*/
            
            self.circleView.addSubview(self.circleBufferSlider!)
        }else{
            circleBufferSlider?.maxValue = length
            updateBufferCircle()
        }
        
        
        //if the slider is not initialized, initialize it
        if circleSlider == nil {
            self.circleSlider = CircleSlider(frame: self.circleView.bounds, options: options)
            self.circleSlider?.addTarget(self, action: Selector("valueChange:"), forControlEvents: .AllTouchEvents)
            self.circleView.addSubview(self.circleSlider!)
        }else{
            circleSlider?.maxValue = length
            updateCircle()
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
            self.updateBufferCircle()
        })
    }
    
    
    /**
     Function called to update the circle on the timer tick
     
     - parameter void:
     - returns: void
     */
    func updateCircle(){
        
        if let myStreamer = sharedSongPlayer.audioStreamer {
            if !Float(myStreamer.currentTime().seconds).isNaN && circleSlider != nil {
                circleSlider?.value = Float(myStreamer.currentTime().seconds)
            }else{
                circleSlider?.value = 0
            }
        }else{
            circleSlider?.value = 0
        }
    }
    
    
    /**
     Function called to update the buffer circle on the timer tick
     
     - parameter void:
     - returns: void
     */
    func updateBufferCircle(){
        
        if let myStreamer = sharedSongPlayer.audioStreamer {
            if myStreamer.currentItem?.loadedTimeRanges.count >= 1 {
                if let duration = myStreamer.currentItem?.loadedTimeRanges[0].CMTimeRangeValue.duration, let start = myStreamer.currentItem?.loadedTimeRanges[0].CMTimeRangeValue.start {
                    
                    let seconds = Float(CMTimeGetSeconds(duration) + CMTimeGetSeconds(start))
                    
                    if !Float(myStreamer.currentTime().seconds).isNaN && circleBufferSlider != nil {
                        circleBufferSlider?.value = seconds
                        return
                    }
                }
            }
        }
        
        circleBufferSlider?.value = 0
    }
    
    
    /**
     Function called to update the UI after a song has finished playing
     
     - parameter void:
     - returns: void
     */
    func updateUI() {
        print("called from VC")
        
        updateOutsidePlayer()
        
        if sharedSongPlayer.tracks.count > sharedSongPlayer.currentTrack+1 {
            sharedSongPlayer.currentTrack++
            setupNextSong()
        }
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
        
        if let currentTrack = track {
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
                MPMediaItemPropertyTitle:currentTrack.title,
                MPMediaItemPropertyArtist:currentTrack.createdBy.username,
                MPMediaItemPropertyPlaybackDuration:currentTrack.duration/1000,
                MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
                MPNowPlayingInfoPropertyPlaybackRate:1.0
            ]
        }
    }
    
    
    /**
     Re-enables the forward and back buttons for song changing
     
     - parameter void:
     - returns: void
     */
    func allowForwardAndBack(){
        btnBack.enabled = true
        btnForward.enabled = true
        sharedSongPlayer.canChange = true
        
        if circleSlider != nil {
            circleSlider?.enabled = true
        }
        
        updateOutsidePlayer()
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
                if sharedSongPlayer.canChange && sharedSongPlayer.tracks.count > sharedSongPlayer.currentTrack+1 {
                    sharedSongPlayer.currentTrack++
                    sharedSongPlayer.audioStreamer?.advanceToNextItem()
                    
                    setupNextSong()
                    
                    updateOutsidePlayer()
                }
                
                break
            case UIEventSubtype.RemoteControlPreviousTrack:
                print("previous track")
                
                if sharedSongPlayer.canChange {
                    setupPreviousSong()
                }
                
                break
            case UIEventSubtype.RemoteControlPlay:
                print("play")
                paused = false
                sharedSongPlayer.paused = false
                btnPausePlay.setTitle("Pause", forState: .Normal)
                sharedSongPlayer.audioStreamer?.play()
                
                updateOutsidePlayer()
                
                break
            case UIEventSubtype.RemoteControlPause:
                print("pause")
                paused = true
                sharedSongPlayer.paused = true
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
     Function called when the pause/play button is pressed
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnPausePlayPressed(sender: AnyObject) {
        if let _ = sharedSongPlayer.audioStreamer {
            if !paused {
                paused = true
                sharedSongPlayer.paused = true
                btnPausePlay.setTitle("Play", forState: .Normal)
                sharedSongPlayer.audioStreamer?.pause()
                return
            }else{
                paused = false
                sharedSongPlayer.paused = false
                btnPausePlay.setTitle("Pause", forState: .Normal)
                sharedSongPlayer.audioStreamer?.play()
            }
            
            updateOutsidePlayer()
        }
    }
    
    
    /**
     Function called when the back button is pressed
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnBackPressed(sender: AnyObject) {
        if sharedSongPlayer.currentTrack > 0 {
            btnBack.enabled = false
            btnForward.enabled = false
            circleSlider?.enabled = false
            sharedSongPlayer.canChange = false
            self.imgArtwork.image = UIImage(named: "musicNote.png")
        }
        
        setupPreviousSong()
    }
    
    
    /**
     Function called when the forward button is pressed
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnForwardPressed(sender: AnyObject) {
        if sharedSongPlayer.tracks.count > sharedSongPlayer.currentTrack+1 {
            btnBack.enabled = false
            btnForward.enabled = false
            circleSlider?.enabled = false
            sharedSongPlayer.canChange = false
            sharedSongPlayer.currentTrack++
            sharedSongPlayer.audioStreamer?.advanceToNextItem()
            self.imgArtwork.image = UIImage(named: "musicNote.png")
            
            setupNextSong()
        }
    }
    
    
    /**
     Function called to set up the UI for the next song
     
     - parameter void:
     - returns: void
     */
    func setupNextSong(){
        
        if sharedSongPlayer.tracks.count > sharedSongPlayer.currentTrack {
            
            track = sharedSongPlayer.tracks[sharedSongPlayer.currentTrack]
            getAlbumArt()
            
            if let currentTrack = track {
                setUpTimer(currentTrack)
                
                lblSongTitle.text = currentTrack.title
                lblArtistName.text = currentTrack.createdBy.username
            }
            
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
            
            track = sharedSongPlayer.tracks[sharedSongPlayer.currentTrack-1]
            getAlbumArt()
            
            if let currentTrack = track {
                setUpTimer(currentTrack)
                
                lblSongTitle.text = currentTrack.title
                lblArtistName.text = currentTrack.createdBy.username
            }
            
            sharedSongPlayer.playPreviousSong()
        }
    }
    
    
    /**
     Function called to get the album art
     
     - parameter void:
     - returns: void
     */
    func getAlbumArt(){
        if let thisTrack = track {
            sharedSoundcloudAPIAccess.getSongArt(thisTrack, success: { (songData) -> Void in
                
                let image = UIImage(data: songData)
                self.imgArtwork.image = image
                
                }) { (error) -> Void in
                    print("Error fetching image: \(error)")
                    self.imgArtwork.image = UIImage(named: "musicNote.png")
            }
        }
    }
    
    
}
