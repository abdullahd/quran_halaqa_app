import 'package:flutter_test/flutter_test.dart';
import 'package:quran_halaqa_app/main.dart';

void main() {
  testWidgets('عرض قائمة الحلقات', (WidgetTester tester) async {
    await tester.pumpWidget(const QuranHalaqaApp());
    expect(find.text('حلقاتي'), findsOneWidget);
  });
}
