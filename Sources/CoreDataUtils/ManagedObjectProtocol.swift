//
//  ManagedObjectProtocol.swift
//  CoreDataUtils
//
//  Created by yukonblue on 07/14/2022.
//

import CoreData

/// Protocol for managed objects that encapsulates a set of common facilities.
public protocol ManagedObjectProtocol: NSManagedObject {

    /// Create an instance of the entity in the given context.
    init(in context: NSManagedObjectContext)

    /// Gets the name of the entity.
    static var entityName: String { get }

    /// Creates a fetch request for the entity.
    static func fetchRequest() -> NSFetchRequest<Self>
}

public extension ManagedObjectProtocol {

    init(in context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entity(forEntityName: Self.entityName, in: context)!
        self.init(entity: entityDescription, insertInto: context)
    }

    /// Default implementation.
    static var entityName: String {
        String(describing: Self.self)
    }

    /// Default implementation.
    /// Returns a barebone fetch request.
    static func fetchRequest() -> NSFetchRequest<Self> {
        NSFetchRequest<Self>(entityName: Self.entityName)
    }

    static func fetchAll(in context: NSManagedObjectContext) throws -> [Self] {
        try context.fetch(Self.fetchRequest())
    }

    static func fetchAll(withPredicate predicate: NSPredicate, in context: NSManagedObjectContext) throws -> [Self] {
        let fetchRequest = Self.fetchRequest()
        fetchRequest.predicate = predicate
        return try context.fetch(fetchRequest)
    }
}
