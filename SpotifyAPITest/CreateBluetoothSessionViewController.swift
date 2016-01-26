//
//  CreateBluetoothSessionViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/25/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit
import BluetoothKit

class CreateBluetoothSessionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BluetoothCentralDelegate {
    
    @IBOutlet weak var tblDeviceList: UITableView!
    
    var central: BluetoothCentral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
         central = try BluetoothCentral.sharedCentral()
            central?.delegate = self
        } catch let error {
            logErr(error)
        }
        tblDeviceList.dataSource = self
        tblDeviceList.delegate = self
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    /**
     Returns the number of rows in the given tableView in the given section
     
     - parameter tableView: the tableView passed in
     - parameter section: the section being described
     - returns: the number of sections in this tableView
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return central?.dataSource.count ?? 0
    }
    
    
    /**
     Returns the cell at the given index
     
     - parameter tableView: the tableView passed in
     - parameter indexPath: the index of the cell being described
     - returns: the new table cell to be loaded into the table view
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BluetoothTableCell", forIndexPath: indexPath) as! BluetoothDeviceTableCell

        let name = central?.dataSource[indexPath.row].localName ?? "Unknown"
        cell.lblDeviceName.text = "\(name)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        do {
            try central?.connect(indexPath.row)
        } catch let error {
            logErr(error)
        }
    }
    
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tblDeviceList.reloadData()
        }
    }
    
    func bcDidConnectToRemotePeripheral(sender: BluetoothCentral) {
        logMsg("bcDidConnectToRemotePeripheral(sender: \(sender)")
        reloadTableView()
    }
    
    func bcDidDisconnectFromRemotePeripheral(sender: BluetoothCentral) {
        logMsg("bcDidDisconnectFromRemotePeripheral(sender: \(sender))")
        reloadTableView()
    }
    
    func bcDidUpdateDataSource(sender: BluetoothCentral) {
        logMsg("bcDidUpdateDataSource(sender: \(sender))")
        reloadTableView()
    }
    
    func bcDidUpdateState(sender: BluetoothCentral, state: BKCentral.ContinuousScanState) {
        logMsg("bcDidUpdateState(sender: \(sender), state: \(state))")
    }
    
    func bcErrorOccured(sender: BluetoothCentral, error: ErrorType) {
        logMsg("bcErrorOccured(sender: \(sender), error: \(error))")
    }
    
    func bcIsAbleToScan(sender: BluetoothCentral) {
        logMsg("bcIsAbleToScan(sender: \(sender))")
        central?.startContinuousScan()
    }
    
    func bcDidReceiveData(sender: BluetoothCentral, remotePeripheral: BKRemotePeripheral, data: NSData) {
        let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: AnyObject]
        logMsg("bcDidRecieveData(sender: \(sender), remotePeripheral: \(remotePeripheral), data: \(dict))")
    }
    
}
