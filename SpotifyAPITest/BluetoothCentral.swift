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
    func bcDidUpdateDataSource(sender: BluetoothCentral)
    func bcDidUpdateState(sender: BluetoothCentral, state: BKCentral.ContinuousScanState)
    
    func bcIsAbleToScan(sender: BluetoothCentral)
    
    func bcDidConnectToRemotePeripheral(sender: BluetoothCentral)
    func bcDidDisconnectFromRemotePeripheral(sender: BluetoothCentral)
    
    func bcErrorOccured(sender: BluetoothCentral, error: ErrorType)
}

class BluetoothCentral: BKCentralDelegate, BKAvailabilityObserver {
    
    private static var privateSharedCentral = try? BluetoothCentral()
    
    static func sharedCentral() throws -> BluetoothCentral {
        if privateSharedCentral == nil {
            privateSharedCentral = try BluetoothCentral()
        }
        return privateSharedCentral!
    }
    
    var delegate: BluetoothCentralDelegate?
    
    private let central = BKCentral()
    var dataSource = [BKDiscovery]() {
        didSet {
            delegate?.bcDidUpdateDataSource(self)
        }
    }
    
    var connectedPeripheral: BKRemotePeripheral? {
        didSet {
            if connectedPeripheral == nil {
                delegate?.bcDidDisconnectFromRemotePeripheral(self)
            } else {
                delegate?.bcDidConnectToRemotePeripheral(self)
            }
        }
    }
    
    /** Time that we will scan for devices */
    var scanTime: NSTimeInterval = 3.0
    /** Delay between continuous scans */
    var scanDelayTime: NSTimeInterval = 3.0
    /**  */
    var connectionTimeout: NSTimeInterval = 5.0
    
    required init() throws {
        
        central.delegate = self
        central.addAvailabilityObserver(self)
        guard let serviceUUID = NSUUID(UUIDString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23"),
            let characteristicUUID = NSUUID(UUIDString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D") else {
                print("serviceUUID or characteristicUUID are nil")
                throw BluetoothErrorType.FailedToInitialize(message: "serviceUUID or characteristicUUID are nil")
        }
        
        let configuration = BKConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID)
        try central.startWithConfiguration(configuration)
        // You are now ready to discover and connect to peripherals.
        
    }
    
    deinit {
        delegate = nil
        dataSource.removeAll()
        connectedPeripheral = nil
        do {
            try self.stop()
        } catch let error {
            logErr(error)
        }
    }
    
    func startContinuousScan() {
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            // Handle changes to "availabile" discoveries, [BKDiscoveriesChange].
            logMsg(changes)
            logMsg(discoveries)
            // Handle current "available" discoveries, [BKDiscovery].
            self.dataSource = discoveries
            // This is where you'd ie. update a table view.
            }, stateHandler: { newState in
                // Handle newState, BKCentral.ContinuousScanState.
                // This is where you'd ie. start/stop an activity indicator.
                
                self.delegate?.bcDidUpdateState(self, state: newState)
                
            }, duration: scanTime, inBetweenDelay: scanDelayTime, errorHandler: { error in
                // Handle error.
                logErr(error)
                self.delegate?.bcErrorOccured(self, error: error)
        })
    }
    
    func startScan() {
        central.scanWithDuration(scanTime, progressHandler: { newDiscoveries in
            // Handle newDiscoveries, [BKDiscovery].
            logMsg(newDiscoveries)
            }, completionHandler: { result, error in
                // Handle error.
                if let error = error {
                    logErr(error)
                    self.delegate?.bcErrorOccured(self, error: error)
                    return
                }
                
                // If no error, handle result, [BKDiscovery].
                if let result = result {
                    self.dataSource = result
                    return
                }
        })
    }
    
    func stop() throws {
        try central.stop()
    }
    
    func connect(idx: Int) throws {
        if dataSource.count < idx {
            throw BluetoothErrorType.IndexOutOfBounds(idx: idx, cnt: dataSource.count)
        }
        
        central.connect(connectionTimeout, remotePeripheral: dataSource[idx].remotePeripheral) { (remotePeripheral, error) -> Void in
            if let error = error {
                logErr(error)
                self.delegate?.bcErrorOccured(self, error: error)
                return
            }
            
            logMsg(remotePeripheral)
            self.connectedPeripheral = remotePeripheral
        }
    }
    
    //MARK: - BKCentralDelegate
    
    /**
     Called when a remote peripheral disconnects or is disconnected.
     - parameter central: The central from which it disconnected.
     - parameter remotePeripheral: The remote peripheral that disconnected.
     */
    func central(central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        logMsg(remotePeripheral)
        if remotePeripheral == connectedPeripheral {
            connectedPeripheral = nil
        }
    }
    
    /**
     Informs the observer about a change in Bluetooth LE availability.
     - parameter availabilityObservable: The object that registered the availability change.
     - parameter availability: The new availability value.
     */
    func availabilityObserver(availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        logMsg(availability)
        if availability == .Available {
            delegate?.bcIsAbleToScan(self)
        }
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