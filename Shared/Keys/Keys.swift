//
//  Keys.swift
//  Papier
//
//  Created by Eric Groom on 6/29/20.
//

import Foundation

struct Keys: Codable {
    let iexcloud: IEXCloud
    
    struct IEXCloud: Codable {
        let sandbox: String
        let publishable: String
    }
}

extension Keys {
    static func fetch(from suite: UserDefaults) throws -> Keys {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist") else {
            throw KeyFetchingError.unableToFindKeysPlist
        }
        guard let contents = FileManager.default.contents(atPath: path) else {
            throw KeyFetchingError.unableToReadKeysPlist
        }
        
        let decoder = PropertyListDecoder()
        return try decoder.decode(Keys.self, from: contents)
    }
}

enum KeyFetchingError: Error {
    case unableToFindKeysPlist
    case unableToReadKeysPlist
}
