//
//  FirebaseController.swift
//  Roamly
//
//  Created by Justin Mai on 9/5/2024.
//

import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth
import UIKit

class FirebaseController: NSObject, DatabaseProtocol {
    func addExpense(name: String, date: Date, amount: Double, category: Category, completion: @escaping ((any Error)?) -> Void) {
        let expenseId = UUID().uuidString

          let expense = Expenses(
              expenseName: name,
              expenseDate: date,
              expenseValue: amount,
              expenseCategory: category
          )

          do {
              try database.collection("expenses").document(expenseId).setData(from: expense) { error in
                  if let error = error {
                      completion(error)
                  } else {
                      completion(nil)
                  }
              }
          } catch let error {
              completion(error)
          }
    }
    
    
    func fetchExpenses(completion: @escaping ([Expenses]?, (any Error)?) -> Void) {
        database.collection("expenses").getDocuments { snapshot, error in
                 if let error = error {
                     completion(nil, error)
                 } else {
                     var expenses: [Expenses] = []
                     for document in snapshot!.documents {
                         if let expense = try? document.data(as: Expenses.self) {
                             expenses.append(expense)
                         }
                     }
                     completion(expenses, nil)
                 }
             }
    }
    
    func searchExpenses(query: String, completion: @escaping ([Expenses]?, (any Error)?) -> Void) {
        database.collection("expenses")
                  .whereField("expenseName", isGreaterThanOrEqualTo: query)
                  .whereField("expenseName", isLessThanOrEqualTo: query + "\u{f8ff}")
                  .getDocuments { snapshot, error in
                      if let error = error {
                          completion(nil, error)
                      } else {
                          var expenses: [Expenses] = []
                          for document in snapshot!.documents {
                              if let expense = try? document.data(as: Expenses.self) {
                                  expenses.append(expense)
                              }
                          }
                          completion(expenses, nil)
                      }
              }
    }
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var tripList: [Trip] = []
    var expenseList: [Expenses] = []
    
    override init() {
        // Initialize Firebase authentication and Firestore database
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        tripList = [Trip]()
        
        super.init()
        
        Task {
            do {
                let authDataResult = try await authController.signInAnonymously()
                currentUser = authDataResult.user
                self.setupTripListener()
            } catch {
                print("Firebase Authentication Failed with Error: \(String(describing: error))")
            }
        }
    }

    var authController: Auth
    var database: Firestore
    var tripsRef: CollectionReference?
    var currentUser: User?
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        listener.onDatabaseChange(change: .update, trips: tripList, expenses: expenseList)
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addTrip(tripName: String, startDate: Date, endDate: Date, completion: @escaping (Error?) -> Void) {
        let tripId = UUID().uuidString

        let trip = Trip(
            tripName: tripName,
            startDate: startDate,
            endDate: endDate
        )

        do {
            try database.collection("trips").document(tripId).setData(from: trip) { error in
                completion(error)
            }
        } catch let error {
            completion(error)
        }
    }

    func deleteTrip(trip: Trip, completion: @escaping (Error?) -> Void) {
        guard let tripID = trip.id else {
            completion(NSError(domain: "Trip ID is missing", code: 0, userInfo: nil))
            return
        }
        database.collection("trips").document(tripID).delete(completion: completion)
    }

    func fetchTrips(completion: @escaping ([Trip]?, Error?) -> Void) {
        database.collection("trips").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let documents = snapshot?.documents else {
                completion([], nil)
                return
            }

            let trips = documents.compactMap { doc -> Trip? in
                return try? doc.data(as: Trip.self)
            }
            completion(trips, nil)
        }
    }
    
    func searchTrips(query: String, completion: @escaping ([Trip]?, Error?) -> Void) {
        database.collection("trips").whereField("tripName", isGreaterThanOrEqualTo: query).whereField("tripName", isLessThanOrEqualTo: query + "\u{f8ff}").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let documents = snapshot?.documents else {
                completion([], nil)
                return
            }

            let trips = documents.compactMap { doc -> Trip? in
                return try? doc.data(as: Trip.self)
            }
            completion(trips, nil)
        }
    }

    func setupTripListener() {
        tripsRef = database.collection("trips")
        tripsRef?.addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            self.parseTripsSnapshot(snapshot: querySnapshot)
        }
    }
    
    func parseTripsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in
            var trip: Trip
            do {
                trip = try change.document.data(as: Trip.self)
            } catch {
                print("Unable to decode trip: \(error.localizedDescription)")
                return
            }

            if change.type == .added {
                tripList.insert(trip, at: Int(change.newIndex))
            } else if change.type == .modified {
                tripList.remove(at: Int(change.oldIndex))
                tripList.insert(trip, at: Int(change.newIndex))
            } else if change.type == .removed {
                tripList.remove(at: Int(change.oldIndex))
            }

            listeners.invoke { listener in
                listener.onDatabaseChange(change: .update, trips: tripList, expenses: expenseList)
            }
        }
    }
}
