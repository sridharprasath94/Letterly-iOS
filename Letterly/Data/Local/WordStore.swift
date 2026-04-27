import Foundation

actor WordStore {
    static let shared = WordStore()

    private var wordsByLength: [Int: [String]] = [:]
    private let timestampKey = "word_timestamps"

    private init() {}

    func load() {
        for length in [5, 6, 7] {
            guard let url = Bundle.main.url(forResource: "words_\(length)", withExtension: "txt"),
                  let content = try? String(contentsOf: url, encoding: .utf8) else { continue }
            wordsByLength[length] = content
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
                .filter { $0.count == length }
        }
    }

    func getRandomWord(length: Int) -> String? {
        wordsByLength[length]?.randomElement()
    }

    func exists(_ value: String) -> Bool {
        let lower = value.lowercased()
        return wordsByLength[lower.count]?.contains(lower) ?? false
    }

    func getTimestamp(for word: String) -> Date? {
        let timestamps = UserDefaults.standard.dictionary(forKey: timestampKey) as? [String: Double] ?? [:]
        guard let interval = timestamps[word.lowercased()] else { return nil }
        return Date(timeIntervalSince1970: interval)
    }

    func setTimestamp(for word: String, date: Date) {
        var timestamps = UserDefaults.standard.dictionary(forKey: timestampKey) as? [String: Double] ?? [:]
        timestamps[word.lowercased()] = date.timeIntervalSince1970
        UserDefaults.standard.set(timestamps, forKey: timestampKey)
    }
}
