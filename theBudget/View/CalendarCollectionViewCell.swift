//
//  CalendarCollectionViewCell.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 15/01/2021.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override var isSelected: Bool {
        didSet{
            if isSelected{
                dateLabel.font = UIFont.init(name: "Avenir-Heavy", size: 18)
                dateLabel.textColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            } else {
                dateLabel.font = UIFont.init(name: "Avenir-Heavy", size: 15)
                dateLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            }
        }
    }
    
    public enum Avenir: String {
    case avenir = "Avenir"
        case bold = "Avenir-Heavy"
        case book = "Avenir-Book"
        case medium = "Avenir-Medium"

        public func font(size: CGFloat) -> UIFont {
            return UIFont(name: self.rawValue, size: size)!
        }
    }
    
}
