//
//  ManagedPlaylist.swift
//  CoreDataUtilsTests
//
//  Created by yukonblue on 07/14/2022.
//

import Foundation
import CoreData

@testable import CoreDataUtils

@objc(ManagedPlaylist)
final class ManagedPlaylist: NSManagedObject, ManagedObjectProtocol {

    @NSManaged var id: UUID
    @NSManaged var name: String

    @NSManaged var items: Set<ManagedPlayerItem>
}

extension ManagedPlaylist {

    convenience init(name: String,
                     in context: NSManagedObjectContext) {
        self.init(in: context)
        self.id = UUID()
        self.name = name
    }
}
