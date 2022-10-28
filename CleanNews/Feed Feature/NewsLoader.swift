//
//  NewsLoader.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 28/10/2022.
//

import Foundation

public enum NewsLoaderResult<Error: Swift.Error> {
    case success([NewsItem])
    case failure(Error)
}

protocol NewsLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (NewsLoaderResult<Error>) -> Void)
}
