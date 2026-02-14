import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var viewModel = ReadingViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isReading {
                    ReadingView(viewModel: viewModel)
                } else {
                    InputView(viewModel: viewModel)
                }
            }
            .navigationTitle("Fast Reader")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Input View

struct InputView: View {
    @ObservedObject var viewModel: ReadingViewModel
    @State private var inputText = ""
    @State private var showURLAlert = false
    @State private var urlString = ""
    @State private var showFilePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                textInputSection
                speedSection
                actionButtons
            }
            .padding()
        }
        .overlay { if viewModel.isLoading { loadingOverlay } }
        .alert("Enter URL", isPresented: $showURLAlert) {
            TextField("https://example.com/article", text: $urlString)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button("Cancel", role: .cancel) {}
            Button("Load") { viewModel.loadFromURL(urlString) }
        } message: {
            Text("Enter a link to a website, text file, or PDF")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $showFilePicker) {
            DocumentPicker { url in viewModel.loadFromFile(url) }
        }
    }

    // MARK: - Sub-views

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "text.word.spacing")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Fast Reading")
                .font(.largeTitle.bold())
            Text("Paste text, enter a URL, or open a file to start speed-reading word by word.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Text")
                .font(.headline)
            TextEditor(text: $inputText)
                .frame(minHeight: 160)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
        }
    }

    private var speedSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Speed: \(Int(viewModel.wordsPerMinute)) WPM")
                .font(.headline)
            Slider(value: $viewModel.wordsPerMinute, in: 60...1200, step: 30)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.loadText(inputText)
            } label: {
                Label("Start Reading", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            HStack(spacing: 12) {
                Button {
                    urlString = ""
                    showURLAlert = true
                } label: {
                    Label("URL", systemImage: "link")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    showFilePicker = true
                } label: {
                    Label("File", systemImage: "doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Loading content…")
                    .font(.headline)
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Reading View (RSVP Display)

struct ReadingView: View {
    @ObservedObject var viewModel: ReadingViewModel

    var body: some View {
        VStack(spacing: 0) {
            progressSection
            Spacer()
            wordDisplay
            Spacer()
            controlsSection
        }
        .padding()
    }

    private var progressSection: some View {
        VStack(spacing: 6) {
            ProgressView(value: viewModel.progress)
                .tint(viewModel.progress >= 1.0 ? .green : .accentColor)
            Text("\(viewModel.displayWordIndex) / \(viewModel.totalWords)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }

    private var wordDisplay: some View {
        Text(viewModel.currentWord)
            .font(.system(size: 52, weight: .bold, design: .rounded))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .frame(maxWidth: .infinity, minHeight: 80)
            .multilineTextAlignment(.center)
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.08), value: viewModel.currentWord)
    }

    private var controlsSection: some View {
        VStack(spacing: 20) {
            playbackButtons
            speedSlider
            actionRow
        }
    }

    private var playbackButtons: some View {
        HStack(spacing: 32) {
            Button { viewModel.previousWord() } label: {
                Image(systemName: "backward.fill")
                    .font(.title2)
            }
            .disabled(viewModel.currentWordIndex == 0)

            Button { viewModel.togglePlayPause() } label: {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 56))
            }

            Button { viewModel.nextWord() } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
            }
            .disabled(viewModel.progress >= 1.0)
        }
    }

    private var speedSlider: some View {
        VStack(spacing: 2) {
            Text("\(Int(viewModel.wordsPerMinute)) WPM")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            Slider(value: $viewModel.wordsPerMinute, in: 60...1200, step: 30)
        }
    }

    private var actionRow: some View {
        HStack(spacing: 16) {
            Button(role: .destructive) { viewModel.stopReading() } label: {
                Label("Stop", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button { viewModel.restartReading() } label: {
                Label("Restart", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Document Picker (UIKit bridge)

struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let types: [UTType] = [.pdf, .plainText, .text, .utf8PlainText]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
