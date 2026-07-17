import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/session/session_state.dart';
import 'package:osta/features/shared/onboarding/presentation/widgets/marketing_carousel.dart';

/// Records `acknowledgeOnboarding` without touching storage — the only
/// SessionController call the carousel makes.
class _RecordingSession extends Cubit<SessionState>
    implements SessionController {
  _RecordingSession() : super(const SessionState());

  int acknowledged = 0;

  @override
  void acknowledgeOnboarding() => acknowledged++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const slides = <MarketingSlide>[
    (image: 'assets/images/logo.png', title: 'One', body: 'First'),
    (image: 'assets/images/logo.png', title: 'Two', body: 'Second'),
  ];

  late _RecordingSession session;

  Future<void> pump(WidgetTester tester, {int count = 2}) async {
    session = _RecordingSession();
    await tester.pumpWidget(
      BlocProvider<SessionController>.value(
        value: session,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MarketingCarousel(slides: slides.take(count).toList()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Skip is wrapped in a `Visibility` that maintains size/state, so it stays
  /// mounted on the last slide and only turns invisible — that reserved space
  /// is what stops the pager jumping. Assert the flag, not the tree.
  bool skipIsVisible(WidgetTester tester) => tester
      .widget<Visibility>(
        find.ancestor(
          of: find.widgetWithText(TextButton, 'Skip'),
          matching: find.byType(Visibility),
        ),
      )
      .visible;

  testWidgets('renders the first slide', (tester) async {
    await pump(tester);
    expect(find.text('One'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
  });

  testWidgets('Skip acknowledges without advancing', (tester) async {
    await pump(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Skip'));
    expect(session.acknowledged, 1);
  });

  testWidgets('Next advances instead of finishing, then Start finishes', (
    tester,
  ) async {
    await pump(tester);

    // Slide 1 of 2 -> primary button advances.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Two'), findsOneWidget);
    expect(session.acknowledged, 0, reason: 'Next must not finish onboarding');

    // Last slide -> Skip hides and the primary button finishes.
    expect(skipIsVisible(tester), isFalse);
    await tester.tap(find.text('Get started'));
    expect(session.acknowledged, 1);
  });

  testWidgets('a single-slide carousel starts on its last slide', (
    tester,
  ) async {
    await pump(tester, count: 1);
    expect(find.text('Get started'), findsOneWidget);
    expect(skipIsVisible(tester), isFalse);
  });
}
