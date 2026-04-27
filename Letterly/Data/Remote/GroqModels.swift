struct GroqRequest: Codable {
    let model: String
    let messages: [GroqMessage]
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model, messages
        case maxTokens = "max_tokens"
    }

    init(messages: [GroqMessage], maxTokens: Int = 60) {
        self.model = "llama-3.1-8b-instant"
        self.messages = messages
        self.maxTokens = maxTokens
    }
}

struct GroqMessage: Codable {
    let role: String
    let content: String
}

struct GroqResponse: Codable {
    let choices: [GroqChoice]
}

struct GroqChoice: Codable {
    let message: GroqMessage
}
