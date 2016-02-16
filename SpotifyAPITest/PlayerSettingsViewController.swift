//
//  SettingsViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/20/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

protocol SettingsDelegate {
    func disconnect()
}

class PlayerSettingsViewController: UIViewController {
    
    
    var delegate: SettingsDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //show the player when the phone is locked
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    
    //make sure the view only goes into portrait mode
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    /**
     Function called when the user controls music from the lock screen
     
     - parameter event: the event being triggered from the lock screen
     - returns: void
     */
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        
        guard let playerVC = self.tabBarController?.viewControllers?[1] as? SongPlayerViewController else {
            return
        }
        
        if event?.type == .RemoteControl {
            
            switch (event!.subtype) {
            case UIEventSubtype.RemoteControlTogglePlayPause:
                print("Play/pause")
                break
            case UIEventSubtype.RemoteControlNextTrack:
                print("next track")
                
                if sharedSongPlayer.canChange {
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
                playerVC.songPlayerView.paused = false
                sharedSongPlayer.paused = false
                sharedSongPlayer.audioStreamer?.play()
                
                updateOutsidePlayer()
                
                break
            case UIEventSubtype.RemoteControlPause:
                print("pause")
                playerVC.songPlayerView.paused = true
                sharedSongPlayer.paused = true
                sharedSongPlayer.audioStreamer?.pause()
                
                updateOutsidePlayer()
                
                break
            default:
                print("default")
            }
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
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
            MPMediaItemPropertyTitle:sharedSongPlayer.tracks[sharedSongPlayer.currentTrack].title,
            MPMediaItemPropertyArtist:sharedSongPlayer.tracks[sharedSongPlayer.currentTrack].createdBy.username,
            MPMediaItemPropertyPlaybackDuration:sharedSongPlayer.tracks[sharedSongPlayer.currentTrack].duration/1000,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate:1.0
        ]
    }
    
    
    /**
     Function called to set up the UI for the next song
     
     - parameter void:
     - returns: void
     */
    func setupNextSong(){
        
        guard let playerVC = self.tabBarController?.viewControllers?[1] as? SongPlayerViewController else {
            return
        }
        
        if sharedSongPlayer.tracks.count > sharedSongPlayer.currentTrack {
            
            playerVC.songPlayerView.track = sharedSongPlayer.tracks[sharedSongPlayer.currentTrack]
            
            sharedSongPlayer.canChange = false
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
        
        guard let playerVC = self.tabBarController?.viewControllers?[1] as? SongPlayerViewController else {
            return
        }
        
        if sharedSongPlayer.currentTrack > 0 {
            
            playerVC.songPlayerView.track = sharedSongPlayer.tracks[sharedSongPlayer.currentTrack-1]
            
            sharedSongPlayer.canChange = false
            sharedSongPlayer.playPreviousSong()
        }
    }

    
    
    /**
     Function called when the user pressed the save playlist button
     
     - parameter sender: the button pressed
     - returns: void
    */
    @IBAction func btnSavePlaylistPressed(sender: AnyObject) {
        
    }
    
    
    /**
     Function called when the user pressed the disconnect button
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnDisconnectPressed(sender: AnyObject) {
        sharedSongPlayer.clearStreamer()
        delegate?.disconnect()
    }
    
}
