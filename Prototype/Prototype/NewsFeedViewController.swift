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
    private let newsFeed = NewsFeedViewModel.prototypeNewsFeed
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsFeed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsFeedCell", for: indexPath) as! NewsFeedCell
        let model = newsFeed[indexPath.row]
        
        cell.configure(with: model)
        
        return cell
    }
}

extension NewsFeedCell {
    func configure(with model: NewsFeedViewModel) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        
        fadeIn(UIImage(named: model.imageName))
    }
}
