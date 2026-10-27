import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/ai_bubble_theme.dart';

/// Collapsible accordion displaying model reasoning and internal chain-of-thought
/// (such as DeepSeek-R1 `<think>` tokens and Claude reasoning blocks).
class AiReasoningAccordion extends StatefulWidget {
  const AiReasoningAccordion({
    super.key,
    required this.reasoning,
    required this.theme,
    this.isStreaming = false,
    this.thinkingDuration,
    this.initiallyExpanded,
  });

  final String reasoning;
  final AiBubbleTheme theme;
  final bool isStreaming;
  final Duration? thinkingDuration;
  final bool? initiallyExpanded;

  @override
  State<AiReasoningAccordion> createState() => _AiReasoningAccordionState();
}

class _AiReasoningAccordionState extends State<AiReasoningAccordion>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  Timer? _timer;
  int _elapsedMillis = 0;
  late final Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    // Default: expanded while streaming so user sees thought process, collapsed when done
    _isExpanded = widget.initiallyExpanded ?? widget.isStreaming;
    _stopwatch = Stopwatch()..start();

    if (widget.isStreaming) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        setState(() {
          _elapsedMillis = _stopwatch.elapsedMilliseconds;
        });
      }
    });
  }

  @override
  void didUpdateWidget(AiReasoningAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isStreaming && !widget.isStreaming) {
      _timer?.cancel();
      _stopwatch.stop();
    } else if (!oldWidget.isStreaming && widget.isStreaming) {
      _stopwatch
        ..reset()
        ..start();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final seconds = d.inMilliseconds / 1000.0;
    return '${seconds.toStringAsFixed(1)}s';
  }

  @override
  Widget build(BuildContext context) {
    final durationText = widget.isStreaming
        ? _formatDuration(Duration(milliseconds: _elapsedMillis))
        : (widget.thinkingDuration != null
            ? _formatDuration(widget.thinkingDuration!)
            : _formatDuration(
                Duration(milliseconds: _stopwatch.elapsedMilliseconds)));

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: widget.theme.reasoningBackgroundColor,
        borderRadius: BorderRadius.circular(widget.theme.borderRadius * 0.75),
        border: Border.all(
          color: widget.theme.reasoningBorderColor,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius:
                BorderRadius.circular(widget.theme.borderRadius * 0.75),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 16.0,
                    color: widget.theme.cursorColor,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    widget.isStreaming
                        ? 'Thinking...'
                        : 'Thought for $durationText',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: widget.theme.reasoningTextColor,
                      fontFamily: widget.theme.fontFamily,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      size: 18.0,
                      color: widget.theme.reasoningTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 10.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: widget.theme.reasoningBorderColor
                        .withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.reasoning.isEmpty
                      ? 'Formulating hypothesis...'
                      : widget.reasoning,
                  style: TextStyle(
                    fontSize: 12.0,
                    height: 1.45,
                    color:
                        widget.theme.reasoningTextColor.withValues(alpha: 0.9),
                    fontStyle: FontStyle.italic,
                    fontFamily: widget.theme.fontFamily,
                  ),
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
