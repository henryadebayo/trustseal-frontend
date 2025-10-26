// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:trustseal_app/main.dart';

// void main() {
//   testWidgets('TrustSeal app widget test', (WidgetTester tester) async {
//     // Provide mock or fake services since null can't be used for required parameters
//     final dummyBusinessService = FakeBusinessOwnersService();
//     final dummyAdminService = FakeAdminService();

//     await tester.pumpWidget(
//       TrustSealApp(
//         businessService: dummyBusinessService,
//         adminService: dummyAdminService,
//       ),
//     );

//     // Verify that our app loads with the correct title.
//     expect(find.text('TrustSeal'), findsOneWidget);

//     // Verify that the MaterialApp is present
//     expect(find.byType(MaterialApp), findsOneWidget);
//   });
// }
