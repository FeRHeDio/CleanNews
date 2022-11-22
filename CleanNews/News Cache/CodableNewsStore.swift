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
        private let title: String
        private let description: String
        private let content: String
        
        init(_ item: LocalNewsItem) {
            title = item.title
            description = item.description
            content = item.content
        }
        
        var local: LocalNewsItem {
            return LocalNewsItem(title: title, description: description, content: content)
        }
    }
    
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(items: cache.localNews, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
        
    }
    
    public func insert(_ items: [LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let cache = Cache(items: items.map(CodableNewsItem.init), timestamp: timestamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
    
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func deleteCachedNews(completion: @escaping DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }

        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
