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
            completion(Result {
                try ManagedNewsItem.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            })
        }
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedNewsItem.first(with: url, in: context)?.data
            })
        }
    }
}
