//
//  SocialsViewController.swift
//  Roamly
//
//  Created by Justin Mai on 2/5/2024.
//

import UIKit
import Foundation

// Define the TripData model to match the API response
struct TripData: Codable {
    let id: String
    let name: String
    let details: String?
    // Add other fields as required by your API
}

// Define the TripResponse model to handle API responses
struct TripResponse: Codable {
    let trips: [TripData]
    // Ensure this matches the actual structure of your API response
}


class SocialsViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    
   
    let CELL_TRIP = "socialCell"
    let REQUEST_STRING = "https://test.api.amadeus.com/v1/security/oauth2/token"
    var newTrips: [TripData] = []
    var indicator = UIActivityIndicatorView()
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the search bar delegate
        searchBar.delegate = self
        
        // Register the cell identifier
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_TRIP)
        
        // Set up the activity indicator
        indicator.style = .large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchBar.resignFirstResponder()
        indicator.startAnimating()
        
        // Perform the search
        searchTripsNamed(searchText)
    }
    
    // MARK: - API Call
    func searchTripsNamed(_ tripName: String) {
        Task {
            await requestTripsNamed(tripName, page: 1)
        }
    }
    
    func requestTripsNamed(_ tripName: String, page: Int = 1) async {
        guard let queryString = tripName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let requestURL = URL(string: "\(REQUEST_STRING)?query=\(queryString)&page=\(page)&apiKey=AmPD7A9nnmRx3E7XRGuUKkbc6tdW0V0g") else {
            print("Invalid URL.")
            return
        }
        
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            
            let decoder = JSONDecoder()
            let tripResponse = try decoder.decode(TripResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.newTrips = tripResponse.trips
                self.tableView.reloadData()
            }
        } catch {
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            print("Error fetching trips: \(error.localizedDescription)")
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newTrips.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_TRIP, for: indexPath)
        let trip = newTrips[indexPath.row]
        cell.textLabel?.text = trip.name
        cell.detailTextLabel?.text = trip.details
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrip = newTrips[indexPath.row]
        // Handle the trip selection, e.g., navigate to detail view
        print("Selected trip: \(selectedTrip)")
    }
}

