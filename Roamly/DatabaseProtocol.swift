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
    func onDatabaseChange(change: DatabaseChange, trips: [Trip]?)
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
    // Method to add a trip to the database
    func addTrip(tripName: String, startDate: Date, endDate: Date, completion: @escaping (Error?) -> Void)
    
    // Method to fetch all trips from the database
    func fetchTrips(completion: @escaping ([Trip]?, Error?) -> Void)
    
    // Method to search for trips based on a query
    func searchTrips(query: String, completion: @escaping ([Trip]?, Error?) -> Void)
    
    // Method to add a listener to the database
    func addListener(listener: DatabaseListener)
    
    // Method to remove a listener from the database
    func removeListener(listener: DatabaseListener)
}




