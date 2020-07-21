//
//  RequestServicer.swift
//  Papier
//
//  Created by Eric Groom on 6/29/20.
//

import Foundation
import Combine

protocol RequestServicing {
    func service(request: URLRequest) -> URLSession.DataTaskPublisher
    func fetch<T: Decodable>(request: Request<T>) -> AnyPublisher<T, NetworkError>
}

struct RequestServicer: RequestServicing {
    private var printJSON = false
    
    func service(request: URLRequest) -> URLSession.DataTaskPublisher {
        URLSession.shared.dataTaskPublisher(for: request)
    }
    
    func fetch<T: Decodable>(request: Request<T>) -> AnyPublisher<T, NetworkError> {
        let decoder = JSONDecoder()
        
        return service(request: request.urlRequest)
            .mapError { NetworkError.urlError($0) }
            .map(\.data)
            .handleEvents(receiveOutput: printJson(from:))
            .decode(type: T.self, decoder: decoder)
            .mapError({ error in
                switch error {
                case let networkError as NetworkError:
                    return networkError
                case let decodingError as DecodingError:
                    return .decodingError(decodingError)
                default:
                    return .unknown(error)
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func printJson(from data: Data) {
        guard
            printJSON,
            let str = String(data: data, encoding: .utf8)
        else {
            return
        }
        print(str)
    }
}

enum NetworkError: Error {
    case urlError(URLError)
    case decodingError(DecodingError)
    case unknown(Error)
}
