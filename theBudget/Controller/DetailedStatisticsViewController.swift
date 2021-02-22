//
//  DetailedStatisticsViewController.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 11/02/2021.
//

import UIKit

class DetailedStatisticsViewController: UIViewController {
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var detailedStatisticsTable: UITableView!

    var filteredRecordsByCategories = [RecordParsed]()
    var records: [Record]?
    var calculatedSlices: [Slice] = []
    var totalPercents: Double?
    var monthSelected: String?
    let formatter = DateFormatter()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Fetching necessary data from CoreData
        records = dataService.instance.fetchRecords()
        calculateTotal(month: monthSelected!)
        dataService.instance.fetchCoreDataCategories()
        
        
        //Observer for the update if necessary
        NotificationCenter.default.addObserver(self, selector: #selector(fetchRecordsWithNotification(notification:)), name: NSNotification.Name(rawValue: "UpdateEverything"), object: nil)

        
        //Getting slices for the PieChart
        let dates = records!.map({ return $0.date! })
        formatter.dateFormat = "MMM"
        let result = records!.filter({ dates.contains($0.date!) })
        for res in result {
            if formatter.string(from: res.date!) == monthSelected && res.category != "Credit" {
                filteredRecordsByCategories.append(contentsOf: searchTotalAmountOfEachCategory(searchItem: res.category!))
                calculatedSlices = fillArrayOfSlices(searchCategory: res.category!, searchMonth: monthSelected!)
            }
        }
        
        pieChartView.slices = calculatedSlices
        
        
    }
    
    
    @IBAction func dismissVC(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Animating the PieChart
    override func viewDidAppear(_ animated: Bool) {
        pieChartView.animateChart()
    }
    
    
    //Function for the observer
    @objc func fetchRecordsWithNotification(notification: NSNotification) {
        records = dataService.instance.fetchRecords()
        detailedStatisticsTable.reloadData()
    }
    
    
    //***************************************************
    //MARK: Calculation of total amount for all expenses
    //MARK: Excluding Credit (because not expense)
    //***************************************************
    
        func calculateTotal(month: String) {
            var totalSum = [Double]()
            var incomeAmount = [Double]()
            var income: Double = 0.0
            let searchItem = "Credit"
            formatter.dateFormat = "MMM"
            let searchPredicate = NSPredicate(format: "category CONTAINS[C] %@", searchItem)
            let array = (records! as NSArray).filtered(using: searchPredicate) as! [Record]
            let datesMap = array.map({return $0.date!})
            let filteredArray = array.filter({datesMap.contains($0.date!)})
            for result in filteredArray {
                if formatter.string(from: result.date!) == month {
                incomeAmount += incomeAmount.append(result.amount) as? [Double] ?? [0.0]
                income = incomeAmount.reduce(0, +)
                }
            }
            let dates = records!.map({ return $0.date! })
            let result = records!.filter({ dates.contains($0.date!) })
            for res in result {
                if formatter.string(from: res.date!) == month {
                    totalSum += totalSum.append(res.amount) as? [Double] ?? [0.0]
                    let sum = totalSum.reduce(0, +)
                    totalPercents = sum - income
            }

        }
    }
    
    
    //***********************************************
    //MARK: Searching percent to reflect on PieChart
    //***********************************************

    func searchPercentage(searchItem: String, searchMonth: String) -> CGFloat {
        var amount = [Double]()
        var calculatedPercent: Double = 0.0
        let searchPredicate = NSPredicate(format: "category CONTAINS[C] %@", searchItem)
        let array = (records as! NSArray).filtered(using: searchPredicate) as! [Record]
            for result in array{
                amount += amount.append(result.amount) as? [Double] ?? [0.0]
                let sum = amount.reduce(0, +)
                calculatedPercent = sum / (totalPercents ?? 0.0)
                if calculatedPercent == 1.0 {
                    calculatedPercent = 0.9999
                }
            }
        return CGFloat(calculatedPercent)
    }
    
    //***********************************************
    //MARK: Searching total amount for each Category
    //***********************************************
    
    func searchTotalAmountOfEachCategory(searchItem: String) -> [RecordParsed] {
        var amount = [Double]()
        var color: UIColor?
        var computedAmount = 0.0
        let searchPredicate = NSPredicate(format: "category CONTAINS[C] %@", searchItem)
        let array = (records as! NSArray).filtered(using: searchPredicate) as! [Record]
        for result in array {
            amount += amount.append(result.amount) as? [Double] ?? [0.0]
            let sum = amount.reduce(0, +)
            if sum != 0.0 {
                computedAmount = sum
            }
        }
        switch searchItem {
        case "Electronics": color =         #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        case "Hospital": color =            #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        case "Other": color =               #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        case "Clothes": color =             #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        case "Food": color =                #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        case "Hobby": color =               #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        case "Online Shopping": color =     #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        case "Activity": color =            #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
        case "Utility Payments": color =    #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)
        case "Work": color =                #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
        case "New Category": color =        #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        case "Beauty": color =              #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        case "Car": color =                 #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        case "Gifts": color =               #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        case "Lunch": color =               #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
        case "Pharmacy": color =            #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1)
        case "Transport": color =           #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        case "Vacation": color =            #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        case "Household": color =           #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        default:
            color = UIColor.black
        }
        return [RecordParsed(category: searchItem, amount: computedAmount, color: color!)]
    }
    
    
    
    //*******************************************
    //MARK: General function for PieChart slices
    //*******************************************
    
    func fillSlices(percent: CGFloat, color: UIColor) -> [Slice] {
        if percent != 0.0 {
            calculatedSlices.append(Slice.init(percent: percent, color: color))
        }
        return calculatedSlices
    }
    
    //*******************************************
    //MARK: Filling array of slices for PieChart
    //*******************************************
    
    func fillArrayOfSlices(searchCategory: String, searchMonth: String) -> [Slice] {
        
        
        //Getting the color by category
        var color: UIColor?
        switch searchCategory {
        case "Electronics": color =         #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        case "Hospital": color =            #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        case "Other": color =               #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        case "Clothes": color =             #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        case "Food": color =                #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        case "Hobby": color =               #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        case "Online Shopping": color =     #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        case "Activity": color =            #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
        case "Utility Payments": color =    #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)
        case "Work": color =                #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
        case "New Category": color =        #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        case "Beauty": color =              #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        case "Car": color =                 #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        case "Gifts": color =               #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        case "Lunch": color =               #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
        case "Pharmacy": color =            #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1)
        case "Transport": color =           #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        case "Vacation": color =            #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        case "Household": color =           #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        default:
            color = UIColor.black
        }
           calculatedSlices = fillSlices(percent: searchPercentage(searchItem: searchCategory, searchMonth: searchMonth), color: color!)
        return calculatedSlices
    }
    

}

//MARK: Extension for TableView to show the records that are drawn in PieChart

extension DetailedStatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        calculatedSlices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = detailedStatisticsTable.dequeueReusableCell(withIdentifier: "PieStatisticsCell", for: indexPath) as? PieStatisticsCell
            else {
                return UITableViewCell()
    }
        let statisticsRecord = filteredRecordsByCategories[indexPath.row]
            cell.configureCell(category: statisticsRecord.category, amount: String(describing: (statisticsRecord.amount)), color: statisticsRecord.color)
        return cell
    }
}
