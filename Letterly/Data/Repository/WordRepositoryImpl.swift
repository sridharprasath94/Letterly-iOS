struct WordRepositoryImpl: WordRepository {
    private let store: WordStore

    init(store: WordStore = .shared) {
        self.store = store
    }

    func getRandomWord(length: Int) async -> Word? {
        guard let value = await store.getRandomWord(length: length) else { return nil }
        let timestamp = await store.getTimestamp(for: value)
        return Word(value: value, length: length, lastAnsweredAt: timestamp)
    }

    func getWord(value: String) async -> Word? {
        let lower = value.lowercased()
        guard await store.exists(lower) else { return nil }
        let timestamp = await store.getTimestamp(for: lower)
        return Word(value: lower, length: lower.count, lastAnsweredAt: timestamp)
    }

    func updateWord(_ word: Word) async {
        if let date = word.lastAnsweredAt {
            await store.setTimestamp(for: word.value, date: date)
        }
    }

    func exists(_ value: String) async -> Bool {
        await store.exists(value)
    }
}
