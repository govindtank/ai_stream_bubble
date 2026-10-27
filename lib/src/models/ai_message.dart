import 'package:flutter/foundation.dart';

/// The role of the participant in the AI conversation.
enum AiRole {
  user,
  assistant,
  system,
}

/// The streaming status of an AI message.
enum AiStreamStatus {
  idle,
  streaming,
  completed,
  error,
}

/// The execution state of a tool or function call.
enum AiToolStatus {
  calling,
  running,
  success,
  error,
}

/// Represents a tool call executed or suggested by the AI model.
@immutable
class AiToolCall {
  const AiToolCall({
    required this.id,
    required this.name,
    this.arguments = const {},
    this.result,
    this.status = AiToolStatus.success,
    this.errorMessage,
  });

  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  final String? result;
  final AiToolStatus status;
  final String? errorMessage;

  AiToolCall copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? arguments,
    String? result,
    AiToolStatus? status,
    String? errorMessage,
  }) {
    return AiToolCall(
      id: id ?? this.id,
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      result: result ?? this.result,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiToolCall &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          mapEquals(arguments, other.arguments) &&
          result == other.result &&
          status == other.status &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        Object.hashAll(arguments.entries),
        result,
        status,
        errorMessage,
      );
}

/// Data representation of an AI chat message with streaming, reasoning, and tool calls.
@immutable
class AiMessage {
  const AiMessage({
    required this.id,
    required this.role,
    this.content = '',
    this.reasoningContent,
    this.toolCalls = const [],
    this.status = AiStreamStatus.idle,
    this.thinkingDuration,
    this.errorMessage,
    this.createdAt,
  });

  final String id;
  final AiRole role;
  final String content;
  final String? reasoningContent;
  final List<AiToolCall> toolCalls;
  final AiStreamStatus status;
  final Duration? thinkingDuration;
  final String? errorMessage;
  final DateTime? createdAt;

  DateTime get timestamp => createdAt ?? DateTime.now();

  bool get isUser => role == AiRole.user;
  bool get isAssistant => role == AiRole.assistant;
  bool get isSystem => role == AiRole.system;
  bool get isStreaming => status == AiStreamStatus.streaming;
  bool get hasReasoning =>
      reasoningContent != null && reasoningContent!.trim().isNotEmpty;
  bool get hasTools => toolCalls.isNotEmpty;

  AiMessage copyWith({
    String? id,
    AiRole? role,
    String? content,
    String? reasoningContent,
    List<AiToolCall>? toolCalls,
    AiStreamStatus? status,
    Duration? thinkingDuration,
    String? errorMessage,
    DateTime? createdAt,
  }) {
    return AiMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      reasoningContent: reasoningContent ?? this.reasoningContent,
      toolCalls: toolCalls ?? this.toolCalls,
      status: status ?? this.status,
      thinkingDuration: thinkingDuration ?? this.thinkingDuration,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Parses a raw LLM text stream chunk that may include `<think>...</think>` tags
  /// (as emitted by DeepSeek-R1, Qwen-Thinking, and similar reasoning models).
  static ({String reasoning, String content}) extractReasoning(String rawText) {
    const thinkStart = '<think>';
    const thinkEnd = '</think>';

    if (!rawText.contains(thinkStart)) {
      return (reasoning: '', content: rawText);
    }

    final startIndex = rawText.indexOf(thinkStart);
    final prefix = rawText.substring(0, startIndex);
    final afterStart = rawText.substring(startIndex + thinkStart.length);

    if (afterStart.contains(thinkEnd)) {
      final endIndex = afterStart.indexOf(thinkEnd);
      final reasoning = afterStart.substring(0, endIndex).trim();
      final suffix = afterStart.substring(endIndex + thinkEnd.length).trim();
      final finalContent =
          prefix.isNotEmpty ? '$prefix\n$suffix'.trim() : suffix;
      return (reasoning: reasoning, content: finalContent);
    } else {
      // In active streaming mode, <think> is opened but not yet closed
      return (reasoning: afterStart.trim(), content: prefix.trim());
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          role == other.role &&
          content == other.content &&
          reasoningContent == other.reasoningContent &&
          listEquals(toolCalls, other.toolCalls) &&
          status == other.status &&
          thinkingDuration == other.thinkingDuration &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
        id,
        role,
        content,
        reasoningContent,
        Object.hashAll(toolCalls),
        status,
        thinkingDuration,
        errorMessage,
      );
}
