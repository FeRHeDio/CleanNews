//
//  NewsFeedViewController.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 08/03/2023.
//

import UIKit
import CleanNewsFramework

final public class NewsFeedViewController: UITableViewController {
    private var loader: NewsLoader?
    private var tableModel = [NewsItem]()

    public convenience init(loader: NewsLoader) {
        self.init()
        self.loader = loader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            if let newsFeed = try? result.get() {
                self?.tableModel = newsFeed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = NewsItemCell()
        
        cell.titleLabel.text = cellModel.title
        cell.descriptionLabel.text = cellModel.description
        
        return cell
    }
}
