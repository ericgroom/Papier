//
//  RequestServicer.swift
//  Papier
//
//  Created by Eric Groom on 6/29/20.
//

import Foundation
import Combine

protocol RequestServicing {
    typealias AnyURLSessionPublisher = AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure>

    func service(request: URLRequest) -> AnyURLSessionPublisher
    func fetch<T: Decodable>(request: Request<T>) -> AnyPublisher<T, NetworkError>
}

struct RequestServicer: RequestServicing {
    private var printJSON = false
    
    class Hooks {
        fileprivate let servicingRequestSubject = PassthroughSubject<URLRequest, Never>()
        var servicingRequest: AnyPublisher<URLRequest, Never> {
            servicingRequestSubject.eraseToAnyPublisher()
        }
        
        fileprivate let receivedResponseSubject = PassthroughSubject<URLResponse, Never>()
        var receivedResponse: AnyPublisher<URLResponse, Never> {
            receivedResponseSubject.eraseToAnyPublisher()
        }
    }
    
    public let hooks = Hooks()
    
    func service(request: URLRequest) -> AnyURLSessionPublisher {
        hooks.servicingRequestSubject.send(request)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { (_, response) in hooks.receivedResponseSubject.send(response)
            })
            .eraseToAnyPublisher()
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
