import Foundation

struct HighScore: Codable {
    let score: Int
    let date: Date
}

class HighScoreManager {
    static let shared = HighScoreManager()
    private let userDefaults = UserDefaults.standard
    private let highScoresKey = "highScores"
    private let maxScores = 10
    
    private init() {}
    
    func getHighScores() -> [HighScore] {
        guard let data = userDefaults.data(forKey: highScoresKey),
              let highScores = try? JSONDecoder().decode([HighScore].self, from: data) else {
            return []
        }
        return highScores
    }
    
    func addHighScore(_ score: Int) {
        var highScores = getHighScores()
        let newScore = HighScore(score: score, date: Date())
        highScores.append(newScore)
        highScores.sort { $0.score > $1.score }
        highScores = Array(highScores.prefix(maxScores))
        
        if let encodedData = try? JSONEncoder().encode(highScores) {
            userDefaults.set(encodedData, forKey: highScoresKey)
        }
    }
}
