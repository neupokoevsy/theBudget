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
    
    private(set) public var editableAmount: Double?
    private(set) public var editableCategory: String?
    private(set) public var editableComment: String?
    private(set) public var editableDate: Date?
    private(set) public var editableType: String?
    
    public var categories: [Categories] = []
    public var categoriesArray: [String] = []
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
                if categoriesArray.count > 0 {
                    categoriesArray = []
                }
                for category in categories {
                    categoriesArray.append(String(describing: category.title!))
                    }
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
//            print("Sucessfully saved new record")
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
                categoriesFetched.useCount = categoriesFetched.useCount+0.01
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
    
    //******************************************************************
    //MARK: Delete selected CoreData record
    //******************************************************************
    
    
    func removeRecord(atIndexPath indexPath: IndexPath) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext
        else
        {
            return
        }
        managedContext.delete(records[indexPath.row])
        do {
            try managedContext.save()
            self.records = dataService.instance.fetchRecords()
//            print("successfully removed item at \(indexPath.row)")
        } catch {
            debugPrint("Could not remove: \(error.localizedDescription)")
        }
        
    }
    
    func editRecord(atIndexPath indexPath: IndexPath, updateAmount: Double, updateCategory: String, updateComment: String, updateDate: Date, updateType: String) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext
    else
    {
        return
    }
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
            let sort = NSSortDescriptor(key: "date", ascending: false)
            fetchRequest.sortDescriptors = [sort]
            let result = try managedContext.fetch(fetchRequest) as! [Record]
            
            result[indexPath.row].setValue(updateAmount, forKey: "amount")
            result[indexPath.row].setValue(updateCategory, forKey: "category")
            result[indexPath.row].setValue(updateComment, forKey: "comment")
            result[indexPath.row].setValue(updateDate, forKey: "date")
            result[indexPath.row].setValue(updateType, forKey: "type")
            
            try managedContext.save()
        }

        catch
            {
            print("Could not fetch data: \(error.localizedDescription)")
        }
        
    }
    
    func showEditRecord(atIndexPath indexPath: IndexPath) {
         let managedContext = appDelegate!.persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
            let sort = NSSortDescriptor(key: "date", ascending: false)
            fetchRequest.sortDescriptors = [sort]
            let result = try managedContext.fetch(fetchRequest) as! [Record]
//            print(result[indexPath.row].value(forKey: "amount")!)
            self.editableAmount = result[indexPath.row].value(forKey: "amount") as? Double ?? 0.0
            if result[indexPath.row].value(forKey: "category") != nil {
                self.editableCategory = (result[indexPath.row].value(forKey: "category") as! String)
            } else {
                self.editableCategory = "Income"
            }
            self.editableComment = (result[indexPath.row].value(forKey: "comment") as! String)
            self.editableDate = (result[indexPath.row].value(forKey: "date") as! Date)
            self.editableType = (result[indexPath.row].value(forKey: "type") as! String)
        }

        catch
            {
            print("Could not fetch data: \(error.localizedDescription)")
        }
    }
    
}
