//
//  NewsFeedViewController.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 08/03/2023.
//

import UIKit
import CleanNewsFramework

public final class NewsFeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: NewsRefreshController?
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [NewsItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()

    public convenience init(newsFeedLoader: NewsLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.refreshController = NewsRefreshController(newsFeedLoader: newsFeedLoader)
        self.imageLoader = imageLoader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        
        refreshControl = refreshController?.view
       
        refreshController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed
        }
        refreshController?.refresh()
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
