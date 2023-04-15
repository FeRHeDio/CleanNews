//
//  ManagedNewsItem.swift
//  CleanNewsFramework
//
//  Created by Fernando Putallaz on 15/04/2023.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
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
class ManagedNewsItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var itemDescription: String
    @NSManaged var imageURL: URL
    @NSManaged var content: String
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
 
    static func articles(from localNews: [LocalNewsItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localNews.map { local in
            let managed = ManagedNewsItem(context: context)
            managed.id = local.id
            managed.title = local.title
            managed.itemDescription = local.description
            managed.imageURL = local.imageURL
            managed.content = local.content
            
            return managed
        })
    }
    
    var local: LocalNewsItem {
        return LocalNewsItem(id: id, title: title, description: itemDescription, imageURL: imageURL, content: content)
    }
}
