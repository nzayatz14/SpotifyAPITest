//
//  PlaybackTypeViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/25/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import MPSkewed

class PlaybackTypeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var colPlaylists: UICollectionView!
    var btnNewConnection: UIBarButtonItem!
    
    var playlists = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playlists = ["George", "Nick", "Terrance", "Joe", "Kyle"]
        self.automaticallyAdjustsScrollViewInsets = false
        
        let layout = MPSkewedParallaxLayout()
        layout.lineSpacing = 2.0
        layout.itemSize = CGSize(width: self.view.frame.width, height: 250)
        
        colPlaylists.dataSource = self
        colPlaylists.delegate = self
        colPlaylists.collectionViewLayout = layout
        colPlaylists.registerClass(MPSkewedCell.classForCoder(), forCellWithReuseIdentifier: "PlaylistCollectionCell")
        colPlaylists.backgroundColor = UIColor(patternImage: UIImage(named: "BlurredEDMBackground.png")!)
        
        
        //set new connection button
        let rightButton = UIButton(frame: CGRectMake(0, 0, 50, 36))
        rightButton.setTitle("New", forState: .Normal)
        rightButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        rightButton.addTarget(self, action: "btnNewConnectionPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnNewConnection = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = btnNewConnection
        
        
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
    
    
    //make sure the view only goes into portrait mode
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
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
        return playlists.count
    }
    
    
    /**
     Returns the cell at the given index
     
     - parameter collectionView: the collectionView passed in
     - parameter indexPath: the index of the cell being described
     - returns: the new collection cell to be loaded into the collection view
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PlaylistCollectionCell", forIndexPath: indexPath) as! MPSkewedCell
        
        cell.text = playlists[indexPath.row]
        cell.image = UIImage(named: "BlurredEDMBackground.png")
        
        return cell
    }
    
}
