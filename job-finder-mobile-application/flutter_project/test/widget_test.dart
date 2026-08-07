import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:job_finder_app/main.dart';
import 'package:job_finder_app/services/app_store.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppStore.instance.init();
  });

  testWidgets('App launches to Language Selection screen', (tester) async {
    await tester.pumpWidget(const JobFinderApp());
    await tester.pumpAndSettle();

    expect(find.text('Job Finder'), findsOneWidget);
    expect(find.text('जागिर खोज्ने मोबाइल एप'), findsOneWidget);
  });

  testWidgets('Selecting English navigates to login', (tester) async {
    await tester.pumpWidget(const JobFinderApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Mobile Login'), findsOneWidget);
  });
}
