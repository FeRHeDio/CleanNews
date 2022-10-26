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
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [NewsItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteNewsLoader.Error.invalidData
        }
        
        return try JSONDecoder().decode(Root.self, from: data).articles
    }
}


