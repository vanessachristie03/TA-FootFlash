struct Leaderboard: Identifiable {
    let id = UUID()
    let userId: UUID
    let fullName: String
    let totalAccuracy: Double
    
    init(userId: UUID, fullName: String, totalAccuracy: Double) {
        self.userId = userId
        self.fullName = fullName
        self.totalAccuracy = totalAccuracy
    }
}