protocol WordRepository {
    func getRandomWord(length: Int) async -> Word?
    func getWord(value: String) async -> Word?
    func updateWord(_ word: Word) async
    func exists(_ value: String) async -> Bool
}
