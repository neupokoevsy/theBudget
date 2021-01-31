//
//  StatisticsViewController.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 06/01/2021.
//

import UIKit

public var dataReceivedForGraph = [Double]()

class StatisticsViewController: UIViewController {
    
    @IBOutlet weak var NoDataLabel: UILabel!
    

    var records: [Record]?
    var monthsReceived: [String] = []
    
    var someMonths: [String] = []
    
    //Outlets
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var graphView: StatisticsGraphView!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        records = dataService.instance.fetchRecords()
        if records!.count > 0 {
            NoDataLabel.isHidden = true
            graphView.isHidden = false
            getAmountsByMonths()

            setupGraphDisplay()
            
        } else {
            NoDataLabel.isHidden = false
            graphView.isHidden = true
        }
    }
    
    func getAmountsByMonths() {
        for result in records! {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
//            print(result.date!)
            let convertedDate = formatter.string(from: result.date!)
            someMonths.append(convertedDate)
//            let uniqueMonths = someMonths.removingDuplicates()
//            someMonths = uniqueMonths
//            monthsReceived = uniqueMonths
//            print(someMonths)
//            print(result.date!)
        }
    }
    
    func setupGraphDisplay() {
        let maxMonthIndex = stackView.arrangedSubviews.count - 1
        
        graphView.setNeedsDisplay()
        
        //Max label to be updated
        
        let maximum = dataReceivedForGraph.max() ?? 0.0
//        print(maximum)

        maxLabel.text = "\(maximum)"
//        print(monthsReceived)
        
        let today = Date()
        let calenendar = Calendar.current

        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        
        for i in 0...maxMonthIndex {
            if let date = calenendar.date(byAdding: .month, value: -i, to: today),
               let label = stackView.arrangedSubviews[maxMonthIndex - i] as? UILabel {
                label.text = formatter.string(from: date)
                monthsReceived.append(formatter.string(from: date))
            }
        }
    }

}
