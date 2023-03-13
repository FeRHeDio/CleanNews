//
//  NewsFeedViewController.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 08/03/2023.
//

import UIKit
import CleanNewsFramework

public protocol NewsFeedImageDataLoaderTask {
    func cancel()
}

public protocol NewsFeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> NewsFeedImageDataLoaderTask
}

final public class NewsFeedViewController: UITableViewController {
    private var newsFeedLoader: NewsLoader?
    private var imageLoader: NewsFeedImageDataLoader?
    private var tableModel = [NewsItem]()
    private var tasks = [IndexPath: NewsFeedImageDataLoaderTask]()

    public convenience init(newsFeedLoader: NewsLoader, imageLoader: NewsFeedImageDataLoader) {
        self.init()
        self.newsFeedLoader = newsFeedLoader
        self.imageLoader = imageLoader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        newsFeedLoader?.load { [weak self] result in
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
        cell.newsImageContainer.startShimmering()
        tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.imageURL) { [weak cell] result in
            cell?.newsImageContainer.stopShimmering()
        }

        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
