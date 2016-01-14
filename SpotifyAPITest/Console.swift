//
//  Console.swift
//  SpotifyAPITest
//
//  Created by Thomas Douglas on 1/14/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import Foundation

private let consoleQueue = dispatch_queue_create("console_queue", DISPATCH_QUEUE_SERIAL)

//MARK: - Logging
struct zipsyLogging {
    static let sharedLogger = zipsyLogging()
    
    var logVerbose = false
    var logMainMsg = true //set to false to turn off message logging
    var logMainErr = true //set to false to turn off error logging
}

/**
 logs a message
 
 :param: message: the message that will be logged.
 
 :param: file: by default this prints the file name if you with to dissable the file name set the parameter to nil.
 
 :param: function: by default this prints the function name if you with to dissable the function name set the parameter to nil.
 
 :param: line: by default this prints the line number if you with to dissable the file line number the parameter to nil.
 
 :returns: void
 */
@inline(__always) func logMsg<T>(message: T, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
    if zipsyLogging.sharedLogger.logMainMsg {
        dispatch_sync(consoleQueue) {
            if zipsyLogging.sharedLogger.logVerbose {
                print("»»» (File: \(file.lastPathComponent.stringByDeletingPathExtension), Function: \(function), Line: \(line))\nMessage: \"\(message)\"")
            } else {
                print("»»» \"\(message)\"")
            }
        }
    }
}

/**
 logs an error
 
 :param: error: the error that will be logged.
 
 :param: file: by default this prints the file name if you with to dissable the file name set the parameter to nil.
 
 :param: function: by default this prints the function name if you with to dissable the function name set the parameter to nil.
 
 :param: line: by default this prints the line number if you with to dissable the file line number the parameter to nil.
 
 :returns: void
 */
@inline(__always) func logErr<T>(error: T, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
    if zipsyLogging.sharedLogger.logMainMsg {
        dispatch_sync(consoleQueue) {
            print("❌ »»» ERROR: (File: \(file.lastPathComponent.stringByDeletingPathExtension), Function: \(function), Line: \(line)):\nError Message: \"\(error)\"")
        }
    }
}
