//
//  SocialsViewController.swift
//  Roamly
//
//  Created by Justin Mai on 2/5/2024.
//

import UIKit
import Foundation

// Define the TripData model to match the API response
struct Trip2Data: Codable {
    let id: String
    let name: String
    let details: String?
    let type: String?
    let origin: String?
    let destination: String?
    let departureDate: String?
    let returnDate: String?
    let price: String?
    // Add other fields as required by your API
}

// Define the TripResponse model to handle API responses
struct TripResponse: Codable {
    let data: [Trip2Data]
    // Ensure this matches the actual structure of your API response
}

// Function to get OAuth2 access token
func getAccessToken() async -> String? {
    let url = URL(string: "https://test.api.amadeus.com/v1/security/oauth2/token")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let clientId = "AmPD7A9nnmRx3E7XRGuUKkbc6tdW0V0g"
    let clientSecret = "bcSUiOnV6zPacM09"
    let body = "grant_type=client_credentials&client_id=\(clientId)&client_secret=\(clientSecret)"
    request.httpBody = body.data(using: .utf8)
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let accessToken = jsonResponse["access_token"] as? String {
            return accessToken
        }
    } catch {
        print("Error obtaining access token: \(error)")
    }
    return nil
}

class SocialsViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    
    let CELL_TRIP = "socialCell"
    let TRIP_SEARCH_ENDPOINT = "https://test.api.amadeus.com/v2/travel/trips" // Update to actual endpoint
    var newTrips: [Trip2Data] = []
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
              let token = await getAccessToken() else {
            print("Invalid URL or missing access token.")
            return
        }
        
        guard let requestURL = URL(string: "\(TRIP_SEARCH_ENDPOINT)?query=\(queryString)&page=\(page)") else {
            print("Invalid URL.")
            return
        }
        
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            
            let decoder = JSONDecoder()
            let tripResponse = try decoder.decode(TripResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.newTrips = tripResponse.data
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
