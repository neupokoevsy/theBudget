//
//  RecordMainTableViewCell.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 25/01/2021.
//

import UIKit

class RecordMainTableViewCell: UITableViewCell {

    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet var categoryImage: UIImageView!
    

    func configureCell(record: Record) {
        self.amountLabel.text = String(describing: record.amount)
        self.categoryLabel.text = record.category
        self.typeLabel.text = record.type
        if record.type! == "Credit" {
            self.categoryImage.image = UIImage(named: "credit.png")
            self.categoryLabel.text = "Credit"
        }
        if record.category != nil {
            self.categoryImage.image = UIImage(named: "\(String(describing: record.category!.lowercased())).png")
            }
        self.commentLabel.text = record.comment
        
        let date = record.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        self.dateLabel.text = dateFormatter.string(from: date!)
        
//        dateFormatter.dateFormat = "MMMM"
//        dateConverted = record.date
        
        if typeLabel.text == "Debit" {
            typeLabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        } else {
            typeLabel.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
    }
    
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
