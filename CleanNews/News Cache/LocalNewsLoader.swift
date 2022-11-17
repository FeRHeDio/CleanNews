//
//  LocalNewsLoader.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 07/11/2022.
//

import Foundation

public final class LocalNewsLoader {
    private let store: NewsStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = NewsLoaderResult
    
    public init(store: NewsStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [NewsItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedNews { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve{ result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .found(news, _):
                completion(.success(news.toModels()))
                
            case .empty:
                completion(.success([]))
            }
        }
    }
    
    private func cache(_ items: [NewsItem], with completion: @escaping (SaveResult) -> Void ) {
        store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

private extension Array where Element == NewsItem {
    func toLocal() -> [LocalNewsItem] {
        return map { LocalNewsItem(title: $0.title, description: $0.description, content: $0.content) }
    }
}

private extension Array where Element == LocalNewsItem {
    func toModels() -> [NewsItem] {
        return map { NewsItem(title: $0.title, description: $0.description, content: $0.content) }
    }
}
