import Foundation
import AVFoundation

final class WhisperBridge: NSObject {
	private var audioEngine: AVAudioEngine?
	private let recognitionQueue = DispatchQueue(label: "whisper.recognition.queue")

	func startRecording(to fileURL: URL) throws {
		let engine = AVAudioEngine()
		let input = engine.inputNode
		let format = input.outputFormat(forBus: 0)
		let file = try AVAudioFile(forWriting: fileURL, settings: format.settings)
		input.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, _ in
			try? file.write(from: buffer)
		}
		engine.prepare()
		try engine.start()
		self.audioEngine = engine
	}

	func stopRecording() {
		audioEngine?.stop()
		audioEngine?.inputNode.removeTap(onBus: 0)
		audioEngine = nil
	}

	func transcribe(fileURL: URL, modelPath: URL) async throws -> String {
		// Placeholder: integrate whisper.cpp via FFIs or a C wrapper
		// For demonstration, return a mock transcription
		return "Transcribed text (offline, mock)."
	}
}