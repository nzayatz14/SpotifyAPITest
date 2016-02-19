//
//  PlaybackTypeViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/25/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import MPSkewed
import Soundcloud

class PlaybackTypeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var colPlaylists: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var btnNewConnection: UIBarButtonItem!
    
    var playlists = [PlaylistTableCellInfo]()
    var filteredPlaylists = [PlaylistTableCellInfo]()
    var searchActive = false
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let playlistNames = ["George Gorokhov", "John Caldwell", "Terrance Diggs", "Joe Zayatz", "Kyle Schmadden-Stricker"]
        
        for var i = 0; i < 5; i++ {
            
            let index = i % 5 + 1
            
            let cellInfo = PlaylistTableCellInfo()
            cellInfo.name = playlistNames[i]
            cellInfo.image = UIImage(named: "EDM\(index).png")
            playlists.append(cellInfo)
        }
        
        
        let layout = MPSkewedParallaxLayout()
        layout.lineSpacing = 2.0
        layout.itemSize = CGSize(width: self.view.frame.width, height: 250)
        
        colPlaylists.dataSource = self
        colPlaylists.delegate = self
        colPlaylists.collectionViewLayout = layout
        colPlaylists.registerClass(MPSkewedCell.classForCoder(), forCellWithReuseIdentifier: "PlaylistCollectionCell")
        colPlaylists.backgroundColor = UIColor.clearColor()
        
        searchBar.delegate = self
        
        setupNavBar()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    
    
    //make sure the view only goes into portrait mode
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    /**
     Function called to set up the nav bar scheme
     
     - parameter void:
     - returns: void
     */
    func setupNavBar(){
        //set new connection button
        let rightButton = UIButton(frame: CGRectMake(0, 0, 50, 36))
        rightButton.setTitle("New", forState: .Normal)
        rightButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        rightButton.addTarget(self, action: "btnNewConnectionPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnNewConnection = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = btnNewConnection
        
        self.navigationController?.navigationBar.translucent = false
        
        //crop the background image
        let standardCrop = CGRect(x: (imgBackground.image!.size.width - UIScreen.mainScreen().bounds.width)/2.0 , y: fmax((imgBackground.image!.size.height - UIScreen.mainScreen().bounds.height), 0) , width: UIScreen.mainScreen().bounds.width, height: imgBackground.image!.size.height)
        
        logMsg("\(standardCrop)")
        
        if let standardThumb = CGImageCreateWithImageInRect(imgBackground.image!.CGImage, standardCrop) {
            let newImage = UIImage(CGImage: standardThumb, scale: 1.0, orientation: UIImageOrientation.Up)
            logMsg("\(newImage)")
            
            imgBackground.image = newImage
        }
    }
    
    
    /**
     Function called when the user pressed the new connection button
     
     - parameter sender: the button pressed
     - returns: void
     */
    func btnNewConnectionPressed(sender: AnyObject) {
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
     Returns the number of rows in the given collectionView in the given section
     
     - parameter collectionView: the collectionView passed in
     - parameter section: the section being described
     - returns: the number of sections in this collectionView
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive == true {
            return filteredPlaylists.count
        } else {
            return playlists.count
        }
    }
    
    
    /**
     Returns the cell at the given index
     
     - parameter collectionView: the collectionView passed in
     - parameter indexPath: the index of the cell being described
     - returns: the new collection cell to be loaded into the collection view
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PlaylistCollectionCell", forIndexPath: indexPath) as! MPSkewedCell
        
        //if there is a current user, append their name to it
        if let currentUser = user {
            if searchActive == true {
                cell.text = filteredPlaylists[indexPath.row].name + "\n vs. \(currentUser.username)"
                cell.image = filteredPlaylists[indexPath.row].image
            } else {
                cell.text = playlists[indexPath.row].name + "\n vs. \(currentUser.username)"
                cell.image = playlists[indexPath.row].image
            }
        } else {
            if searchActive == true {
                cell.text = filteredPlaylists[indexPath.row].name
                cell.image = filteredPlaylists[indexPath.row].image
            } else {
                cell.text = playlists[indexPath.row].name
                cell.image = playlists[indexPath.row].image
            }
        }
        
        return cell
    }
    
    
    /**
     Delegate method to say that the search bar is active
     
     - parameter searchBar: the search bar being used
     - returns: void
     */
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
        colPlaylists.reloadData()
    }
    
    
    /**
     Delegate method to say that the search bar is inactive
     
     - parameter searchBar: the search bar being described
     - returns: void
     */
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        if searchBar.text == "" {
            searchActive = false;
        }
        
        colPlaylists.reloadData()
    }
    
    
    /**
     Action triggered when the cancel button on the search bar is clicked
     
     - parameter searchBar: the searchBar being described
     - returns: void
     */
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        filteredPlaylists.removeAll()
        filteredPlaylists = playlists
        colPlaylists.reloadData()
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    
    
    /**
     Action triggered when the search button on the search bar is clicked
     
     - parameter searchBar: the searchBar being described
     - returns: void
     */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    /**
     Delegate function for the search bar to filter the results
     
     - parameter searchBar: the search bar being described
     - parameter searchText: the text used for filtering the results
     - returns: void
     */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        logMsg("SEARCH TEXT: \(searchText)")
        
        //if there is text, filter the results. If not, don't filter
        if searchText != "" {
            filteredPlaylists = playlists.filter({ (filterType) -> Bool in
                let filterString = filterType.name
                let range = filterString.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                if let myRange = range {
                    return !myRange.isEmpty
                } else {
                    return false
                }
            })
        }else{
            filteredPlaylists = playlists
        }
        
        self.colPlaylists.reloadData()
    }
    
    
}
