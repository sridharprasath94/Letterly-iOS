struct ClearGameStateUseCase {
    private let repository: GameStateRepository
    init(repository: GameStateRepository) { self.repository = repository }

    func execute(mode: GameMode) {
        repository.clear(for: mode)
    }
}
