//
//  ExpensesViewController.swift
//  Roamly
//
//  Created by Justin Mai on 2/5/2024.
//

import UIKit

class ExpensesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var expenseSearchBar: UISearchBar!
    @IBOutlet weak var expenseTableView: UITableView!
    @IBOutlet weak var addExpenseViewControllerButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        expenseTableView.delegate = self
        expenseTableView.dataSource = self
        expenseSearchBar.delegate = self

        // Optional: Set up the button action programmatically
        addExpenseViewControllerButton.target = self
        addExpenseViewControllerButton.action = #selector(addExpenseTapped)
    }
    
    @objc func addExpenseTapped() {
        performSegue(withIdentifier: "showAddExpense", sender: self)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddExpense" {
            if let addExpenseVC = segue.destination as? AddExpenseViewController {
                // Pass any necessary data to AddExpenseViewController
            }
        }
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows for the table
        return 10 // Replace with your data source count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure and return the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath)
        cell.textLabel?.text = "Expense \(indexPath.row + 1)" // Replace with your data
        return cell
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Handle search bar text changes
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
