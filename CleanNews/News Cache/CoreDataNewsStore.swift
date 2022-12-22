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
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false

                if let cache = try context.fetch(request).first {
                      completion(
                        .found(
                        items: cache.newsFeed
                            .compactMap { ($0 as? ManagedNewsItem) }
                            .map {
                                LocalNewsItem(id: $0.id, title: $0.title, description: $0.description, content: $0.content)
                            },
                        timestamp: cache.timestamp))
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
                let managedCache = ManagedCache(context: context)
                managedCache.timestamp = timestamp
                managedCache.newsFeed = NSOrderedSet(array: items.map { local in
                    let managed = ManagedNewsItem(context: context)
                    managed.id = local.id
                    managed.title = local.title
                    managed.itemDescription = local.description
                    managed.content = local.content
                    
                    return managed
                })

                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedNews(completion: @escaping DeletionCompletion) {
        
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
}

@objc(ManagedNewsItem)
private class ManagedNewsItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var itemDescription: String?
    @NSManaged var content: String
    @NSManaged var cache: ManagedCache
    
}
