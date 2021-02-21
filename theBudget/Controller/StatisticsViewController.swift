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
    var recordsForDetailedView: [Record]?
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
            monthlyStatisticsTable.isHidden = false
            dataReceivedForGraph = [Double]()
            monthsReceived = []
            setupGraphDisplay()
            getMonthsForRecords()
            for months in monthsReceived {
                dataReceivedForGraph.append(getAmountsByMonths(months: months))
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(fetchRecordsWithNotification(notification:)), name: NSNotification.Name(rawValue: "UpdateEverything"), object: nil)
            
            print(dataReceivedForGraph)
            maxLabel.text = String(describing: "Max. monthly spent: \((String(format: "%.2f", dataReceivedForGraph.max()!)))")
            totalSpentLabel.text = String(describing: "Total spent: \(String(format: "%.2f", dataReceivedForGraph.reduce(0, +)))")
        } else {
            NoDataLabel.isHidden = false
            graphView.isHidden = true
            monthlyStatisticsTable.isHidden = true
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
        dataReceivedForGraph.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = monthlyStatisticsTable.dequeueReusableCell(withIdentifier: "MonthlyStatisticsCell") as? MonthlyStatisticsCell
        else {
            return UITableViewCell()
        }
        let statisticsRecord = dataReceivedForGraph[indexPath.row]
        let statisticsMonth = monthsReceived[indexPath.row]
        
        cell.configureCell(month: statisticsMonth, amount: String(describing: statisticsRecord))
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMonth = monthsReceived[indexPath.row]
        print("Selected month is: \(String(describing: selectedMonth))")
        let viewControllerB = storyboard?.instantiateViewController(withIdentifier: "StatisticsDetailVC") as! DetailedStatisticsViewController
        viewControllerB.monthSelected = selectedMonth
        self.present(viewControllerB, animated: true, completion: nil)
    }
    
    
    @objc func fetchRecordsWithNotification(notification: NSNotification) {
        records = dataService.instance.fetchRecords()
        monthlyStatisticsTable.reloadData()
    }
    
//    func getRecordsByMonths(month: String) -> [Record] {
//            var amount = [Double]()
//            var sum: Double = 0.0
//            let dates = records!.map({ return $0.date! })
//            formatter.dateFormat = "MMM"
//            let result = records!.filter({ dates.contains($0.date!) })
//            for res in result {
//                if formatter.string(from: res.date!) == month && (res.type! != "Credit") {
//                    amount.append(res.amount)
//                    sum = amount.reduce(0, +)
//            }
//        }
//        return recordsForDetailedView!
//    }
    
    func getMonthsForRecords() {

        let today = Date()
        let calenendar = Calendar.current
        
        var monthsToShow = [String]()
        var arrayOfNonEmptyRecords = [Double]()

        var startOfYear = today
        var timeInterval : TimeInterval = 0.0
        let dateToDate = Calendar.current.dateInterval(of: .year, start: &startOfYear, interval: &timeInterval, for: today)
        print(dateToDate)

        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM")
        
        for records in dataReceivedForGraph {
            if records != 0.0 {
                arrayOfNonEmptyRecords.append(records)
            }
        }

        for i in 0...arrayOfNonEmptyRecords.count {
            let date = calenendar.date(byAdding: .month, value: i, to: startOfYear)
                monthsToShow.append(formatter.string(from: date!))
        }
        
//        print(monthsToShow)
    }
}
