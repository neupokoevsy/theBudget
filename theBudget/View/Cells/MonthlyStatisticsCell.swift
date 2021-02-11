//
//  MonthlyStatisticsCell.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 08/02/2021.
//

import UIKit

class MonthlyStatisticsCell: UITableViewCell {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var monthlyAmountLabel: UILabel!
    
    func configureCell(month: String, amount: String) {
        self.monthLabel.text = month
        self.monthlyAmountLabel.text = amount
        
        if self.monthlyAmountLabel.text == "0.0" {
            self.monthlyAmountLabel.text = ""
        }
    }

}
