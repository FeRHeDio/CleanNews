//
//  CodableNewsStore.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 22/11/2022.
//

import Foundation

public class CodableNewsStore: NewsStore {
    private struct Cache: Codable {
        let items: [CodableNewsItem]
        let timestamp: Date
        
        var localNews: [LocalNewsItem] {
            return items.map { $0.local }
        }
    }
    
    private struct CodableNewsItem: Codable {
        private let id: UUID
        private let title: String
        private let description: String
        private let imageURL: URL
        private let content: String
        
        init(_ item: LocalNewsItem) {
            id = item.id
            title = item.title
            description = item.description
            imageURL = item.imageURL
            content = item.content
        }
        
        var local: LocalNewsItem {
            return LocalNewsItem(id: id, title: title, description: description, imageURL: imageURL, content: content)
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableNewsStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(CachedNews(items: cache.localNews, timestamp: cache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ items: [LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(items: items.map(CodableNewsItem.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
        
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedNews(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(.success(()))
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
