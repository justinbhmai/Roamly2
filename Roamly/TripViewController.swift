//
//  TripViewController.swift
//  Roamly
//
//  Created by Justin Mai on 2/5/2024.
//

import UIKit

class TripViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var currentTripsTableView: UITableView!
    @IBOutlet weak var futureTripsTableView: UITableView!
    @IBOutlet weak var pastTripsTableView: UITableView!
    let CELL_TRIP = "currentCell"
    
    private let firebaseController = FirebaseController()

    
    var pastTrips: [Trip] = []
    var futureTrips: [Trip] = []
    var currentTrips: [Trip] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupTableViews()
        loadTrips()
    }
    
    /// Set up the table views' delegates and data sources.
    private func setupTableViews() {
        pastTripsTableView.delegate = self
        pastTripsTableView.dataSource = self
        futureTripsTableView.delegate = self
        futureTripsTableView.dataSource = self
        currentTripsTableView.delegate = self
        currentTripsTableView.dataSource = self
    }
    
    /// Load trips and categorize them into past, current, and future.
        private func loadTrips() {
            firebaseController.fetchTrips { [weak self] (trips, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching trips: \(error)")
                    return
                }
                
                guard let allTrips = trips else { return }
                
                let now = Date()
                
                self.pastTrips = allTrips.filter { $0.endDate < now }
                self.futureTrips = allTrips.filter { $0.startDate > now }
                self.currentTrips = allTrips.filter { $0.startDate <= now && $0.endDate >= now }
                
                self.pastTripsTableView.reloadData()
                self.futureTripsTableView.reloadData()
                self.currentTripsTableView.reloadData()
            }
        }
        
        // MARK: - UITableViewDataSource
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch tableView {
            case pastTripsTableView:
                return pastTrips.count
            case futureTripsTableView:
                return futureTrips.count
            case currentTripsTableView:
                return currentTrips.count
            default:
                return 0
            }
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_TRIP, for: indexPath)
            
            let trip: Trip
            switch tableView {
            case pastTripsTableView:
                trip = pastTrips[indexPath.row]
            case futureTripsTableView:
                trip = futureTrips[indexPath.row]
            case currentTripsTableView:
                trip = currentTrips[indexPath.row]
            default:
                return UITableViewCell()
            }
            
            // Configure the cell with trip details
            cell.textLabel?.text = trip.tripName
            // Customize the cell further if needed
            
            return cell
        }
        
        // MARK: - Navigation

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
        }
    }

