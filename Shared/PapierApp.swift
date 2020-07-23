//
//  PapierApp.swift
//  Shared
//
//  Created by Eric Groom on 6/27/20.
//

import SwiftUI
import Combine

@main
struct PapierApp: App {
    init() {
        
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                WatchlistView()
            }
            .onAppear {
                print(RealEnvironment.shared.coreDataService.mainManagedObjectContext)
            }
        }
    }
}
