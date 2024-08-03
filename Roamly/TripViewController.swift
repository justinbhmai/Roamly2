//
//  TripViewController.swift
//  Roamly
//
//  Created by Justin Mai on 2/5/2024.
//

import UIKit
import Firebase
import FirebaseFirestore

class TripViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tripTableView: UITableView!
    @IBOutlet weak var addTripButton: UIBarButtonItem!
    
    let CELL_TRIP = "currentCell"
    
    private let firebaseController = FirebaseController()
    
    var trips: [Trip] = []
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure outlets are not nil
        guard tripTableView != nil, addTripButton != nil else {
            fatalError("Outlets are not properly connected.")
        }
        
        // Set up the table view's delegates and data sources
        tripTableView.delegate = self
        tripTableView.dataSource = self
        
        // Set up Firestore
        db = Firestore.firestore()
        
        // Load trips from Firestore
        fetchTrips()
        
        // Add target for addTripButton
        addTripButton.target = self
        addTripButton.action = #selector(addTripTapped)
    }
    
    @objc func addTripTapped() {
        print("Add Trip button tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addTripVC = storyboard.instantiateViewController(withIdentifier: "AddTripViewController") as? AddTripViewController {
            self.navigationController?.pushViewController(addTripVC, animated: true)
        } else {
            print("Failed to instantiate AddTripViewController")
        }
    }
    
    /// Load trips from Firestore.
    private func fetchTrips() {
        db.collection("trips").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching trips: \(error)")
                return
            }
            
            self.trips = querySnapshot?.documents.compactMap({ try? $0.data(as: Trip.self) }) ?? []
            self.tripTableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_TRIP, for: indexPath)
        let trip = trips[indexPath.row]
        
        // Configure the cell with trip details
        cell.textLabel?.text = trip.tripName
        // Customize the cell further if needed
        
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddTrip" {
            if let addTripVC = segue.destination as? AddTripViewController {
                // Pass any necessary data to AddTripViewController
                addTripVC.delegate = self  // Ensure `self` conforms to `AddTripDelegate`
            }
        }
    }
}
// Delegate to update trips
extension TripViewController: AddTripDelegate {
    func didAddTrip(_ trip: Trip) {
        // Add the new trip to the list and reload the table view
        self.trips.append(trip)
        self.tripTableView.reloadData()
        
    }
}

