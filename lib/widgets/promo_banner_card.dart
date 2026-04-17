import 'package:flutter/material.dart';
import 'app_colors.dart';

class PromoBannerCard extends StatelessWidget {
  final String title;
  final Gradient gradient;
  final IconData icon;

  const PromoBannerCard({
    super.key,
    required this.title,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 128,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.background.withAlpha(60),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
