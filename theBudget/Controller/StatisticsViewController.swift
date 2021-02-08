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
    
    var dataToShow: Double?
    
    let formatter = DateFormatter()
    
    //Outlets
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var totalSpentLabel: UILabel!
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
            dataReceivedForGraph = [Double]()
            monthsReceived = []
            
            setupGraphDisplay()
            for months in monthsReceived {
                dataReceivedForGraph.append(getAmountsByMonths(months: months))
            }
            print(dataReceivedForGraph)
            maxLabel.text = String(describing: "Max. monthly spent: \((String(format: "%.2f", dataReceivedForGraph.max()!)))")
            totalSpentLabel.text = String(describing: "Total spent: \(String(format: "%.2f", dataReceivedForGraph.reduce(0, +)))")
        } else {
            NoDataLabel.isHidden = false
            graphView.isHidden = true
        }
    }
    

    func getAmountsByMonths(months: String) -> Double {
            var amount = [Double]()
            var sum: Double = 0.0
            let dates = records!.map({ return $0.date! })
            formatter.dateFormat = "MMM"
            let result = records!.filter({ dates.contains($0.date!) })
            for res in result {
                if formatter.string(from: res.date!) == months && (res.type! != "Credit") {
                    amount.append(res.amount)
                    sum = amount.reduce(0, +)
            }
        }
        return sum
    }
    
    func setupGraphDisplay() {
        let maxMonthIndex = monthsReceived.count
        
        graphView.setNeedsDisplay()
        
        //Max label to be updated
        
//        let maximum = dataReceivedForGraph.max() ?? 0.0
//        maxLabel.text = "\(maximum)"
        
        let today = Date()
        let calenendar = Calendar.current
        
        var startOfYear = today
        var timeInterval : TimeInterval = 0.0
        Calendar.current.dateInterval(of: .year, start: &startOfYear, interval: &timeInterval, for: today)


        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        
        for i in 0...11 {
            if let date = calenendar.date(byAdding: .month, value: i, to: startOfYear),
               let label = stackView.arrangedSubviews[maxMonthIndex + i] as? UILabel {
                label.text = formatter.string(from: date)

                monthsReceived.append(formatter.string(from: date))
//                print(monthsReceived)
            }
        }
    }
    
    

}
