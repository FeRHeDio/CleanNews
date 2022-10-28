//
//  NewsLoader.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 28/10/2022.
//

import Foundation

public enum NewsLoaderResult {
    case success([NewsItem])
    case failure(Error)
}

protocol NewsLoader {
    func load(completion: @escaping (NewsLoaderResult) -> Void)
}
