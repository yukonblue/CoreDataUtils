//
//  PersistenceController.swift
//  CoreDataUtilsTests
//
//  Created by yukonblue on 07/14/2022.
//

import CoreData

class PersistenceController {

    static let shared = PersistenceController()

    static let modelName = "Model"

    let viewContext: NSManagedObjectContext

    /// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/InitializingtheCoreDataStack.html
    init?() {
        guard let modelBundleURL = Bundle(for: PersistenceController.self).url(forResource: "CoreDataUtils_CoreDataUtilsTests", withExtension: "bundle"),
              let modelBundle = Bundle(url: modelBundleURL) else {
            return nil
        }

        guard let modelURL = modelBundle.url(forResource: "Model", withExtension: "momd") else {
            return nil
        }

        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            return nil
        }

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)

        viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = persistentStoreCoordinator

        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
        queue.async {
            let storeURL = URL(fileURLWithPath: "/dev/null")
            do {
                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                  configurationName: nil,
                                                                  at: storeURL,
                                                                  options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
}
