//
//  CategoryCollectionViewCell.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 24/01/2021.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var CategoryImageView: UIImageView!
    @IBOutlet weak var CategoryLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected && traitCollection.userInterfaceStyle == UIUserInterfaceStyle.light {
                CategoryLabel.textColor = UIColor.black
                CategoryLabel.font.withSize(12)
                CategoryImageView.alpha = 1
            } else if isSelected && traitCollection.userInterfaceStyle == UIUserInterfaceStyle.dark {
               CategoryLabel.textColor = UIColor.white
               CategoryLabel.font.withSize(12)
               CategoryImageView.alpha = 1
            } else {
                CategoryLabel.textColor = UIColor.gray
                CategoryLabel.font.withSize(12)
                CategoryImageView.alpha = 0.3
            }
        }
    }
    
    func updateViews(category: Categories){
        CategoryImageView.image = UIImage(named: category.imageName!)
        print("\(category.title!) used \(category.useCount) times")
        CategoryLabel.text = category.title
    }
    
}
