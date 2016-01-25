//
//  PlaybackTypeViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/25/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit

class PlaybackTypeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var tblPlaylists: UITableView!
    var playlists = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //crop the background image
        let standardCrop = CGRect(x: (imgBackground.image!.size.width - UIScreen.mainScreen().bounds.width)/2.0 , y: fmax((imgBackground.image!.size.height - UIScreen.mainScreen().bounds.height), 0) , width: UIScreen.mainScreen().bounds.width, height: imgBackground.image!.size.height)
        
        logMsg("\(standardCrop)")
        
        if let standardThumb = CGImageCreateWithImageInRect(imgBackground.image!.CGImage, standardCrop) {
            let newImage = UIImage(CGImage: standardThumb, scale: 1.0, orientation: UIImageOrientation.Up)
            logMsg("\(newImage)")
            
            imgBackground.image = newImage
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    
    
    /**
     Function called when the user pressed the new connection button
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnNewConnectionPressed(sender: AnyObject) {
        let nextVC = storyboard?.instantiateViewControllerWithIdentifier("CreateSession") as! CreateBluetoothSessionViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    /**
     Function called when the user pressed the just me button
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnJustMePressed(sender: AnyObject) {
        let nextVC = storyboard?.instantiateViewControllerWithIdentifier("TabViewController") as! SoundCloudTabViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistTableCell", forIndexPath: indexPath) as! BluetoothDeviceTableCell
        
        cell.lblDeviceName.text = playlists[indexPath.row]
        
        return cell
    }
}
