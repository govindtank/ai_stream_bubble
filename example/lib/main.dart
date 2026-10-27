import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ai_stream_bubble/ai_stream_bubble.dart';

void main() {
  runApp(const AiStreamBubbleDemoApp());
}

class AiStreamBubbleDemoApp extends StatefulWidget {
  const AiStreamBubbleDemoApp({super.key});

  @override
  State<AiStreamBubbleDemoApp> createState() => _AiStreamBubbleDemoAppState();
}

enum DemoThemeType { dark, light, claude, cyberpunk }

class _AiStreamBubbleDemoAppState extends State<AiStreamBubbleDemoApp> {
  DemoThemeType _selectedTheme = DemoThemeType.dark;

  AiBubbleTheme get _currentBubbleTheme {
    switch (_selectedTheme) {
      case DemoThemeType.dark:
        return AiBubbleTheme.dark();
      case DemoThemeType.light:
        return AiBubbleTheme.light();
      case DemoThemeType.claude:
        return AiBubbleTheme.claudeWarm();
      case DemoThemeType.cyberpunk:
        return AiBubbleTheme.cyberpunk();
    }
  }

  Color get _appScaffoldColor {
    switch (_selectedTheme) {
      case DemoThemeType.dark:
        return const Color(0xFF131315);
      case DemoThemeType.light:
        return const Color(0xFFF9FAFB);
      case DemoThemeType.claude:
        return const Color(0xFFF4EDE4);
      case DemoThemeType.cyberpunk:
        return const Color(0xFF07040D);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ai_stream_bubble — Live Interactive Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _selectedTheme == DemoThemeType.light
            ? Brightness.light
            : Brightness.dark,
        scaffoldBackgroundColor: _appScaffoldColor,
        useMaterial3: true,
      ),
      home: AiStreamBubbleDemoScreen(
        currentTheme: _currentBubbleTheme,
        themeType: _selectedTheme,
        onThemeChanged: (theme) => setState(() => _selectedTheme = theme),
      ),
    );
  }
}

class AiStreamBubbleDemoScreen extends StatefulWidget {
  const AiStreamBubbleDemoScreen({
    super.key,
    required this.currentTheme,
    required this.themeType,
    required this.onThemeChanged,
  });

  final AiBubbleTheme currentTheme;
  final DemoThemeType themeType;
  final ValueChanged<DemoThemeType> onThemeChanged;

  @override
  State<AiStreamBubbleDemoScreen> createState() =>
      _AiStreamBubbleDemoScreenState();
}

class _AiStreamBubbleDemoScreenState extends State<AiStreamBubbleDemoScreen> {
  late final AiStreamScrollController _scrollController;
  final TextEditingController _inputController = TextEditingController();
  final List<AiMessage> _messages = [];
  Timer? _streamTimer;
  bool _isStreaming = false;
  bool _copiedCommand = false;

  @override
  void initState() {
    super.initState();
    _scrollController = AiStreamScrollController();
    _loadInitialConversation();
  }

  void _loadInitialConversation() {
    _messages.addAll([
      const AiMessage(
        id: 'msg_welcome_user',
        role: AiRole.user,
        content: 'Explain how DeepSeek-R1 reasoning works in real-time.',
      ),
      const AiMessage(
        id: 'msg_welcome_asst',
        role: AiRole.assistant,
        reasoningContent:
            '1. Model initiates pure chain-of-thought tokens enclosed inside <think>...</think> tags.\n'
            '2. Evaluates verification criteria, self-corrects potential errors, and tests hypothesis.\n'
            '3. Closes reasoning tags and begins synthesizing clean user-facing solution.',
        thinkingDuration: Duration(milliseconds: 2300),
        status: AiStreamStatus.completed,
        content:
            'DeepSeek-R1 uses **Reinforcement Learning** without human cold-start data. It generates an explicit chain of reasoning before presenting the final answer.\n\n'
            '```python\n'
            '# DeepSeek Token Streaming Consumer\n'
            'async for chunk in client.chat.stream(prompt):\n'
            '    parsed = AiMessage.extractReasoning(chunk.delta)\n'
            '    yield parsed.reasoning, parsed.content\n'
            '```\n'
            'Notice how the reasoning accordion above remains collapsible with instant copy options.',
      ),
    ]);
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _simulateDeepSeekStream() {
    if (_isStreaming) return;
    setState(() => _isStreaming = true);

    const prompt = 'Implement an asynchronous rate limiter in Dart.';
    _messages.add(
      const AiMessage(id: 'stream_user', role: AiRole.user, content: prompt),
    );

    final asstMsgId = 'stream_asst_${DateTime.now().millisecondsSinceEpoch}';
    _messages.add(
      AiMessage(
        id: asstMsgId,
        role: AiRole.assistant,
        reasoningContent:
            'Formulating leaky-bucket vs token-bucket algorithm...',
        content: '',
        status: AiStreamStatus.streaming,
      ),
    );

    final reasoningChunks = [
      'Considering token bucket algorithm for optimal burst traffic handling.\n',
      'Need an async lock to prevent race conditions during concurrent requests.\n',
      'Calculating token replenishment rate based on Duration.\n',
      'Structure looks optimal; producing production Dart implementation.\n',
    ];

    final contentChunks = [
      'Here is a high-performance **Token Bucket Rate Limiter** in Dart:\n\n',
      '```dart\n',
      'import \'dart:async\';\n\n',
      'class TokenBucketLimiter {\n',
      '  TokenBucketLimiter({\n',
      '    required this.capacity,\n',
      '    required this.refillDuration,\n',
      '  }) : _tokens = capacity;\n\n',
      '  final int capacity;\n',
      '  final Duration refillDuration;\n',
      '  int _tokens;\n\n',
      '  Future<bool> acquire() async {\n',
      '    if (_tokens > 0) {\n',
      '      _tokens--;\n',
      '      return true;\n',
      '    }\n',
      '    return false; // Rate limit exceeded\n',
      '  }\n',
      '}\n',
      '```\n\n',
      'This guarantees zero race conditions across asynchronous microtasks.',
    ];

    int reasoningIdx = 0;
    int contentIdx = 0;
    String currentReasoning = '';
    String currentContent = '';

    _streamTimer = Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (reasoningIdx < reasoningChunks.length) {
        currentReasoning += reasoningChunks[reasoningIdx];
        reasoningIdx++;
      } else if (contentIdx < contentChunks.length) {
        currentContent += contentChunks[contentIdx];
        contentIdx++;
      } else {
        timer.cancel();
        setState(() {
          _isStreaming = false;
          final index = _messages.indexWhere((m) => m.id == asstMsgId);
          if (index != -1) {
            _messages[index] = _messages[index].copyWith(
              status: AiStreamStatus.completed,
              thinkingDuration: const Duration(milliseconds: 1800),
            );
          }
        });
        return;
      }

      setState(() {
        final index = _messages.indexWhere((m) => m.id == asstMsgId);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            reasoningContent: currentReasoning,
            content: currentContent,
          );
        }
      });
      _scrollController.onTokenStreamed(tokenDelta: 1);
    });
  }

  void _simulateToolCall() {
    if (_isStreaming) return;

    _messages.add(
      const AiMessage(
        id: 'tool_user',
        role: AiRole.user,
        content: 'Fetch live Flutter market share and pub.dev trends.',
      ),
    );

    final asstId = 'tool_asst_${DateTime.now().millisecondsSinceEpoch}';
    final initialTool = const AiToolCall(
      id: 'tool_1',
      name: 'pub_dev_search',
      arguments: {'query': 'ai streaming chat ui', 'limit': 5},
      status: AiToolStatus.running,
    );

    setState(() {
      _messages.add(
        AiMessage(
          id: asstId,
          role: AiRole.assistant,
          status: AiStreamStatus.streaming,
          toolCalls: [initialTool],
          content: 'Executing search on pub.dev package registry...',
        ),
      );
    });

    _scrollController.scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        final index = _messages.indexWhere((m) => m.id == asstId);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            status: AiStreamStatus.completed,
            toolCalls: [
              initialTool.copyWith(
                status: AiToolStatus.success,
                result:
                    '{"found": 12, "top": "ai_stream_bubble", "score": 160}',
              ),
            ],
            content:
                'Successfully queried the registry. Package **ai_stream_bubble** delivers 100% test coverage with zero-jank token streaming!',
          );
        }
      });
      _scrollController.scrollToBottom();
    });
  }

  void _sendUserMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isStreaming) return;
    _inputController.clear();

    setState(() {
      _messages.add(
        AiMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          role: AiRole.user,
          content: text,
        ),
      );
    });

    _scrollController.scrollToBottom();

    // Auto respond with assistant
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          AiMessage(
            id: 'asst_${DateTime.now().millisecondsSinceEpoch}',
            role: AiRole.assistant,
            content:
                'Echo response to: "$text"\n\n'
                '```json\n'
                '{\n'
                '  "status": "received",\n'
                '  "tokens": ${text.split(" ").length},\n'
                '  "time": "${DateTime.now().toIso8601String()}"\n'
                '}\n'
                '```',
            status: AiStreamStatus.completed,
          ),
        );
      });
      _scrollController.scrollToBottom();
    });
  }

  Future<void> _copyPubCommand() async {
    await Clipboard.setData(
      const ClipboardData(text: 'flutter pub add ai_stream_bubble'),
    );
    HapticFeedback.lightImpact();
    setState(() => _copiedCommand = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedCommand = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF10A37F), size: 20),
            const SizedBox(width: 8),
            const Text(
              'ai_stream_bubble',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF10A37F).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10A37F),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // 1-Tap Copy Install Button
          InkWell(
            onTap: _copyPubCommand,
            borderRadius: BorderRadius.circular(6.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: _copiedCommand
                    ? const Color(0xFF10B981).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  color: _copiedCommand
                      ? const Color(0xFF10B981)
                      : Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _copiedCommand ? Icons.check : Icons.terminal_rounded,
                    size: 14,
                    color: _copiedCommand
                        ? const Color(0xFF10B981)
                        : Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _copiedCommand ? 'Copied pub add!' : 'pub add',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _copiedCommand
                          ? const Color(0xFF10B981)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Theme Dropdown
          DropdownButtonHideUnderline(
            child: DropdownButton<DemoThemeType>(
              value: widget.themeType,
              icon: const Icon(Icons.palette_outlined, size: 18),
              onChanged: (val) {
                if (val != null) widget.onThemeChanged(val);
              },
              items: const [
                DropdownMenuItem(
                  value: DemoThemeType.dark,
                  child: Text('Dark Theme'),
                ),
                DropdownMenuItem(
                  value: DemoThemeType.light,
                  child: Text('Light Theme'),
                ),
                DropdownMenuItem(
                  value: DemoThemeType.claude,
                  child: Text('Claude Warm'),
                ),
                DropdownMenuItem(
                  value: DemoThemeType.cyberpunk,
                  child: Text('Cyberpunk'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Interactive Toolbar with Simulation Scenarios
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: widget.currentTheme.assistantBubbleColor.withValues(
                    alpha: 0.4,
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: widget.currentTheme.reasoningBorderColor
                          .withValues(alpha: 0.25),
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.psychology, size: 16),
                        label: const Text('Stream DeepSeek-R1'),
                        onPressed: _isStreaming
                            ? null
                            : _simulateDeepSeekStream,
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(Icons.extension, size: 16),
                        label: const Text('Tool Execution'),
                        onPressed: _isStreaming ? null : _simulateToolCall,
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Clear Chat'),
                        onPressed: _isStreaming
                            ? null
                            : () => setState(() => _messages.clear()),
                      ),
                    ],
                  ),
                ),
              ),
              // Chat List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return AiStreamBubble(
                      key: ValueKey(message.id),
                      message: message,
                      theme: widget.currentTheme,
                    );
                  },
                ),
              ),
              // User Prompt Input
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: widget.currentTheme.assistantBubbleColor,
                  border: Border(
                    top: BorderSide(
                      color: widget.currentTheme.reasoningBorderColor
                          .withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          decoration: InputDecoration(
                            hintText: 'Type an AI prompt...',
                            hintStyle: TextStyle(
                              color: widget.currentTheme.assistantTextColor
                                  .withValues(alpha: 0.4),
                              fontSize: 14.0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.0),
                              borderSide: BorderSide(
                                color: widget.currentTheme.reasoningBorderColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                          ),
                          onSubmitted: (_) => _sendUserMessage(),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      IconButton(
                        onPressed: _isStreaming ? null : _sendUserMessage,
                        icon: const Icon(Icons.arrow_upward_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: widget.currentTheme.cursorColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Floating Scroll to Bottom Button
          Positioned(
            right: 16.0,
            bottom: 74.0,
            child: AiScrollToBottomButton(
              controller: _scrollController,
              badgeColor: widget.currentTheme.cursorColor,
            ),
          ),
        ],
      ),
    );
  }
}
