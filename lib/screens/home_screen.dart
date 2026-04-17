import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/app_colors.dart';
import '../widgets/home_header.dart';
import '../widgets/promo_banner_card.dart';
import '../widgets/bonus_card.dart';
import '../widgets/section_header.dart';
import '../widgets/credit_card_tile.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  static const _navTitles = ['Мой банк', 'История', 'Платежи', 'Чаты', 'Оформить'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildMainTab(),
          _buildPlaceholderTab(_navTitles[1]),
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
          SliverToBoxAdapter(child: _buildCardsSection()),
          SliverToBoxAdapter(child: _buildCreditsSection()),
          SliverToBoxAdapter(child: _buildSavingsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
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

  Widget _buildCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Карты', actionLabel: 'Оформить'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Карты не добавлены',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
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
          label: 'История',
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
