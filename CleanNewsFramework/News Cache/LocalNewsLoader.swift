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
    
    public init(store: NewsStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}
 
extension LocalNewsLoader {
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ items: [NewsItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedNews { [weak self] deletionResult in
            guard let self = self else { return }
            
            switch deletionResult {
            case .success():
                self.cache(items, with: completion)
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ items: [NewsItem], with completion: @escaping (SaveResult) -> Void ) {
        store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }
            
            completion(insertionResult)
        }
    }
}
    
extension LocalNewsLoader: NewsLoader {
    public typealias LoadResult = NewsLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(.some((news, timestamp))) where NewsCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(news.toModels()))
                
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalNewsLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedNews(completion: completion)
            
            case let .success(.some(cache)) where !NewsCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedNews { _ in
                completion(.success(()))
            }
                
            case .success:
                completion(.success(()))
            }
        }
    }
}

private extension Array where Element == NewsItem {
    func toLocal() -> [LocalNewsItem] {
        map { LocalNewsItem(id: $0.id, title: $0.title, description: $0.description, imageURL: $0.imageURL, content: $0.content) }
    }
}

private extension Array where Element == LocalNewsItem {
    func toModels() -> [NewsItem] {
        map { NewsItem(id: $0.id, title: $0.title, description: $0.description, imageURL: $0.imageURL, content: $0.content) }
    }
}
