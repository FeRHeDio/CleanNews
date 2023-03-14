//
//  NewsItemCell.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 08/03/2023.
//

import UIKit

public class NewsItemCell: UITableViewCell {
    public let titleLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let newsImageContainer = UIView()
    public let newsImageView = UIImageView()
    
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
