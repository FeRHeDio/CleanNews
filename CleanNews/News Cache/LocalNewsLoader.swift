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
    public typealias SaveResult = Error?
    
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
    
    private func cache(_ items: [NewsItem], with completion: @escaping (SaveResult) -> Void ) {
        store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
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
                
            case let .success(.some(news, timestamp)) where NewsCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(news.toModels()))
                
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalNewsLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                self.store.deleteCachedNews { _ in
                    print(error)
                }
                
            case let .success(.some(_, timestamp)) where !NewsCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedNews { _ in }
                
            case .success: break
            }
        }
    }
}

private extension Array where Element == NewsItem {
    func toLocal() -> [LocalNewsItem] {
        return map { LocalNewsItem(id: $0.id, title: $0.title, description: $0.description, content: $0.content) }
    }
}

private extension Array where Element == LocalNewsItem {
    func toModels() -> [NewsItem] {
        return map { NewsItem(id: $0.id, title: $0.title, description: $0.description, content: $0.content) }
    }
}
