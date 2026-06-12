import Foundation

struct HintAPIService {
    private let workerURL: URL

    init(workerURL: URL) {
        self.workerURL = workerURL
    }

    func requestHint(_ request: HintRequest) async throws -> HintResponse {
        var urlRequest = URLRequest(url: workerURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(HintResponse.self, from: data)
    }
}
