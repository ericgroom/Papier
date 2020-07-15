//
//  FromResult.swift
//  iOS
//
//  Created by Eric Groom on 7/15/20.
//

import Combine

func FromResult<Success, Failure: Error>(_ result: Result<Success, Failure>) -> Future<Success, Failure> {
    return Future.init { promise in
        switch result {
        case .success(let value):
            promise(.success(value))
        case .failure(let error):
            promise(.failure(error))
        }
    }
}
