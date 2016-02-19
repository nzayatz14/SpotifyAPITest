//
//  ServerClientDecisionViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/25/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import Soundcloud
import AVFoundation

let playerViewInset = CGFloat(30)
let playerSwipeVelocityThreshold = CGFloat(1000)
let stickyDistanceFromSide = CGFloat(5)

class ServerClientDecisionViewController: UIViewController {
    
    
    @IBOutlet weak var lblCurrentLogin: UILabel!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var btnHost: UIButton!
    @IBOutlet weak var btnClient: UIButton!
    
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
        
        sharedSoundcloudAPIAccess.getUser { (user) -> Void in
            self.user = user
            self.lblCurrentLogin.text = "Currently logged in as: \(user.username)"
            self.lblCurrentLogin.hidden = false
        }
        
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
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
        trackTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateStickyCircle"), userInfo: nil, repeats: true)
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if playerButton == nil {
            animator = UIDynamicAnimator(referenceView: self.view)
            initStickyButton()
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        trackTimer?.invalidate()
        trackTimer = nil
    }
    
    
    //make sure the view only goes into portrait mode
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    /**
     Function called when the user opts to host a playlist
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnHostPressed(sender: AnyObject) {
        let nextVC = storyboard?.instantiateViewControllerWithIdentifier("PlaybackType") as! PlaybackTypeViewController
        nextVC.user = user
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    /**
     Function called when the user opts not to host a playlist
     
     - parameter sender: the button pressed
     - returns: void
     */
    @IBAction func btnClientPressed(sender: AnyObject) {
        let nextVC = storyboard?.instantiateViewControllerWithIdentifier("ConnectToSession") as! ConnectToBluetoothSessionViewController
        nextVC.user = user
        self.navigationController?.pushViewController(nextVC, animated: true)
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
