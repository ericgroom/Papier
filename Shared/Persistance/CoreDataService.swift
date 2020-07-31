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
    
    public var managedObjectContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    public func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Problem saving context: \(error.localizedDescription)")
            }
        }
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Error loading persistentStores: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
}
