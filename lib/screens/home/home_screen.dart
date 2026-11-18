import 'package:flutter/material.dart';
import '../../models/coin_model.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/charts/area_chart_widget.dart';
import '../../widgets/charts/sparkline_painter.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/coinmoney_logo.dart';
import '../settings/settings_screen.dart';
import '../trade/coin_graph_screen.dart';

/// Home dashboard matching HOME.png and HOME-1.png.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _openCoinGraph(BuildContext context, CoinModel coin) {
    AppStateScope.of(context).selectCoin(coin.symbol);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CoinGraphScreen(initialCoin: coin)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final state = AppStateScope.of(context);
    final movers = state.marketMovers;
    final portfolio = state.portfolioCoins;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.account_circle_outlined,
                        color: c.textSecondary, size: 28),
                    onPressed: () => _openSettings(context),
                  ),
                  const CoinmoneyLogo(iconSize: 25, fontSize: 21),
                  IconButton(
                    icon: Icon(Icons.settings_outlined,
                        color: c.textSecondary, size: 26),
                    onPressed: () => _openSettings(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Portfolio Balance',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state.balanceVisible
                  ? '\$${_formatMoney(state.portfolioBalanceUsd)}'
                  : '\$••••••',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              '+2.60%',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.positiveTextGreen,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            AreaChartWidget(
              points: CoinMockData.portfolioBalanceHistory,
              height: 155,
            ),
            const SizedBox(height: 18),
            _sectionHeader(
              title: 'Market Movers',
              onMore: () => state.setBottomTab(2),
              c: c,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 172,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: movers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final coin = movers[index];
                  return _MarketMoverCard(
                    coin: coin,
                    onTap: () => _openCoinGraph(context, coin),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            _sectionHeader(
              title: 'Portfolio',
              onMore: () => state.setBottomTab(4, walletSegment: 1),
              c: c,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: portfolio.take(3).map((coin) {
                  return GestureDetector(
                    onTap: () => _openCoinGraph(context, coin),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: c.cardDecoration(radius: 14),
                      child: Row(
                        children: [
                          CoinBadge(symbol: coin.symbol, size: 42),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coin.name,
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  coin.symbol,
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${coin.holdingsUsd.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                coin.formattedChange24h,
                                style: TextStyle(
                                  color: coin.isPositive
                                      ? AppColors.positiveTextGreen
                                      : AppColors.negativeTextRed,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required VoidCallback onMore,
    required AppColors c,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: onMore,
            child: const Text(
              'More',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      final revIdx = intPart.length - i;
      if (i > 0 && revIdx % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return '${buf.toString()}.${parts[1]}';
  }
}

class _MarketMoverCard extends StatelessWidget {
  const _MarketMoverCard({required this.coin, required this.onTap});

  final CoinModel coin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final displayPair = coin.symbol == 'SOL'
        ? 'Sol/USD'
        : '${coin.symbol}/USD';
    final displayPrice = coin.symbol == 'SOL' ? '40,11' : coin.priceFormatted;
    final displayVol = coin.symbol == 'BTC'
        ? '394 897 432,26'
        : (coin.symbol == 'SOL' ? '150 897 992,26' : coin.volumeFormatted);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 172,
        padding: const EdgeInsets.all(14),
        decoration: c.cardDecoration(radius: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayPair,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayPrice,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                CoinBadge(symbol: coin.symbol, size: 36),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              coin.symbol == 'SOL' ? '+3.75%' : coin.formattedChange24h,
              style: TextStyle(
                color: coin.isPositive
                    ? AppColors.positiveTextGreen
                    : AppColors.negativeTextRed,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: SparklineChart(
                points: coin.sparklinePoints,
                isPositive: coin.isPositive,
                width: 112,
                height: 28,
              ),
            ),
            const Spacer(),
            Text(
              '24H Vol.',
              style: TextStyle(color: c.textSecondary, fontSize: 11),
            ),
            Text(
              displayVol,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
