import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ai_message.dart';
import '../theme/ai_bubble_theme.dart';
import 'ai_code_artifact_card.dart';
import 'ai_reasoning_accordion.dart';
import 'ai_streaming_cursor.dart';
import 'ai_tool_call_chip.dart';

/// Primary AI message bubble widget supporting high-throughput token streaming,
/// collapsible reasoning accordions, code artifacts, tool calls, and action buttons.
class AiStreamBubble extends StatefulWidget {
  const AiStreamBubble({
    super.key,
    required this.message,
    this.theme,
    this.avatar,
    this.showAvatar = true,
    this.showActions = true,
    this.showLineNumbersInCode = true,
    this.onCopy,
    this.onRegenerate,
    this.onLike,
    this.onDislike,
    this.onToolCallTap,
  });

  final AiMessage message;
  final AiBubbleTheme? theme;
  final Widget? avatar;
  final bool showAvatar;
  final bool showActions;
  final bool showLineNumbersInCode;
  final VoidCallback? onCopy;
  final VoidCallback? onRegenerate;
  final ValueChanged<bool>? onLike;
  final ValueChanged<bool>? onDislike;
  final ValueChanged<AiToolCall>? onToolCallTap;

  @override
  State<AiStreamBubble> createState() => _AiStreamBubbleState();
}

class _AiStreamBubbleState extends State<AiStreamBubble> {
  bool? _liked;
  bool _copied = false;

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.message.content));
    HapticFeedback.selectionClick();
    if (mounted) {
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _copied = false);
      });
    }
    widget.onCopy?.call();
  }

  Widget _buildAvatar(AiBubbleTheme activeTheme) {
    if (widget.avatar != null) return widget.avatar!;

    if (widget.message.isUser) {
      return CircleAvatar(
        radius: 14.0,
        backgroundColor: activeTheme.userBubbleColor.withValues(alpha: 0.8),
        child: const Icon(Icons.person, size: 16.0, color: Colors.white),
      );
    } else {
      return CircleAvatar(
        radius: 14.0,
        backgroundColor: activeTheme.cursorColor.withValues(alpha: 0.15),
        child: Icon(Icons.auto_awesome,
            size: 15.0, color: activeTheme.cursorColor),
      );
    }
  }

  /// Parses text into text paragraphs and code artifact blocks
  List<Widget> _buildContentBlocks(AiBubbleTheme activeTheme) {
    final text = widget.message.content;
    if (text.isEmpty && !widget.message.isStreaming) {
      return const [];
    }

    final blocks = <Widget>[];
    final codeBlockRegex = RegExp(r'```([a-zA-Z0-9_\-\+]*)\n([\s\S]*?)```');
    int lastEnd = 0;

    for (final match in codeBlockRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        final plain = text.substring(lastEnd, match.start).trim();
        if (plain.isNotEmpty) {
          blocks.add(_buildPlainText(plain, activeTheme));
        }
      }

      final lang = match.group(1)?.trim();
      final code = match.group(2) ?? '';
      blocks.add(
        AiCodeArtifactCard(
          language: (lang == null || lang.isEmpty) ? 'code' : lang,
          code: code,
          theme: activeTheme,
          showLineNumbers: widget.showLineNumbersInCode,
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      final remaining = text.substring(lastEnd);
      // Check if there is an unclosed code block during active streaming
      if (widget.message.isStreaming && remaining.contains('```')) {
        final parts = remaining.split('```');
        if (parts.first.trim().isNotEmpty) {
          blocks.add(_buildPlainText(parts.first.trim(), activeTheme));
        }
        final afterBackticks = parts.sublist(1).join('```');
        final firstNewline = afterBackticks.indexOf('\n');
        final lang = firstNewline != -1
            ? afterBackticks.substring(0, firstNewline).trim()
            : 'code';
        final codePart = firstNewline != -1
            ? afterBackticks.substring(firstNewline + 1)
            : '';
        blocks.add(
          AiCodeArtifactCard(
            language: lang.isEmpty ? 'code' : lang,
            code: codePart,
            theme: activeTheme,
            showLineNumbers: widget.showLineNumbersInCode,
          ),
        );
      } else {
        blocks.add(_buildPlainText(remaining, activeTheme,
            appendCursor: widget.message.isStreaming));
      }
    } else if (widget.message.isStreaming) {
      // Append streaming cursor at end if needed
      blocks.add(
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: AiStreamingCursor(color: activeTheme.cursorColor),
        ),
      );
    }

    return blocks;
  }

  Widget _buildPlainText(String text, AiBubbleTheme activeTheme,
      {bool appendCursor = false}) {
    final textColor = widget.message.isUser
        ? activeTheme.userTextColor
        : activeTheme.assistantTextColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: SelectableText(
              text,
              style: TextStyle(
                fontSize: 14.0,
                height: 1.5,
                color: textColor,
                fontFamily: activeTheme.fontFamily,
              ),
            ),
          ),
          if (appendCursor) AiStreamingCursor(color: activeTheme.cursorColor),
        ],
      ),
    );
  }

  Widget _buildActions(AiBubbleTheme activeTheme) {
    if (!widget.showActions ||
        widget.message.isUser ||
        widget.message.isStreaming) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Copy Button
          InkWell(
            onTap: _handleCopy,
            borderRadius: BorderRadius.circular(4.0),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                _copied ? Icons.check : Icons.copy_rounded,
                size: 15.0,
                color: _copied
                    ? const Color(0xFF10B981)
                    : activeTheme.actionIconColor,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          // Like Button
          InkWell(
            onTap: () {
              setState(() {
                _liked = (_liked == true) ? null : true;
              });
              widget.onLike?.call(_liked == true);
            },
            borderRadius: BorderRadius.circular(4.0),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                _liked == true
                    ? Icons.thumb_up_alt_rounded
                    : Icons.thumb_up_alt_outlined,
                size: 15.0,
                color: _liked == true
                    ? const Color(0xFF10B981)
                    : activeTheme.actionIconColor,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          // Dislike Button
          InkWell(
            onTap: () {
              setState(() {
                _liked = (_liked == false) ? null : false;
              });
              widget.onDislike?.call(_liked == false);
            },
            borderRadius: BorderRadius.circular(4.0),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                _liked == false
                    ? Icons.thumb_down_alt_rounded
                    : Icons.thumb_down_alt_outlined,
                size: 15.0,
                color: _liked == false
                    ? const Color(0xFFEF4444)
                    : activeTheme.actionIconColor,
              ),
            ),
          ),
          if (widget.onRegenerate != null) ...[
            const SizedBox(width: 8.0),
            InkWell(
              onTap: widget.onRegenerate,
              borderRadius: BorderRadius.circular(4.0),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.refresh_rounded,
                  size: 16.0,
                  color: activeTheme.actionIconColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = widget.theme ??
        (Theme.of(context).brightness == Brightness.dark
            ? AiBubbleTheme.dark()
            : AiBubbleTheme.light());

    final isUser = widget.message.isUser;
    final bubbleColor =
        isUser ? activeTheme.userBubbleColor : activeTheme.assistantBubbleColor;
    final defaultBorderRadius = BorderRadius.circular(activeTheme.borderRadius);
    final borderRadius = isUser
        ? (activeTheme.userBorderRadius ?? defaultBorderRadius)
        : (activeTheme.assistantBorderRadius ?? defaultBorderRadius);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && widget.showAvatar) ...[
            _buildAvatar(activeTheme),
            const SizedBox(width: 10.0),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Material(
                  color: bubbleColor,
                  elevation: isUser
                      ? activeTheme.userElevation
                      : activeTheme.assistantElevation,
                  borderRadius: borderRadius,
                  child: Container(
                    padding: activeTheme.padding,
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      border: Border.all(
                        color: isUser
                            ? activeTheme.userBubbleColor
                            : activeTheme.reasoningBorderColor
                                .withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Collapsible Reasoning Accordion (DeepSeek/Claude thinking)
                        if (widget.message.hasReasoning)
                          AiReasoningAccordion(
                            reasoning: widget.message.reasoningContent!,
                            theme: activeTheme,
                            isStreaming: widget.message.isStreaming,
                            thinkingDuration: widget.message.thinkingDuration,
                          ),
                        // 2. Tool Calls
                        if (widget.message.hasTools)
                          ...widget.message.toolCalls.map(
                            (tool) => AiToolCallChip(
                              toolCall: tool,
                              theme: activeTheme,
                              onTap: () => widget.onToolCallTap?.call(tool),
                            ),
                          ),
                        // 3. Message Body (Text + Code Artifacts + Streaming Cursor)
                        ..._buildContentBlocks(activeTheme),
                        // 4. Error Message Banner
                        if (widget.message.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(top: 8.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                  color: const Color(0xFFEF4444), width: 1.0),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 16.0, color: Color(0xFFEF4444)),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    widget.message.errorMessage!,
                                    style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Color(0xFFEF4444)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // 5. Actions Footer
                _buildActions(activeTheme),
              ],
            ),
          ),
          if (isUser && widget.showAvatar) ...[
            const SizedBox(width: 10.0),
            _buildAvatar(activeTheme),
          ],
        ],
      ),
    );
  }
}
