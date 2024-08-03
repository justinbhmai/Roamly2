//
//  Trip.swift
//  Roamly
//
//  Created by Justin Mai on 3/8/2024.
//

import Foundation
import FirebaseFirestoreSwift

class Trip: Codable {
    @DocumentID var tripID: String?
    var tripName: String
    var startDate: Date
    var endDate: Date
    
    init(tripName: String, startDate: Date, endDate: Date) {
        self.tripName = tripName
        self.startDate = startDate
        self.endDate = endDate
    }
    
    enum CodingKeys: String, CodingKey {
        case tripID = "id"
        case tripName
        case startDate
        case endDate
    }
    
    // MARK: - Decodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tripID = try container.decodeIfPresent(String.self, forKey: .tripID)
        self.tripName = try container.decode(String.self, forKey: .tripName)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
    }
    
    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(tripID, forKey: .tripID)
        try container.encode(tripName, forKey: .tripName)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
    }
}
