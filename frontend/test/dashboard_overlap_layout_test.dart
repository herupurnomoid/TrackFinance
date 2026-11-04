import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/dashboard_overlap_layout.dart';

void main() {
  group('DashboardOverlapLayout & TopOnlyShadowClipper Tests', () {
    testWidgets('DashboardOverlapLayout correctly adjusts layout height to match visual bottom exactly',
        (tester) async {
      const double headerHeight = 220.0;
      const double overlap = 72.0;
      const double panelHeight = 850.0;

      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Container(
                    height: headerHeight,
                    color: Colors.blue,
                  ),
                  DashboardOverlapLayout(
                    topOverlap: overlap,
                    child: Container(
                      key: const ValueKey('panel_content'),
                      height: panelHeight,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify Column height equals headerHeight + panelHeight - overlap
      final columnRenderBox = tester.renderObject<RenderBox>(find.byType(Column));
      expect(
        columnRenderBox.size.height,
        equals(headerHeight + panelHeight - overlap),
      );

      // Verify panel visual top starts at headerHeight - overlap
      final panelRenderBox =
          tester.renderObject<RenderBox>(find.byKey(const ValueKey('panel_content')));
      final panelTopLeft = panelRenderBox.localToGlobal(Offset.zero);
      expect(panelTopLeft.dy, equals(headerHeight - overlap));

      // Verify panel visual bottom exactly matches Column bottom (zero gap)
      final panelVisualBottom = panelTopLeft.dy + panelRenderBox.size.height;
      expect(panelVisualBottom, equals(columnRenderBox.size.height));
    });

    test('TopOnlyShadowClipper clips bottom shadow at size.height', () {
      const clipper = TopOnlyShadowClipper(shadowBleed: 40.0);
      const testSize = Size(400, 600);

      final clipRect = clipper.getClip(testSize);

      // Top, left, right should extend by shadowBleed
      expect(clipRect.left, equals(-40.0));
      expect(clipRect.top, equals(-40.0));
      expect(clipRect.right, equals(440.0));

      // Bottom must be clipped exactly at size.height (600.0) so no bottom shadow bleeds
      expect(clipRect.bottom, equals(600.0));
    });

    testWidgets('DashboardOverlapLayout correctly handles hit testing in top overlap area', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(height: 200, color: Colors.blue),
                DashboardOverlapLayout(
                  topOverlap: 72.0,
                  child: Container(
                    height: 300,
                    color: Colors.green,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          key: const ValueKey('shortcut_button'),
                          onTap: () => tapped = true,
                          child: Container(
                            height: 50,
                            width: 100,
                            color: Colors.red,
                            child: const Text('Tambah'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Tap button in the overlap region
      await tester.tap(find.byKey(const ValueKey('shortcut_button')));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
