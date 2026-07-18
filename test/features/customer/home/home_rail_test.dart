import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/features/customer/home/presentation/widgets/home_rail.dart';
import 'package:osta/features/customer/home/presentation/widgets/home_tile.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );

  testWidgets('renders every tile under its title', (tester) async {
    await pump(
      tester,
      const HomeRail(
        title: 'Nearby',
        tiles: [
          HomeTile(title: 'A', footer: Text('1')),
          HomeTile(title: 'B', footer: Text('2')),
        ],
      ),
    );

    expect(find.text('Nearby'), findsOneWidget);
    expect(find.byType(HomeTile), findsNWidgets(2));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('separates tiles without a trailing gap', (tester) async {
    await pump(
      tester,
      const HomeRail(
        title: 'Rail',
        tiles: [
          HomeTile(title: 'A', footer: Text('1')),
          HomeTile(title: 'B', footer: Text('2')),
          HomeTile(title: 'C', footer: Text('3')),
        ],
      ),
    );

    // The rail is a content-sized horizontal scroll (so tiles are never
    // clipped). n tiles -> n-1 separators with none trailing: the row's last
    // child must be a tile, not dead space.
    expect(find.byType(HomeTile), findsNWidgets(3));
    final row = tester.widget<Row>(
      find
          .descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(Row),
          )
          .first,
    );
    expect(row.children.last, isA<HomeTile>());
  });

  testWidgets('an empty rail still shows its title', (tester) async {
    await pump(tester, const HomeRail(title: 'Empty', tiles: []));
    expect(find.text('Empty'), findsOneWidget);
    expect(find.byType(HomeTile), findsNothing);
  });

  testWidgets('HomeTile renders its footer widget', (tester) async {
    await pump(
      tester,
      const HomeTile(title: 'Oil', footer: Text('250 EGP')),
    );
    expect(find.text('Oil'), findsOneWidget);
    expect(find.text('250 EGP'), findsOneWidget);
  });
}
