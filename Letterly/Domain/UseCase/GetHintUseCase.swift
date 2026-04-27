struct GetHintUseCase {
    private let repository: HintRepository

    init(repository: HintRepository) {
        self.repository = repository
    }

    func execute(word: String, previousHints: [String]) async -> Result<String, Error> {
        await repository.getHint(word: word, previousHints: previousHints)
    }
}
