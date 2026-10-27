# ai_stream_bubble

<p align="center">
  <a href="https://pub.dev/packages/ai_stream_bubble"><img src="https://img.shields.io/pub/v/ai_stream_bubble.svg?style=flat-square&color=blue" alt="Pub Version"></a>
  <a href="https://pub.dev/packages/ai_stream_bubble/score"><img src="https://img.shields.io/pub/points/ai_stream_bubble?style=flat-square&color=2E8B57&label=pub%20points" alt="Pub Points"></a>
  <a href="https://govindtank.github.io/ai_stream_bubble/"><img src="https://img.shields.io/badge/Live%20Demo-Try%20In%20Browser-00ff88?style=flat-square&logo=flutter" alt="Live Demo"></a>
  <a href="https://pub.dev/packages/ai_stream_bubble"><img src="https://img.shields.io/pub/likes/ai_stream_bubble?style=flat-square" alt="Pub Likes"></a>
  <a href="https://github.com/govindtank/ai_stream_bubble/actions"><img src="https://github.com/govindtank/ai_stream_bubble/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square" alt="License"></a>
</p>

A high-performance streaming AI message bubble for Flutter. Built specifically for modern Conversational AI (DeepSeek-R1, Claude, ChatGPT, Gemini, Ollama) with **zero-jank token streaming, collapsible reasoning accordions, syntax-highlighted code artifacts, tool-call status chips, and smart auto-scroll locking**.

---

## ⚡ Why `ai_stream_bubble`?

Most Flutter chat packages were designed for human-to-human instant messaging (WhatsApp/Telegram style). When adapted for high-throughput LLM token streaming (40–100+ tokens/sec), they suffer from severe shortcomings:

* 🚫 **Severe AST Re-parsing Jank**: Re-parsing entire markdown strings on every streamed token drops frames and overheats devices.
* 🚫 **No Native Chain-of-Thought**: Modern reasoning models (DeepSeek-R1, Qwen-Thinking, Claude) emit reasoning tokens inside `<think>...</think>`. Standard chat bubbles dump raw thinking tags directly into the UI.
* 🚫 **Viewport Fighting**: While the AI streams, automatic `animateTo(maxScrollExtent)` yanks the screen downward, fighting users who try to scroll up to read earlier paragraphs.
* 🚫 **Clunky Code Blocks**: Code snippets lack line numbers, language badges, and 1-tap copy action cards.

`ai_stream_bubble` fixes this with a purpose-built, 120 FPS pure Flutter architecture.

---

## 🚀 Features

| Feature | Description |
|---|---|
| **⚡ Zero-Jank Token Streaming** | Incremental token append pipeline without full-text re-parsing or layout churn. |
| **🧠 DeepSeek Reasoning Accordion** | Expandable `<think>` block with real-time thinking stopwatch (`Thought for 2.3s`), brain icon, and collapsible body. |
| **💻 Code Artifact Cards** | Syntax-tinted code blocks with language badges, line numbers gutter, and 1-tap copy with haptic confirmation. |
| **🛠️ Tool-Call Status Chips** | Status indicators for AI agent function calls (`calling`, `running`, `success`, `error`) with expandable JSON arguments and output viewer. |
| **🎯 Smart Scroll Lock** | Unlocks viewport when user manually scrolls up, displays a floating "Scroll to bottom" button with an unread token counter. |
| **🎨 4 Modern Design Presets** | `dark` (ChatGPT aesthetic), `light`, `claudeWarm` (iconic terracotta), and `cyberpunk` (neon glow). |
| **🌐 Multi-Platform** | 100% pure Dart & Flutter with zero platform channels. Runs flawlessly on iOS, Android, Web, macOS, Windows, and Linux. |

---

## 📦 Installation

Add `ai_stream_bubble` to your `pubspec.yaml`:

```bash
flutter pub add ai_stream_bubble
```

---

## 💡 Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:ai_stream_bubble/ai_stream_bubble.dart';

class MyAiChatScreen extends StatelessWidget {
  const MyAiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const assistantMessage = AiMessage(
      id: 'msg_1',
      role: AiRole.assistant,
      reasoningContent: 'Analyzing asymptotic time complexity of Quicksort.',
      thinkingDuration: Duration(milliseconds: 1450),
      status: AiStreamStatus.completed,
      content: '''
Here is how you implement Quicksort in Dart:

```dart
List<int> quicksort(List<int> list) {
  if (list.length <= 1) return list;
  final pivot = list[list.length ~/ 2];
  return [
    ...quicksort(list.where((x) => x < pivot).toList()),
    ...list.where((x) => x == pivot),
    ...quicksort(list.where((x) => x > pivot).toList()),
  ];
}
```
''',
    );

    return Scaffold(
      backgroundColor: const Color(0xFF131315),
      body: Center(
        child: AiStreamBubble(
          message: assistantMessage,
          theme: AiBubbleTheme.dark(),
          onCopy: () => debugPrint('Message copied!'),
          onLike: (liked) => debugPrint('Feedback: $liked'),
        ),
      ),
    );
  }
}
```

---

## 🧠 Handling DeepSeek `<think>` Streams

When streaming from models like DeepSeek-R1 or Qwen-2.5-Coder that emit `<think>` tags, use `AiMessage.extractReasoning`:

```dart
final rawStreamText = '<think>Considering binary search vs interpolation search</think>The optimal choice is binary search.';

final parsed = AiMessage.extractReasoning(rawStreamText);
// parsed.reasoning => "Considering binary search vs interpolation search"
// parsed.content   => "The optimal choice is binary search."

final message = AiMessage(
  id: 'stream_1',
  role: AiRole.assistant,
  reasoningContent: parsed.reasoning,
  content: parsed.content,
  status: AiStreamStatus.streaming,
);
```

---

## 🛠️ Displaying Agent Tool Calls

```dart
final toolCall = AiToolCall(
  id: 'call_search',
  name: 'web_search',
  arguments: {'query': 'Flutter AI chat UI', 'max_results': 3},
  status: AiToolStatus.success,
  result: '{"results": ["ai_stream_bubble pub.dev", "flutter.dev"]}',
);

final message = AiMessage(
  id: 'tool_msg_1',
  role: AiRole.assistant,
  toolCalls: [toolCall],
  content: 'I verified the current pub.dev trends.',
);
```

---

## 📜 Smart Auto-Scroll Controller

```dart
final scrollController = AiStreamScrollController();

// When a token arrives from WebSocket or HTTP SSE stream:
scrollController.onTokenStreamed(tokenDelta: 1);

// Inside your Scaffold:
Stack(
  children: [
    ListView.builder(
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) => AiStreamBubble(message: messages[index]),
    ),
    Positioned(
      right: 16,
      bottom: 16,
      child: AiScrollToBottomButton(
        controller: scrollController,
      ),
    ),
  ],
)
```

---

## 🎨 Design Presets

Switch palettes instantly with pre-configured themes:

* `AiBubbleTheme.dark()`: Obsidian dark mode (default).
* `AiBubbleTheme.light()`: Clean modern light mode.
* `AiBubbleTheme.claudeWarm()`: Claude's parchment and terracotta tones.
* `AiBubbleTheme.cyberpunk()`: Neon purple and cyan accents.

---

## 🔗 Related Packages by Author

* **[ai_voice_orb](https://pub.dev/packages/ai_voice_orb)** — Fluid neural voice orb for Conversational AI, Gemini Live & Siri style voice agents.
* **[spatial_card](https://pub.dev/packages/spatial_card)** — High-performance 3D tactile interactive cards & parallax surfaces.
* **[waveform_pro](https://pub.dev/packages/waveform_pro)** — GPU-accelerated audio waveform scrubbing & peak visualizer.
* **[ambient_backdrop_glow](https://pub.dev/packages/ambient_backdrop_glow)** — Dynamic background glow & fluid mesh gradients with OKLab color blending.

---

## 💖 Support the Project

If you find this project useful, consider supporting its active maintenance and future development:

<p align="left">
  <a href="https://buymeacoffee.com/govindtanko"><img src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee" /></a>
  <a href="https://github.com/sponsors/govindtank"><img src="https://img.shields.io/badge/GitHub%20Sponsors-EA4AAA?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Sponsors" /></a>
  <a href="https://www.patreon.com/govindtank"><img src="https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white" alt="Patreon" /></a>
</p>

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

*Maintained with ❤️ by [Govind Tank](https://github.com/govindtank).*
