import Foundation
import FirebaseFirestoreSwift

class Expenses: Codable {
    @DocumentID var expenseID: String?
    var expenseName: String
    var expenseDate: Date
    var expenseValue: Double
    var expenseCategory: Category
    
    init(expenseName: String, expenseDate: Date, expenseValue: Double, expenseCategory: Category) {
        self.expenseName = expenseName
        self.expenseDate = expenseDate
        self.expenseValue = expenseValue
        self.expenseCategory = expenseCategory
    }
    
    enum CodingKeys: String, CodingKey {
        case expenseID = "id"
        case expenseName
        case expenseDate
        case expenseValue
        case expenseCategory
    }
    
    // MARK: - Decodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.expenseID = try container.decodeIfPresent(String.self, forKey: .expenseID)
        self.expenseName = try container.decode(String.self, forKey: .expenseName)
        self.expenseDate = try container.decode(Date.self, forKey: .expenseDate)
        self.expenseValue = try container.decode(Double.self, forKey: .expenseValue)
        self.expenseCategory = try container.decode(Category.self, forKey: .expenseCategory)
    }
    
    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(expenseID, forKey: .expenseID)
        try container.encode(expenseName, forKey: .expenseName)
        try container.encode(expenseDate, forKey: .expenseDate)
        try container.encode(expenseValue, forKey: .expenseValue)
        try container.encode(expenseCategory, forKey: .expenseCategory)
    }
}

// Example Category class/enum that conforms to Codable
enum Category: String, Codable {
    case food
    case transport
    case shopping
    case entertainment
    case others
}
