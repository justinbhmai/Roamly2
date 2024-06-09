//
//  ExpensesViewController.swift
//  Roamly
//
//  Created by Justin Mai on 2/5/2024.
//

import UIKit
import Firebase
import FirebaseFirestore

class ExpensesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var expenseSearchBar: UISearchBar!
    @IBOutlet weak var expenseTableView: UITableView!
    @IBOutlet weak var addExpenseViewControllerButton: UIBarButtonItem!
    
   
        var expenses: [Expenses] = []
        var filteredExpenses: [Expenses] = []
        var db: Firestore!

        override func viewDidLoad() {
            super.viewDidLoad()

            // Set up the table view and search bar delegates
            expenseTableView.delegate = self
            expenseTableView.dataSource = self
            expenseSearchBar.delegate = self
            
            // Set up Firestore
            db = Firestore.firestore()

            // Set up the button action programmatically
            addExpenseViewControllerButton.target = self
            addExpenseViewControllerButton.action = #selector(addExpenseTapped)

            fetchExpenses()
        }

        @objc func addExpenseTapped() {
            performSegue(withIdentifier: "showAddExpense", sender: self)
        }
        
        // Fetch expenses from Firestore
        func fetchExpenses() {
            db.collection("expenses").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    return
                }
                
                self.expenses = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Expenses.self)
                } ?? []

                self.filteredExpenses = self.expenses
                self.expenseTableView.reloadData()
            }
        }
        
        // MARK: - UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredExpenses.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath)
            let expense = filteredExpenses[indexPath.row]
            cell.textLabel?.text = expense.expenseName
            cell.detailTextLabel?.text = "\(expense.expenseCategory.rawValue) - $\(expense.expenseValue)"
            return cell
        }

        // MARK: - UISearchBarDelegate
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                filteredExpenses = expenses
            } else {
                filteredExpenses = expenses.filter { $0.expenseName.lowercased().contains(searchText.lowercased()) }
            }
            expenseTableView.reloadData()
        }
        
        // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showAddExpense" {
                if let addExpenseVC = segue.destination as? AddExpenseViewController {
                    // Pass any necessary data to AddExpenseViewController
                }
            }
        }
    }
