//
//  CDPlaylist+CoreDataProperties.swift
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

extension CDPlaylist {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var songs: NSOrderedSet?

}
