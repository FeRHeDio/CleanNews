//
//  API.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 16/08/2022.
//

import Foundation

class API: OldNewsLoader {
    let client = URLSession.shared
    var request = URLRequest(url: URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=\(Privates.newsApi.rawValue)")!)
        
    func loadNews(completion: @escaping (News) -> Void) {
        let decoder = JSONDecoder()
        request.httpMethod = "GET"

        client.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Heads Up! We receive an error with this description: \(error.localizedDescription)")
            }
            
            if let response = response as? HTTPURLResponse {
                print("The response from the server is: \(response.statusCode)")
            }
            
            if let data = data {
                print("Here comes the news!")
                do {
                    
                    let news = try decoder.decode(News.self, from: data)
                    
                    completion(news)
                } catch let error {
                    print(error)
                }
            }
        }
        .resume()
    }
}
