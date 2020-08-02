//
//  WatchlistPeristenceService.swift
//  iOS
//
//  Created by Eric Groom on 7/23/20.
//

import Foundation
import CoreData

class WatchlistPeristenceService {
    let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func getWatchedSymbols() throws -> [WatchedSymbol] {
        let request: NSFetchRequest<CDWatchedSymbol> = CDWatchedSymbol.fetchRequest()
        let orderDescriptor = NSSortDescriptor(keyPath: \CDWatchedSymbol.order, ascending: true)
        let alphaDescriptor = NSSortDescriptor(keyPath: \CDWatchedSymbol.symbol, ascending: true)
        request.sortDescriptors = [orderDescriptor, alphaDescriptor]
        
        let objects = try managedObjectContext.fetch(request)
        return objects.compactMap(WatchedSymbol.init(cdModel:))
    }
    
    func new(_ model: WatchedSymbol) throws {
        let cdModel = CDWatchedSymbol(model: model, context: managedObjectContext)
        managedObjectContext.insert(cdModel)
        try managedObjectContext.save()
    }
    
    func delete(_ model: [WatchedSymbol]) throws {
        let request: NSFetchRequest<NSFetchRequestResult> = CDWatchedSymbol.fetchRequest()
        request.predicate = NSPredicate(format: "symbol IN %@", model.map(\.symbol))
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
        try managedObjectContext.execute(batchDelete)
        try managedObjectContext.save()
    }
    
    func upsert(_ models: [WatchedSymbol]) throws {
        let cdModels = models.map { model in
            CDWatchedSymbol(model: model, context: managedObjectContext)
        }
        for model in cdModels {
            managedObjectContext.insert(model)
        }
        try managedObjectContext.save()
    }
}

extension WatchedSymbol {
    init?(cdModel: CDWatchedSymbol) {
        guard let symbol = cdModel.symbol else { return nil }
        self.init(symbol: symbol, order: Int(cdModel.order))
    }
}

extension CDWatchedSymbol {
    convenience init(model: WatchedSymbol, context: NSManagedObjectContext) {
        self.init(context: context)
        self.symbol = model.symbol
        self.order = Int32(model.order)
    }
}
