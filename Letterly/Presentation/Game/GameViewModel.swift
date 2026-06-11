import Foundation
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    @Published var board: [[LetterTile]] = []
    @Published var currentRow: Int = 0
    @Published var currentCol: Int = 0
    @Published var gameStatus: GameStatus = .continueGame
    @Published var keyboard: [Character: LetterState] = [:]
    @Published var hintState: HintState = .idle
    @Published var hintsUsed: Int = 0
    @Published var receivedHints: [String] = []
    @Published var targetWord: String = ""

    let mode: GameMode
    let eventPublisher = PassthroughSubject<GameEvent, Never>()

    private var guesses: [String] = []
    private var previousHints: [String] = []

    private let getRandomWordUseCase: GetRandomWordUseCase
    private let checkWordExistsUseCase: CheckWordExistsUseCase
    private let evaluateGuessUseCase: EvaluateGuessUseCase
    private let applyGuessResultUseCase: ApplyGuessResultUseCase
    private let checkGameStatusUseCase: CheckGameStatusUseCase
    private let checkDuplicateGuessUseCase: CheckDuplicateGuessUseCase
    private let clearRowUseCase: ClearRowUseCase
    private let updateKeyboardStateUseCase: UpdateKeyboardStateUseCase
    private let updateWordTimestampUseCase: UpdateWordTimestampUseCase
    private let getHintUseCase: GetHintUseCase
    private let recordGameResultUseCase: RecordGameResultUseCase
    private let saveGameStateUseCase: SaveGameStateUseCase
    private let loadGameStateUseCase: LoadGameStateUseCase
    private let clearGameStateUseCase: ClearGameStateUseCase

    init(
        mode: GameMode,
        getRandomWordUseCase: GetRandomWordUseCase,
        checkWordExistsUseCase: CheckWordExistsUseCase,
        evaluateGuessUseCase: EvaluateGuessUseCase,
        applyGuessResultUseCase: ApplyGuessResultUseCase,
        checkGameStatusUseCase: CheckGameStatusUseCase,
        checkDuplicateGuessUseCase: CheckDuplicateGuessUseCase,
        clearRowUseCase: ClearRowUseCase,
        updateKeyboardStateUseCase: UpdateKeyboardStateUseCase,
        updateWordTimestampUseCase: UpdateWordTimestampUseCase,
        getHintUseCase: GetHintUseCase,
        recordGameResultUseCase: RecordGameResultUseCase,
        saveGameStateUseCase: SaveGameStateUseCase,
        loadGameStateUseCase: LoadGameStateUseCase,
        clearGameStateUseCase: ClearGameStateUseCase
    ) {
        self.mode = mode
        self.getRandomWordUseCase = getRandomWordUseCase
        self.checkWordExistsUseCase = checkWordExistsUseCase
        self.evaluateGuessUseCase = evaluateGuessUseCase
        self.applyGuessResultUseCase = applyGuessResultUseCase
        self.checkGameStatusUseCase = checkGameStatusUseCase
        self.checkDuplicateGuessUseCase = checkDuplicateGuessUseCase
        self.clearRowUseCase = clearRowUseCase
        self.updateKeyboardStateUseCase = updateKeyboardStateUseCase
        self.updateWordTimestampUseCase = updateWordTimestampUseCase
        self.getHintUseCase = getHintUseCase
        self.recordGameResultUseCase = recordGameResultUseCase
        self.saveGameStateUseCase = saveGameStateUseCase
        self.loadGameStateUseCase = loadGameStateUseCase
        self.clearGameStateUseCase = clearGameStateUseCase
    }

    func startGame() {
        Task {
            if let saved = loadGameStateUseCase.execute(mode: mode) {
                restoreState(saved)
                return
            }
            guesses.removeAll()
            guard let word = await getRandomWordUseCase.execute(mode: mode) else { return }
            targetWord = word.value
            board = createBoard(wordLength: mode.wordLength, maxGuesses: mode.maxGuesses)
            currentRow = 0
            currentCol = 0
            gameStatus = .continueGame
            keyboard = [:]
        }
    }

    private func restoreState(_ saved: GameSaveState) {
        targetWord = saved.targetWord
        board = saved.board
        currentRow = saved.currentRow
        currentCol = saved.currentCol
        keyboard = saved.keyboard.reduce(into: [Character: LetterState]()) { result, pair in
            if let c = pair.key.first { result[c] = pair.value }
        }
        guesses = saved.guesses
        hintsUsed = saved.hintsUsed
        receivedHints = saved.receivedHints
        previousHints = saved.receivedHints
        gameStatus = .continueGame
    }

    private func saveState() {
        let encodedKeyboard = keyboard.reduce(into: [String: LetterState]()) { result, pair in
            result[String(pair.key)] = pair.value
        }
        let state = GameSaveState(
            mode: mode,
            targetWord: targetWord,
            board: board,
            currentRow: currentRow,
            currentCol: currentCol,
            keyboard: encodedKeyboard,
            guesses: guesses,
            hintsUsed: hintsUsed,
            receivedHints: receivedHints
        )
        saveGameStateUseCase.execute(state: state, mode: mode)
    }

    func addLetter(_ letter: Character) {
        guard currentCol < mode.wordLength else { return }
        board[currentRow][currentCol] = LetterTile(letter: letter, state: .empty)
        currentCol += 1
        if currentCol == mode.wordLength {
            submitGuess()
        }
    }

    func removeLetter() {
        guard currentCol > 0 else { return }
        currentCol -= 1
        board[currentRow][currentCol] = LetterTile()
    }

    private func submitGuess() {
        Task {
            guard currentCol >= mode.wordLength else { return }
            let guess = board[currentRow].compactMap { $0.letter }.map(String.init).joined()

            if checkDuplicateGuessUseCase.execute(guess: guess, guesses: guesses) {
                board = clearRowUseCase.execute(board: board, row: currentRow)
                currentCol = 0
                eventPublisher.send(.duplicateWord)
                return
            }

            let exists = await checkWordExistsUseCase.execute(guess)
            if !exists {
                board = clearRowUseCase.execute(board: board, row: currentRow)
                currentCol = 0
                eventPublisher.send(.invalidWord)
                return
            }

            guesses.append(guess)

            let result = evaluateGuessUseCase.execute(guess: guess, target: targetWord)
            board = applyGuessResultUseCase.execute(board: board, row: currentRow, states: result.states)
            keyboard = updateKeyboardStateUseCase.execute(keyboard: keyboard, guess: guess, states: result.states)

            let status = checkGameStatusUseCase.execute(
                guesses: guesses,
                targetWord: targetWord,
                maxGuesses: mode.maxGuesses
            )
            currentRow += 1
            currentCol = 0
            gameStatus = status

            if status == .win {
                await updateWordTimestampUseCase.execute(word: targetWord, mode: mode)
                recordGameResultUseCase.execute(didWin: true)
                clearGameStateUseCase.execute(mode: mode)
                eventPublisher.send(.gameWon)
            } else if status == .lose {
                recordGameResultUseCase.execute(didWin: false)
                clearGameStateUseCase.execute(mode: mode)
                eventPublisher.send(.gameLost(target: targetWord))
            } else {
                saveState()
            }
        }
    }

    func requestHint() {
        guard hintsUsed < mode.maxHints else { return }
        Task {
            hintState = .loading
            let result = await getHintUseCase.execute(word: targetWord, previousHints: previousHints)
            hintState = .idle
            switch result {
            case .success(let hint):
                previousHints.append(hint)
                receivedHints = previousHints
                hintsUsed += 1
                saveState()
                eventPublisher.send(.hintReceived(hints: receivedHints))
            case .failure:
                eventPublisher.send(.hintFailed)
            }
        }
    }

    func showHints() {
        eventPublisher.send(.hintReceived(hints: receivedHints))
    }

    func resetGame() {
        clearGameStateUseCase.execute(mode: mode)
        guesses.removeAll()
        previousHints.removeAll()
        receivedHints = []
        hintsUsed = 0
        hintState = .idle
        startGame()
    }
}
