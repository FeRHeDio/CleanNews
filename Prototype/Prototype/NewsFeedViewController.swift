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
    private var newsFeed = [NewsFeedViewModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
    }
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.newsFeed.isEmpty {
                self.newsFeed = NewsFeedViewModel.prototypeNewsFeed
                self.tableView.reloadData()
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
    
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
