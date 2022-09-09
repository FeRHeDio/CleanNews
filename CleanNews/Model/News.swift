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

struct Article: Decodable, Identifiable {
    var id = UUID().uuidString
    let title: String

    enum CodingKeys: String, CodingKey {
        case title = "title"
    }
}
