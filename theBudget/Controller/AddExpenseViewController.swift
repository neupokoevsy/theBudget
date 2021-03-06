//
//  AddExpenseViewController.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 06/01/2021.
//

import UIKit

class AddExpenseViewController: UIViewController {
    
    //Calendar variables
    @IBOutlet weak var CalendarCollectionView: UICollectionView!
    var datesToDisplay = [String]()
    var datesForCoreData = [String]()
    var selectedDateIndex: Int = 0
    var currentDateIndex = 0
    var date: Date?
    
    //Categories variables
    @IBOutlet weak var CategoriesCollectionView: UICollectionView!
    var categories: [Categories] = []
    var currentlySelectedCategory: String?
//    var categoriesToShow: [Categories] = []
    
    
    //User Input
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    var enteredAmount: String?
    var amount: Double = 0.0
    var type: String = "Debit"
    var comment: String?
    let formatter = DateFormatter()
    @IBOutlet weak var saveButton: UIButton!
    
    //Haptic feedback for selection
    let selection = UISelectionFeedbackGenerator()
    let lightImpact = UIImpactFeedbackGenerator(style: .light)
    
    //Outlets
    @IBOutlet weak var debitedAmountLabel: UILabel!
    @IBOutlet weak var creditedAmountLabel: UILabel!
    @IBOutlet weak var expenseSwitch: UISwitch!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Necessary setup
        adjustUI()
        self.selection.prepare()

        
        //***************************************************************************
        //MARK: Calendar get dates, autoselect & autocenter date
        //***************************************************************************
        datesToDisplay = CalendarService.instance.getDates()
        currentDateIndex = CalendarService.instance.currentDateIndex
        datesForCoreData = CalendarService.instance.datesForCoreData()
        
        let indexPathForFirstRow = IndexPath(row: currentDateIndex, section: 0)
        self.setSelectedItemFromScrollView(CalendarCollectionView)
        self.CalendarCollectionView.selectItem(at: indexPathForFirstRow, animated: true, scrollPosition: .centeredHorizontally)
        date = Date()
        
        //***************************************************************************
        //MARK: Categories fetch
        //***************************************************************************
        dataService.instance.fetchCoreDataCategories()
        categories = dataService.instance.categories
        
    }
    
    //***************************************************************************
    //MARK: Adjusting the UI slightly to make it look nice :)
    //***************************************************************************
    
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

    //***************************************************************************
    //MARK: Checking that all entry values have been set
    //***************************************************************************
    
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
    
    @IBAction func expenseSwitchAction(_ sender: UISwitch) {
        if !expenseSwitch.isOn {
            CategoriesCollectionView.isHidden = true
            debitedAmountLabel.isHidden = true
            creditedAmountLabel.isHidden = false
            type = "Credit"
            if type == "Credit"{
                currentlySelectedCategory = "Credit"
            }
        } else {
            type = "Debit"
            CategoriesCollectionView.isHidden = false
            debitedAmountLabel.isHidden = false
            creditedAmountLabel.isHidden = true
        }
    }
    
    
    //***************************************************************************
    //MARK: Save the data and notifying the TableView to update views
    //***************************************************************************
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        enteredAmount = amountTextField.text?.replacingOccurrences(of: ",", with: ".")
        amount = Double(enteredAmount!) ?? 0.0
        if checkEntry() {
            dataService.instance.saveNewRecord(amount: amount, category: currentlySelectedCategory!, date: date!, type: type, comment: commentTextField.text ?? "")
            dataService.instance.usedCertainCategory(category: currentlySelectedCategory!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateEverything"), object: nil)
            dismiss(animated: true, completion: nil)
        }
    }

}


extension AddExpenseViewController: UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    //***************************************************************************
    //MARK: Collection Views related code goes below
    //***************************************************************************
    
    
    //***************************************************************************
    //Automatically select and center date
    //***************************************************************************
    
    
    func setSelectedItemFromScrollView(_ scrollView: UIScrollView) {
            self.CalendarCollectionView.setNeedsLayout()
            self.CalendarCollectionView.layoutIfNeeded()
            let center = CGPoint(x: scrollView.center.x + scrollView.contentOffset.x, y: (scrollView.center.y + scrollView.contentOffset.y))
//            print(center)
            let index = CalendarCollectionView.indexPathForItem(at: center)
            if index != nil {
                CalendarCollectionView.scrollToItem(at: index!, at: .centeredHorizontally, animated: true)
                self.CalendarCollectionView.selectItem(at: index, animated: true, scrollPosition: [])
                self.selectedDateIndex = (index?.row)!
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
                let currentlySelectedDate = CalendarService.instance.datesForCoreData()[selectedDateIndex]
                date = formatter.date(from: currentlySelectedDate) ?? Date()
//                print(date!)
            }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == CalendarCollectionView {
        selection.selectionChanged()
        setSelectedItemFromScrollView(CalendarCollectionView)
        } else {
            selection.selectionChanged()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == CalendarCollectionView {
        selection.selectionChanged()
        setSelectedItemFromScrollView(CalendarCollectionView)
        } else {
            selection.selectionChanged()
        }
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
            formatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
            date = formatter.date(from: selectedDate)!
            self.selection.selectionChanged()
        } else {
            let category = categories[indexPath.row]
            currentlySelectedCategory = category.title!
            self.selection.selectionChanged()
        }
    }
    
    //***************************************************************************
    //MARK: Text field related code goes below
    //***************************************************************************
    
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
