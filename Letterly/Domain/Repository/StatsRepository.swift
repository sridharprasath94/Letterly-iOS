protocol StatsRepository {
    func load() -> GameStats
    func save(_ stats: GameStats)
}
