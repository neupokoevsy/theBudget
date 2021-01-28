//
//  StatisticsViewController.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 06/01/2021.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    @IBOutlet weak var NoDataLabel: UILabel!
    var records: [Record]?


    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        records = dataService.instance.fetchRecords()
        if records!.count > 0 {
            NoDataLabel.isHidden = true
        } else {
            NoDataLabel.isHidden = false
        }
    }

}
