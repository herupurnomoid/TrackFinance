import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/models/user_profile.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/category/data/category_repository.dart';
import 'package:track_finance/features/transaction/data/transaction_repository.dart';
import 'package:track_finance/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:track_finance/features/transaction/presentation/widgets/tactile_3d_button.dart';
import 'package:track_finance/features/transaction/presentation/widgets/transaction_date_picker_modal.dart';
import 'package:track_finance/features/transaction/presentation/widgets/transaction_time_picker_modal.dart';

void main() {
  group('Tambah Transaksi Modifikasi & Enhancements Tests', () {
    const testUser = UserProfile(
      uid: 'user_test_enhancements',
      email: 'test@trackfinance.app',
      displayName: 'Test User',
      photoUrl: null,
    );

    late FakeFirebaseFirestore fakeFirestore;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      TransactionRepository.instance =
          TransactionRepository(firestore: fakeFirestore);
      final categoryRepo = CategoryRepository(firestore: fakeFirestore);
      CategoryRepository.instance = categoryRepo;
      await categoryRepo.seedDefaultCategoriesIfEmpty(testUser.uid);
    });

    // -------------------------------------------------------------------------
    // 1. Test Date Picker Scroller (Tanggal, Bulan, Tahun)
    // -------------------------------------------------------------------------
    testWidgets('TransactionDatePickerModal opens with 3 scroller wheels (TANGGAL, BULAN, TAHUN) and confirms date', (tester) async {
      DateTime? selectedDate;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  TransactionDatePickerModal.show(
                    context,
                    initialDate: DateTime(2026, 11, 7),
                    onConfirm: (d) => selectedDate = d,
                  );
                },
                child: const Text('Buka Tanggal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Tanggal'));
      await tester.pumpAndSettle();

      // Memastikan elemen scroller tampil
      expect(find.text('Pilih Tanggal'), findsOneWidget);
      expect(find.text('TANGGAL'), findsOneWidget);
      expect(find.text('BULAN'), findsOneWidget);
      expect(find.text('TAHUN'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Terapkan'), findsOneWidget);

      // Verifikasi: badge "Hari Ini" dan "Tahun Ini" telah dihapus
      expect(find.text('Hari Ini'), findsNothing);
      expect(find.text('Tahun Ini'), findsNothing);

      // Verifikasi: yang terpilih (07) dibold (w800) dan berukuran lebih besar (fontSize 22)
      final text07 = tester.widget<Text>(find.text('07'));
      expect(text07.style?.fontWeight, equals(FontWeight.w800));
      expect(text07.style?.fontSize, equals(22));

      // Verifikasi: tidak ada container selection lens berlatar belakang warna
      final lensContainers = tester.widgetList<Container>(find.byType(Container)).where((c) {
        final dec = c.decoration;
        if (dec is BoxDecoration && dec.color != null) {
          return dec.color == const Color(0xFF2563EB).withValues(alpha: 0.05);
        }
        return false;
      });
      expect(lensContainers, isEmpty);

      // Konfirmasi pemilihan tanggal
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      expect(selectedDate, equals(DateTime(2026, 11, 7)));
    });

    testWidgets('TransactionDatePickerModal Batal button dismisses without calling onConfirm', (tester) async {
      DateTime? selectedDate;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  TransactionDatePickerModal.show(
                    context,
                    initialDate: DateTime(2026, 11, 7),
                    onConfirm: (d) => selectedDate = d,
                  );
                },
                child: const Text('Buka Tanggal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Tanggal'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Tanggal'), findsOneWidget);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Tanggal'), findsNothing);
      expect(selectedDate, isNull);
    });

    // -------------------------------------------------------------------------
    // 2. Test Time Picker Scroller (Jam & Menit)
    // -------------------------------------------------------------------------
    testWidgets('TransactionTimePickerModal opens with dual scroller wheels (JAM, MENIT) and presets', (tester) async {
      TimeOfDay? selectedTime;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  TransactionTimePickerModal.show(
                    context,
                    initialTime: const TimeOfDay(hour: 14, minute: 30),
                    onConfirm: (t) => selectedTime = t,
                  );
                },
                child: const Text('Buka Waktu'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Waktu'));
      await tester.pumpAndSettle();

      // Memastikan elemen scroller tampil
      expect(find.text('Pilih Waktu'), findsOneWidget);
      expect(find.text('JAM'), findsOneWidget);
      expect(find.text('MENIT'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Terapkan'), findsOneWidget);

      // Verifikasi: badge "Hari Ini" dan "Tahun Ini" telah dihapus
      expect(find.text('Hari Ini'), findsNothing);
      expect(find.text('Tahun Ini'), findsNothing);

      // Verifikasi: teks WAKTU TRANSAKSI (WIB) dan rekomendasi preset (Sekarang) telah dihapus
      expect(find.text('WAKTU TRANSAKSI (WIB)'), findsNothing);
      expect(find.text('Sekarang'), findsNothing);
      expect(find.text('09:00'), findsNothing);
      expect(find.text('12:00'), findsNothing);

      // Verifikasi: yang terpilih (14) dibold (w800) dan berukuran lebih besar (fontSize 24)
      final text14 = tester.widget<Text>(find.text('14'));
      expect(text14.style?.fontWeight, equals(FontWeight.w800));
      expect(text14.style?.fontSize, equals(24));

      // Verifikasi: tidak ada container selection lens berlatar belakang warna
      final timeLensContainers = tester.widgetList<Container>(find.byType(Container)).where((c) {
        final dec = c.decoration;
        if (dec is BoxDecoration && dec.color != null) {
          return dec.color == const Color(0xFF2563EB).withValues(alpha: 0.05);
        }
        return false;
      });
      expect(timeLensContainers, isEmpty);

      // Tap Terapkan
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      expect(selectedTime, equals(const TimeOfDay(hour: 14, minute: 30)));
    });

    testWidgets('TransactionTimePickerModal Batal button dismisses without calling onConfirm', (tester) async {
      TimeOfDay? selectedTime;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  TransactionTimePickerModal.show(
                    context,
                    initialTime: const TimeOfDay(hour: 14, minute: 30),
                    onConfirm: (t) => selectedTime = t,
                  );
                },
                child: const Text('Buka Waktu'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Waktu'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Waktu'), findsOneWidget);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Waktu'), findsNothing);
      expect(selectedTime, isNull);
    });

    // -------------------------------------------------------------------------
    // 3. Test removal of 'Data tersinkron otomatis ke dompet utama'
    // -------------------------------------------------------------------------
    testWidgets('AddTransactionScreen does NOT show "Data tersinkron otomatis ke dompet utama"', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AddTransactionScreen(user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Data tersinkron otomatis ke dompet utama'), findsNothing);
      expect(find.text('Perubahan akan otomatis terbarui di laporan'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // 4. Test button color consistency (abu-abu when disabled, biru when enabled)
    // -------------------------------------------------------------------------
    testWidgets('Simpan Transaksi button is disabled and gray when invalid, turns blue and clickable when valid', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AddTransactionScreen(user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Initial State: Nominal adalah 0 dan Kategori belum dipilih
      final buttonFinder = find.byType(Tactile3DButton);
      expect(buttonFinder, findsOneWidget);
      Tactile3DButton buttonWidget = tester.widget<Tactile3DButton>(buttonFinder);
      expect(buttonWidget.isEnabled, isFalse);
      expect(buttonWidget.onTap, isNull); // Tidak bisa diklik

      // Periksa dekorasi tombol dalam keadaan disabled (abu-abu)
      final animatedContainerFinder = find.descendant(
        of: buttonFinder,
        matching: find.byType(AnimatedContainer),
      );
      expect(animatedContainerFinder, findsOneWidget);
      AnimatedContainer containerWidget = tester.widget<AnimatedContainer>(animatedContainerFinder);
      BoxDecoration decoration = containerWidget.decoration as BoxDecoration;
      LinearGradient gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors, equals(const [Color(0xFFCBD5E1), Color(0xFF94A3B8)]));

      // 2. Masukkan nominal > 0
      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '75000');
      await tester.pump();

      // Masih invalid karena kategori belum dipilih
      buttonWidget = tester.widget<Tactile3DButton>(buttonFinder);
      expect(buttonWidget.isEnabled, isFalse);
      expect(buttonWidget.onTap, isNull);

      // 3. Pilih kategori transaksi
      await tester.tap(find.text('Makanan & Minuman'));
      await tester.pumpAndSettle();

      // Sekarang form valid: isEnabled = true, onTap tidak null, dan warna biru konsisten
      buttonWidget = tester.widget<Tactile3DButton>(buttonFinder);
      expect(buttonWidget.isEnabled, isTrue);
      expect(buttonWidget.onTap, isNotNull); // Sekarang bisa diklik!

      containerWidget = tester.widget<AnimatedContainer>(animatedContainerFinder);
      decoration = containerWidget.decoration as BoxDecoration;
      gradient = decoration.gradient as LinearGradient;
      // Warna BIRU konsisten: 0xFF2563EB ke 0xFF1E40AF
      expect(gradient.colors, equals(const [Color(0xFF2563EB), Color(0xFF1E40AF)]));
    });

    // -------------------------------------------------------------------------
    // 5. Test Date and Time form uses No Container and No Background Color
    // -------------------------------------------------------------------------
    testWidgets('Date and Time form uses No Container and No Background Color concept', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AddTransactionScreen(user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Tanggal & Waktu labels and icons exist
      expect(find.text('Tanggal'), findsOneWidget);
      expect(find.text('Waktu'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);

      // Verify that the Date and Time containers have NO background color (Colors.transparent) and no gradient or box shadows
      final dateFinder = find.ancestor(
        of: find.text('Tanggal'),
        matching: find.byType(Container),
      ).first;
      final dateContainer = tester.widget<Container>(dateFinder);
      final dateDec = dateContainer.decoration as BoxDecoration;
      expect(dateDec.color, equals(Colors.transparent));
      expect(dateDec.boxShadow, isNull);
      expect(dateDec.gradient, isNull);
      expect(dateDec.border?.bottom.width, 1.5);

      final timeFinder = find.ancestor(
        of: find.text('Waktu'),
        matching: find.byType(Container),
      ).first;
      final timeContainer = tester.widget<Container>(timeFinder);
      final timeDec = timeContainer.decoration as BoxDecoration;
      expect(timeDec.color, equals(Colors.transparent));
      expect(timeDec.boxShadow, isNull);
      expect(timeDec.gradient, isNull);
      expect(timeDec.border?.bottom.width, 1.5);

      // Verify tapping opens modals
      await tester.tap(find.text('Tanggal'));
      await tester.pumpAndSettle();
      expect(find.text('Pilih Tanggal'), findsOneWidget);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Waktu'));
      await tester.pumpAndSettle();
      expect(find.text('Pilih Waktu'), findsOneWidget);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
    });

    // -------------------------------------------------------------------------
    // 6. Test Vertical Ordering: Date and Time is ABOVE Category Input
    // -------------------------------------------------------------------------
    testWidgets('Input Date and Time is vertically placed ABOVE Category input section', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AddTransactionScreen(user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      final nominalFinder = find.text('Nominal Transaksi');
      final dateFinder = find.text('Tanggal');
      final timeFinder = find.text('Waktu');
      final categoryFinder = find.text('Kategori');

      expect(nominalFinder, findsOneWidget);
      expect(dateFinder, findsOneWidget);
      expect(timeFinder, findsOneWidget);
      expect(categoryFinder, findsOneWidget);

      final nominalY = tester.getTopLeft(nominalFinder).dy;
      final dateY = tester.getTopLeft(dateFinder).dy;
      final timeY = tester.getTopLeft(timeFinder).dy;
      final categoryY = tester.getTopLeft(categoryFinder).dy;

      // Verifikasi urutan vertikal:
      // Nominal < Tanggal/Waktu < Kategori
      expect(nominalY, lessThan(dateY));
      expect(nominalY, lessThan(timeY));
      expect(dateY, lessThan(categoryY));
      expect(timeY, lessThan(categoryY));
    });
  });
}
