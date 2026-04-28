import Foundation

final class AppContainer {
    static let shared = AppContainer()

    let wordRepository: WordRepository
    let hintRepository: HintRepository

    let getRandomWordUseCase: GetRandomWordUseCase
    let checkWordExistsUseCase: CheckWordExistsUseCase
    let evaluateGuessUseCase: EvaluateGuessUseCase
    let applyGuessResultUseCase: ApplyGuessResultUseCase
    let checkGameStatusUseCase: CheckGameStatusUseCase
    let checkDuplicateGuessUseCase: CheckDuplicateGuessUseCase
    let clearRowUseCase: ClearRowUseCase
    let updateKeyboardStateUseCase: UpdateKeyboardStateUseCase
    let updateWordTimestampUseCase: UpdateWordTimestampUseCase
    let getHintUseCase: GetHintUseCase

    private init() {
        let groqAPIKey = Bundle.main.object(forInfoDictionaryKey: "GROQ_API_KEY") as? String ?? ""

        wordRepository = WordRepositoryImpl()
        hintRepository = HintRepositoryImpl(apiService: GroqAPIService(apiKey: groqAPIKey))

        getRandomWordUseCase = GetRandomWordUseCase(repository: wordRepository)
        checkWordExistsUseCase = CheckWordExistsUseCase(repository: wordRepository)
        evaluateGuessUseCase = EvaluateGuessUseCase()
        applyGuessResultUseCase = ApplyGuessResultUseCase()
        checkGameStatusUseCase = CheckGameStatusUseCase()
        checkDuplicateGuessUseCase = CheckDuplicateGuessUseCase()
        clearRowUseCase = ClearRowUseCase()
        updateKeyboardStateUseCase = UpdateKeyboardStateUseCase()
        updateWordTimestampUseCase = UpdateWordTimestampUseCase(repository: wordRepository)
        getHintUseCase = GetHintUseCase(repository: hintRepository)
    }

    func makeGameViewModel(mode: GameMode) -> GameViewModel {
        GameViewModel(
            mode: mode,
            getRandomWordUseCase: getRandomWordUseCase,
            checkWordExistsUseCase: checkWordExistsUseCase,
            evaluateGuessUseCase: evaluateGuessUseCase,
            applyGuessResultUseCase: applyGuessResultUseCase,
            checkGameStatusUseCase: checkGameStatusUseCase,
            checkDuplicateGuessUseCase: checkDuplicateGuessUseCase,
            clearRowUseCase: clearRowUseCase,
            updateKeyboardStateUseCase: updateKeyboardStateUseCase,
            updateWordTimestampUseCase: updateWordTimestampUseCase,
            getHintUseCase: getHintUseCase
        )
    }
}
