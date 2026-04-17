import 'package:flutter/material.dart';
import 'app_colors.dart';

class HomeHeader extends StatefulWidget {
  final String username;
  final VoidCallback? onProfileTap;

  const HomeHeader({
    super.key,
    required this.username,
    this.onProfileTap,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Редрамка',
              style: TextStyle(
                color: AppColors.background,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onProfileTap,
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.surfaceAlt,
                  child: Icon(Icons.person_outline, color: AppColors.textPrimary, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.username,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Поиск',
                      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 18),
                      prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      filled: true,
                      fillColor: AppColors.surfaceAlt,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: ValueListenableBuilder(
                        valueListenable: _searchController,
                        builder: (context, value, child) => value.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 16),
                                onPressed: () => _searchController.clear(),
                                padding: EdgeInsets.zero,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.visibility_off_outlined, color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 4),
              Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 22),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
