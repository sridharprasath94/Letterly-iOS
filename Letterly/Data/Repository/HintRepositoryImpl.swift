import Foundation
struct HintRepositoryImpl: HintRepository {
    private let apiService: GroqAPIService

    init(apiService: GroqAPIService) {
        self.apiService = apiService
    }

    func getHint(word: String, previousHints: [String]) async -> Result<String, Error> {
        let avoidClause = previousHints.isEmpty ? "" :
            " Do not repeat or rephrase these previous hints: \(previousHints.map { "\"\($0)\"" }.joined(separator: "; "))."

        let prompt = "Give a single concise hint (under 15 words) for the word \"\(word)\" in a word guessing game. Describe its meaning or category without revealing the word itself.\(avoidClause)"

        do {
            let response = try await apiService.getChatCompletion(
                request: GroqRequest(messages: [GroqMessage(role: "user", content: prompt)])
            )
            guard let hint = response.choices.first?.message.content else {
                return .failure(GroqError.noHintReceived)
            }
            return .success(hint.trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            return .failure(error)
        }
    }
}

enum GroqError: Error {
    case noHintReceived
}
