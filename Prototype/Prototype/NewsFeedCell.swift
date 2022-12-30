//
//  NewsFeedCell.swift
//  Prototype
//
//  Created by Fernando Putallaz on 29/12/2022.
//

import UIKit

final class NewsFeedCell: UITableViewCell {
    @IBOutlet private(set) var titleLabel: UILabel!
    @IBOutlet private(set) var descriptionLabel: UILabel!
    @IBOutlet private(set) var newsImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        newsImage.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        newsImage.alpha = 0
    }
    
    func fadeIn(_ image: UIImage?) {
        newsImage.image = image
        
        UIView.animate(withDuration: 0.3, delay: 0.3) {
            self.newsImage.alpha = 1
        }
        
    }
    
    
}
