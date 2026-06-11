import Foundation

struct StatsRepositoryImpl: StatsRepository {
    private let key = "game_stats"

    func load() -> GameStats {
        guard let data = UserDefaults.standard.data(forKey: key),
              let stats = try? JSONDecoder().decode(GameStats.self, from: data)
        else { return GameStats() }
        return stats
    }

    func save(_ stats: GameStats) {
        guard let data = try? JSONEncoder().encode(stats) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
