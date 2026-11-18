import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'favorites/favorites_screen.dart';
import 'home/home_screen.dart';
import 'market/market_screen.dart';
import 'trade/trade_spot_screen.dart';
import 'wallet/wallet_screen.dart';

/// Main 5-tab navigation shell (Home, Trade, Market, Favorites, Wallet).
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final state = AppStateScope.of(context);

    final pages = const <Widget>[
      HomeScreen(),
      TradeSpotScreen(),
      MarketScreen(),
      FavoritesScreen(),
      WalletScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: state.currentBottomTab,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: c.navBarBackground,
          boxShadow: [
            BoxShadow(
              color: c.cardShadow,
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavTabItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  active: state.currentBottomTab == 0,
                  onTap: () => state.setBottomTab(0),
                ),
                _NavTabItem(
                  icon: Icons.swap_horiz_rounded,
                  activeIcon: Icons.swap_horiz_rounded,
                  label: 'Trade',
                  active: state.currentBottomTab == 1,
                  onTap: () => state.setBottomTab(1),
                ),
                _NavTabItem(
                  icon: Icons.show_chart_rounded,
                  activeIcon: Icons.analytics_outlined,
                  label: 'Market',
                  active: state.currentBottomTab == 2,
                  onTap: () => state.setBottomTab(2),
                ),
                _NavTabItem(
                  icon: Icons.star_border_rounded,
                  activeIcon: Icons.star_border_rounded,
                  label: 'Favorites',
                  active: state.currentBottomTab == 3,
                  onTap: () => state.setBottomTab(3),
                ),
                _NavTabItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet_outlined,
                  label: 'Wallet',
                  active: state.currentBottomTab == 4,
                  onTap: () => state.setBottomTab(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  const _NavTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = active ? AppColors.primaryBlue : c.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
