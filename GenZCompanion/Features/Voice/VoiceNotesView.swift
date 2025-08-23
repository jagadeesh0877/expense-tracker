import SwiftUI

struct VoiceNotesView: View {
	@State private var isRecording = false
	@State private var transcript: String = ""
	@State private var summary: [String] = []
	@State private var actionItems: [String] = []
	@State private var isProcessing = false

	private let whisper = WhisperBridge()
	private let summarizer: SummarizerServiceProtocol = SummarizerService()

	var body: some View {
		NavigationView {
			ScrollView {
				VStack(spacing: 16) {
					ZStack {
						Circle()
							.fill(AppTheme.gradient)
							.frame(width: 160, height: 160)
							.shadow(radius: 12)
						Button(action: toggleRecording) {
							Image(systemName: isRecording ? "stop.fill" : "mic.fill")
								.font(.system(size: 56))
								.foregroundStyle(.white)
						}
					}

					if !transcript.isEmpty {
						SectionHeader(title: "Transcript")
						Text(transcript).textSelection(.enabled)
					}

					if !summary.isEmpty {
						SectionHeader(title: "Summary")
						VStack(alignment: .leading, spacing: 8) {
							ForEach(summary, id: \.self) { s in Text("• \(s)") }
						}
					}

					if !actionItems.isEmpty {
						SectionHeader(title: "Action Items")
						VStack(alignment: .leading, spacing: 8) {
							ForEach(actionItems, id: \.self) { s in Text("• \(s)") }
						}
					}
				}
				.padding()
			}
			.navigationTitle("Voice → Notes")
		}
	}

	private func toggleRecording() {
		if isRecording { stop() } else { start() }
	}

	private func start() {
		isRecording = true
		let url = FileManager.default.temporaryDirectory.appendingPathComponent("voice.m4a")
		try? FileManager.default.removeItem(at: url)
		try? whisper.startRecording(to: url)
	}

	private func stop() {
		isRecording = false
		whisper.stopRecording()
		Task { await processTranscription() }
	}

	private func processTranscription() async {
		isProcessing = true
		defer { isProcessing = false }
		let audioURL = FileManager.default.temporaryDirectory.appendingPathComponent("voice.m4a")
		do {
			let modelURL = URL(fileURLWithPath: "") // filled when bundled or downloaded
			let t = try await whisper.transcribe(fileURL: audioURL, modelPath: modelURL)
			await MainActor.run {
				transcript = t
			}
			let s = try await summarizer.summarize(t, maxBullets: 5)
			let a = summarizer.detectActionItems(t)
			await MainActor.run {
				summary = s
				actionItems = a
			}
		} catch {
			await MainActor.run { transcript = "Transcription failed: \(error.localizedDescription)" }
		}
	}
}

private struct SectionHeader: View {
	let title: String
	var body: some View {
		HStack {
			Text(title).font(.headline)
			Spacer()
		}
	}
}