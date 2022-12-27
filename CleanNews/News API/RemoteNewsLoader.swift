//
//  RemoteNewsLoader.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 27/09/2022.
//

import Foundation

public class RemoteNewsLoader: NewsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = NewsLoader.Result

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(RemoteNewsLoader.map(data, from: response))
            
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try NewsItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteNewsItem {
    func toModels() -> [NewsItem] {
        return map { NewsItem(id: $0.id, title: $0.title, description: $0.description, content: $0.content) }
    }
}
