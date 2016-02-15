//
//  SoundCloudMainViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/5/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import Soundcloud
import AVKit
import AVFoundation
import MediaPlayer

class SoundCloudMainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tblSongList: UITableView!
    
    var songs = [Track]() {
        didSet{
            tblSongList.reloadData()
        }
    }
    
    var songDatas = [String : NSData]()
    var songSelected = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblSongList.dataSource = self
        tblSongList.delegate = self
        
        //TODO: decide which call to make based on whether the user is by himself or not
        sharedSoundcloudAPIAccess.getUserSongs { (songlist) -> Void in
            self.songs = songlist
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //show the player when the phone is locked
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    //make sure the view only goes into portrait mode
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    /**
     Returns the number of rows in the given tableView in the given section
     
     - parameter tableView: the tableView passed in
     - parameter section: the section being described
     - returns: the number of sections in this tableView
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    
    /**
     Returns the cell at the given index
     
     - parameter tableView: the tableView passed in
     - parameter indexPath: the index of the cell being described
     - returns: the new table cell to be loaded into the table view
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SoundcloudTableCell", forIndexPath: indexPath) as! SoundCloudTableCell
        
        cell.lblSongTitle.text = songs[indexPath.row].title
        
        return cell
    }
    
    
    /**
     Function called when a row in the table was selected
     
     - parameter tableView: the tableView that had its row selected
     - parameter indexPath: the index of the row that was selected
     - returns: void
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        songSelected = indexPath.row
        
        if let playerVC = self.tabBarController?.viewControllers?[1] as? SongPlayerViewController {
            playerVC.track = songs[songSelected]
            sharedSongPlayer.initPlayerWithTrack(songs[songSelected])
            updateOutsidePlayer()
            print("PASSED PLAYER VIEW")
        }
    }
    
    
    /**
     Prepare the view for a segue
     
     - parameter segue: the segue being made
     - parameter sender: the sender of the segue
     - returns: void
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sgeToPlayer"{
            let playerVC = segue.destinationViewController as! SongPlayerViewController
            playerVC.songPlayerView.track = songs[songSelected]
        }
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
    
}
