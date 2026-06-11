import Foundation

struct GameStateRepositoryImpl: GameStateRepository {
    private func key(for mode: GameMode) -> String {
        "active_game_state_\(mode.rawValue)"
    }

    func save(_ state: GameSaveState, for mode: GameMode) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: key(for: mode))
    }

    func load(for mode: GameMode) -> GameSaveState? {
        guard let data = UserDefaults.standard.data(forKey: key(for: mode)),
              let state = try? JSONDecoder().decode(GameSaveState.self, from: data)
        else { return nil }
        return state
    }

    func clear(for mode: GameMode) {
        UserDefaults.standard.removeObject(forKey: key(for: mode))
    }
}
