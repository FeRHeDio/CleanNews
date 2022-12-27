//
//  NewsLoader.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 28/10/2022.
//

import Foundation



public protocol NewsLoader {
    typealias Result = Swift.Result<[NewsItem], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
