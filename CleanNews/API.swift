//
//  API.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 16/08/2022.
//

import Foundation

class API {
    
    static let shared = API()
    
    let client = URLSession.shared
    let apiSecret = "d08988aa3d4247f5b37c1a712f884148"
    var request = URLRequest(url: URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=d08988aa3d4247f5b37c1a712f884148")!)
        
    func getNews() {
        request.httpMethod = "GET"

        client.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Heads Up! We receive an error with this description: \(error.localizedDescription)")
            }

            if let response = response as? HTTPURLResponse {
                print("The response is: \(response.statusCode)")
            }
            
            if let data = data {
                print("Here comes the news!")
                print(String(data: data, encoding: .utf8)!)
            }
        }
        .resume()
    }
}
