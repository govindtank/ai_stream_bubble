import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_stream_bubble/ai_stream_bubble.dart';

void main() {
  group('AiMessage parsing and models', () {
    test('extractReasoning cleanly splits completed <think> block', () {
      const raw = '<think>I should calculate 2 + 2 = 4</think>The answer is 4.';
      final parsed = AiMessage.extractReasoning(raw);
      expect(parsed.reasoning, equals('I should calculate 2 + 2 = 4'));
      expect(parsed.content, equals('The answer is 4.'));
    });

    test('extractReasoning handles active streaming unclosed <think> block',
        () {
      const raw = '<think>Generating candidate plan';
      final parsed = AiMessage.extractReasoning(raw);
      expect(parsed.reasoning, equals('Generating candidate plan'));
      expect(parsed.content, isEmpty);
    });

    test('extractReasoning returns raw content when no <think> tag is present',
        () {
      const raw = 'Hello world from AI model.';
      final parsed = AiMessage.extractReasoning(raw);
      expect(parsed.reasoning, isEmpty);
      expect(parsed.content, equals('Hello world from AI model.'));
    });

    test('AiMessage copyWith preserves or overrides fields', () {
      const msg = AiMessage(
        id: 'msg_1',
        role: AiRole.assistant,
        content: 'Initial',
        status: AiStreamStatus.streaming,
      );

      final updated = msg.copyWith(
        content: 'Final',
        status: AiStreamStatus.completed,
      );

      expect(updated.id, equals('msg_1'));
      expect(updated.role, equals(AiRole.assistant));
      expect(updated.content, equals('Final'));
      expect(updated.status, equals(AiStreamStatus.completed));
      expect(updated.isStreaming, isFalse);
    });
  });

  group('AiBubbleTheme presets', () {
    test('all theme presets instantiate valid non-null color palettes', () {
      final dark = AiBubbleTheme.dark();
      final light = AiBubbleTheme.light();
      final claude = AiBubbleTheme.claudeWarm();
      final cyberpunk = AiBubbleTheme.cyberpunk();

      expect(dark.userBubbleColor, isNotNull);
      expect(light.userBubbleColor, isNotNull);
      expect(claude.userBubbleColor, isNotNull);
      expect(cyberpunk.userBubbleColor, isNotNull);
    });
  });

  group('AiStreamBubble Widget Tests', () {
    testWidgets('renders user message properly', (tester) async {
      const userMessage = AiMessage(
        id: 'user_1',
        role: AiRole.user,
        content: 'Write a Python function to sort an array.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiStreamBubble(message: userMessage),
          ),
        ),
      );

      expect(find.text('Write a Python function to sort an array.'),
          findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders assistant message with reasoning accordion',
        (tester) async {
      const assistantMessage = AiMessage(
        id: 'asst_1',
        role: AiRole.assistant,
        reasoningContent: 'Analyzing quicksort vs timsort time complexities.',
        content: 'Here is the Python implementation.',
        status: AiStreamStatus.completed,
        thinkingDuration: Duration(milliseconds: 1500),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiStreamBubble(message: assistantMessage),
          ),
        ),
      );

      expect(find.textContaining('Thought for 1.5s'), findsOneWidget);
      expect(find.text('Here is the Python implementation.'), findsOneWidget);
    });

    testWidgets('renders code block artifact card with language tag',
        (tester) async {
      const codeMessage = AiMessage(
        id: 'asst_2',
        role: AiRole.assistant,
        content: '```python\ndef add(a, b):\n    return a + b\n```',
        status: AiStreamStatus.completed,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiStreamBubble(message: codeMessage),
          ),
        ),
      );

      expect(find.text('PYTHON'), findsOneWidget);
      expect(find.textContaining('def add(a, b):'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('renders tool call chip with status', (tester) async {
      const toolMessage = AiMessage(
        id: 'asst_3',
        role: AiRole.assistant,
        content: 'Results found.',
        toolCalls: [
          AiToolCall(
            id: 'call_1',
            name: 'web_search',
            arguments: {'query': 'Flutter AI chat UI'},
            result: '{"results": 5}',
            status: AiToolStatus.success,
          ),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiStreamBubble(message: toolMessage),
          ),
        ),
      );

      expect(find.text('web_search'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });

  group('AiStreamScrollController', () {
    test('tracks tokens and maintains bottom lock', () {
      final controller = AiStreamScrollController();
      expect(controller.isAtBottom.value, isTrue);
      expect(controller.unreadTokensCount.value, equals(0));

      controller.dispose();
    });
  });
}
