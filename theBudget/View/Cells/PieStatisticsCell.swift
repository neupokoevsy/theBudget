//
//  PieStatisticsCell.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 21/02/2021.
//

import UIKit

class PieStatisticsCell: UITableViewCell {

    @IBOutlet weak var CategoryLabel: UILabel!
    @IBOutlet weak var AmountLabel: UILabel!
    @IBOutlet weak var CategoryColor: UIImageView!
    
    func configureCell(category: String, amount: String, color: UIColor) {
        self.CategoryLabel.text = category
        self.AmountLabel.text = amount
        self.CategoryColor.backgroundColor = color
    }

}
