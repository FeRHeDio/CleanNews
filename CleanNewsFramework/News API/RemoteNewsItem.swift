//
//  RemoteNewsItem.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 08/11/2022.
//

import Foundation

class RemoteNewsItem: Decodable {
    let id: UUID
    let title: String
    let description: String
    let imageURL: String
    let content: String
}
