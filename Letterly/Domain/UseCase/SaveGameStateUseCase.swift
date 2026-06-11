struct SaveGameStateUseCase {
    private let repository: GameStateRepository
    init(repository: GameStateRepository) { self.repository = repository }

    func execute(state: GameSaveState, mode: GameMode) {
        repository.save(state, for: mode)
    }
}
