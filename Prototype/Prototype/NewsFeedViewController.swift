//
//  NewsFeedViewController.swift
//  Prototype
//
//  Created by Fernando Putallaz on 29/12/2022.
//

import UIKit

struct NewsFeedViewModel {
    let title: String
    let description: String
    let imageName: String
}

final class NewsFeedViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "NewsFeedCell")!
    }
}
