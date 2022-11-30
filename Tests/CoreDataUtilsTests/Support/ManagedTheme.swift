//
//  ManagedTheme.swift
//  CoreDataUtilsTests
//
//  Created by yukonblue on 08/09/2022.
//

import CoreData

@testable import CoreDataUtils

@objc(ManagedTheme)
final class ManagedTheme: NSManagedObject, ManagedObjectProtocol {

    @NSManaged var identifier: String
    @NSManaged var title: String
    @NSManaged var subtitle: String
    @NSManaged var defaultImageName: String
    @NSManaged var font: String

    @NSManaged var playerItems: Set<ManagedPlayerItem>
}

extension ManagedTheme {

    @discardableResult
    convenience init(identifier: String,
                     title: String,
                     subtitle: String,
                     image: String,
                     font: String,
                     in context: NSManagedObjectContext) {
        self.init(in: context)
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.font = font
        self.defaultImageName = image
    }
}

extension ManagedTheme {

    static func fetchRecord(withIdentifiers identifiers: [String], in context: NSManagedObjectContext) throws -> [ManagedTheme] {
        let predicate = NSPredicate(
            format: "%K IN %@",
            #keyPath(ManagedTheme.identifier),
            identifiers
        )
        return try Self.fetchAll(withPredicate: predicate, in: context)
    }

    static func fetchRecordsWithAtLeastOnePlayerItem(in context: NSManagedObjectContext) throws -> [ManagedTheme] {
        let predicate = NSPredicate(
            format: "%K.@count > 0",
            #keyPath(ManagedTheme.playerItems)
        )
        return try Self.fetchAll(withPredicate: predicate, in: context)
    }
}
