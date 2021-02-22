//
//  RecordsViewController.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 06/01/2021.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate


class RecordsViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var addRecordButton: UIButton!
    @IBOutlet weak var recordsButton: UITabBarItem!
    @IBOutlet weak var recordsTable: UITableView!
    
    @IBOutlet weak var monthsCollectionView: UICollectionView!
    
    //Variables
    var records: [Record]?
    var monthsToDisplay: [String] = []
    var numberOfMonthsToDisplay: Int?
    let formatter = DateFormatter()
    var arrayOfDates: [String] = []
    var currentlySelectedMonth: String?

    

    override func viewDidLoad() {
        super.viewDidLoad()
                
        records = dataService.instance.fetchRecords()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchRecordsWithNotification(notification:)), name: NSNotification.Name(rawValue: "UpdateEverything"), object: nil)
        
        
        getMonthsForSelection()
        getDataForMonths()
        //MARK: Show the add button always on top of other views
        super.view.bringSubviewToFront(addRecordButton)        
        
    }
    
    //******************************************************************
    //MARK: Fetch CoreData when receive notification from other VC's
    //******************************************************************
    
    @objc func fetchRecordsWithNotification(notification: NSNotification) {
        records = dataService.instance.fetchRecords()
        recordsTable.reloadData()
    }
    
    
    //Switch no next month
    @IBAction func nextMonthButton(_ sender: UIButton) {
        
        guard let indexPath = monthsCollectionView.indexPathsForVisibleItems.first.flatMap(
                { IndexPath(item: $0.row + 1, section: $0.section)})
        else {
                return
        }
        if indexPath.item < monthsToDisplay.count && indexPath.item >= 0 {
            currentlySelectedMonth = monthsToDisplay[indexPath.item]
            getDataForMonths()
            monthsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    //Switch no previous month
    @IBAction func previousMonthButton(_ sender: UIButton) {
        
        guard let indexPath = monthsCollectionView.indexPathsForVisibleItems.first.flatMap(
                { IndexPath(item: $0.row - 1, section: $0.section)})
        else {
                return
        }
        if indexPath.item < monthsToDisplay.count && indexPath.item >= 0 {
            currentlySelectedMonth = monthsToDisplay[indexPath.item]
            getDataForMonths()
            monthsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func getDataForMonths() {
        var dates = records!.map({ return $0.date! })
        formatter.dateFormat = "MMMM"
        for date in dates {
            arrayOfDates.append(formatter.string(from: date))
        }
        let result = records!.filter({ dates.contains($0.date!) })
//        for res in result {
//            if formatter.string(from: res.date!) == currentlySelectedMonth {
//                print(res.amount)
//                print(res.category!)
//            }
//        }

    }
}
    



extension RecordsViewController: UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //******************************************************************
    //MARK: Month collection view
    //******************************************************************
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        monthsToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthsDisplayCell", for: indexPath) as! MonthsCollectionViewCell
        cell.monthsToDisplayLabel.text = monthsToDisplay[indexPath.row]
//        print(monthsToDisplay[indexPath.row])
        currentlySelectedMonth = monthsToDisplay[indexPath.row]
        return cell
    }
    
    func getMonthsForSelection() {
        for result in records! {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM"
            monthsToDisplay.append(formatter.string(from: result.date!))
            monthsToDisplay = monthsToDisplay.removingDuplicates()
            numberOfMonthsToDisplay = monthsToDisplay.count
        }
    }
    
    //******************************************************************
    //MARK: Getting work done with TableView
    //******************************************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        records!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = recordsTable.dequeueReusableCell(withIdentifier: "recordsCell") as? RecordMainTableViewCell
        else {
            return UITableViewCell()
        }
        let record = records![indexPath.row]
        cell.configureCell(record: record)
        
        return cell
    }
    
    
    //Edit action
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = self.contextualEditAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [editAction])
        swipeConfig.performsFirstActionWithFullSwipe = true
        editAction.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        return swipeConfig
    }
    
    func contextualEditAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction{
        let editAction = UIContextualAction(style: .normal, title: "EDIT") { (action, RecordsViewController, completionHandler: (Bool) -> Void) in
            dataService.instance.showEditRecord(atIndexPath: indexPath)
            let editingViewController = self.storyboard?.instantiateViewController(identifier: "RecordEditingViewController") as! EditingViewController
            editingViewController.receivedIndexPath = indexPath
            self.present(editingViewController, animated: true)
            completionHandler(true)
        }
        return editAction
    }
    
    
    //Delete action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeConfig.performsFirstActionWithFullSwipe = true
        deleteAction.backgroundColor = UIColor.red
        return swipeConfig
    }
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "DELETE") { (UIContextualAction, RecordsViewController, completionHandler: (Bool) -> Void) in
            dataService.instance.removeRecord(atIndexPath: indexPath)
            self.records = dataService.instance.fetchRecords()
            self.recordsTable.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateEverything"), object: nil)
        }
        return action
    }
    
    
}
