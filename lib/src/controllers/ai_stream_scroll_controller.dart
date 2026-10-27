import 'package:flutter/material.dart';

/// Intelligent auto-scroll controller that sticks to the bottom during active streaming,
/// but automatically releases lock when the user manually scrolls up to read past content.
class AiStreamScrollController extends ScrollController {
  AiStreamScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
    this.bottomThreshold = 48.0,
  }) {
    addListener(_handleScrollChange);
  }

  /// Distance from bottom (in logical pixels) to consider the viewport "at the bottom".
  final double bottomThreshold;

  final ValueNotifier<bool> isAtBottom = ValueNotifier<bool>(true);
  final ValueNotifier<int> unreadTokensCount = ValueNotifier<int>(0);

  bool _isAutoScrolling = false;

  void _handleScrollChange() {
    if (!hasClients) return;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    final atBottom = (maxScroll - currentScroll) <= bottomThreshold;

    if (isAtBottom.value != atBottom) {
      isAtBottom.value = atBottom;
      if (atBottom) {
        unreadTokensCount.value = 0;
      }
    }
  }

  /// Called when a new token chunk arrives.
  /// If [isAtBottom] is true, smoothly jumps/animates to bottom.
  /// If user scrolled up, increments [unreadTokensCount] without disrupting reading.
  void onTokenStreamed({int tokenDelta = 1, bool animate = true}) {
    if (!hasClients) return;

    if (isAtBottom.value) {
      scrollToBottom(animate: animate);
    } else {
      unreadTokensCount.value += tokenDelta;
    }
  }

  /// Scrolls the viewport to the bottom.
  Future<void> scrollToBottom({bool animate = true}) async {
    if (!hasClients || _isAutoScrolling) return;

    _isAutoScrolling = true;
    try {
      final target = position.maxScrollExtent;
      if (animate) {
        await animateTo(
          target,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutQuad,
        );
      } else {
        jumpTo(target);
      }
      unreadTokensCount.value = 0;
      isAtBottom.value = true;
    } finally {
      _isAutoScrolling = false;
    }
  }

  @override
  void dispose() {
    removeListener(_handleScrollChange);
    isAtBottom.dispose();
    unreadTokensCount.dispose();
    super.dispose();
  }
}

/// Floating badge button that appears when the user is scrolled away from the bottom,
/// displaying an optional unread token counter and springing back to the bottom on tap.
class AiScrollToBottomButton extends StatelessWidget {
  const AiScrollToBottomButton({
    super.key,
    required this.controller,
    this.backgroundColor = const Color(0xFF1E1E22),
    this.foregroundColor = Colors.white,
    this.badgeColor = const Color(0xFF10A37F),
  });

  final AiStreamScrollController controller;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isAtBottom,
      builder: (context, atBottom, child) {
        if (atBottom) return const SizedBox.shrink();

        return ValueListenableBuilder<int>(
          valueListenable: controller.unreadTokensCount,
          builder: (context, unread, _) {
            return FloatingActionButton.small(
              heroTag: 'ai_scroll_to_bottom',
              onPressed: () => controller.scrollToBottom(),
              backgroundColor: backgroundColor,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.0,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(Icons.arrow_downward_rounded,
                      color: foregroundColor, size: 18.0),
                  if (unread > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
