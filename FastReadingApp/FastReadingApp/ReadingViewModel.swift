import Foundation
import Combine

class ReadingViewModel: ObservableObject {
    @Published var currentWord: String = ""
    @Published var currentWordIndex: Int = 0
    @Published var totalWords: Int = 0
    @Published var isReading: Bool = false
    @Published var isPlaying: Bool = false
    @Published var wordsPerMinute: Double = 300 {
        didSet {
            // If playing, restart timer with new speed
            if isPlaying {
                startAutoPlay()
            }
        }
    }
    @Published var progress: Float = 0.0
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    // Computed property for display word index (capped at totalWords)
    var displayWordIndex: Int {
        min(currentWordIndex + 1, totalWords)
    }
    
    private var textReader: TextReader?
    private var timer: Timer?
    
    func loadText(_ text: String) {
        guard !text.isEmpty else { return }
        
        textReader = TextReader(text: text)
        guard let reader = textReader else { return }
        
        totalWords = reader.wordCount
        currentWordIndex = 0
        currentWord = reader.currentWord ?? ""
        progress = reader.progress
        isReading = true
        isPlaying = false
    }
    
    func loadFromURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            showErrorMessage("Invalid URL format")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showErrorMessage("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self?.showErrorMessage("No data received from URL")
                    return
                }
                
                guard let text = String(data: data, encoding: .utf8) else {
                    self?.showErrorMessage("Unable to read text from URL (encoding error)")
                    return
                }
                
                if text.isEmpty {
                    self?.showErrorMessage("URL returned empty content")
                    return
                }
                
                self?.loadText(text)
            }
        }.resume()
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    func togglePlayPause() {
        isPlaying.toggle()
        
        if isPlaying {
            startAutoPlay()
        } else {
            stopAutoPlay()
        }
    }
    
    func nextWord() {
        guard let reader = textReader else { return }
        
        if let word = reader.nextWord() {
            currentWord = word
            currentWordIndex += 1
            progress = reader.progress
        } else {
            // Reached the end
            isPlaying = false
            stopAutoPlay()
        }
    }
    
    func previousWord() {
        guard let reader = textReader else { return }
        
        if let word = reader.previousWord() {
            currentWord = word
            currentWordIndex = max(0, currentWordIndex - 1)
            progress = reader.progress
        }
    }
    
    func stopReading() {
        isReading = false
        isPlaying = false
        stopAutoPlay()
        textReader = nil
        currentWord = ""
        currentWordIndex = 0
        totalWords = 0
        progress = 0.0
    }
    
    private func startAutoPlay() {
        stopAutoPlay() // Clear any existing timer
        
        let interval = 60.0 / wordsPerMinute
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.nextWord()
        }
    }
    
    private func stopAutoPlay() {
        timer?.invalidate()
        timer = nil
    }
}
