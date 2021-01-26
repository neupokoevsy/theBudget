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
        
        
        //MARK: Show the add button always on top of other views
        super.view.bringSubviewToFront(addRecordButton)        
        
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
        if record.category != nil {
            print(record.category!.lowercased())
        }
        return cell
    }
    
    
}
