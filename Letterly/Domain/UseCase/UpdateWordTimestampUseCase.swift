import Foundation
struct UpdateWordTimestampUseCase {
    private let repository: WordRepository

    init(repository: WordRepository) {
        self.repository = repository
    }

    func execute(word: String, mode: GameMode) async {
        let updated = Word(value: word.lowercased(), length: mode.wordLength, lastAnsweredAt: Date())
        await repository.updateWord(updated)
    }
}
