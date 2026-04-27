import Foundation
struct GetRandomWordUseCase {
    private let repository: WordRepository

    init(repository: WordRepository) {
        self.repository = repository
    }

    func execute(mode: GameMode) async -> Word? {
        for _ in 0..<10 {
            guard let word = await repository.getRandomWord(length: mode.wordLength) else { return nil }
            if word.lastAnsweredAt == nil || isOlderThanTenDays(word) {
                return word
            }
        }
        return nil
    }

    private func isOlderThanTenDays(_ word: Word) -> Bool {
        guard let lastAnswered = word.lastAnsweredAt else { return true }
        let tenDays: TimeInterval = 10 * 24 * 60 * 60
        return Date().timeIntervalSince(lastAnswered) >= tenDays
    }
}
