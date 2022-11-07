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
    func insert(_ items: [NewsItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
