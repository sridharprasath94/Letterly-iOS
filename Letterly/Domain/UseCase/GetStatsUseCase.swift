struct GetStatsUseCase {
    private let repository: StatsRepository

    init(repository: StatsRepository) {
        self.repository = repository
    }

    func execute() -> GameStats {
        repository.load()
    }
}
