//
//  CoreDataNewsStore+FeedImageDataLoader.swift
//  CleanNewsFramework
//
//  Created by Fernando Putallaz on 17/04/2023.
//

import Foundation

extension CoreDataNewsStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            guard let image = try? ManagedNewsItem.first(with: url, in: context) else { return }
            
            image.data = data
            try? context.save()
        }
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                return try ManagedNewsItem.first(with: url, in: context)?.data
            })
        }
    }
}
