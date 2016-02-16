//
//  SelectPlaylistViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/28/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import Soundcloud

class SelectPlaylistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tblPlaylists: UITableView!
    
    
    
    var playlists = [Playlist]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblPlaylists.dataSource = self
        tblPlaylists.delegate = self
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
        return playlists.count
    }
    
    
    /**
     Returns the cell at the given index
     
     - parameter tableView: the tableView passed in
     - parameter indexPath: the index of the cell being described
     - returns: the new table cell to be loaded into the table view
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectPlaylistTableCell", forIndexPath: indexPath) as! SelectPlaylistTableCell
        
        cell.lblPlaylistName.text = "\(playlists[indexPath.row])"
        
        return cell
    }
    
}
