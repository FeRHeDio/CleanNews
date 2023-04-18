//
//  CoreDataNewsStore+NewsStore.swift
//  CleanNewsFramework
//
//  Created by Fernando Putallaz on 17/04/2023.
//

import CoreData

extension CoreDataNewsStore: NewsStore {
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CachedNews(items: $0.localNews, timestamp: $0.timestamp)
                }
            })
        }
    }
    
    public func insert(_ items: [LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.newsFeed = ManagedNewsItem.articles(from: items, in: context)
                
                try context.save()
            })
        }
    }
    
    public func deleteCachedNews(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
}
