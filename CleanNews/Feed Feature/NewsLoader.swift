//
//  NewsLoader.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 27/10/2022.
//

import Foundation

protocol NewsLoader {
    func loadNews(completion: @escaping (News) -> Void)
}
