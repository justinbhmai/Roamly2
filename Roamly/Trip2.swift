//
//  Trip2.swift
//  Roamly
//
//  Created by Justin Mai on 9/6/2024.
//

import Foundation

// Define a class to represent the flight destination details
class Trip2: Codable {
    // Define properties
    var type: String
    var origin: String
    var destination: String
    var departureDate: String
    var returnDate: String
    var price: String
    
    // Nested class for price details
    class Price: Codable {
        var total: String
        
        // Initializer for Price
        init(total: String) {
            self.total = total
        }
    }
    
    // Initializer for Trip2
    init(type: String, origin: String, destination: String, departureDate: String, returnDate: String, price: String) {
        self.type = type
        self.origin = origin
        self.destination = destination
        self.departureDate = departureDate
        self.returnDate = returnDate
        self.price = price
    }
    
    // Method to decode JSON to Trip2 object
    static func fromJSON(_ jsonData: Data) -> Trip2? {
        let decoder = JSONDecoder()
        do {
            let trip = try decoder.decode(Trip2.self, from: jsonData)
            return trip
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    
    // Method to encode Trip2 object to JSON
    func toJSON() -> Data? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(self)
            return jsonData
        } catch {
            print("Error encoding JSON: \(error)")
            return nil
        }
    }
}

// A function to test JSON conversion
func testJSONConversion() {
    // Example JSON string for a Trip2 object
    let jsonString = """
    {
        "type": "flight-destination",
        "origin": "PAR",
        "destination": "CAS",
        "departureDate": "2022-09-06",
        "returnDate": "2022-09-11",
        "price": {
            "total": "161.90"
        }
    }
    """
    
    // Convert the JSON string to Data
    if let jsonData = jsonString.data(using: .utf8) {
        // Decode the JSON to a Trip2 object
        if let trip = Trip2.fromJSON(jsonData) {
            print("Trip from \(trip.origin) to \(trip.destination)")
            print("Total price: \(trip.price)")
        }
    }
}

// Call the test function
func main() {
    testJSONConversion()
}
