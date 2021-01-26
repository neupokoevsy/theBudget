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
    
    
    @IBOutlet weak var addRecordButton: UIButton!
    @IBOutlet weak var recordsButton: UITabBarItem!
    @IBOutlet weak var recordsTable: UITableView!
    
    var records: [Record]?
    

    override func viewDidLoad() {
        super.viewDidLoad()
                
        records = dataService.instance.fetchRecords()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchRecordsWithNotification(notification:)), name: NSNotification.Name(rawValue: "UpdateEverything"), object: nil)
        
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
    

}

extension RecordsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
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
        }
        return action
    }
    
    
}
