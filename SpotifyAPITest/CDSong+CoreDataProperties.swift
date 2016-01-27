//
//  CDSong+CoreDataProperties.swift
//  
//
//  Created by Thomas Douglas on 1/27/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDSong {

    @NSManaged var id: Int
    @NSManaged var playlists: NSSet?

}
