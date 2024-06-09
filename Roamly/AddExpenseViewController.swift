//
//  AddExpenseViewController.swift
//  Roamly
//
//  Created by Justin Mai on 8/6/2024.
//

import UIKit

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
    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Handle category selection if needed
    }
    
    // MARK: - Form Submission
    
    @objc func submitButtonTapped() {
        guard let name = expenseName.text, !name.isEmpty,
              let amountText = expenseAmount.text, let amount = Double(amountText),
              amount > 0 else {
            showAlert(message: "Please enter a valid name and amount.")
            return
        }
        
        let selectedCategory = categories[categoryPicker.selectedRow(inComponent: 0)]
        let selectedDate = datePicker.date
        
        // Process the expense data
        print("Expense Name: \(name)")
        print("Expense Amount: \(amount)")
        print("Expense Date: \(selectedDate)")
        print("Expense Category: \(selectedCategory)")
        
        // Optionally clear the form or navigate away
        clearForm()
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
