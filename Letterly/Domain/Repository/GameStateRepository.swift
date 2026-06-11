protocol GameStateRepository {
    func save(_ state: GameSaveState, for mode: GameMode)
    func load(for mode: GameMode) -> GameSaveState?
    func clear(for mode: GameMode)
}
