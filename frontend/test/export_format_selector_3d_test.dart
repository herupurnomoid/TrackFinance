import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/export/presentation/widgets/export_format_selector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExportFormatSelector 3D Icons - No Container & No Background Color', () {
    testWidgets('Renders 3D icons for PDF and CSV without card container background',
        (WidgetTester tester) async {
      String selectedFormat = 'CSV';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ExportFormatSelector(
                  selectedFormat: selectedFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      selectedFormat = format;
                    });
                  },
                  showSubtitle: true,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Format'), findsOneWidget);
      expect(find.text('Pilih 1 jenis file'), findsOneWidget);

      // Verify Format Names & Subtitles
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);
      expect(find.text('Laporan visual'), findsOneWidget);
      expect(find.text('Excel & Spreadsheet'), findsOneWidget);

      // Verify 3D icon images are rendered
      final imageFinders = find.byType(Image);
      expect(imageFinders, findsNWidgets(2));

      // Verify asset paths
      final pdfImage = tester.widget<Image>(imageFinders.at(0));
      final pdfProvider = pdfImage.image;
      final String pdfAssetName = pdfProvider is ResizeImage
          ? (pdfProvider.imageProvider as AssetImage).assetName
          : (pdfProvider as AssetImage).assetName;
      expect(pdfAssetName, 'assets/icons/3d/pdf.webp');

      final csvImage = tester.widget<Image>(imageFinders.at(1));
      final csvProvider = csvImage.image;
      final String csvAssetName = csvProvider is ResizeImage
          ? (csvProvider.imageProvider as AssetImage).assetName
          : (csvProvider as AssetImage).assetName;
      expect(csvAssetName, 'assets/icons/3d/csv.webp');

      // Verify tapping PDF changes selection
      await tester.tap(find.text('PDF'));
      await tester.pumpAndSettle();

      expect(selectedFormat, 'PDF');

      // Verify tapping CSV changes selection back
      await tester.tap(find.text('CSV'));
      await tester.pumpAndSettle();

      expect(selectedFormat, 'CSV');
    });
  });
}
