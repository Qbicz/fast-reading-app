import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ReadingViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.isReading {
                    ReadingView(viewModel: viewModel)
                } else {
                    InputView(viewModel: viewModel)
                }
            }
            .navigationTitle("Fast Reader")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InputView: View {
    @ObservedObject var viewModel: ReadingViewModel
    @State private var inputText = ""
    @State private var showingURLInput = false
    @State private var urlString = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Fast Reading App")
                .font(.largeTitle)
                .padding()
            
            Text("Enter text or paste URL to start reading")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Text input area
            TextEditor(text: $inputText)
                .frame(minHeight: 200)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding()
            
            // Speed control
            VStack(alignment: .leading) {
                Text("Reading Speed: \(Int(viewModel.wordsPerMinute)) WPM")
                    .font(.subheadline)
                Slider(value: $viewModel.wordsPerMinute, in: 100...1000, step: 50)
            }
            .padding()
            
            // Action buttons
            HStack(spacing: 20) {
                Button(action: {
                    showingURLInput.toggle()
                }) {
                    Label("Load URL", systemImage: "link")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    viewModel.loadText(inputText)
                }) {
                    Label("Start Reading", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(inputText.isEmpty)
            }
            .padding()
            
            Spacer()
        }
        .alert("Enter URL", isPresented: $showingURLInput) {
            TextField("https://example.com", text: $urlString)
            Button("Cancel", role: .cancel) { }
            Button("Load") {
                viewModel.loadFromURL(urlString)
            }
        } message: {
            Text("Enter the URL of a text file or webpage")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct ReadingView: View {
    @ObservedObject var viewModel: ReadingViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            // Progress bar
            ProgressView(value: viewModel.progress)
                .padding()
            
            if viewModel.totalWords > 0 {
                Text("\(min(viewModel.currentWordIndex + 1, viewModel.totalWords)) / \(viewModel.totalWords)")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Text("No words to display")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Main word display
            Text(viewModel.currentWord)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 100)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            // Controls
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.previousWord()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                }
                .disabled(viewModel.currentWordIndex == 0)
                
                Button(action: {
                    viewModel.togglePlayPause()
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                }
                
                Button(action: {
                    viewModel.nextWord()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                }
                .disabled(viewModel.currentWordIndex >= viewModel.totalWords - 1)
            }
            .padding()
            
            // Speed control
            VStack {
                Text("Speed: \(Int(viewModel.wordsPerMinute)) WPM")
                    .font(.caption)
                Slider(value: $viewModel.wordsPerMinute, in: 100...1000, step: 50)
                    .padding(.horizontal)
            }
            
            // Stop button
            Button(action: {
                viewModel.stopReading()
            }) {
                Label("Stop", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
