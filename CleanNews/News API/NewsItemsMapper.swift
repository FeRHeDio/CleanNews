//
//  NewsItemsMapper.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 26/10/2022.
//

import Foundation

final class NewsItemsMapper {
    private struct Root: Decodable {
        let articles: [RemoteNewsItem]
    }
    
    private static var OK_200: Int { return 200 }
   
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteNewsItem] {
        guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteNewsLoader.Error.invalidData
        }
        
        return root.articles
    }
}


