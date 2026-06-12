import Combine
import Foundation

@MainActor
final class StatsViewModel: ObservableObject {
    @Published private(set) var stats: GameStats

    private let getStatsUseCase: GetStatsUseCase
    private let resetStatsUseCase: ResetStatsUseCase

    init(getStatsUseCase: GetStatsUseCase, resetStatsUseCase: ResetStatsUseCase) {
        self.getStatsUseCase = getStatsUseCase
        self.resetStatsUseCase = resetStatsUseCase
        self.stats = getStatsUseCase.execute()
    }

    func reload() {
        stats = getStatsUseCase.execute()
    }

    func resetStats() {
        resetStatsUseCase.execute()
        stats = getStatsUseCase.execute()
    }
}
