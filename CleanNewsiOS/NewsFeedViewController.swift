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

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> NewsFeedImageDataLoaderTask
}

final public class NewsFeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var newsFeedLoader: NewsLoader?
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [NewsItem]()
    private var tasks = [IndexPath: NewsFeedImageDataLoaderTask]()

    public convenience init(newsFeedLoader: NewsLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.newsFeedLoader = newsFeedLoader
        self.imageLoader = imageLoader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        tableView.prefetchDataSource = self
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
        cell.newsImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.newsImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self else { return }
            
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.imageURL) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.newsImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.newsImageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.imageURL) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
    
    public func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
