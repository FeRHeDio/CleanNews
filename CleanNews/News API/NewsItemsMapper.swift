//
//  NewsItemsMapper.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 26/10/2022.
//

import Foundation

internal final class NewsItemsMapper {
    private struct Root: Decodable {
        let articles: [NewsItem]
    }
    
    private static var OK_200: Int { return 200 }
   
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteNewsLoader.Result {
        guard response.statusCode == OK_200 else {
            return .failure(.invalidData)
        }
        
        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            let items = root.articles.map { $0 }
            return .success(items)
        } catch {
            return .failure(.invalidData)
        }
    }
}


