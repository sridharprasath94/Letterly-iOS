struct CheckWordExistsUseCase {
    private let repository: WordRepository

    init(repository: WordRepository) {
        self.repository = repository
    }

    func execute(_ word: String) async -> Bool {
        await repository.exists(word.lowercased())
    }
}
