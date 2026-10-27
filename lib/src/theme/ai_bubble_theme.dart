import 'package:flutter/material.dart';

/// Defines the visual styling for [AiStreamBubble] and its subcomponents.
@immutable
class AiBubbleTheme {
  const AiBubbleTheme({
    required this.userBubbleColor,
    required this.userTextColor,
    required this.assistantBubbleColor,
    required this.assistantTextColor,
    required this.reasoningBackgroundColor,
    required this.reasoningBorderColor,
    required this.reasoningTextColor,
    required this.codeBackgroundColor,
    required this.codeBorderColor,
    required this.codeTextColor,
    required this.toolCallBackgroundColor,
    required this.toolCallBorderColor,
    required this.toolCallTextColor,
    this.cursorColor = const Color(0xFF10A37F),
    this.borderRadius = 16.0,
    this.userBorderRadius,
    this.assistantBorderRadius,
    this.fontFamily,
    this.codeFontFamily = 'monospace',
    this.userElevation = 0.0,
    this.assistantElevation = 0.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
    this.actionIconColor = const Color(0xFF9E9E9E),
  });

  final Color userBubbleColor;
  final Color userTextColor;
  final Color assistantBubbleColor;
  final Color assistantTextColor;

  final Color reasoningBackgroundColor;
  final Color reasoningBorderColor;
  final Color reasoningTextColor;

  final Color codeBackgroundColor;
  final Color codeBorderColor;
  final Color codeTextColor;

  final Color toolCallBackgroundColor;
  final Color toolCallBorderColor;
  final Color toolCallTextColor;

  final Color cursorColor;
  final double borderRadius;
  final BorderRadiusGeometry? userBorderRadius;
  final BorderRadiusGeometry? assistantBorderRadius;
  final String? fontFamily;
  final String codeFontFamily;
  final double userElevation;
  final double assistantElevation;
  final EdgeInsetsGeometry padding;
  final Color actionIconColor;

  /// Default sleek dark obsidian theme (ChatGPT/Claude dark mode aesthetic).
  factory AiBubbleTheme.dark() {
    return const AiBubbleTheme(
      userBubbleColor: Color(0xFF262628),
      userTextColor: Color(0xFFF5F5F5),
      assistantBubbleColor: Color(0xFF1E1E20),
      assistantTextColor: Color(0xFFECECEC),
      reasoningBackgroundColor: Color(0xFF141416),
      reasoningBorderColor: Color(0xFF2A2A2E),
      reasoningTextColor: Color(0xFFA0A0AB),
      codeBackgroundColor: Color(0xFF0F0F11),
      codeBorderColor: Color(0xFF2A2A2E),
      codeTextColor: Color(0xFFE2E8F0),
      toolCallBackgroundColor: Color(0xFF161618),
      toolCallBorderColor: Color(0xFF2D2D35),
      toolCallTextColor: Color(0xFF93C5FD),
      cursorColor: Color(0xFF10A37F),
      actionIconColor: Color(0xFF71717A),
    );
  }

  /// Clean modern light theme.
  factory AiBubbleTheme.light() {
    return const AiBubbleTheme(
      userBubbleColor: Color(0xFF007AFF),
      userTextColor: Colors.white,
      assistantBubbleColor: Color(0xFFF3F4F6),
      assistantTextColor: Color(0xFF1F2937),
      reasoningBackgroundColor: Color(0xFFE5E7EB),
      reasoningBorderColor: Color(0xFFD1D5DB),
      reasoningTextColor: Color(0xFF4B5563),
      codeBackgroundColor: Color(0xFF1E293B),
      codeBorderColor: Color(0xFF334155),
      codeTextColor: Color(0xFFF8FAFC),
      toolCallBackgroundColor: Color(0xFFEFF6FF),
      toolCallBorderColor: Color(0xFFBFDBFE),
      toolCallTextColor: Color(0xFF1D4ED8),
      cursorColor: Color(0xFF007AFF),
      actionIconColor: Color(0xFF9CA3AF),
    );
  }

  /// Claude's iconic warm terracotta & parchment theme.
  factory AiBubbleTheme.claudeWarm() {
    return const AiBubbleTheme(
      userBubbleColor: Color(0xFFECE3D4),
      userTextColor: Color(0xFF2E2A25),
      assistantBubbleColor: Color(0xFFFBF8F3),
      assistantTextColor: Color(0xFF1F1E1D),
      reasoningBackgroundColor: Color(0xFFF3EDE2),
      reasoningBorderColor: Color(0xFFE2D7C5),
      reasoningTextColor: Color(0xFF7A6E5F),
      codeBackgroundColor: Color(0xFF272522),
      codeBorderColor: Color(0xFF3C3833),
      codeTextColor: Color(0xFFEDE8E1),
      toolCallBackgroundColor: Color(0xFFF5EFE6),
      toolCallBorderColor: Color(0xFFDECDB5),
      toolCallTextColor: Color(0xFFB95A2B),
      cursorColor: Color(0xFFC96442),
      actionIconColor: Color(0xFF8C8071),
    );
  }

  /// Vibrant Cyberpunk theme with glowing accents.
  factory AiBubbleTheme.cyberpunk() {
    return const AiBubbleTheme(
      userBubbleColor: Color(0xFF1F1135),
      userTextColor: Color(0xFFF3E8FF),
      assistantBubbleColor: Color(0xFF0D0B18),
      assistantTextColor: Color(0xFFE0E7FF),
      reasoningBackgroundColor: Color(0xFF150E24),
      reasoningBorderColor: Color(0xFF3B1E6D),
      reasoningTextColor: Color(0xFFC084FC),
      codeBackgroundColor: Color(0xFF08060F),
      codeBorderColor: Color(0xFF2E1065),
      codeTextColor: Color(0xFF38BDF8),
      toolCallBackgroundColor: Color(0xFF1E1035),
      toolCallBorderColor: Color(0xFF9333EA),
      toolCallTextColor: Color(0xFFF472B6),
      cursorColor: Color(0xFF06B6D4),
      actionIconColor: Color(0xFFA855F7),
    );
  }

  AiBubbleTheme copyWith({
    Color? userBubbleColor,
    Color? userTextColor,
    Color? assistantBubbleColor,
    Color? assistantTextColor,
    Color? reasoningBackgroundColor,
    Color? reasoningBorderColor,
    Color? reasoningTextColor,
    Color? codeBackgroundColor,
    Color? codeBorderColor,
    Color? codeTextColor,
    Color? toolCallBackgroundColor,
    Color? toolCallBorderColor,
    Color? toolCallTextColor,
    Color? cursorColor,
    double? borderRadius,
    BorderRadiusGeometry? userBorderRadius,
    BorderRadiusGeometry? assistantBorderRadius,
    String? fontFamily,
    String? codeFontFamily,
    double? userElevation,
    double? assistantElevation,
    EdgeInsetsGeometry? padding,
    Color? actionIconColor,
  }) {
    return AiBubbleTheme(
      userBubbleColor: userBubbleColor ?? this.userBubbleColor,
      userTextColor: userTextColor ?? this.userTextColor,
      assistantBubbleColor: assistantBubbleColor ?? this.assistantBubbleColor,
      assistantTextColor: assistantTextColor ?? this.assistantTextColor,
      reasoningBackgroundColor:
          reasoningBackgroundColor ?? this.reasoningBackgroundColor,
      reasoningBorderColor: reasoningBorderColor ?? this.reasoningBorderColor,
      reasoningTextColor: reasoningTextColor ?? this.reasoningTextColor,
      codeBackgroundColor: codeBackgroundColor ?? this.codeBackgroundColor,
      codeBorderColor: codeBorderColor ?? this.codeBorderColor,
      codeTextColor: codeTextColor ?? this.codeTextColor,
      toolCallBackgroundColor:
          toolCallBackgroundColor ?? this.toolCallBackgroundColor,
      toolCallBorderColor: toolCallBorderColor ?? this.toolCallBorderColor,
      toolCallTextColor: toolCallTextColor ?? this.toolCallTextColor,
      cursorColor: cursorColor ?? this.cursorColor,
      borderRadius: borderRadius ?? this.borderRadius,
      userBorderRadius: userBorderRadius ?? this.userBorderRadius,
      assistantBorderRadius:
          assistantBorderRadius ?? this.assistantBorderRadius,
      fontFamily: fontFamily ?? this.fontFamily,
      codeFontFamily: codeFontFamily ?? this.codeFontFamily,
      userElevation: userElevation ?? this.userElevation,
      assistantElevation: assistantElevation ?? this.assistantElevation,
      padding: padding ?? this.padding,
      actionIconColor: actionIconColor ?? this.actionIconColor,
    );
  }
}
