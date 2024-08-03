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
    var listeners = MulticastDelegate<DatabaseListener>()
    var tripList: [Trip] = []
    var expenseList: [Expenses] = []

    var authController: Auth
    var database: Firestore
    var tripsRef: CollectionReference?
    var expensesRef: CollectionReference?
    var currentUser: User?

    override init() {
        // Initialize Firebase authentication and Firestore database
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        tripsRef = database.collection("trips")
        expensesRef = database.collection("expenses")
        super.init()
        
        authenticateUser()
    }

    private func authenticateUser() {
        Task {
            do {
                let authDataResult = try await authController.signInAnonymously()
                currentUser = authDataResult.user
                setupTripListener()
            } catch {
                print("Firebase Authentication Failed with Error: \(error.localizedDescription)")
            }
        }
    }
    
    func addListener(listener: DatabaseListener) {
          listeners.addDelegate(listener)
          listener.onDatabaseChange(change: .update, trips: tripList, expenses: expenseList)
      }
      
      func removeListener(listener: DatabaseListener) {
          listeners.removeDelegate(listener)
      }

    func addExpense(name: String, date: Date, amount: Double, category: Category, completion: @escaping (Error?) -> Void) {
        let expenseId = UUID().uuidString
        let expense = Expenses(expenseName: name, expenseDate: date, expenseValue: amount, expenseCategory: category)

        do {
            try expensesRef?.document(expenseId).setData(from: expense) { error in
                completion(error)
            }
        } catch let error {
            completion(error)
        }
    }
    
    func fetchExpenses(completion: @escaping ([Expenses]?, Error?) -> Void) {
        expensesRef?.getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let documents = snapshot?.documents else {
                completion([], nil)
                return
            }

            let expenses = documents.compactMap { try? $0.data(as: Expenses.self) }
            completion(expenses, nil)
        }
    }
    
    func searchExpenses(query: String, completion: @escaping ([Expenses]?, Error?) -> Void) {
        expensesRef?
            .whereField("expenseName", isGreaterThanOrEqualTo: query)
            .whereField("expenseName", isLessThanOrEqualTo: query + "\u{f8ff}")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }

                let expenses = documents.compactMap { try? $0.data(as: Expenses.self) }
                completion(expenses, nil)
            }
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
        guard let tripID = trip.tripID else {
            completion(NSError(domain: "Trip ID is missing", code: 0, userInfo: nil))
            return
        }
        tripsRef?.document(tripID).delete(completion: completion)
    }

    func fetchTrips(completion: @escaping ([Trip]?, Error?) -> Void) {
        tripsRef?.getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let documents = snapshot?.documents else {
                completion([], nil)
                return
            }

            let trips = documents.compactMap { try? $0.data(as: Trip.self) }
            completion(trips, nil)
        }
    }
    
    func searchTrips(query: String, completion: @escaping ([Trip]?, Error?) -> Void) {
        tripsRef?
            .whereField("tripName", isGreaterThanOrEqualTo: query)
            .whereField("tripName", isLessThanOrEqualTo: query + "\u{f8ff}")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }

                let trips = documents.compactMap { try? $0.data(as: Trip.self) }
                completion(trips, nil)
            }
    }

    func setupTripListener() {
        tripsRef?.addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(error?.localizedDescription ?? "No error information")")
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

            switch change.type {
            case .added:
                tripList.insert(trip, at: Int(change.newIndex))
            case .modified:
                tripList.remove(at: Int(change.oldIndex))
                tripList.insert(trip, at: Int(change.newIndex))
            case .removed:
                tripList.remove(at: Int(change.oldIndex))
            }

            listeners.invoke { listener in
                listener.onDatabaseChange(change: .update, trips: tripList, expenses: expenseList)
            }
        }
    }
}
