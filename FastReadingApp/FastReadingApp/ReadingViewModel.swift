import Foundation
import Combine

@MainActor
final class ReadingViewModel: ObservableObject {

    // MARK: - Published state

    @Published var currentWord: String = ""
    @Published var currentWordIndex: Int = 0
    @Published var totalWords: Int = 0
    @Published var isReading: Bool = false
    @Published var isPlaying: Bool = false
    @Published var isLoading: Bool = false
    @Published var wordsPerMinute: Double = 300 {
        didSet { if isPlaying { startAutoPlay() } }
    }
    @Published var progress: Float = 0.0
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false

    var displayWordIndex: Int { min(currentWordIndex + 1, totalWords) }

    // MARK: - Private

    private var reader: RustTextReader?
    private var timer: Timer?

    // MARK: - Loading content

    /// Load plain text directly.
    func loadText(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showErrorMessage("No text to read.")
            return
        }
        reader = RustTextReader(text: text)
        guard let r = reader else {
            showErrorMessage("Failed to initialise reader.")
            return
        }
        totalWords = r.wordCount
        guard totalWords > 0 else {
            showErrorMessage("The content has no readable words.")
            reader = nil
            return
        }
        currentWordIndex = 0
        currentWord = r.currentWord ?? ""
        progress = r.progress
        isReading = true
        isPlaying = false
    }

    /// Fetch a URL and auto-detect content type (website / text file / PDF).
    func loadFromURL(_ urlString: String) {
        var normalized = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !normalized.lowercased().hasPrefix("http://") && !normalized.lowercased().hasPrefix("https://") {
            normalized = "https://\(normalized)"
        }
        guard let url = URL(string: normalized) else {
            showErrorMessage("Invalid URL format.")
            return
        }
        isLoading = true

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false

                if let error {
                    self.showErrorMessage("Network error: \(error.localizedDescription)")
                    return
                }
                guard let data, !data.isEmpty else {
                    self.showErrorMessage("No data received from URL.")
                    return
                }

                let contentType = detectContentType(from: response, url: url)
                let text: String?

                switch contentType {
                case .pdf:
                    text = extractPDFText(from: data)
                    if text == nil { self.showErrorMessage("Could not extract text from PDF."); return }
                case .html, .unknown:
                    text = extractHTMLText(from: data)
                    if text == nil { self.showErrorMessage("Could not extract text from page."); return }
                case .plainText:
                    text = String(data: data, encoding: .utf8)
                    if text == nil { self.showErrorMessage("Could not decode text (encoding error)."); return }
                }

                if let text { self.loadText(text) }
            }
        }.resume()
    }

    /// Load from a local file URL (document picker result).
    func loadFromFile(_ fileURL: URL) {
        let accessing = fileURL.startAccessingSecurityScopedResource()
        defer { if accessing { fileURL.stopAccessingSecurityScopedResource() } }

        guard let data = try? Data(contentsOf: fileURL) else {
            showErrorMessage("Could not read file.")
            return
        }

        let ext = fileURL.pathExtension.lowercased()
        if ext == "pdf" {
            if let text = extractPDFText(from: data) {
                loadText(text)
            } else {
                showErrorMessage("Could not extract text from PDF.")
            }
        } else {
            if let text = String(data: data, encoding: .utf8) {
                loadText(text)
            } else {
                showErrorMessage("Could not read file as text.")
            }
        }
    }

    // MARK: - Playback

    func togglePlayPause() {
        isPlaying.toggle()
        isPlaying ? startAutoPlay() : stopAutoPlay()
    }

    func nextWord() {
        guard let r = reader else { return }
        if let word = r.nextWord() {
            currentWord = word
            currentWordIndex = r.currentIndex
            progress = r.progress
        } else {
            isPlaying = false
            stopAutoPlay()
            progress = 1.0
        }
    }

    func previousWord() {
        guard let r = reader else { return }
        if let word = r.previousWord() {
            currentWord = word
            currentWordIndex = r.currentIndex
            progress = r.progress
        }
    }

    func stopReading() {
        isReading = false
        isPlaying = false
        stopAutoPlay()
        reader = nil
        currentWord = ""
        currentWordIndex = 0
        totalWords = 0
        progress = 0.0
    }

    func restartReading() {
        guard let r = reader else { return }
        r.reset()
        currentWordIndex = 0
        currentWord = r.currentWord ?? ""
        progress = r.progress
        isPlaying = false
        stopAutoPlay()
    }

    // MARK: - Timer

    private func startAutoPlay() {
        stopAutoPlay()
        let interval = 60.0 / wordsPerMinute
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.nextWord() }
        }
    }

    private func stopAutoPlay() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Errors

    private func showErrorMessage(_ msg: String) {
        errorMessage = msg
        showError = true
    }
}
