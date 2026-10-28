## 1.1.0

- **Inline Markdown Support**: Full support for inline code tags (`` `code` ``), bold (`**text**`), and italic (`*text*`) without heavyweight AST dependencies.
- **Model Badge & Live Throughput Header**: Displays AI model identity badge (`DeepSeek-R1`, `Claude 3.5 Sonnet`, `GPT-4o`) and real-time generation speed (`⚡ 64 tok/s`).
- **Telemetry Enhancements**: Added `modelName`, `tokenCount`, and `tokensPerSecond` attributes to `AiMessage`.

## 1.0.0

- Initial release of `ai_stream_bubble`.
- **Zero-Jank Token Streaming**: Efficient text chunk parsing and incremental layout updates.
- **DeepSeek/Claude Reasoning Accordion**: Collapsible `<think>` / reasoning accordion block with elapsed thinking duration timer and spark animation.
- **Code Artifact Cards**: Syntax-highlighted code blocks with language labels, line numbers, and copy-to-clipboard button with haptic feedback.
- **Tool-Call Status Chips**: Live status indicators (`calling`, `running`, `success`, `error`) with arguments and expandable output viewer.
- **Smart Auto-Scroll Lock**: Locks scroll viewport when user scrolls up during active streaming, and displays a floating "Scroll to bottom" badge.
- **Theming & Presets**: Dark and light themes (ChatGPT, Claude Warm, Cyberpunk Neon, Minimalist Glass).
