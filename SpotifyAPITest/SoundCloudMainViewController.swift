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
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        sharedSoundcloudAPIAccess.getSongs { (songlist) -> Void in
            self.songs = songlist
        }
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
        self.performSegueWithIdentifier("sgeToPlayer", sender: self)
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
            playerVC.track = songs[songSelected]
            playerVC.trackInArray = songSelected
        }
    }
    
    
    
}
