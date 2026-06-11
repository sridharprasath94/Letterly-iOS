import Combine
import Foundation

@MainActor
final class StatsViewModel: ObservableObject {
    @Published private(set) var stats: GameStats

    private let getStatsUseCase: GetStatsUseCase

    init(getStatsUseCase: GetStatsUseCase) {
        self.getStatsUseCase = getStatsUseCase
        self.stats = getStatsUseCase.execute()
    }

    func reload() {
        stats = getStatsUseCase.execute()
    }
}
