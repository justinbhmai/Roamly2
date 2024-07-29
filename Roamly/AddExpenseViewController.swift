//
//  AddExpenseViewController.swift
//  Roamly
//
//  Created by Justin Mai on 8/6/2024.
//

import UIKit
import FirebaseFirestore

protocol AddExpenseDelegate: AnyObject {
    func didAddExpense(_ expense: Expenses)
}


class AddExpenseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var expenseName: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var expenseAmount: UITextField!
    
    let categories = ["Food", "Transport", "Entertainment", "Shopping", "Other"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
                
        // Set up text fields
        expenseName.delegate = self
        expenseAmount.delegate = self
                
        // Set up date picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
                
        // Set up the submit button action
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }
    
    // UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    // UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Handle category selection if needed
    }
    
    private func saveExpenseToFirestore(name: String, amount: Double, date: Date, category: String) {
           let db = Firestore.firestore()
           let expensesCollection = db.collection("expenses")
           
           let expenseData: [String: Any] = [
               "name": name,
               "amount": amount,
               "date": Timestamp(date: date),
               "category": category
           ]
           
           expensesCollection.addDocument(data: expenseData) { error in
               if let error = error {
                   print("Error adding document: \(error)")
                   self.showAlert(message: "Failed to save expense. Please try again.")
               } else {
                   print("Document added successfully.")
                   self.showAlert(message: "Expense added.")
                   self.clearForm()
               }
           }
       }
       
       @objc func submitButtonTapped() {
           guard let name = expenseName.text, !name.isEmpty,
                 let amountText = expenseAmount.text, let amount = Double(amountText),
                 amount > 0 else {
               showAlert(message: "Please enter a valid name and amount.")
               return
           }
           
           let selectedCategory = categories[categoryPicker.selectedRow(inComponent: 0)]
           let selectedDate = datePicker.date
           
           let newExpense = Expenses(name: name, amount: amount, date: selectedDate, category: selectedCategory)

           
           // Process the expense data
           print("Expense Name: \(name)")
           print("Expense Amount: \(amount)")
           print("Expense Date: \(selectedDate)")
           print("Expense Category: \(selectedCategory)")
           
           // Save the expense data to Firestore
           saveExpenseToFirestore(name: name, amount: amount, date: selectedDate, category: selectedCategory)
       }
    
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
              // Perform any action after the alert is dismissed, such as navigating back
              self.navigationController?.popViewController(animated: true)
          }))
          present(alert, animated: true, completion: nil)
      }
    
    private func clearForm() {
        expenseName.text = ""
        expenseAmount.text = ""
        categoryPicker.selectRow(0, inComponent: 0, animated: false)
        datePicker.setDate(Date(), animated: false)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Ensure amount field only accepts valid numbers
        if textField == expenseAmount {
            let allowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
