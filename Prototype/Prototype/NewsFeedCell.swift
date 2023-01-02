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
    @IBOutlet private(set) var newsImageContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        newsImage.alpha = 0
        newsImageContainer.startShimmering()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        newsImage.alpha = 0
        newsImageContainer.startShimmering()
    }
    
    func fadeIn(_ image: UIImage?) {
        newsImage.image = image
        
        UIView.animate(withDuration: 0.3, delay: 1.25, animations: {
            self.newsImage.alpha = 1
        }, completion: { completed in
            if completed {
                self.newsImageContainer.stopShimmering()
            }
            
        })
    }
}

private extension UIView {
    private var shimmeryAnimationKey: String {
        return "shimmer"
    }
    
    func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let width = bounds.width
        let height = bounds.height
        
        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        
        gradient.locations = [0.4, 0.5, 0.6]
        
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient
        
        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmeryAnimationKey)
    }
    
    func stopShimmering() {
        layer.mask = nil
    }
}
