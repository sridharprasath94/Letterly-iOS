struct ResetStatsUseCase {
    private let repository: StatsRepository

    init(repository: StatsRepository) {
        self.repository = repository
    }

    func execute() {
        repository.save(GameStats())
    }
}
