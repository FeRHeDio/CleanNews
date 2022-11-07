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
    
    private func cache(_ items: [NewsItem], with completion: @escaping (SaveResult) -> Void ) {
        store.insert(items, timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}
