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
    func bpDidConnectToRemoteCentral(sender: BluetoothPeripheral)
    func bpDidDisconnectFromRemoteCentral(sender: BluetoothPeripheral)
    
    func bpErrorOccured(sender: BluetoothPeripheral, error: ErrorType)
}

class BluetoothPeripheral: BKPeripheralDelegate, BKAvailabilityObserver {
    
    static let sharedPeripheral = BluetoothPeripheral()
    
    var delegate: BluetoothPeripheralDelegate?
    
    var connectedCentral: BKRemoteCentral? {
        didSet {
            if connectedCentral == nil {
                delegate?.bpDidDisconnectFromRemoteCentral(self)
            } else {
                delegate?.bpDidConnectToRemoteCentral(self)
            }
        }
    }
    
    
    var availability: BKAvailability {
        return peripheral.availability
    }
    
//    var dataSource: [BKRemoteCentral] {
//        return peripheral.connectedRemoteCentrals
//    }
    
    private let peripheral = BKPeripheral()
    
    required init() {
        
        peripheral.delegate = self
        peripheral.addAvailabilityObserver(self)
        
    }
    
    func start(name: String) throws {
        guard let serviceUUID = NSUUID(UUIDString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23"),
            let characteristicUUID = NSUUID(UUIDString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D") else {
                throw BluetoothErrorType.FailedToInitialize(message: "serviceUUID or characteristicUUID was nil")
        }
        
        let configuration = BKPeripheralConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID:  characteristicUUID, localName: name)
        try peripheral.startWithConfiguration(configuration)
        // You are now ready for incoming connections

    }
    
    func stop() throws {
        try peripheral.stop()
    }
    
    func sendData(data: NSData, success: (() -> Void)? = nil) throws {
        guard let connectedCentral = self.connectedCentral else {
            throw BluetoothErrorType.ConnectedDeviceWasNil
        }
        
        peripheral.sendData(data, toRemoteCentral: connectedCentral) { (data, remoteCentral, error) -> Void in
            if let error = error {
                logErr(error)
                self.delegate?.bpErrorOccured(self, error: error)
                return
            }
            
            success?()
        }
    }
    
    //MARK: - BKPeripheralDelegate
    
    /**
     Called when a remote central connects and is ready to receive data.
     - parameter peripheral: The peripheral object to which the remote central connected.
     - parameter remoteCentral: The remote central that connected.
     */
    func peripheral(peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        logMsg(remoteCentral)
        if connectedCentral == nil {
            connectedCentral = remoteCentral
        } else {
            logErr("connected to more than one central")
        }
    }
    
    /**
     Called when a remote central disconnects and can no longer receive data.
     - parameter peripheral: The peripheral object from which the remote central disconnected.
     - parameter remoteCentral: The remote central that disconnected.
     */
    func peripheral(peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        logMsg(remoteCentral)
        if remoteCentral == connectedCentral {
            connectedCentral = nil
        } else {
            logErr("disconnected from unknown central")
        }
    }
    
    /**
     Informs the observer about a change in Bluetooth LE availability.
     - parameter availabilityObservable: The object that registered the availability change.
     - parameter availability: The new availability value.
     */
    func availabilityObserver(availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        logMsg(availability)
    }
    
    /**
     Informs the observer that the cause of Bluetooth LE unavailability changed.
     - parameter availabilityObservable: The object that registered the cause change.
     - parameter unavailabilityCause: The new cause of unavailability.
     */
    func availabilityObserver(availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        logMsg(unavailabilityCause)
    }
    
}