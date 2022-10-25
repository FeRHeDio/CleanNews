//
//  News.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 31/08/2022.
//

import Foundation

struct News: Decodable {
    let articles: [Article]
}

public struct Article: Decodable, Identifiable {
    public var id = UUID().uuidString
    let title: String

    enum CodingKeys: String, CodingKey {
        case title = "title"
    }
}

public struct NewsItem: Equatable, Decodable {
    public let title: String
    public let description: String
    public let content: String
    
    public init(title: String, description: String, content: String) {
        self.title = title
        self.description = description
        self.content = content
    }
}
