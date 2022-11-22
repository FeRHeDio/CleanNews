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
    private let calendar = Calendar(identifier: .gregorian)
    
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
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .found(news, timestamp) where self.validate(timestamp):
                completion(.success(news.toModels()))
                
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                self.store.deleteCachedNews { _ in
                    print(error)
                }
                
            case let .found(_, timestamp) where !self.validate(timestamp):
                self.store.deleteCachedNews { _ in }
                
            case .empty, .found: break
            }
        }
    }
    
    private var maxCacheDateInDays: Int {
        return 7
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheDateInDays, to: timestamp) else {
            return false
        }
        
        return currentDate() < maxCacheAge
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
