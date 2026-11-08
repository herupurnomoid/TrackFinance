import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/category/data/category_model.dart';
import 'package:track_finance/features/category/presentation/widgets/category_3d_icon.dart';

void main() {
  group('Category3DIcon Path Resolution & Unit Tests', () {
    test('Resolves 3D icon path by standard Expense Category IDs', () {
      expect(Category3DIcon.get3DIconPath(id: 'exp-1'), equals('assets/icons/3d/food.webp'));
      expect(Category3DIcon.get3DIconPath(id: 'exp-2'), equals('assets/icons/3d/transport.webp'));
      expect(Category3DIcon.get3DIconPath(id: 'exp-3'), equals('assets/icons/3d/shopping.webp'));
      expect(Category3DIcon.get3DIconPath(id: 'exp-4'), equals('assets/icons/3d/bills.webp'));
      expect(Category3DIcon.get3DIconPath(id: 'exp-5'), equals('assets/icons/3d/health.webp'));
      expect(Category3DIcon.get3DIconPath(id: 'exp-6'), equals('assets/icons/3d/entertainment.webp'));
      expect(Category3DIcon.get3DIconPath(id: 'exp-7'), equals('assets/icons/3d/education.webp'));
      expect(Category3DIcon.get3DIconPath(id: 'exp-8'), equals('assets/icons/3d/other_expense.webp'));
    });

    test('Resolves 3D icon path by standard Income Category IDs', () {
      expect(Category3DIcon.get3DIconPath(id: 'inc-1'), equals('assets/icons/3d/salary.webp'));
      expect(Category3DIcon.get3DIconPath(id: 'inc-2'), equals('assets/icons/3d/bonus.webp'));
      expect(Category3DIcon.get3DIconPath(id: 'inc-3'), equals('assets/icons/3d/investment.webp'));
      expect(Category3DIcon.get3DIconPath(id: 'inc-4'), equals('assets/icons/3d/store.webp'));
      expect(Category3DIcon.get3DIconPath(id: 'inc-5'), equals('assets/icons/3d/freelance.webp'));
      expect(Category3DIcon.get3DIconPath(id: 'inc-6'), equals('assets/icons/3d/other_income.webp'));
    });

    test('Resolves 3D icon path by IconData', () {
      expect(Category3DIcon.get3DIconPath(icon: Icons.restaurant_rounded), equals('assets/icons/3d/food.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.two_wheeler_rounded), equals('assets/icons/3d/transport.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.shopping_bag_rounded), equals('assets/icons/3d/shopping.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.receipt_long_rounded), equals('assets/icons/3d/bills.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.medical_services_rounded), equals('assets/icons/3d/health.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.sports_esports_rounded), equals('assets/icons/3d/entertainment.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.school_rounded), equals('assets/icons/3d/education.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.home_rounded), equals('assets/icons/3d/home.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.savings_rounded), equals('assets/icons/3d/savings.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.flight_rounded), equals('assets/icons/3d/travel.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.local_cafe_rounded), equals('assets/icons/3d/cafe.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.fitness_center_rounded), equals('assets/icons/3d/fitness.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.pets_rounded), equals('assets/icons/3d/pet.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.bolt_rounded), equals('assets/icons/3d/electricity.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.water_drop_rounded), equals('assets/icons/3d/water.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.wifi_rounded), equals('assets/icons/3d/wifi.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.phone_android_rounded), equals('assets/icons/3d/phone.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.volunteer_activism_rounded), equals('assets/icons/3d/donate.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.checkroom_rounded), equals('assets/icons/3d/fashion.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.spa_rounded), equals('assets/icons/3d/beauty.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.child_care_rounded), equals('assets/icons/3d/baby.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.build_rounded), equals('assets/icons/3d/maintenance.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.music_note_rounded), equals('assets/icons/3d/music.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.menu_book_rounded), equals('assets/icons/3d/books.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.monetization_on_rounded), equals('assets/icons/3d/gold.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.shield_rounded), equals('assets/icons/3d/shield.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.photo_camera_rounded), equals('assets/icons/3d/camera.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.cake_rounded), equals('assets/icons/3d/cake.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.local_gas_station_rounded), equals('assets/icons/3d/fuel.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.credit_card_rounded), equals('assets/icons/3d/card.webp'));
    });

    test('Resolves 3D icon path intelligently by Category Name keywords', () {
      expect(Category3DIcon.get3DIconPath(name: 'Makan Malam Enak'), equals('assets/icons/3d/food.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Ongkos Ojek Motor'), equals('assets/icons/3d/transport.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Bensin Pertamax SPBU'), equals('assets/icons/3d/fuel.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Tagihan Kartu Kredit'), equals('assets/icons/3d/card.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Belanja Supermarket'), equals('assets/icons/3d/shopping.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Tagihan Bulanan'), equals('assets/icons/3d/bills.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Obat & Dokter'), equals('assets/icons/3d/health.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Main Game Steam'), equals('assets/icons/3d/entertainment.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Uang Sekolah Anak'), equals('assets/icons/3d/education.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Gaji Bulanan Kantor'), equals('assets/icons/3d/salary.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Bonus THR Tahunan'), equals('assets/icons/3d/bonus.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Dividen Saham BBCA'), equals('assets/icons/3d/investment.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Hasil Penjualan Warung'), equals('assets/icons/3d/store.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Proyek Freelance UI/UX'), equals('assets/icons/3d/freelance.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Token Listrik Prabayar'), equals('assets/icons/3d/electricity.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Air PDAM Tirta'), equals('assets/icons/3d/water.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Wifi Indihome'), equals('assets/icons/3d/wifi.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Pulsa Telkomsel'), equals('assets/icons/3d/phone.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Donasi Yatim Piatu'), equals('assets/icons/3d/donate.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Beli Pakaian Baru'), equals('assets/icons/3d/fashion.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Skincare Routine'), equals('assets/icons/3d/beauty.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Kebutuhan Popok Bayi'), equals('assets/icons/3d/baby.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Servis Bengkel Motor'), equals('assets/icons/3d/maintenance.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Langganan Musik Spotify'), equals('assets/icons/3d/music.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Beli Buku Pelajaran'), equals('assets/icons/3d/books.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Tabungan Emas Antam'), equals('assets/icons/3d/gold.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Premi Asuransi BPJS'), equals('assets/icons/3d/shield.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Lensa Kamera Hobi'), equals('assets/icons/3d/camera.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Kue Ulang Tahun'), equals('assets/icons/3d/cake.webp'));
    });

    test('Gracefully falls back to other_expense or other_income', () {
      expect(Category3DIcon.get3DIconPath(isExpense: true), equals('assets/icons/3d/other_expense.webp'));
      expect(Category3DIcon.get3DIconPath(isExpense: false), equals('assets/icons/3d/other_income.webp'));
    });

    test('Resolves 3D icon path for "more" / "Lebih Banyak"', () {
      expect(Category3DIcon.get3DIconPath(id: 'more'), equals('assets/icons/3d/more.webp'));
      expect(Category3DIcon.get3DIconPath(icon: Icons.more_horiz_rounded), equals('assets/icons/3d/more.webp'));
      expect(Category3DIcon.get3DIconPath(name: 'Lebih Banyak'), equals('assets/icons/3d/more.webp'));
    });
  });

  group('Category3DIcon Widget Tests', () {
    testWidgets('Renders Image.asset with correct path from CategoryItem', (WidgetTester tester) async {
      const item = CategoryItem(
        id: 'exp-1',
        name: 'Makanan & Minuman',
        icon: Icons.restaurant_rounded,
        isExpense: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Category3DIcon(
              category: item,
              size: 48,
            ),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      final provider = imageWidget.image;
      final asset = provider is ResizeImage ? provider.imageProvider as AssetImage : provider as AssetImage;
      expect(asset.assetName, equals('assets/icons/3d/food.webp'));
      expect(imageWidget.width, equals(48));
      expect(imageWidget.height, equals(48));
    });

    testWidgets('Renders Image.asset with correct path from standalone IconData', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Category3DIcon(
              icon: Icons.card_giftcard_rounded,
              isExpense: false,
              size: 32,
            ),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      final provider = imageWidget.image;
      final asset = provider is ResizeImage ? provider.imageProvider as AssetImage : provider as AssetImage;
      expect(asset.assetName, equals('assets/icons/3d/bonus.webp'));
      expect(imageWidget.width, equals(32));
      expect(imageWidget.height, equals(32));
    });
  });
}
