//
//  CoreDataNewsStore.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 28/11/2022.
//

import CoreData

public final class CoreDataNewsStore: NewsStore {
    private let container: NSPersistentContainer
    
    public init(bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "NewsStore", in: bundle)
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ items: [CleanNews.LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedNews(completion: @escaping DeletionCompletion) {
        
    }
}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
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
