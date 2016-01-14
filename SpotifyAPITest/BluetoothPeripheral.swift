//
//  BluetoothPeripheral.swift
//  SpotifyAPITest
//
//  Created by Thomas Douglas on 1/14/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import Foundation
import BluetoothKit

protocol BluetoothPeripheralDelegate {
    
}

class BluetoothPeripheral: BKPeripheralDelegate {
    
    var delegate: BluetoothPeripheralDelegate?
    
    let peripheral = BKPeripheral()
    
    required init() throws {
        
        guard let serviceUUID = NSUUID(UUIDString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23"),
            let characteristicUUID = NSUUID(UUIDString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D") else {
                throw BluetoothErrorType.FailedToInitialize(message: "serviceUUID or characteristicUUID was nil")
        }
        
        let localName = "My Cool Peripheral"
        let configuration = BKPeripheralConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID:  characteristicUUID, localName: localName)
        try peripheral.startWithConfiguration(configuration)
        // You are now ready for incoming connections
        
    }
    
    //MARK: - BKPeripheralDelegate
    
    /**
     Called when a remote central connects and is ready to receive data.
     - parameter peripheral: The peripheral object to which the remote central connected.
     - parameter remoteCentral: The remote central that connected.
     */
    func peripheral(peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        
    }
    
    /**
     Called when a remote central disconnects and can no longer receive data.
     - parameter peripheral: The peripheral object from which the remote central disconnected.
     - parameter remoteCentral: The remote central that disconnected.
     */
    func peripheral(peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        
    }
    
}