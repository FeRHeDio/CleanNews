//
//  NewsLoader.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 28/10/2022.
//

import Foundation

public typealias NewsLoaderResult = Result<[NewsItem], Error>

public protocol NewsLoader {
    func load(completion: @escaping (NewsLoaderResult) -> Void)
}
