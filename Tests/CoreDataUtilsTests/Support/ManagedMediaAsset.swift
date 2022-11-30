//
//  ManagedMediaAsset.swift
//  CoreDataUtilsTests
//
//  Created by yukonblue on 08/25/2022.
//

import Foundation
import CoreData
import UniformTypeIdentifiers

@testable import CoreDataUtils

@objc(ManagedMediaAsset)
final class ManagedMediaAsset: NSManagedObject, ManagedObjectProtocol {

    // MARK: Attributes

    /// The unique identifier of the record.
    @NSManaged var id: UUID

    /// The media type of the asset.
    @NSManaged var mediaType: String

    /// The **relative** path of the local media file on disk.
    ///
    /// **NOTE**
    /// One must NOT use this directly as the absolute path to load the media file from disk.
    /// Instead, refer to ``ManagedMediaAsset.resolvedURL`` instead.
    @NSManaged var localURL: URL

    // MARK: Relationships

    @NSManaged var playerItem: ManagedPlayerItem?
}

extension ManagedMediaAsset {

    @discardableResult
    convenience init(mediaType: String,
                     localURL: URL,
                     in context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Self.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        self.id = UUID()
        self.mediaType = mediaType
        self.localURL = localURL
    }
}
