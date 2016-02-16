//
//  BluetoothErrorType.swift
//  SpotifyAPITest
//
//  Created by Thomas Douglas on 1/14/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import Foundation

enum BluetoothErrorType : ErrorType {
    case FailedToInitialize(message: String)
    case IndexOutOfBounds(idx: Int, cnt: Int)
}

//func ~=(lhs: BluetoothErrorType, rhs: BluetoothErrorType) -> Bool {
//    return lhs._domain == rhs._domain
//        && lhs._code   == rhs._code
//}
//
///// Extend our Error type to implement `Equatable`.
///// This must be done per individual concrete type
///// and can't be done in general for `ErrorType`.
//extension BluetoothErrorType : Equatable {}
//
///// Implement the `==` operator as required by protocol `Equatable`.
//func ==(lhs: BluetoothErrorType, rhs: BluetoothErrorType) -> Bool {
//    switch (lhs, rhs) {
//    case (.FailedToInitialize(let l), .FailedToInitialize(let r)):
//        return l == r
//    default:
//        // We need a default case to return false for different case combinations.
//        // By falling back to domain and code based comparison, we ensure that
//        // as soon as we add additional error cases, we have to revisit only the
//        // Equatable implementation, if the case has an associated value.
//        return lhs._domain == rhs._domain
//            && lhs._code   == rhs._code
//    }
//}