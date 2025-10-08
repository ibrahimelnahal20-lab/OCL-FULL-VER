import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ocl2/main.dart';
import 'package:ocl2/routes/routes.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // استرجاع آخر صفحة أو العودة إلى صفحة تسجيل الدخول كافتراضية

    // بناء التطبيق مع تمرير المسار الابتدائي
    await tester.pumpWidget(const MyApp(testInitialRoute: AppRoutes.login));

    // التحقق من أن العداد يبدأ من 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // الضغط على زر '+' وتحديث الواجهة
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // التحقق من أن العداد زاد إلى 1
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
