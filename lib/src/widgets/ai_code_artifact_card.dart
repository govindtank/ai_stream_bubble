import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/ai_bubble_theme.dart';

/// Renders a syntax-tinted code snippet or multi-file artifact with language header,
/// line numbers gutter, and copy-to-clipboard action.
class AiCodeArtifactCard extends StatefulWidget {
  const AiCodeArtifactCard({
    super.key,
    required this.code,
    required this.theme,
    this.language = 'code',
    this.title,
    this.showLineNumbers = true,
  });

  final String code;
  final AiBubbleTheme theme;
  final String language;
  final String? title;
  final bool showLineNumbers;

  @override
  State<AiCodeArtifactCard> createState() => _AiCodeArtifactCardState();
}

class _AiCodeArtifactCardState extends State<AiCodeArtifactCard> {
  bool _copied = false;

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    HapticFeedback.lightImpact();
    if (mounted) {
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _copied = false);
        }
      });
    }
  }

  Color _getLanguageAccent(String lang) {
    switch (lang.toLowerCase()) {
      case 'dart':
      case 'flutter':
        return const Color(0xFF02569B);
      case 'python':
      case 'py':
        return const Color(0xFF3776AB);
      case 'javascript':
      case 'js':
        return const Color(0xFFF7DF1E);
      case 'typescript':
      case 'ts':
        return const Color(0xFF3178C6);
      case 'json':
        return const Color(0xFF10B981);
      case 'bash':
      case 'sh':
      case 'shell':
        return const Color(0xFF4EAA25);
      case 'rust':
        return const Color(0xFFDEA584);
      case 'html':
      case 'css':
        return const Color(0xFFE34F26);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  List<TextSpan> _highlightCode(String code, Color baseColor) {
    // Lightweight keyword highlighting for key common keywords
    final keywords = {
      'class',
      'import',
      'from',
      'def',
      'return',
      'if',
      'else',
      'final',
      'const',
      'var',
      'void',
      'int',
      'double',
      'String',
      'bool',
      'true',
      'false',
      'null',
      'async',
      'await',
      'function',
      'export',
      'let',
      'new',
      'this',
      'super'
    };

    final lines = code.split('\n');
    final spans = <TextSpan>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final words = line.split(RegExp(r'(\s+|[.,;(){}[\]])'));

      // Check for comments
      if (line.trimLeft().startsWith('//') || line.trimLeft().startsWith('#')) {
        spans.add(TextSpan(
          text: line,
          style: TextStyle(
              color: Colors.grey.shade500, fontStyle: FontStyle.italic),
        ));
      } else {
        int currentIndex = 0;
        for (final word in words) {
          if (word.isEmpty) continue;
          final wordIndex = line.indexOf(word, currentIndex);
          if (wordIndex > currentIndex) {
            spans.add(TextSpan(text: line.substring(currentIndex, wordIndex)));
          }
          if (keywords.contains(word)) {
            spans.add(TextSpan(
              text: word,
              style: const TextStyle(
                  color: Color(0xFFF43F5E), fontWeight: FontWeight.bold),
            ));
          } else if (RegExp(r'^\d+(\.\d+)?$').hasMatch(word)) {
            spans.add(TextSpan(
              text: word,
              style: const TextStyle(color: Color(0xFFF59E0B)),
            ));
          } else {
            spans.add(TextSpan(text: word));
          }
          currentIndex = wordIndex + word.length;
        }
        if (currentIndex < line.length) {
          spans.add(TextSpan(text: line.substring(currentIndex)));
        }
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final cleanCode = widget.code.trimRight();
    final lineCount = cleanCode.isEmpty ? 1 : cleanCode.split('\n').length;
    final accentColor = _getLanguageAccent(widget.language);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: widget.theme.codeBackgroundColor,
        borderRadius: BorderRadius.circular(widget.theme.borderRadius * 0.75),
        border: Border.all(
          color: widget.theme.codeBorderColor,
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: widget.theme.codeBorderColor.withValues(alpha: 0.35),
              border: Border(
                bottom: BorderSide(
                  color: widget.theme.codeBorderColor,
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  widget.title ?? widget.language.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: widget.theme.codeTextColor.withValues(alpha: 0.75),
                    fontFamily: widget.theme.codeFontFamily,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: _handleCopy,
                  borderRadius: BorderRadius.circular(4.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _copied ? Icons.check : Icons.copy_rounded,
                          size: 13.0,
                          color: _copied
                              ? const Color(0xFF10B981)
                              : widget.theme.actionIconColor,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          _copied ? 'Copied!' : 'Copy',
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: _copied
                                ? const Color(0xFF10B981)
                                : widget.theme.actionIconColor,
                            fontFamily: widget.theme.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code Body with Optional Line Numbers
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.showLineNumbers) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(lineCount, (index) {
                        return Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12.0,
                            height: 1.5,
                            fontFamily: widget.theme.codeFontFamily,
                            color: widget.theme.codeTextColor
                                .withValues(alpha: 0.3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 14.0),
                    Container(
                      width: 1.0,
                      height: lineCount * 18.0,
                      color:
                          widget.theme.codeBorderColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 14.0),
                  ],
                  SelectableText.rich(
                    TextSpan(
                      children:
                          _highlightCode(cleanCode, widget.theme.codeTextColor),
                      style: TextStyle(
                        fontSize: 12.0,
                        height: 1.5,
                        fontFamily: widget.theme.codeFontFamily,
                        color: widget.theme.codeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
