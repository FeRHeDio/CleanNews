//
//  RemoteNewsLoader.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 27/09/2022.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public class RemoteNewsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([NewsItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
                
            case let .success(data, response):
                if let items = try? NewsItemsMapper.map(data, response) {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
            
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private class NewsItemsMapper {
    private struct Root: Decodable {
        let articles: [NewsItem]
    }
    
    static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [NewsItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteNewsLoader.Error.invalidData
        }
        
        return try JSONDecoder().decode(Root.self, from: data).articles
    }
}


