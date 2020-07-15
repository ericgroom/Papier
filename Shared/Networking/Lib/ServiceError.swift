//
//  ServiceError.swift
//  iOS
//
//  Created by Eric Groom on 7/15/20.
//

import Foundation

enum ServiceError: Swift.Error {
    case requestConstruction(RequestConstructionError)
    case network(NetworkError)
}
