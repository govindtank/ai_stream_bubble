import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('AiStreamBubbleDemoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AiStreamBubbleDemoApp());
    expect(find.text('ai_stream_bubble'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);
  });
}
