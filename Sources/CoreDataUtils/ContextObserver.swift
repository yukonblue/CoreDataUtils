//
//  ContextObserver.swift
//  CoreDataUtils
//
//  Created by yukonblue on 08/10/2022.
//

import Foundation
import CoreData
import Combine

public struct ObservableContextChange: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static public let inserts = ObservableContextChange(rawValue: 1 << 0)
    static public let updates = ObservableContextChange(rawValue: 1 << 1)
    static public let deletes = ObservableContextChange(rawValue: 1 << 2)
}

public class ContextObserver<T: NSManagedObject> {

    public enum ContextChange {
        case insert(Int)
        case update(Int)
        case delete(Int)
    }

    var context: NSManagedObjectContext

    let subject: PassthroughSubject<ContextChange, Never>
    let updatesToObserve: ObservableContextChange

    public var publisher: AnyPublisher<ContextChange, Never> {
        self.subject.eraseToAnyPublisher()
    }

    public init(context: NSManagedObjectContext, updatesToObserve: ObservableContextChange) {
        self.context = context
        self.updatesToObserve = updatesToObserve
        self.subject = PassthroughSubject<ContextChange, Never>()
        self.register(context: self.context)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func register(context: NSManagedObjectContext) {
        self.context = context

        NotificationCenter.default.removeObserver(self)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextObjectsDidChange),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: self.context)
    }

    @objc
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        if self.updatesToObserve.contains(.inserts),
           let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>,
           let insertsForType = Optional(inserts.compactMap({ $0 as? T })),
           insertsForType.count > 0 {
            self.subject.send(.insert(inserts.count))
        }

        if self.updatesToObserve.contains(.updates),
           let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
           let updatesForType = Optional(updates.compactMap({ $0 as? T })),
           updatesForType.count > 0 {
            self.subject.send(.update(updates.count))
        }

        if self.updatesToObserve.contains(.deletes),
           let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
           let deletesForType = Optional(deletes.compactMap({ $0 as? T })),
           deletesForType.count > 0 {
            self.subject.send(.delete(deletes.count))
        }
    }
}
