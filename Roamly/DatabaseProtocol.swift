//
//  DatabaseProtocol.swift
//  Roamly
//
//  Created by Justin Mai on 7/6/2024.
//

import UIKit
import Foundation // Define the Trip model conforming to Codable
import Firebase
import FirebaseFirestoreSwift


// Protocol to be conformed by any class that wants to listen to database changes
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType { get set }
    func onDatabaseChange(change: DatabaseChange, trips: [Trip]?, expenses: [Expenses]?)
}

// Enum to represent different types of database changes
enum DatabaseChange {
    case add
    case remove
    case update
}

// Enum to represent different types of listeners for database changes
enum ListenerType {
    case trips
    case all
}

// Protocol to be conformed by any class that interacts with the database
protocol DatabaseProtocol {
    // Trip management methods
       func addTrip(tripName: String, startDate: Date, endDate: Date, completion: @escaping (Error?) -> Void)
       func fetchTrips(completion: @escaping ([Trip]?, Error?) -> Void)
       func searchTrips(query: String, completion: @escaping ([Trip]?, Error?) -> Void)

       // Expense management methods
       func addExpense(name: String, date: Date, amount: Double, category: Category, completion: @escaping (Error?) -> Void)
       func fetchExpenses(completion: @escaping ([Expenses]?, Error?) -> Void)
       func searchExpenses(query: String, completion: @escaping ([Expenses]?, Error?) -> Void)
       
       // Listener management methods
       func addListener(listener: DatabaseListener)
       func removeListener(listener: DatabaseListener)
}




