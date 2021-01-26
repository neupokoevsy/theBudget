//
//  EditingViewController.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 26/01/2021.
//

import UIKit

class EditingViewController: UIViewController {
    
    //Calendar variables
    @IBOutlet weak var CalendarCollectionView: UICollectionView!
    var datesToDisplay = [String]()
    var datesForCoreData = [String]()
    var selectedDateIndex: Int = 0
    var currentDateIndex = 0
    var date: Date?
    let formatter = DateFormatter()
    
    //Record variables
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    var records: [Record]?
    var amount: Double?
    var type: String = "Expense"
    var comment: String?
    
    //Categories variables
    @IBOutlet weak var CategoriesCollectionView: UICollectionView!
    var categories: [Categories]?
    var currentlySelectedCategory: String?

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var expenseSwitch: UISwitch!



    override func viewDidLoad() {
        super.viewDidLoad()
        
        records = dataService.instance.fetchRecords()
        
        //MARK: Calendar get dates, autoselect & autocenter date
        datesToDisplay = CalendarService.instance.getDates()
        currentDateIndex = CalendarService.instance.currentDateIndex
        datesForCoreData = CalendarService.instance.datesForCoreData()
        let indexPathForFirstRow = IndexPath(row: currentDateIndex, section: 0)
        self.setSelectedItemFromScrollView(CalendarCollectionView)
        self.CalendarCollectionView.selectItem(at: indexPathForFirstRow, animated: true, scrollPosition: .centeredHorizontally)
        date = Date()
        
        //MARK: Categories fetch
        dataService.instance.fetchCoreDataCategories()
        categories = dataService.instance.categories
        
    }
    
    
    func checkEntry() -> Bool {
        if amount == 0.0 || amountTextField.text == "" {
            amountTextField.shake()
            amountTextField.vibrate()
        } else if currentlySelectedCategory == nil || currentlySelectedCategory == "" || currentlySelectedCategory == "New Category" {
            CategoriesCollectionView.shake()
            CategoriesCollectionView.vibrate()
        } else if date == nil {
            CalendarCollectionView.shake()
            CalendarCollectionView.vibrate()
        } else {
            return true
        }
        return false
    }
    
    @IBAction func editExistingRecord(_ sender: UIButton) {
        
    }
    
    @IBAction func toggleExpenseSwitch(_ sender: UISwitch) {
        if !expenseSwitch.isOn {
            CategoriesCollectionView.isHidden = true
            type = "Income"
        } else {
            CategoriesCollectionView.isHidden = false
            type = "Expense"
        }
    }
    
}

extension EditingViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func setSelectedItemFromScrollView(_ scrollView: UIScrollView) {
            self.CalendarCollectionView.setNeedsLayout()
            self.CalendarCollectionView.layoutIfNeeded()
            let center = CGPoint(x: scrollView.center.x + scrollView.contentOffset.x, y: (scrollView.center.y + scrollView.contentOffset.y))
            let index = CalendarCollectionView.indexPathForItem(at: center)
            if index != nil {
                CalendarCollectionView.scrollToItem(at: index!, at: .centeredHorizontally, animated: true)
                self.CalendarCollectionView.selectItem(at: index, animated: true, scrollPosition: [])
                self.selectedDateIndex = (index?.row)!
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-DD"
                let currentlySelectedDate = CalendarService.instance.datesForCoreData()[selectedDateIndex]
                date = formatter.date(from: currentlySelectedDate) ?? Date()
//                print(date!)
            }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setSelectedItemFromScrollView(CalendarCollectionView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setSelectedItemFromScrollView(CalendarCollectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.CalendarCollectionView {
        return datesToDisplay.count
        } else {
            return categories!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.CalendarCollectionView {
            let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as! CalendarCollectionViewCell
            cellA.dateLabel.text = datesToDisplay[indexPath.row]
            return cellA
        } else {
            let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: "CatecogyCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            let category = categories![indexPath.row]
            cellB.updateViews(category: category)
            return cellB
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == CalendarCollectionView {
            let selectedDate = datesForCoreData[indexPath.row]
//            print(selectedDate)
            formatter.dateFormat = "YYYY-MM-DD"
            date = formatter.date(from: selectedDate)!
//            print(date!)
        } else {
            let category = categories![indexPath.row]
            currentlySelectedCategory = category.title!
//            print(currentlySelectedCategory!)
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 100
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
