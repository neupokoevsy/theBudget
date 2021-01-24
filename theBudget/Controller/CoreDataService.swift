//
//  CoreDataService.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 23/01/2021.
//

import Foundation
import CoreData

class dataService{
    
    static let instance = dataService()
    
    public var categories: [Categories] = []
    
    //******************************************************************
    //MARK: Categories related code (CoreData)
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
}
