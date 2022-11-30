//
//  ContextObserverTests.swift
//  CoreDataUtilsTests
//
//  Created by yukonblue on 08/31/2022.
//

import Foundation
import Combine
import CoreData

import XCTest
@testable import CoreDataUtils

class PersistenceTestsBase: XCTestCase {

    // MARK: Properties

    var persistenceController: PersistenceController!

    var context: NSManagedObjectContext {
        self.persistenceController.viewContext
    }

    // MARK: Setup and teardown

    override func setUpWithError() throws {
        self.persistenceController = PersistenceController()
    }
}

class ContextObserverTests: PersistenceTestsBase {

    var cancellable: AnyCancellable!

    func testObserveInsertions() throws {
        let observer = ContextObserver<ManagedPlayerItem>(context: self.context, updatesToObserve: [.inserts])

        let managedObjects = self.createManagedObjects()

        let expectedInsertionCount = managedObjects.count

        let expectation = XCTestExpectation(description: "Correct context changes (insertions) observed")

        self.cancellable = observer.publisher.sink { contextChange in
            if case let .insert(insertionCount) = contextChange, insertionCount == expectedInsertionCount {
                expectation.fulfill()
            }
        }

        try self.context.save()

        wait(for: [expectation], timeout: 1.0)
    }

    func testObserveUpdates() throws {
        let observer = ContextObserver<ManagedPlayerItem>(context: self.context, updatesToObserve: [.updates])

        let managedObjects = self.createManagedObjects()

        try self.context.save()

        let expectedUpdateCount = 2

        let expectation = XCTestExpectation(description: "Correct context changes (updates) observed")

        self.cancellable = observer.publisher.sink { contextChange in
            if case let .update(updateCount) = contextChange, updateCount == expectedUpdateCount {
                expectation.fulfill()
            }
        }

        // Perform the actual updates.
        managedObjects[0].isFavorite.toggle()
        managedObjects[2].isFavorite.toggle()

        try self.context.save()

        wait(for: [expectation], timeout: 1.0)
    }

    func testObserveDeletions() throws {
        let observer = ContextObserver<ManagedPlayerItem>(context: self.context, updatesToObserve: [.deletes])

        let managedObjects = self.createManagedObjects()

        try self.context.save()

        let expectedDeletionCount = 2

        let expectation = XCTestExpectation(description: "Correct context changes (deletions) observed")

        self.cancellable = observer.publisher.sink { contextChange in
            if case let .delete(deleteCount) = contextChange, deleteCount == expectedDeletionCount {
                expectation.fulfill()
            }
        }

        // Perform the actual updates.
        self.context.delete(managedObjects[0])
        self.context.delete(managedObjects[2])

        try self.context.save()

        wait(for: [expectation], timeout: 1.0)
    }

    private func createManagedObjects() -> [ManagedPlayerItem] {
        [
            ManagedPlayerItem.init(id: UUID(),
                                   title: "Til the End",
                                   author: "MACO",
                                   source: "Sony",
                                   sourceURL: URL(string: "freesound.org")!,
                                   duration: TimeInterval(180),
                                   url: URL(fileURLWithPath: "/maco/til-the-end"),
                                   mediaType: .mpeg4Audio,
                                   in: self.context),
            ManagedPlayerItem.init(id: UUID(),
                                   title: "Into the Wild",
                                   author: "Christopher McCandless",
                                   source: "Sean",
                                   sourceURL: URL(string: "freesound.org")!,
                                   duration: TimeInterval(180),
                                   url: URL(fileURLWithPath: "/chris/into-the-wild"),
                                   mediaType: .mpeg4Audio,
                                   in: self.context),
            ManagedPlayerItem.init(id: UUID(),
                                   title: "Fly to the Moon",
                                   author: "Ayanami",
                                   source: "EVA",
                                   sourceURL: URL(string: "freesound.org")!,
                                   duration: TimeInterval(180),
                                   url: URL(fileURLWithPath: "/ayanami/fly-to-the-moon"),
                                   mediaType: .mpeg4Audio,
                                   in: self.context)
        ]
    }
}
