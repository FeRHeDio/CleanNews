//
//  CoreDataNewsStore+FeedImageDataLoader.swift
//  CleanNewsFramework
//
//  Created by Fernando Putallaz on 17/04/2023.
//

import Foundation

extension CoreDataNewsStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
