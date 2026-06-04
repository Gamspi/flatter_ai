import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/loan_model.dart';
import 'app_colors.dart';

class LoanCard extends StatelessWidget {
  final LoanModel loan;

  const LoanCard({super.key, required this.loan});

  String _formatDate(String iso) {
    final parts = iso.split('-');
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final amountFormatted = NumberFormat('#,##0', 'ru_RU').format(loan.amount);

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
                loan.number,
                style: const TextStyle(
                  color: AppColors.lime,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Закрыт',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loan.name,
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
          const SizedBox(height: 4),
          Text(
            'Дата: ${_formatDate(loan.date)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          if (loan.tillDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Закрыт: ${_formatDate(loan.tillDate!)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
