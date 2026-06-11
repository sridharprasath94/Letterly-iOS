struct LoadGameStateUseCase {
    private let repository: GameStateRepository
    init(repository: GameStateRepository) { self.repository = repository }

    func execute(mode: GameMode) -> GameSaveState? {
        repository.load(for: mode)
    }
}
