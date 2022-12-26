//
//  CoreDataNewsStore.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 28/11/2022.
//

import CoreData

public final class CoreDataNewsStore: NewsStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "NewsStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context = self.context
        
        context.perform {
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(items: cache.localNews, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ items: [LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = self.context

        context.perform {
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.newsFeed = ManagedNewsItem.articles(from: items, in: context)
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedNews(completion: @escaping DeletionCompletion) {
        let context = self.context
        
        context.perform {
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var newsFeed: NSOrderedSet
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        
        return ManagedCache(context: context)
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false

        return try! context.fetch(request).first
    }
    
    var localNews: [LocalNewsItem] {
        return newsFeed.compactMap {
            ($0 as? ManagedNewsItem)?.local
        }
    }
}

@objc(ManagedNewsItem)
private class ManagedNewsItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var itemDescription: String
    @NSManaged var content: String
    @NSManaged var cache: ManagedCache
 
    static func articles(from localNews: [LocalNewsItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localNews.map { local in
            let managed = ManagedNewsItem(context: context)
            managed.id = local.id
            managed.title = local.title
            managed.itemDescription = local.description
            managed.content = local.content
            
            return managed
        })
    }
    
    var local: LocalNewsItem {
        return LocalNewsItem(id: id, title: title, description: itemDescription, content: content)
    }
    
}
