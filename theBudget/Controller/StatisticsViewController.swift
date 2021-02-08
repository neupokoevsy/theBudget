//
//  StatisticsViewController.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 06/01/2021.
//

import UIKit

public var dataReceivedForGraph = [Double]()

class StatisticsViewController: UIViewController {
    
    

    var records: [Record]?
    var monthsReceived: [String] = []
    
    var dataToShow: Double?
    
    let formatter = DateFormatter()
    
    //Outlets
    
    @IBOutlet weak var monthlyStatisticsTable: UITableView!
    @IBOutlet weak var NoDataLabel: UILabel!
    @IBOutlet weak var addRecordButton: UIButton!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var totalSpentLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var graphView: StatisticsGraphView!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        // Do any additional setup after loading the view.
        super.view.bringSubviewToFront(addRecordButton)
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

extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var arrayOfNonEmptyRecords = [Double]()
        for quantity in dataReceivedForGraph {
            if quantity != 0.0 {
                arrayOfNonEmptyRecords.append(quantity)
            }
        }
//        dataReceivedForGraph.count
      return arrayOfNonEmptyRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = monthlyStatisticsTable.dequeueReusableCell(withIdentifier: "MonthlyStatisticsCell") as? MonthlyStatisticsCell
        else {
            return UITableViewCell()
        }
        let statisticsRecord = dataReceivedForGraph[indexPath.row]
        let statisticsMonth = monthsReceived[indexPath.row]
        
        if String(describing: statisticsRecord) != "0.0"{
        cell.configureCell(month: statisticsMonth, amount: String(describing: statisticsRecord))
        }
//        print(monthsReceived)
        
        return cell
    }
    
    
}
