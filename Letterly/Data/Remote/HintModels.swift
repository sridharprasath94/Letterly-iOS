struct HintRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model, messages
        case maxTokens = "max_tokens"
    }

    init(messages: [ChatMessage], maxTokens: Int = 60) {
        self.model = "llama-3.1-8b-instant"
        self.messages = messages
        self.maxTokens = maxTokens
    }
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct HintResponse: Codable {
    let choices: [ChatChoice]
}

struct ChatChoice: Codable {
    let message: ChatMessage
}
