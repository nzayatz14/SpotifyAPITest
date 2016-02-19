//
//  CreateBluetoothSessionViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/25/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit

class CreateBluetoothSessionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tblDeviceList: UITableView!
    
    var deviceList = [Int]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblDeviceList.dataSource = self
        tblDeviceList.delegate = self
        
        //self.automaticallyAdjustsScrollViewInsets = false
    }
    
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.translucent = false
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
        return deviceList.count
    }
    
    
    /**
     Returns the cell at the given index
     
     - parameter tableView: the tableView passed in
     - parameter indexPath: the index of the cell being described
     - returns: the new table cell to be loaded into the table view
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BluetoothTableCell", forIndexPath: indexPath) as! BluetoothDeviceTableCell
        
        cell.lblDeviceName.text = "\(deviceList[indexPath.row])"
        
        return cell
    }
    
    
}
