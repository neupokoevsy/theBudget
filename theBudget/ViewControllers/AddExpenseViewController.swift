//
//  AddExpenseViewController.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 06/01/2021.
//

import UIKit

class AddExpenseViewController: UIViewController {
    
    //MARK: Calendar variables
    @IBOutlet weak var CalendarCollectionView: UICollectionView!
    var datesToDisplay = [String]()
    var datesForCoreData = [String]()
    var selectedDateIndex: Int = 0
    var currentDateIndex = 0
    var date: Date?
    
    //MARK: Categories variables
    @IBOutlet weak var CategoriesCollectionView: UICollectionView!
    var categories: [Categories] = []
    var currentlySelectedCategory: String?
    var categoriesToShow: [Categories] = []
    
    
    //MARK: User Input
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    var amount: Double = 0.0
    let type: String = "Expense"
    var comment: String?
    let formatter = DateFormatter()
    @IBOutlet weak var saveButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        adjustUI()
        
//        dataService.instance.usedCertainCategory(category: "Work")
        
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
    
    func adjustUI() {
        CalendarCollectionView.layer.cornerRadius = 5
        CalendarCollectionView.layer.borderWidth = 2
        CalendarCollectionView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.hideKeyboardWhenTappedAround()
        saveButton.layer.cornerRadius = 3
        saveButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        amountTextField.becomeFirstResponder()
        amountTextField.addDoneButtonOnKeyboard(textViewDescription: amountTextField)
        commentTextField.delegate = self
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        amount = Double(amountTextField.text!) ?? 0.0
        if checkEntry() {
            dataService.instance.saveNewRecord(amount: amount, category: currentlySelectedCategory!, date: date!, type: type, comment: commentTextField.text ?? "")
            dataService.instance.usedCertainCategory(category: currentlySelectedCategory!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateEverything"), object: nil)
            dismiss(animated: true, completion: nil)
        }
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

}


extension AddExpenseViewController: UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    
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
            return categories.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.CalendarCollectionView {
            let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as! CalendarCollectionViewCell
            cellA.dateLabel.text = datesToDisplay[indexPath.row]
            return cellA
        } else {
            let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: "CatecogyCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            let category = categories[indexPath.row]
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
            let category = categories[indexPath.row]
            currentlySelectedCategory = category.title!
//            print(currentlySelectedCategory!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
