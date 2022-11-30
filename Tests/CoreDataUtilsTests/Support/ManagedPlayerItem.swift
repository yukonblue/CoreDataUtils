//
//  ManagedPlayerItem.swift
//  CoreDataUtilsTests
//
//  Created by yukonblue on 07/14/2022.
//

import Foundation
import CoreData
import UniformTypeIdentifiers

@testable import CoreDataUtils

@objc(ManagedPlayerItem)
final class ManagedPlayerItem: NSManagedObject, ManagedObjectProtocol {

    // MARK: Attributes

    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var author: String
    @NSManaged var source: String?
    @NSManaged var sourceURL: URL
    @NSManaged var itemDescription: String?
    @NSManaged var duration: TimeInterval
    @NSManaged var url: URL
    @NSManaged var mediaType: String
    @NSManaged var isFavorite: Bool

    // MARK: Relationships

    @NSManaged var playlists: Set<ManagedPlaylist>
    @NSManaged var themes: Set<ManagedTheme>
    @NSManaged var mediaAsset: ManagedMediaAsset?

    private var markIsFavorite: Bool = true
    private var markLocalURL: URL? = nil
}

extension ManagedPlayerItem {

    @discardableResult
    convenience init(id: UUID,
                     title: String,
                     author: String,
                     source: String?,
                     sourceURL: URL,
                     itemDescription: String? = nil,
                     duration: TimeInterval,
                     url: URL,
                     mediaType: UTType,
                     isFavorite: Bool = false,
                     in context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Self.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        self.id = id
        self.title = title
        self.author = author
        self.source = source
        self.sourceURL = sourceURL
        self.itemDescription = itemDescription
        self.duration = duration
        self.url = url
        self.mediaType = mediaType.identifier
        self.isFavorite = isFavorite
    }
}

extension ManagedPlayerItem {

    static func fetchRecord(withIDs ids: [UUID], in context: NSManagedObjectContext) throws -> [ManagedPlayerItem] {
        let fetchRequest = ManagedPlayerItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K IN %@",
            #keyPath(ManagedPlayerItem.id),
            ids
        )
        return try context.fetch(fetchRequest)
    }

    static func fetchAllFavroties(in context: NSManagedObjectContext) throws -> [ManagedPlayerItem] {
        let fetchRequest = ManagedPlayerItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K == true",
            #keyPath(ManagedPlayerItem.isFavorite)
        )
        return try context.fetch(fetchRequest)
    }
}
