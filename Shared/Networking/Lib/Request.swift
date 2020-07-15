//
//  Request.swift
//  Papier
//
//  Created by Eric Groom on 7/12/20.
//

import Foundation

public struct Request<Response: Decodable> {
    public let urlRequest: URLRequest
    
    public init(_ urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
}
