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
    var transferredDateIndex: Int?
    
    //Record variables
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    var records: [Record]?
    var enteredAmount: String?
    var amount: Double?
    var type: String = "Debit"
    var comment: String?
    
    //Categories variables
    @IBOutlet weak var CategoriesCollectionView: UICollectionView!
    var categories: [Categories]?
    var currentlySelectedCategory: String?
    var indexOfCategory: Int?
    
    //Outlets
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var expenseSwitch: UISwitch!
    @IBOutlet weak var debitedAmountLabel: UILabel!
    @IBOutlet weak var creditedAmountLabel: UILabel!
    var receivedIndexPath: IndexPath?
    
    var alertView: UIAlertController?

    
    //Haptic feedback for selection
    let selection = UISelectionFeedbackGenerator()
    let lightImpact = UIImpactFeedbackGenerator(style: .light)



    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Necessary setup
        adjustUI()
        records = dataService.instance.fetchRecords()
        setupInfoFromTableView()
        self.selection.prepare()
        
        
        //***************************************************************************
        //MARK: Calendar get dates, autoselect & autocenter date
        //***************************************************************************
        
        datesToDisplay = CalendarService.instance.getDates()
        currentDateIndex = CalendarService.instance.currentDateIndex
        datesForCoreData = CalendarService.instance.datesForCoreData()
        
        formatter.dateFormat = "MMM\ndd\nE"
        let convertedDate = formatter.string(from: dataService.instance.editableDate!)
        
        
        //Checking if the date transferred is still available for selection
        //If yes, select it. If no - Hide the Calendar and show the alert
        transferredDateIndex = CalendarService.instance.find(value: convertedDate, in: datesToDisplay)
        if transferredDateIndex == nil {
            CalendarCollectionView.isHidden = true
        } else {
            CalendarCollectionView.isHidden = false
            let indexPathForFirstRow = IndexPath(row: transferredDateIndex!, section: 0)
            self.setSelectedItemFromScrollView(CalendarCollectionView)
            self.CalendarCollectionView.selectItem(at: indexPathForFirstRow, animated: true, scrollPosition: .centeredHorizontally)
        }
        
    
        //***************************************************************************
        //MARK: Categories fetch, autoselect the category which was chosen originally
        //***************************************************************************
        dataService.instance.fetchCoreDataCategories()
        categories = dataService.instance.categories
        indexOfCategory = CalendarService.instance.find(value: dataService.instance.editableCategory!, in: dataService.instance.categoriesArray)
        
        let indexPathForFirstRowCategory = IndexPath(row: indexOfCategory ?? 0, section: 0)
        self.setSelectedCategoryFromScrollView(CategoriesCollectionView)
        self.CategoriesCollectionView.selectItem(at: indexPathForFirstRowCategory, animated: true, scrollPosition: .centeredHorizontally)
    
    }
    
    //In case if date cannot be selected, alert user that index of date is out of bounds
    override func viewDidAppear(_ animated: Bool) {
        if transferredDateIndex == nil {
            presentAlert()
        }
    }
    
    //***************************************************************************
    //MARK: Alert function
    //***************************************************************************

    func presentAlert() {

        self.alertView = UIAlertController(title: "Date index is out of bounds", message: "Sorry. Selected date is too old to be edited. You can either delete this record or modify this record without changing the date.", preferredStyle: .alert)
        alertView?.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in })

        self.present(alertView!, animated: true, completion: nil)

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
    
    //***************************************************************************
    //MARK: Saving the edited data and notifying the TableView to update views
    //***************************************************************************
    
    @IBAction func editExistingRecord(_ sender: UIButton) {
        enteredAmount = amountTextField.text?.replacingOccurrences(of: ",", with: ".")
        amount = Double(enteredAmount!) ?? 0.0
        if checkEntry(){
            dataService.instance.editRecord(atIndexPath: receivedIndexPath!, updateAmount: amount!, updateCategory: currentlySelectedCategory!, updateComment: commentTextField.text ?? "", updateDate: date!, updateType: type)
            dataService.instance.usedCertainCategory(category: currentlySelectedCategory!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateEverything"), object: nil)
        dismiss(animated: true, completion: nil)
        }
    }
    
    //***************************************************************************
    //MARK: Checking if the type of record have been changed
    //MARK: By default it is always expense
    //***************************************************************************
    
    @IBAction func toggleExpenseSwitch(_ sender: UISwitch) {
        if !expenseSwitch.isOn {
            CategoriesCollectionView.isHidden = true
            debitedAmountLabel.isHidden = true
            creditedAmountLabel.isHidden = false
            type = "Credit"
            if type == "Credit" {
                currentlySelectedCategory = "Credit"
            }
        } else {
            currentlySelectedCategory = nil
            CategoriesCollectionView.selectItem(at: nil, animated: true, scrollPosition: .centeredHorizontally)
            CategoriesCollectionView.isHidden = false
            debitedAmountLabel.isHidden = false
            creditedAmountLabel.isHidden = true
            type = "Debit"
        }
    }
    
    //***************************************************************************
    //MARK: Receiving original information about that particular record
    //***************************************************************************
    
    func setupInfoFromTableView() {
        if dataService.instance.editableCategory == "Credit" {
            expenseSwitch.setOn(false, animated: true)
            currentlySelectedCategory = "Credit"
            CategoriesCollectionView.isHidden = true
            debitedAmountLabel.isHidden = true
            creditedAmountLabel.isHidden = false
            type = "Credit"
        } else {
            expenseSwitch.setOn(true, animated: true)
            currentlySelectedCategory = dataService.instance.editableCategory!
            CategoriesCollectionView.isHidden = false
            debitedAmountLabel.isHidden = false
            creditedAmountLabel.isHidden = true
        }
        let receivedAmount = dataService.instance.editableAmount
        amountTextField.text = String(describing: receivedAmount!)
        commentTextField.text = dataService.instance.editableComment
        date = dataService.instance.editableDate
    }
    
}

extension EditingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate{
    
    //***************************************************************************
    //MARK: Collection Views related code goes below
    //***************************************************************************
    
    
    //***************************************************************************
    //Function that allows automatically select and center date
    //***************************************************************************
    
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
                formatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
                let currentlySelectedDate = CalendarService.instance.datesForCoreData()[selectedDateIndex]
                date = formatter.date(from: currentlySelectedDate) ?? Date()
            }
    }
    
    //****************************************************************************************
    //Function that allows automatically select the category that have been chosen originally
    //****************************************************************************************
    
    func setSelectedCategoryFromScrollView(_ scrollView: UIScrollView) {
        self.CategoriesCollectionView.setNeedsLayout()
        self.CategoriesCollectionView.layoutIfNeeded()
        let index = IndexPath(row: indexOfCategory ?? 0, section: 0)
        CategoriesCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        self.CategoriesCollectionView.selectItem(at: index, animated: true, scrollPosition: [])
        currentlySelectedCategory = dataService.instance.editableCategory!
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == CalendarCollectionView && transferredDateIndex != nil {
        selection.selectionChanged()
        setSelectedItemFromScrollView(CalendarCollectionView)
        } else {
            selection.selectionChanged()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == CalendarCollectionView && transferredDateIndex != nil {
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
            formatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
            date = formatter.date(from: selectedDate)!
            selection.selectionChanged()
        } else {
            let category = categories![indexPath.row]
            currentlySelectedCategory = category.title!
            selection.selectionChanged()
        }
    }
    
    //***************************************************************************
    //MARK: Text field related code goes below
    //***************************************************************************
    
    //Limiting the textField to 100 symbols
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
