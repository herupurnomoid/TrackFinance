import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/dummy_dashboard_data.dart';

class RecentTransactionsSection extends StatelessWidget {
  final List<TransactionDateGroup> groups;
  final VoidCallback? onSortTap;
  final Function(TransactionItem item)? onTransactionTap;

  const RecentTransactionsSection({
    super.key,
    required this.groups,
    this.onSortTap,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Rincian Transaksi',
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: onSortTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Terbaru',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.swap_vert_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Date Grouped Transactions
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: groups.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, groupIndex) {
            final group = groups[groupIndex];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 4.0,
                  ),
                  child: Text(
                    group.date,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.secondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Items in this Date
                ...group.items.map((tx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: _buildTransactionCard(tx),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionItem tx) {
    final isIncome = tx.isIncome;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final iconBg = isIncome
        ? AppColors.primaryContainer.withValues(alpha: 0.30)
        : AppColors.surfaceContainerHighest;
    final iconColor = isIncome ? AppColors.income : AppColors.expense;
    final iconData = isIncome
        ? Icons.south_west_rounded
        : Icons.north_east_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E65D0F4), // rgba(101,208,244,0.18)
            blurRadius: 16,
            spreadRadius: -4,
            offset: Offset(0, 8),
          ),
          BoxShadow(color: Colors.white, blurRadius: 4, offset: Offset(0, -2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onTransactionTap?.call(tx),
          child: Row(
            children: [
              // Icon Circle (40x40)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(iconData, size: 20, color: iconColor),
                ),
              ),

              const SizedBox(width: 12),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: AppTextStyles.headlineSm.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tx.subtitle,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Amount
              Text(
                tx.amount,
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
