//
//  CoreDataNewsStore.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 28/11/2022.
//

import CoreData

public final class CoreDataNewsStore: NewsStore {
    public init() {}
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ items: [CleanNews.LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedNews(completion: @escaping DeletionCompletion) {
        
    }
}
