import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

Widget defaultScreen(int id) => Container(child: Text("Screen$id"));

Widget screenWithSubPages(int id) => id > 99
    ? defaultScreen(id)
    : Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            defaultScreen(id),
            Builder(builder: (context) {
              return ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          screenWithSubPages(id * 10 + (id % 10))),
                ),
                child: Text("SubPage"),
              );
            })
          ],
        ),
      );

void main() {
  Widget wrapTabView(WidgetBuilder builder) {
    return MaterialApp(
      home: Builder(
        builder: (context) => builder(context),
      ),
    );
  }

  group('PersistentTabView', () {
    List<PersistentBottomNavBarItem> items = [
      PersistentBottomNavBarItem(title: "Item1", icon: Icon(Icons.add)),
      PersistentBottomNavBarItem(title: "Item2", icon: Icon(Icons.add)),
      PersistentBottomNavBarItem(title: "Item3", icon: Icon(Icons.add)),
    ];

    testWidgets('builds a PersistentBottomNavBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
          ),
        ),
      );

      expect(find.byType(PersistentBottomNavBar).hitTestable(), findsOneWidget);
    });

    testWidgets('shows all tabs and the correct screen for it',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
          ),
        ),
      );

      expect(find.text('Screen1'), findsOneWidget);
      expect(find.text('Screen2'), findsNothing);
      expect(find.text('Screen3'), findsNothing);
      await tester.tap(find.text("Item2"));
      await tester.pumpAndSettle();
      expect(find.text('Screen1'), findsNothing);
      expect(find.text('Screen2'), findsOneWidget);
      expect(find.text('Screen3'), findsNothing);
      await tester.tap(find.text("Item3"));
      await tester.pumpAndSettle();
      expect(find.text('Screen1'), findsNothing);
      expect(find.text('Screen2'), findsNothing);
      expect(find.text('Screen3'), findsOneWidget);
      await tester.tap(find.text("Item1"));
      await tester.pumpAndSettle();
      expect(find.text('Screen1'), findsOneWidget);
      expect(find.text('Screen2'), findsNothing);
      expect(find.text('Screen3'), findsNothing);
    });

    testWidgets('switches screens when tapping on items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
          ),
        ),
      );

      expect(find.text('Screen1'), findsOneWidget);
      expect(find.text('Screen2'), findsNothing);
      await tester.tap(find.text("Item2"));
      await tester.pumpAndSettle();
      expect(find.text('Screen1'), findsNothing);
      expect(find.text('Screen2'), findsOneWidget);
    });

    testWidgets('hides the navbar when hideNavBar is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
            hideNavigationBar: true,
          ),
        ),
      );

      expect(find.byType(PersistentBottomNavBar).hitTestable(), findsNothing);
    });

    testWidgets(
        'hides the navbar when hideNavigationBarWhenKeyboardShows is true and keyboard is up',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
            hideNavigationBarWhenKeyboardShows: true,
          ),
        ),
      );

      expect(find.byType(PersistentBottomNavBar).hitTestable(), findsOneWidget);

      await tester.pumpWidget(
        wrapTabView(
          (context) => MediaQuery(
            data: MediaQueryData(
              viewInsets: const EdgeInsets.only(
                  bottom: 100), // Simulate an open keyboard
            ),
            child: Builder(builder: (context) {
              return PersistentTabView(
                context,
                screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
                items: items,
                navBarStyle: NavBarStyle.style3,
                hideNavigationBarWhenKeyboardShows: true,
              );
            }),
          ),
        ),
      );

      expect(find.byType(PersistentBottomNavBar).hitTestable(), findsNothing);
    });

    testWidgets("sizes the navbar according to navBarHeight",
        (WidgetTester tester) async {
      double height = 42;

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
            navBarHeight: height,
          ),
        ),
      );

      expect(tester.getSize(find.byType(PersistentBottomNavBar)).height,
          equals(height));
    });

    testWidgets("puts padding around the navbar specified by margin",
        (WidgetTester tester) async {
      EdgeInsets margin = EdgeInsets.zero;

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
            margin: margin,
          ),
        ),
      );

      expect(
          Offset(0, 600) -
              tester.getBottomLeft(find.byType(PersistentBottomNavBar)),
          equals(margin.bottomLeft));
      expect(
          Offset(800, 600 - 56) -
              tester.getTopRight(find.byType(PersistentBottomNavBar)),
          equals(margin.topRight));

      margin = EdgeInsets.fromLTRB(12, 10, 8, 6);

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
            margin: margin,
          ),
        ),
      );

      expect(
          tester.getBottomLeft(find
                  .descendant(
                      of: find.byType(PersistentBottomNavBar),
                      matching: find.byType(Container))
                  .first) -
              Offset(0, 600),
          equals(margin.bottomLeft));
      expect(
          tester.getTopRight(find
                  .descendant(
                      of: find.byType(PersistentBottomNavBar),
                      matching: find.byType(Container))
                  .first) -
              Offset(800, 600 - 56 - margin.vertical),
          equals(margin.topRight));
    });

    testWidgets("navbar is colored by backgroundColor",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
            backgroundColor: Colors.amber,
          ),
        ),
      );

      //TODO: check how backgroundColor also applies to the screens
      expect(
          ((tester.firstWidget((find.descendant(
                      of: find.byType(PersistentBottomNavBar),
                      matching: find.byType(Container)))) as Container)
                  .decoration as BoxDecoration)
              .color,
          Colors.amber);
    });

    testWidgets("executes onItemSelected when tapping items",
        (WidgetTester tester) async {
      int count = 0;

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
            onItemSelected: (index) => count++,
          ),
        ),
      );

      await tester.tap(find.text("Item2"));
      await tester.pumpAndSettle();
      expect(count, 1);
      await tester.tap(find.text("Item3"));
      await tester.pumpAndSettle();
      expect(count, 2);
    });

    testWidgets("navBarPadding does not make navbar bigger",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
            padding: NavBarPadding.all(4),
          ),
        ),
      );

      expect(tester.getSize(find.byType(PersistentBottomNavBar)).height,
          equals(kBottomNavigationBarHeight));
    });

    testWidgets(
        'resizes screens to avoid bottom inset according to resizeToAvoidBottomInset',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => MediaQuery(
            data: MediaQueryData(
              viewInsets: const EdgeInsets.only(
                  bottom: 100), // Simulate an open keyboard
            ),
            child: Builder(builder: (context) {
              return PersistentTabView(
                context,
                screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
                items: items,
                navBarStyle: NavBarStyle.style3,
                resizeToAvoidBottomInset: true,
              );
            }),
          ),
        ),
      );

      expect(tester.getSize(find.byType(PersistentTabScaffold)).height,
          equals(500));

      await tester.pumpWidget(
        wrapTabView(
          (context) => MediaQuery(
            data: MediaQueryData(
              viewInsets: const EdgeInsets.only(
                  bottom: 100), // Simulate an open keyboard
            ),
            child: Builder(builder: (context) {
              return PersistentTabView(
                context,
                screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
                items: items,
                navBarStyle: NavBarStyle.style3,
                resizeToAvoidBottomInset: false,
              );
            }),
          ),
        ),
      );

      expect(tester.getSize(find.byType(PersistentTabScaffold)).height,
          equals(600));
    });

    testWidgets('resizes screens by bottomScreenMargin',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
            bottomScreenMargin: kBottomNavigationBarHeight,
          ),
        ),
      );

      expect(tester.getSize(find.byKey(Key("TabSwitchingView"))).height,
          equals(600 - kBottomNavigationBarHeight));
    });

    testWidgets(
        'returns current screen context through selectedTabScreenContext',
        (WidgetTester tester) async {
      BuildContext? screenContext;

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => defaultScreen(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
            selectedTabScreenContext: (context) => screenContext = context,
          ),
        ),
      );

      expect(screenContext?.findAncestorWidgetOfExactType<Offstage>()?.offstage,
          isFalse);
      BuildContext? oldContext = screenContext;
      await tester.tap(find.text("Item2"));
      await tester.pumpAndSettle();
      expect(screenContext, isNot(equals(oldContext)));
      expect(screenContext?.findAncestorWidgetOfExactType<Offstage>()?.offstage,
          isFalse);
    });

    testWidgets('pops screens when tapping same tab if specified to do so',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => screenWithSubPages(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
            popAllScreensOnTapOfSelectedTab: true,
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text("Screen1"), findsNothing);
      expect(find.text("Screen11"), findsOneWidget);
      await tester.tap(find.text("Item1"));
      await tester.pumpAndSettle();
      expect(find.text("Screen1"), findsOneWidget);
      expect(find.text("Screen11"), findsNothing);

      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => screenWithSubPages(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
            popAllScreensOnTapOfSelectedTab: false,
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text("Screen1"), findsNothing);
      expect(find.text("Screen11"), findsOneWidget);
      await tester.tap(find.text("Item1"));
      await tester.pumpAndSettle();
      expect(find.text("Screen1"), findsNothing);
      expect(find.text("Screen11"), findsOneWidget);
    });

    testWidgets('pops all screens when tapping same tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapTabView(
          (context) => PersistentTabView(
            context,
            screens: [1, 2, 3].map((id) => screenWithSubPages(id)).toList(),
            items: items,
            navBarStyle: NavBarStyle.style3,
            popAllScreensOnTapOfSelectedTab: true,
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text("Screen1"), findsNothing);
      expect(find.text("Screen11"), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text("Screen1"), findsNothing);
      expect(find.text("Screen11"), findsNothing);
      expect(find.text("Screen111"), findsOneWidget);
      await tester.tap(find.text("Item1"));
      await tester.pumpAndSettle();
      expect(find.text("Screen1"), findsOneWidget);
      expect(find.text("Screen11"), findsNothing);
      expect(find.text("Screen111"), findsNothing);
    });
  });
}
