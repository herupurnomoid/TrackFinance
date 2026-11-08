import 'package:flutter/material.dart';
import '../../data/category_model.dart';

/// Komponen Ikon 3D Taktil untuk Kategori TrackFinance
/// Mendukung rendering gambar 3D WebP/PNG ultra-ringan dengan fallback otomatis.
class Category3DIcon extends StatelessWidget {
  final CategoryItem? category;
  final IconData? icon;
  final int? iconCode;
  final String? name;
  final String? id;
  final bool isExpense;
  final double size;
  final BoxFit fit;

  const Category3DIcon({
    super.key,
    this.category,
    this.icon,
    this.iconCode,
    this.name,
    this.id,
    this.isExpense = true,
    this.size = 40,
    this.fit = BoxFit.contain,
  });

  /// Mengambil path aset 3D berdasarkan id, icon, codePoint, atau nama kategori
  static String get3DIconPath({
    String? id,
    IconData? icon,
    int? iconCode,
    String? name,
    bool isExpense = true,
  }) {
    // 1. Pemetaan berdasarkan ID Kategori
    if (id != null && id.isNotEmpty) {
      switch (id) {
        case 'more':
        case 'more_categories':
          return 'assets/icons/3d/more.webp';
        case 'exp-1':
          return 'assets/icons/3d/food.webp';
        case 'exp-2':
          return 'assets/icons/3d/transport.webp';
        case 'exp-3':
          return 'assets/icons/3d/shopping.webp';
        case 'exp-4':
          return 'assets/icons/3d/bills.webp';
        case 'exp-5':
          return 'assets/icons/3d/health.webp';
        case 'exp-6':
          return 'assets/icons/3d/entertainment.webp';
        case 'exp-7':
          return 'assets/icons/3d/education.webp';
        case 'exp-8':
          return 'assets/icons/3d/other_expense.webp';
        case 'inc-1':
          return 'assets/icons/3d/salary.webp';
        case 'inc-2':
          return 'assets/icons/3d/bonus.webp';
        case 'inc-3':
          return 'assets/icons/3d/investment.webp';
        case 'inc-4':
          return 'assets/icons/3d/store.webp';
        case 'inc-5':
          return 'assets/icons/3d/freelance.webp';
        case 'inc-6':
          return 'assets/icons/3d/other_income.webp';
      }
    }

    // 2. Pemetaan berdasarkan IconData atau codePoint
    final code = iconCode ?? icon?.codePoint;
    if (code != null) {
      if (code == Icons.more_horiz_rounded.codePoint ||
          code == Icons.apps_rounded.codePoint ||
          code == Icons.grid_view_rounded.codePoint ||
          code == Icons.more_vert_rounded.codePoint) {
        return 'assets/icons/3d/more.webp';
      } else if (code == Icons.restaurant_rounded.codePoint) {
        return 'assets/icons/3d/food.webp';
      } else if (code == Icons.two_wheeler_rounded.codePoint ||
          code == Icons.directions_car_rounded.codePoint ||
          code == Icons.directions_bus_rounded.codePoint ||
          code == Icons.commute_rounded.codePoint) {
        return 'assets/icons/3d/transport.webp';
      } else if (code == Icons.shopping_bag_rounded.codePoint) {
        return 'assets/icons/3d/shopping.webp';
      } else if (code == Icons.receipt_long_rounded.codePoint) {
        return 'assets/icons/3d/bills.webp';
      } else if (code == Icons.medical_services_rounded.codePoint) {
        return 'assets/icons/3d/health.webp';
      } else if (code == Icons.sports_esports_rounded.codePoint) {
        return 'assets/icons/3d/entertainment.webp';
      } else if (code == Icons.school_rounded.codePoint) {
        return 'assets/icons/3d/education.webp';
      } else if (code == Icons.payments_rounded.codePoint ||
          code == Icons.account_balance_wallet_rounded.codePoint) {
        return 'assets/icons/3d/salary.webp';
      } else if (code == Icons.card_giftcard_rounded.codePoint) {
        return 'assets/icons/3d/bonus.webp';
      } else if (code == Icons.trending_up_rounded.codePoint) {
        return 'assets/icons/3d/investment.webp';
      } else if (code == Icons.storefront_rounded.codePoint) {
        return 'assets/icons/3d/store.webp';
      } else if (code == Icons.laptop_mac_rounded.codePoint ||
          code == Icons.devices_rounded.codePoint ||
          code == Icons.work_rounded.codePoint ||
          code == Icons.business_center_rounded.codePoint) {
        return 'assets/icons/3d/freelance.webp';
      } else if (code == Icons.home_rounded.codePoint) {
        return 'assets/icons/3d/home.webp';
      } else if (code == Icons.savings_rounded.codePoint) {
        return 'assets/icons/3d/savings.webp';
      } else if (code == Icons.flight_rounded.codePoint) {
        return 'assets/icons/3d/travel.webp';
      } else if (code == Icons.local_cafe_rounded.codePoint) {
        return 'assets/icons/3d/cafe.webp';
      } else if (code == Icons.fitness_center_rounded.codePoint) {
        return 'assets/icons/3d/fitness.webp';
      } else if (code == Icons.pets_rounded.codePoint) {
        return 'assets/icons/3d/pet.webp';
      } else if (code == Icons.bolt_rounded.codePoint ||
          code == Icons.electric_bolt_rounded.codePoint ||
          code == Icons.flash_on_rounded.codePoint ||
          code == Icons.power_rounded.codePoint) {
        return 'assets/icons/3d/electricity.webp';
      } else if (code == Icons.water_drop_rounded.codePoint ||
          code == Icons.water_rounded.codePoint ||
          code == Icons.waves_rounded.codePoint ||
          code == Icons.opacity_rounded.codePoint) {
        return 'assets/icons/3d/water.webp';
      } else if (code == Icons.wifi_rounded.codePoint ||
          code == Icons.wifi_calling_3_rounded.codePoint ||
          code == Icons.router_rounded.codePoint ||
          code == Icons.network_check_rounded.codePoint) {
        return 'assets/icons/3d/wifi.webp';
      } else if (code == Icons.phone_android_rounded.codePoint ||
          code == Icons.smartphone_rounded.codePoint ||
          code == Icons.phone_rounded.codePoint ||
          code == Icons.call_rounded.codePoint) {
        return 'assets/icons/3d/phone.webp';
      } else if (code == Icons.volunteer_activism_rounded.codePoint ||
          code == Icons.favorite_rounded.codePoint ||
          code == Icons.handshake_rounded.codePoint) {
        return 'assets/icons/3d/donate.webp';
      } else if (code == Icons.checkroom_rounded.codePoint ||
          code == Icons.style_rounded.codePoint ||
          code == Icons.dry_cleaning_rounded.codePoint) {
        return 'assets/icons/3d/fashion.webp';
      } else if (code == Icons.spa_rounded.codePoint ||
          code == Icons.face_retouching_natural_rounded.codePoint ||
          code == Icons.brush_rounded.codePoint) {
        return 'assets/icons/3d/beauty.webp';
      } else if (code == Icons.child_care_rounded.codePoint ||
          code == Icons.child_friendly_rounded.codePoint ||
          code == Icons.family_restroom_rounded.codePoint) {
        return 'assets/icons/3d/baby.webp';
      } else if (code == Icons.build_rounded.codePoint ||
          code == Icons.handyman_rounded.codePoint ||
          code == Icons.construction_rounded.codePoint ||
          code == Icons.plumbing_rounded.codePoint) {
        return 'assets/icons/3d/maintenance.webp';
      } else if (code == Icons.music_note_rounded.codePoint ||
          code == Icons.headphones_rounded.codePoint ||
          code == Icons.queue_music_rounded.codePoint) {
        return 'assets/icons/3d/music.webp';
      } else if (code == Icons.menu_book_rounded.codePoint ||
          code == Icons.auto_stories_rounded.codePoint ||
          code == Icons.book_rounded.codePoint) {
        return 'assets/icons/3d/books.webp';
      } else if (code == Icons.monetization_on_rounded.codePoint ||
          code == Icons.diamond_rounded.codePoint ||
          code == Icons.currency_exchange_rounded.codePoint) {
        return 'assets/icons/3d/gold.webp';
      } else if (code == Icons.shield_rounded.codePoint ||
          code == Icons.security_rounded.codePoint ||
          code == Icons.health_and_safety_rounded.codePoint) {
        return 'assets/icons/3d/shield.webp';
      } else if (code == Icons.photo_camera_rounded.codePoint ||
          code == Icons.camera_alt_rounded.codePoint ||
          code == Icons.videocam_rounded.codePoint) {
        return 'assets/icons/3d/camera.webp';
      } else if (code == Icons.cake_rounded.codePoint ||
          code == Icons.celebration_rounded.codePoint ||
          code == Icons.party_mode_rounded.codePoint) {
        return 'assets/icons/3d/cake.webp';
      } else if (code == Icons.local_gas_station_rounded.codePoint ||
          code == Icons.ev_station_rounded.codePoint) {
        return 'assets/icons/3d/fuel.webp';
      } else if (code == Icons.credit_card_rounded.codePoint ||
          code == Icons.payment_rounded.codePoint ||
          code == Icons.contactless_rounded.codePoint) {
        return 'assets/icons/3d/card.webp';
      } else if (code == Icons.category_rounded.codePoint) {
        return isExpense
            ? 'assets/icons/3d/other_expense.webp'
            : 'assets/icons/3d/other_income.webp';
      }
    }

    // 3. Pemetaan cerdas berdasarkan kata kunci nama kategori
    if (name != null && name.trim().isNotEmpty) {
      final n = name.toLowerCase().trim();
      if (n.contains('lebih banyak') || n == 'more' || n.contains('semua kategori') || n.contains('lihat semua')) {
        return 'assets/icons/3d/more.webp';
      }
      if (n.contains('listrik') || n.contains('token') || n.contains('pln') || n.contains('daya') || n.contains('volt')) {
        return 'assets/icons/3d/electricity.webp';
      }
      if (n.contains('air') || n.contains('pdam') || n.contains('pam')) {
        return 'assets/icons/3d/water.webp';
      }
      if (n.contains('wifi') || n.contains('internet') || n.contains('kuota') || n.contains('jaringan') || n.contains('indihome') || n.contains('biznet')) {
        return 'assets/icons/3d/wifi.webp';
      }
      if (n.contains('pulsa') || n.contains('paket data') || n.contains('telepon') || n.contains('handphone') || n.contains('hp')) {
        return 'assets/icons/3d/phone.webp';
      }
      if (n.contains('donasi') || n.contains('zakat') || n.contains('infaq') || n.contains('sedekah') || n.contains('amal') || n.contains('peduli')) {
        return 'assets/icons/3d/donate.webp';
      }
      if (n.contains('baju') || n.contains('pakaian') || n.contains('celana') || n.contains('fashion') || n.contains('mode') || n.contains('sepatu') || n.contains('tas') || n.contains('hoodie')) {
        return 'assets/icons/3d/fashion.webp';
      }
      if (n.contains('skincare') || n.contains('salon') || n.contains('spa') || n.contains('cantik') || n.contains('kosmetik') || n.contains('grooming') || n.contains('potong rambut')) {
        return 'assets/icons/3d/beauty.webp';
      }
      if (n.contains('didik') || n.contains('sekolah') || n.contains('kuliah') || n.contains('kursus')) {
        return 'assets/icons/3d/education.webp';
      }
      if (n.contains('bayi') || n.contains('baby') || n.contains('popok') || n.contains('susu') || n.contains('anak') || n.contains('keluarga')) {
        return 'assets/icons/3d/baby.webp';
      }
      if (n.contains('servis') || n.contains('bengkel') || n.contains('reparasi') || n.contains('montir') || n.contains('perbaikan') || n.contains('maintenance')) {
        return 'assets/icons/3d/maintenance.webp';
      }
      if (n.contains('musik') || n.contains('spotify') || n.contains('lagu') || n.contains('streaming') || n.contains('audio') || n.contains('konser')) {
        return 'assets/icons/3d/music.webp';
      }
      if (n.contains('buku') || n.contains('novel') || n.contains('majalah') || n.contains('komik') || n.contains('bacaan') || n.contains('gramedia')) {
        return 'assets/icons/3d/books.webp';
      }
      if (n.contains('emas') || n.contains('antam') || n.contains('logam') || n.contains('berlian') || n.contains('perhiasan') || n.contains('gold')) {
        return 'assets/icons/3d/gold.webp';
      }
      if (n.contains('asuransi') || n.contains('bpjs') || n.contains('proteksi') || n.contains('keamanan') || n.contains('jaminan')) {
        return 'assets/icons/3d/shield.webp';
      }
      if (n.contains('kamera') || n.contains('foto') || n.contains('fotografi') || n.contains('video') || n.contains('hobi')) {
        return 'assets/icons/3d/camera.webp';
      }
      if (n.contains('kue') || n.contains('ulang tahun') || n.contains('ultah') || n.contains('pesta') || n.contains('celebration')) {
        return 'assets/icons/3d/cake.webp';
      }
      if (n.contains('makan') || n.contains('minum') || n.contains('kuliner') || n.contains('food')) {
        return 'assets/icons/3d/food.webp';
      }
      if (n.contains('bensin') || n.contains('bbm') || n.contains('spbu') || n.contains('pertamax') || n.contains('pertalite') || n.contains('solar') || n.contains('fuel')) {
        return 'assets/icons/3d/fuel.webp';
      }
      if (n.contains('kartu kredit') || n.contains('credit card') || n.contains('e-money') || n.contains('kartu debit') || n.contains('atm') || n.contains('cicilan') || n.contains('angsuran')) {
        return 'assets/icons/3d/card.webp';
      }
      if (n.contains('transport') || n.contains('ojek') || n.contains('motor') || n.contains('mobil')) {
        return 'assets/icons/3d/transport.webp';
      }
      if (n.contains('belanja') || n.contains('pasar') || n.contains('mall') || n.contains('grocer')) {
        return 'assets/icons/3d/shopping.webp';
      }
      if (n.contains('tagihan')) {
        return 'assets/icons/3d/bills.webp';
      }
      if (n.contains('sehat') || n.contains('obat') || n.contains('dokter') || n.contains('klinik') || n.contains('medis')) {
        return 'assets/icons/3d/health.webp';
      }
      if (n.contains('hiburan') || n.contains('game') || n.contains('nonton') || n.contains('bioskop')) {
        return 'assets/icons/3d/entertainment.webp';
      }
      if (n.contains('gaji') || n.contains('upah') || n.contains('salary')) {
        return 'assets/icons/3d/salary.webp';
      }
      if (n.contains('bonus') || n.contains('thr') || n.contains('hadiah') || n.contains('reward')) {
        return 'assets/icons/3d/bonus.webp';
      }
      if (n.contains('invest') || n.contains('saham') || n.contains('reksa') || n.contains('crypto')) {
        return 'assets/icons/3d/investment.webp';
      }
      if (n.contains('jual') || n.contains('toko') || n.contains('dagang') || n.contains('warung')) {
        return 'assets/icons/3d/store.webp';
      }
      if (n.contains('freelance') || n.contains('proyek') || n.contains('remote') || n.contains('side')) {
        return 'assets/icons/3d/freelance.webp';
      }
      if (n.contains('rumah') || n.contains('kost') || n.contains('sewa') || n.contains('kontrakan')) {
        return 'assets/icons/3d/home.webp';
      }
      if (n.contains('tabung') || n.contains('celengan')) {
        return 'assets/icons/3d/savings.webp';
      }
      if (n.contains('libur') || n.contains('wisata') || n.contains('tiket') || n.contains('travel') || n.contains('pesawat')) {
        return 'assets/icons/3d/travel.webp';
      }
      if (n.contains('kopi') || n.contains('cafe')) {
        return 'assets/icons/3d/cafe.webp';
      }
      if (n.contains('gym') || n.contains('fit') || n.contains('olahraga')) {
        return 'assets/icons/3d/fitness.webp';
      }
      if (n.contains('kucing') || n.contains('anjing') || n.contains('hewan') || n.contains('pet')) {
        return 'assets/icons/3d/pet.webp';
      }
    }

    // 4. Default fallback untuk kategori lainnya
    return isExpense
        ? 'assets/icons/3d/other_expense.webp'
        : 'assets/icons/3d/other_income.webp';
  }

  @override
  Widget build(BuildContext context) {
    final effectiveId = id ?? category?.id;
    final effectiveIcon = icon ?? category?.icon;
    final effectiveIconCode = iconCode;
    final effectiveName = name ?? category?.name;
    final effectiveIsExpense = category?.isExpense ?? isExpense;

    final assetPath = get3DIconPath(
      id: effectiveId,
      icon: effectiveIcon,
      iconCode: effectiveIconCode,
      name: effectiveName,
      isExpense: effectiveIsExpense,
    );

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      filterQuality: FilterQuality.medium,
      cacheWidth: (size * 2.5).toInt(),
      cacheHeight: (size * 2.5).toInt(),
      errorBuilder: (context, error, stackTrace) {
        // Fallback anggun ke Icon standar jika berkas gambar belum termuat
        return Icon(
          effectiveIcon ?? Icons.category_rounded,
          size: size * 0.55,
          color: category?.color ?? (effectiveIsExpense ? const Color(0xFFE11D48) : const Color(0xFF10B981)),
        );
      },
    );
  }
}
