import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/deposit_model.dart';
import 'app_colors.dart';

class DepositCard extends StatelessWidget {
  final DepositModel deposit;

  const DepositCard({super.key, required this.deposit});

  String _formatDate(String iso) {
    final parts = iso.split('-');
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'ru_RU');
    final amountFormatted = fmt.format(deposit.amount);
    final currentAmountFormatted = fmt.format(deposit.currentAmount);
    final currentBenefitFormatted = fmt.format(deposit.currentBenefit);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                deposit.number,
                style: const TextStyle(
                  color: AppColors.lime,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                deposit.status,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            deposit.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Сумма: $amountFormatted ₽',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          if (deposit.interest != null) ...[
            const SizedBox(height: 4),
            Text(
              'Ставка: ${deposit.interest}% годовых',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Итого: $currentAmountFormatted ₽',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Проценты: $currentBenefitFormatted ₽',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Период: ${_formatDate(deposit.date)} — ${_formatDate(deposit.tillDate)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
