# GenZCompanion (Private AI, Offline-First)

- iPhone-only MVP (iOS 17+), SwiftUI, StoreKit 2 subscriptions
- 100% offline processing after on-device model downloads
- Free tier: 10 summaries/month; Pro: Unlimited + advanced features

## Features (MVP)
- Voice → Transcript (Whisper) → 3–5 bullet summary + action items
- PDF Summarizer + offline Q&A
- Text Rewriter (Formal, Simple, Funny, Emoji)

## Project Layout
- `App/` entry, tabs, Info.plist
- `Core/AI/` summarizer, rewriter, QA, model manager
- `Core/PDF/` PDF text extraction + summary/Q&A
- `Core/Store/` StoreKit 2 + entitlements
- `Features/` SwiftUI screens for Voice, PDF, Rewrite, Upgrade
- `Tests/` offline workflow tests

## Model Preparation

### Whisper.cpp (speech-to-text)
- Recommended: `small` or `base` models quantized (q5_1 or q4_1)
- Build whisper.cpp iOS static library, expose C wrapper:
```bash
# Example (from whisper.cpp repo)
./models/download-ggml-model.sh small.en
# Build iOS static lib
make ios
```
- Integrate via Swift bridging header and expose:
```c
// whisper_bridge.h
int whisper_transcribe_file(const char* model_path, const char* audio_path, char* out_buffer, int out_max_len);
```
- In `WhisperBridge.transcribe`, call the C function on background queue, return transcript string.

### LLM Summarizer/Rewriter (CoreML or MLX)
- Start with small models: Phi-3-mini, DistilGPT2-like, or Llama-3 8B (int4) for A17 Pro
- Convert → CoreML or run via MLX for Apple Silicon architectures

CoreML conversion (example with Python):
```python
from coremltools.converters import convert
# Use `transformers` + `coremltools`, quantize weights to INT8/INT4 if supported
```

MLX approach (on-device):
- Use `mlx-lm` tooling to quantize and run LLMs efficiently on Apple GPUs/NPUs.
- For iOS, package a minimal runtime or leverage CoreML compiled models for App Store compliance.

### Quantization
- Prefer INT4/INT8 weight quantization
- Target < 5s latency for short prompts on A17 Pro
- Keep app bundle < 250MB: ship minimal app, download models on-demand to Application Support

## On-Demand Model Management
- Use `ModelManager.ensureInstalled(_:)`
- Bundle the tiniest fallback models; download larger variants post-install (BackgroundTasks when connected to power/Wi‑Fi)

## Battery & Performance
- Run inference in short bursts and off main thread
- Measure using `os_signpost` and Instruments (Time Profiler, Energy Log)
- Use `AVAudioEngine` taps only while recording

## Subscription (StoreKit 2)
- Product id: `genzcompanion.pro.monthly`
- Entitlement gating in `EntitlementGating` with free monthly counter reset

## Testing & Benchmarking (iPhone 15 Pro)
- Build Release, run on device
- Benchmark:
  - Whisper small.en.q5 → ~1–2x realtime for short notes (<60s)
  - Summarizer small LLM int4 → <3s for 512 tokens
- Add UI tests for record/summarize and PDF import flows offline (Airplane mode)

## Roadmap
- Phase 2: OCR (VisionKit), Tutor Mode, Journal + Mood
- Phase 3: Keyboard extension, Chat summarizer, Finance insights