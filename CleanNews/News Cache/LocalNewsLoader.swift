//
//  LocalNewsLoader.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 07/11/2022.
//

import Foundation

public final class NewsCachePolicy {
    private init() {}
    
    private static let calendar = Calendar(identifier: .gregorian)
    private static var maxCacheDateInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheDateInDays, to: timestamp) else {
            return false
        }
        
        return date < maxCacheAge
    }
}

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
    public typealias LoadResult = NewsLoaderResult
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .found(news, timestamp) where NewsCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(news.toModels()))
                
            case .found, .empty:
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
                
            case let .found(_, timestamp) where !NewsCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedNews { _ in }
                
            case .empty, .found: break
            }
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
