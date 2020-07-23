//
//  CoreDataService.swift
//  iOS
//
//  Created by Eric Groom on 7/20/20.
//

import Foundation
import CoreData
import UIKit
import Combine

class CoreDataService {
    
    private let modelName: String
    private var bag: Set<AnyCancellable> = Set()
    
    init(modelName: String = "Papier") {
        self.modelName = modelName
        
        let resignActive = NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
        let terminate = NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)
        
        Publishers.Merge(resignActive, terminate)
            .sink { [weak self] _ in
                self?.save()
            }.store(in: &bag)
    }
    
    public private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = privateManagedObjectContext
        return context
    }()
    
    public func save() {
        mainManagedObjectContext.performAndWait {
            if mainManagedObjectContext.hasChanges {
                do {
                    try mainManagedObjectContext.save()
                } catch {
                    print("Unable to save mainManagedObjectContext \(error)")
                }
            }
        }
        
        privateManagedObjectContext.perform { [self] in
            if privateManagedObjectContext.hasChanges {
                do {
                    try privateManagedObjectContext.save()
                } catch {
                    print("Unable to save privateManagedObjectContext \(error)")
                }
            }
        }
    }
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
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
