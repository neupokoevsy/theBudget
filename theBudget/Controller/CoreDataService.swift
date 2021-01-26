//
//  CoreDataService.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 23/01/2021.
//

import UIKit
import CoreData

class dataService{
    
    static let instance = dataService()
    
    public var categories: [Categories] = []
    public var records: [Record] = []
    
    //******************************************************************
    //MARK: Categories related code (CoreData)
    //MARK: Fetching and sorting by the user usage
    //******************************************************************
    
        func fetchCategories(completion: (_ complete: Bool) -> ()) {
            guard let managedContext = appDelegate?.persistentContainer.viewContext
                else {
                    return
                }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
            let sort = NSSortDescriptor(key: "useCount", ascending: false)
            fetchRequest.sortDescriptors = [sort]
            do {
                categories = try managedContext.fetch(fetchRequest) as! [Categories]
                print("Fetched from CoreData Successfully")

            }
            catch
                {
                print("Could not fetch data: \(error.localizedDescription)")
            }
        }
    
    func fetchCoreDataCategories() {
        self.fetchCategories { (complete) in
            if categories.count == 0 {
                print("NO CATEGORIES FOUND!")
            } else {
                print("CATEGORIES FOUND")
            }
        }
    }
    
    
    //******************************************************************
    //MARK: Function that takes user input and saves it in CoreData
    //******************************************************************
    func saveNewRecord(amount: Double, category: String?, date: Date, type: String, comment: String) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext
        else {
            return
        }
        let record = Record(context: managedContext)
        record.amount = amount
        record.category = category
        record.date = date
        record.type = type
        record.comment = comment

        do {
            try managedContext.save()
            print("Sucessfully saved new record")
        }
        catch {
            debugPrint("Could not save data. Error: \(error.localizedDescription)")
        }
    }
    
    
    func usedCertainCategory(category: String){
        guard let managedContext = appDelegate?.persistentContainer.viewContext
        else {
            return
        }
        let fetchRequest: NSFetchRequest<Categories> = Categories.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title contains [c] %@", category)
        do {
            let results = try managedContext.fetch(fetchRequest)
            if let categoriesFetched = results.first{
                categoriesFetched.title = category
                categoriesFetched.useCount = 0.01
            }
          try managedContext.save()
        } catch let error as NSError {
          print(error.localizedDescription)
        }
    }
    
    //******************************************************************
    //MARK: Records related code (CoreData)
    //******************************************************************
    
    func fetchRecords() -> [Record] {
        
        let managedContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do {
            records = try managedContext!.fetch(fetchRequest) as! [Record]
        }
        catch
            {
            print("Could not fetch data: \(error.localizedDescription)")
        }
        
        return records 
    }
    
}
