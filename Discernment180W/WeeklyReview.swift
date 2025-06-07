import Foundation

struct WeeklyReview: Codable, Identifiable {
    let id: Int?
    let highlight: String
    let challenge: String
    let lesson: String
    let date: Date
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case highlight
        case challenge
        case lesson
        case date = "created_at"
        case userId = "user_id"
    }
    
    var highlightText: String {
        highlight
    }
    
    var challengeText: String {
        challenge
    }
    
    var lessonText: String {
        lesson
    }
    
    var reviewDate: Date {
        date
    }
} 
