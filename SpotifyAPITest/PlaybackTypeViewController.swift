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
import AVFoundation

class PlaybackTypeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var colPlaylists: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var btnNewConnection: UIBarButtonItem!
    
    var playlists = [PlaylistTableCellInfo]()
    var filteredPlaylists = [PlaylistTableCellInfo]()
    var searchActive = false
    
    var user: User?
    
    //sticky button and player view stuff
    var playerButton: LLACircularProgressView?
    var animator: UIDynamicAnimator!
    var snapBehavior: UISnapBehavior!
    var snapPoints = [CGPoint]()
    var backgroundPlayerView: UIView?
    var songPlayerView: SongPlayerView!
    var trackTimer: NSTimer?
    var panY: CGFloat?
    
    
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
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if playerButton == nil {
            animator = UIDynamicAnimator(referenceView: self.view)
            initStickyButton()
        }
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
    
    
    /**
     Function called to initialize the sticky button
     
     - parameter void:
     - returns: void
     */
    func initStickyButton(){
        playerButton = LLACircularProgressView(frame: CGRect(x: 20, y: 20, width: 60, height: 60))
        playerButton?.progressTintColor = UIColor.orangeColor()
        playerButton?.progress = 0
        playerButton?.setBackgroundImageType(UIImage(named: "musicNote.png"))
        playerButton?.userInteractionEnabled = true
        
        //add the tap functionality
        let aSelector: Selector = "btnStickyPressed:"
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        playerButton?.backgroundImage.addGestureRecognizer(tapGesture)
        
        //add the drag functionality
        let bSelector: Selector = "btnStickyDragged:"
        let DragGesture = UIPanGestureRecognizer(target: self, action: bSelector)
        playerButton?.backgroundImage.addGestureRecognizer(DragGesture)
        
        self.view.addSubview(playerButton!)
        
        //add snap points for sticky button
        if let stickyButton = playerButton {
            snapPoints.append(CGPoint(x: stickyButton.backgroundImage.frame.width/2 + stickyDistanceFromSide, y: (30 + stickyButton.backgroundImage.frame.width)/2))
            
            snapPoints.append(CGPoint(x: stickyButton.backgroundImage.frame.width/2 + stickyDistanceFromSide, y: self.view.center.y))
            
            snapPoints.append(CGPoint(x: stickyButton.backgroundImage.frame.width/2 + stickyDistanceFromSide, y: self.view.frame.height - stickyButton.backgroundImage.frame.width/2 - stickyDistanceFromSide))
            
            snapPoints.append(CGPoint(x: self.view.frame.width - stickyButton.backgroundImage.frame.width/2 - stickyDistanceFromSide, y: (30 + stickyButton.backgroundImage.frame.width)/2))
            
            snapPoints.append(CGPoint(x: self.view.frame.width - stickyButton.backgroundImage.frame.width/2 - stickyDistanceFromSide, y: self.view.center.y))
            
            snapPoints.append(CGPoint(x: self.view.frame.width - stickyButton.backgroundImage.frame.width/2 - stickyDistanceFromSide, y: self.view.frame.height - stickyButton.backgroundImage.frame.width/2 - stickyDistanceFromSide))
        }
    }
    
    
    /**
     Function called when the sticky button is pressed
     
     - parameter sender: the button pressed
     - returns: void
     */
    func btnStickyPressed(sender: AnyObject){
        print("sticky button")
        
        playerButton?.enabled = false
        
        backgroundPlayerView = UIView(frame: UIScreen.mainScreen().bounds)
        backgroundPlayerView?.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.8)
        backgroundPlayerView?.userInteractionEnabled = true
        
        self.view.layoutIfNeeded()
        songPlayerView = SongPlayerView(frame: CGRect(x: playerViewInset, y: 2*playerViewInset, width: UIScreen.mainScreen().bounds.width - 2*playerViewInset, height: UIScreen.mainScreen().bounds.height - 4*playerViewInset))
        
        backgroundPlayerView?.addSubview(songPlayerView)
        
        songPlayerView.setNeedsLayout()
        songPlayerView.layoutIfNeeded()
        
        //add the dismiss functionality
        let aSelector: Selector = "playerViewPanned:"
        let swipeGesture = UIPanGestureRecognizer(target: self, action: aSelector)
        songPlayerView.addGestureRecognizer(swipeGesture)
        
        
        //show the player view
        UIView.transitionWithView(self.view, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.view.addSubview(self.backgroundPlayerView!)
            }, completion: { (success) in
                self.songPlayerView.setNeedsLayout()
                self.songPlayerView.layoutIfNeeded()
                self.songPlayerView.setupUI()
        })
    }
    
    
    /**
     Function called when the sticky button is being dragged
     
     - parameter sender: the button being dragged
     - returns: void
     */
    func btnStickyDragged(sender: UIPanGestureRecognizer){
        
        if let stickyButton = playerButton {
            
            //important: remove any snap behaviors that may already be existing
            if sender.state == UIGestureRecognizerState.Began {
                animator.removeAllBehaviors()
                snapBehavior = nil
                
                //bring the card being dragged to the front
                self.view.bringSubviewToFront(stickyButton)
            }
            
            let point = CGPoint(x: sender.locationInView(self.view).x, y:sender.locationInView(self.view).y)
            
            stickyButton.center = point
            
            //if the state ends, see where to snap the button to
            if sender.state == .Ended || sender.state == .Cancelled || sender.state == .Failed {
                snapBehavior = UISnapBehavior(item: stickyButton, snapToPoint: snapPoints[getClosestSnapPoint()])
                
                snapBehavior.damping = 0.85
                
                animator.addBehavior(snapBehavior)
            }
        }
    }
    
    
    /**
     Function called to get the closest point to the sticky button at the time
     
     - parameter void:
     - returns: the index of the closest point in the snapPoints array
     */
    func getClosestSnapPoint() -> Int {
        
        var smallest = 0
        var smallestDistance = distance((playerButton?.center)!, p2: snapPoints[0])
        
        for var i = 1; i < snapPoints.count; i++ {
            
            let d = distance((playerButton?.center)!, p2: snapPoints[i])
            
            if d < smallestDistance {
                smallest = i
                smallestDistance = d
            }
        }
        
        return smallest
    }
    
    
    /**
     Function to find the distance between 2 points
     
     - parameter p1: the first point
     - parameter p2: the second point
     - returns: the distance between the points
     */
    func distance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let xDist = (p2.x - p1.x)
        let yDist = (p2.y - p1.y)
        let distance = sqrt((xDist * xDist) + (yDist * yDist))
        
        return distance
    }
    
    
    /**
     Function called when the player view is panned
     
     - parameter void:
     - returns: void
     */
    func playerViewPanned(sender: UIPanGestureRecognizer){
        
        //if the drag begins, initialize the variables
        if sender.state == .Began {
            animator.removeAllBehaviors()
            snapBehavior = nil
            
            if let myView = sender.view {
                panY = myView.center.y - sender.locationInView(self.view).y
            }
            
            //if the drag ends, determine what to do
        } else if sender.state == .Ended || sender.state == .Cancelled || sender.state == .Failed {
            
            let velocity = sender.velocityInView(self.view).y
            
            //determine where to slide the player to depending on the velocity
            if velocity <= -playerSwipeVelocityThreshold {
                let dist = sender.locationInView(self.view).y + self.view.center.y
                let duration = Double(dist/velocity)
                
                //slide the view up
                UIView.transitionWithView(self.view, duration: duration, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    if let background = self.backgroundPlayerView {
                        background.alpha = 0
                        self.songPlayerView.center.y = -self.view.center.y
                    }
                    }, completion: { (success) in
                        self.backgroundPlayerView?.removeFromSuperview()
                        self.backgroundPlayerView = nil
                        self.songPlayerView = nil
                        self.playerButton?.enabled = true
                        self.panY = nil
                })
                
            } else if velocity >= playerSwipeVelocityThreshold {
                let dist = self.view.frame.height + self.view.center.y - sender.locationInView(self.view).y
                let duration = Double(dist/velocity)
                
                //slide the view down
                UIView.transitionWithView(self.view, duration: duration, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    if let background = self.backgroundPlayerView {
                        background.alpha = 0
                        self.songPlayerView.center.y = self.songPlayerView.center.y + self.view.frame.height
                    }
                    }, completion: { (success) in
                        self.backgroundPlayerView?.removeFromSuperview()
                        self.backgroundPlayerView = nil
                        self.songPlayerView = nil
                        self.playerButton?.enabled = true
                        self.panY = nil
                })
                
                //if the velocity threshold is not surpassed, snap the player back to the center
            } else {
                if let background = backgroundPlayerView {
                    snapBehavior = UISnapBehavior(item: songPlayerView, snapToPoint: background.center)
                    snapBehavior.damping = 0.85
                    
                    animator.addBehavior(snapBehavior)
                }
            }
            
            //if the drag is current, move the player along with the finger
        } else {
            if let delta = panY {
                let point = sender.locationInView(self.view).y + delta
                self.songPlayerView.center.y = point
            }
        }
    }
    
    
    /**
     Function called to update the sticky button circle on the timer tick
     
     - parameter void:
     - returns: void
     */
    func updateStickyCircle(){
        
        if let myStreamer = sharedSongPlayer.audioStreamer, let currentItem = sharedSongPlayer.audioStreamer?.currentItem {
            print("myStreamer Time: \(myStreamer.currentTime().seconds)")
            if !Float(myStreamer.currentTime().seconds).isNaN && playerButton != nil {
                playerButton?.setProgress(Float(Double(myStreamer.currentTime().seconds) / CMTimeGetSeconds(currentItem.duration)), animated: true)
            }else{
                playerButton?.progress = 0
            }
        }else{
            playerButton?.progress = 0
        }
    }
    
    
}
