protocol HintRepository {
    func getHint(word: String, previousHints: [String]) async -> Result<String, Error>
}
