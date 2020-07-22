//
//  CoreDataService.swift
//  iOS
//
//  Created by Eric Groom on 7/20/20.
//

import Foundation
import CoreData

class CoreDataService {
    
    private let modelName: String
    
    init(modelName: String = "Papier") {
        self.modelName = modelName
    }
    
    public private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // Fetch Model URL
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }

        // Initialize Managed Object Model
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }

        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        do {
            try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqlitePath, options: options)
        } catch {
            fatalError("Unable to add persistent store")
        }
        
        return storeCoordinator
    }()
    
    private var sqlitePath: URL? {
        let fileName = "\(modelName).sqlite"
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsDir?.appendingPathComponent(fileName)
    }
}
