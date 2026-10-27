import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/ai_message.dart';
import '../theme/ai_bubble_theme.dart';

/// Renders a tool-call chip representing an AI function execution.
/// Expandable to inspect input arguments and output payload.
class AiToolCallChip extends StatefulWidget {
  const AiToolCallChip({
    super.key,
    required this.toolCall,
    required this.theme,
    this.onTap,
  });

  final AiToolCall toolCall;
  final AiBubbleTheme theme;
  final VoidCallback? onTap;

  @override
  State<AiToolCallChip> createState() => _AiToolCallChipState();
}

class _AiToolCallChipState extends State<AiToolCallChip> {
  bool _expanded = false;

  IconData _getToolIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('search') || lower.contains('web')) {
      return Icons.travel_explore;
    } else if (lower.contains('code') ||
        lower.contains('terminal') ||
        lower.contains('exec')) {
      return Icons.terminal_rounded;
    } else if (lower.contains('file') ||
        lower.contains('read') ||
        lower.contains('write')) {
      return Icons.description_outlined;
    } else if (lower.contains('database') || lower.contains('sql')) {
      return Icons.storage_rounded;
    }
    return Icons.build_circle_outlined;
  }

  Widget _buildStatusIndicator() {
    switch (widget.toolCall.status) {
      case AiToolStatus.calling:
      case AiToolStatus.running:
        return SizedBox(
          width: 12.0,
          height: 12.0,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor:
                AlwaysStoppedAnimation<Color>(widget.theme.toolCallTextColor),
          ),
        );
      case AiToolStatus.success:
        return const Icon(
          Icons.check_circle_rounded,
          size: 14.0,
          color: Color(0xFF10B981),
        );
      case AiToolStatus.error:
        return const Icon(
          Icons.error_outline_rounded,
          size: 14.0,
          color: Color(0xFFEF4444),
        );
    }
  }

  String _formatJson(dynamic object) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(object);
    } catch (_) {
      return object.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getToolIcon(widget.toolCall.name);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: widget.theme.toolCallBackgroundColor,
        borderRadius: BorderRadius.circular(widget.theme.borderRadius * 0.6),
        border: Border.all(
          color: widget.theme.toolCallBorderColor,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() => _expanded = !_expanded);
              widget.onTap?.call();
            },
            borderRadius:
                BorderRadius.circular(widget.theme.borderRadius * 0.6),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
              child: Row(
                children: [
                  Icon(icon, size: 15.0, color: widget.theme.toolCallTextColor),
                  const SizedBox(width: 8.0),
                  Text(
                    widget.toolCall.name,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: widget.theme.toolCallTextColor,
                      fontFamily: widget.theme.codeFontFamily,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusIndicator(),
                  const SizedBox(width: 6.0),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      size: 16.0,
                      color:
                          widget.theme.toolCallTextColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color:
                        widget.theme.toolCallBorderColor.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.toolCall.arguments.isNotEmpty) ...[
                    Text(
                      'ARGUMENTS:',
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: widget.theme.toolCallTextColor
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: widget.theme.codeBackgroundColor,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: SelectableText(
                        _formatJson(widget.toolCall.arguments),
                        style: TextStyle(
                          fontSize: 11.0,
                          fontFamily: widget.theme.codeFontFamily,
                          color: widget.theme.codeTextColor,
                        ),
                      ),
                    ),
                  ],
                  if (widget.toolCall.result != null) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      'RESULT:',
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: const Color(0xFF10B981).withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: widget.theme.codeBackgroundColor,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: SelectableText(
                        widget.toolCall.result!,
                        style: TextStyle(
                          fontSize: 11.0,
                          fontFamily: widget.theme.codeFontFamily,
                          color: widget.theme.codeTextColor,
                        ),
                      ),
                    ),
                  ],
                  if (widget.toolCall.errorMessage != null) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      'ERROR: ${widget.toolCall.errorMessage}',
                      style: const TextStyle(
                        fontSize: 11.0,
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
