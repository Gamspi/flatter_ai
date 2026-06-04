import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/archive_provider.dart';
import '../services/auth_service.dart';
import '../widgets/app_colors.dart';
import '../widgets/home_header.dart';
import '../widgets/promo_banner_card.dart';
import '../widgets/bonus_card.dart';
import '../widgets/section_header.dart';
import '../widgets/credit_card_tile.dart';
import '../models/loan_model.dart';
import '../models/deposit_model.dart';
import '../widgets/loan_card.dart';
import '../widgets/deposit_card.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  static const _navTitles = ['Мой банк', 'Архив', 'Платежи', 'Чаты', 'Оформить'];

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<({List<LoanModel> loans, List<DepositModel> deposits})>>(
      archiveProvider,
      (_, next) {
        next.whenOrNull(
          error: (e, _) {
            if (e is AuthException && e.statusCode == 401 && mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ref.read(authProvider.notifier).logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              });
            }
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildMainTab(),
          _buildArchiveTab(),
          _buildPlaceholderTab(_navTitles[2]),
          _buildPlaceholderTab(_navTitles[3]),
          _buildPlaceholderTab(_navTitles[4]),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMainTab() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HomeHeader(
              username: widget.username,
              onProfileTap: _logout,
            ),
          ),
          SliverToBoxAdapter(child: _buildPromoBanners()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: const BonusCard(),
            ),
          ),
          SliverToBoxAdapter(child: _buildArchiveSectionInMain()),
          SliverToBoxAdapter(child: _buildCreditsSection()),
          SliverToBoxAdapter(child: _buildSavingsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildArchiveTab() {
    final asyncValue = ref.watch(archiveProvider);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'Архив',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: asyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.lime)),
              error: (e, _) {
                if (e is AuthException && e.statusCode == 401) {
                  return const SizedBox.shrink();
                }
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        e.toString().contains('502') || e.toString().contains('временно')
                            ? 'Данные временно недоступны'
                            : 'Не удалось загрузить данные',
                        style: const TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => ref.read(archiveProvider.notifier).refresh(),
                        child: const Text('Повторить', style: TextStyle(color: AppColors.lime)),
                      ),
                    ],
                  ),
                );
              },
              data: (archive) => RefreshIndicator(
                color: AppColors.lime,
                onRefresh: () => ref.read(archiveProvider.notifier).refresh(),
                child: CustomScrollView(
                  slivers: [
                    if (archive.loans.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text('Займы', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: LoanCard(loan: archive.loans[i]),
                          ),
                          childCount: archive.loans.length,
                        ),
                      ),
                    ],
                    if (archive.deposits.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text('Вклады', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: DepositCard(deposit: archive.deposits[i]),
                          ),
                          childCount: archive.deposits.length,
                        ),
                      ),
                    ],
                    if (archive.loans.isEmpty && archive.deposits.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'Нет закрытых договоров',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Раздел в разработке',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _banners = [
    (
      title: 'Покупайте без кредитов',
      gradient: LinearGradient(
        colors: [AppColors.purpleCardStart, AppColors.purpleCardEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.shopping_bag_outlined,
    ),
    (
      title: 'Мы в MAX',
      gradient: LinearGradient(
        colors: [AppColors.darkCardStart, AppColors.darkCardEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.play_circle_outline,
    ),
    (
      title: 'Быстрые переводы',
      gradient: LinearGradient(
        colors: [AppColors.blueCardStart, AppColors.blueCardEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.currency_ruble,
    ),
    (
      title: 'Обменяем монеты бесплатно',
      gradient: LinearGradient(
        colors: [AppColors.goldCardStart, AppColors.goldCardEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.toll_outlined,
    ),
  ];

  Widget _buildPromoBanners() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: CarouselSlider.builder(
        itemCount: _banners.length,
        options: CarouselOptions(
          height: 128,
          viewportFraction: 0.48,
          enableInfiniteScroll: false,
          padEnds: false,
        ),
        itemBuilder: (context, i, realIndex) => Padding(
          padding: EdgeInsets.only(left: i == 0 ? 16 : 0, right: 8),
          child: PromoBannerCard(
            title: _banners[i].title,
            gradient: _banners[i].gradient,
            icon: _banners[i].icon,
          ),
        ),
      ),
    );
  }

  Widget _buildArchiveSectionInMain() {
    final asyncValue = ref.watch(archiveProvider);
    return asyncValue.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) {
        if (kDebugMode) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('[debug] archive error: $e', style: const TextStyle(color: Colors.red, fontSize: 11)),
          );
        }
        return const SizedBox.shrink();
      },
      data: (archive) {
        if (archive.loans.isEmpty && archive.deposits.isEmpty) return const SizedBox.shrink();
        final fmt = NumberFormat('#,##0', 'ru_RU');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Архив',
              actionLabel: 'Все',
              onAction: () => setState(() => _navIndex = 1),
            ),
            ...archive.loans.map(
              (loan) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: CreditCardTile(
                  amount: '${fmt.format(loan.amount)} ₽',
                  label: '${loan.number} · ${loan.name}',
                  leadingIcon: Icons.history_outlined,
                  badgeText: loan.status,
                  badgeColor: AppColors.textSecondary,
                ),
              ),
            ),
            ...archive.deposits.map(
              (deposit) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: CreditCardTile(
                  amount: '${fmt.format(deposit.currentAmount)} ₽',
                  label: '${deposit.number} · ${deposit.name}',
                  leadingIcon: Icons.savings_outlined,
                  badgeText: deposit.status,
                  badgeColor: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreditsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Кредиты', actionLabel: 'Получить'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: const CreditCardTile(
            amount: '59 701,30 ₽',
            label: 'Кредит на покупку',
            badgeText: 'Денег хватит для платежа',
            badgeColor: AppColors.green,
            leadingIcon: Icons.credit_card_outlined,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: _buildCreditPromo(),
        ),
      ],
    );
  }

  Widget _buildCreditPromo() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.creditPromoBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Запустите мечты',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'До 933 000 ₽ на любые грандиозные цели',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.lime.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.rocket_launch_outlined, color: AppColors.lime, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Вклады и счета', actionLabel: 'Открыть'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const CreditCardTile(
            amount: '0 ₽',
            label: 'Нет активных вкладов',
            leadingIcon: Icons.savings_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _navIndex,
      onDestinationSelected: (i) => setState(() => _navIndex = i),
      backgroundColor: AppColors.surface,
      indicatorColor: const Color(0x22B5FF4D),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined, color: AppColors.textSecondary),
          selectedIcon: const Icon(Icons.home, color: AppColors.lime),
          label: 'Home',
        ),
        NavigationDestination(
          icon: const Icon(Icons.history_outlined, color: AppColors.textSecondary),
          selectedIcon: const Icon(Icons.history, color: AppColors.lime),
          label: 'Архив',
        ),
        NavigationDestination(
          icon: const Icon(Icons.payments_outlined, color: AppColors.textSecondary),
          selectedIcon: const Icon(Icons.payments, color: AppColors.lime),
          label: 'Платежи',
        ),
        NavigationDestination(
          icon: const Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary),
          selectedIcon: const Icon(Icons.chat_bubble, color: AppColors.lime),
          label: 'Чаты',
        ),
        NavigationDestination(
          icon: const Icon(Icons.add_card_outlined, color: AppColors.textSecondary),
          selectedIcon: const Icon(Icons.add_card, color: AppColors.lime),
          label: 'Оформить',
        ),
      ],
    );
  }
}
