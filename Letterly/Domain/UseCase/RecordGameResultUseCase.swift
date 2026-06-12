struct RecordGameResultUseCase {
    private let repository: StatsRepository

    init(repository: StatsRepository) {
        self.repository = repository
    }

    @discardableResult
    func execute(didWin: Bool) -> GameStats {
        var stats = repository.load()
        stats.gamesPlayed += 1
        if didWin {
            stats.gamesWon += 1
            stats.currentStreak += 1
            if stats.currentStreak > stats.bestStreak {
                stats.bestStreak = stats.currentStreak
            }
        } else {
            stats.currentStreak = 0
        }
        repository.save(stats)
        return stats
    }
}
