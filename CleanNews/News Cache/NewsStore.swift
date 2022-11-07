//
//  NewsStore.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 07/11/2022.
//

import Foundation

public protocol NewsStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedNews(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

public struct LocalNewsItem: Equatable, Decodable {
    public let title: String
    public let description: String
    public let content: String
    
    public init(title: String, description: String, content: String) {
        self.title = title
        self.description = description
        self.content = content
    }
}
