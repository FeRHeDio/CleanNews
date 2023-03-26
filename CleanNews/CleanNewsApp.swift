//
//  CleanNewsApp.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 11/08/2022.
//

import SwiftUI
import CleanNewsFramework
import CleanNewsiOS

@main
struct CleanNewsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(loader: API())
        }
    }
}

