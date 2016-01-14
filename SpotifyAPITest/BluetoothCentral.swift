//
//  BluetoothCentral.swift
//  SpotifyAPITest
//
//  Created by Thomas Douglas on 1/14/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import Foundation
import BluetoothKit

protocol BluetoothCentralDelegate {
    
}

class BluetoothCentral: BKCentralDelegate {
    
    var delegate: BluetoothCentralDelegate?
    
    let central = BKCentral()
    var discoverdDevices = [BKDiscovery]()
    
    /** Time that we will scan for devices */
    var scanTime: NSTimeInterval = 3.0
    /** Delay between continuous scans */
    var scanDelayTime: NSTimeInterval = 3.0
    
    required init() throws {
        
        central.delegate = self
        
        guard let serviceUUID = NSUUID(UUIDString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23"),
            let characteristicUUID = NSUUID(UUIDString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D") else {
                print("serviceUUID or characteristicUUID are nil")
                throw BluetoothErrorType.FailedToInitialize(message: "serviceUUID or characteristicUUID are nil")
        }
        
        let configuration = BKConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID)
        try central.startWithConfiguration(configuration)
        // You are now ready to discover and connect to peripherals.
        
    }
    
    func startContinuousScan() {
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            // Handle changes to "availabile" discoveries, [BKDiscoveriesChange].
            // Handle current "available" discoveries, [BKDiscovery].
            // This is where you'd ie. update a table view.
            }, stateHandler: { newState in
                // Handle newState, BKCentral.ContinuousScanState.
                // This is where you'd ie. start/stop an activity indicator.
            }, duration: scanTime, inBetweenDelay: scanDelayTime, errorHandler: { error in
                // Handle error.
        })
    }
    
    func startScan() {
        central.scanWithDuration(scanTime, progressHandler: { newDiscoveries in
            // Handle newDiscoveries, [BKDiscovery].
            }, completionHandler: { result, error in
                // Handle error.
                // If no error, handle result, [BKDiscovery].
        })
    }
    
    //MARK: - BKCentralDelegate
    
    /**
     Called when a remote peripheral disconnects or is disconnected.
     - parameter central: The central from which it disconnected.
     - parameter remotePeripheral: The remote peripheral that disconnected.
     */
    func central(central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        
    }
    
}