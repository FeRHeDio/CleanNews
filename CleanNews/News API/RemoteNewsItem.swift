//
//  RemoteNewsItem.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 08/11/2022.
//

import Foundation

internal class RemoteNewsItem: Decodable {
    internal let id: UUID
    internal let title: String
    internal let description: String
    internal let content: String
}
