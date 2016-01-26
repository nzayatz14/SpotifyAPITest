//
//  ConnectToBluetoothSessionViewController.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/25/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import UIKit

class ConnectToBluetoothSessionViewController: UIViewController, BluetoothPeripheralDelegate {
    
    var peripheral: BluetoothPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheral = BluetoothPeripheral.sharedPeripheral
        peripheral?.delegate = self
        
        do {
            try peripheral?.start(sharedSoundcloudAPIAccess.userData?.username ?? "Unknown")
        } catch let error {
            logErr(error)
        }
        
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
    
    func bpDidConnectToRemoteCentral(sender: BluetoothPeripheral) {
        logMsg("bpDidConnectToRemoteCentral(sender: \(sender))")
        let data = NSKeyedArchiver.archivedDataWithRootObject(["Message":"Test"])
        do {
            try sender.sendData(data) {
                logMsg("send data success")
            }
        } catch let error {
            logErr(error)
        }
    }
    
    func bpDidDisconnectFromRemoteCentral(sender: BluetoothPeripheral) {
        logMsg("bpDidDisconnectFromRemoteCentral(sender: \(sender))")
    }
    
    func bpErrorOccured(sender: BluetoothPeripheral, error: ErrorType) {
        logErr("errbpErrorOccured(sender: \(sender), error: \(error))")
    }
    
    
}
