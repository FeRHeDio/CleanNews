//
//  ContentView.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 11/08/2022.
//

import SwiftUI

struct ContentView: View {
    var loader: OldNewsLoader!
    
    @State var articles = [Article]()
    
    var body: some View {
        List {
            ForEach(articles) { article in
                Text(article.title)
            }
        }
        .onAppear {
            loader.loadNews { news in
                articles = news.articles
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

