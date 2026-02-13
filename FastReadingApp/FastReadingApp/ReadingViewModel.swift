import Foundation
import Combine

class ReadingViewModel: ObservableObject {
    @Published var currentWord: String = ""
    @Published var currentWordIndex: Int = 0
    @Published var totalWords: Int = 0
    @Published var isReading: Bool = false
    @Published var isPlaying: Bool = false
    @Published var wordsPerMinute: Double = 300
    @Published var progress: Float = 0.0
    
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
        guard let url = URL(string: urlString) else { return }
        
        // Simple URL loading - for real implementation, would need better error handling
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  let text = String(data: data, encoding: .utf8) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.loadText(text)
            }
        }.resume()
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
