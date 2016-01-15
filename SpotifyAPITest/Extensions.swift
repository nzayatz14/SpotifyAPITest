//
//  Extensions.swift
//  SpotifyAPITest
//
//  Created by Nick Zayatz on 1/5/16.
//  Copyright © 2016 Nick Zayatz. All rights reserved.
//

import Foundation
import UIKit
import Soundcloud

extension Array
{
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<10
        {
            sortInPlace { (_,_) in arc4random() < arc4random() }
        }
    }
}
