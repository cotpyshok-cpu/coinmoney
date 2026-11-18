import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/charts/portfolio_donut_chart.dart';
import '../../widgets/charts/sparkline_painter.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/coinmoney_logo.dart';
import '../operations/crypto_operation_screen.dart';
import '../trade/coin_graph_screen.dart';

/// Wallet screen matching Wallet.png, Wallet Portfolio.png, and Wallet Portfolio-2.png
/// (+ dark -1 variants). Includes Cards carousel and expandable My Assets Portfolio.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final PageController _cardController = PageController(viewportFraction: 0.88);
  bool _assetsExpanded = false;

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  void _openOperation(BuildContext context, int tab) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CryptoOperationScreen(initialTab: tab),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final state = AppStateScope.of(context);
    final seg = state.walletSegmentIndex;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: c.textSecondary, size: 20),
                  onPressed: () => state.setBottomTab(0),
                ),
                Text(
                  'Wallet',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.qr_code_scanner_rounded,
                      color: c.textSecondary, size: 24),
                  onPressed: () => _openOperation(context, 0),
                ),
              ],
            ),
          ),
          // Cards | Portfolio segmented toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: c.secondarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _segmentBtn('Cards', seg == 0, c, () => state.setWalletSegment(0)),
                  _segmentBtn('Portfolio', seg == 1, c, () => state.setWalletSegment(1)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: seg == 0
                ? _buildCardsTab(context, c, state)
                : _buildPortfolioTab(context, c, state),
          ),
        ],
      ),
    );
  }

  Widget _segmentBtn(
      String label, bool active, AppColors c, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: active ? c.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: c.cardShadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? c.textPrimary : c.textSecondary,
                fontSize: 15,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardsTab(BuildContext context, AppColors c, AppState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.balanceVisible
                    ? 'My Balance: \$${state.portfolioBalanceUsd.toStringAsFixed(2)}'
                    : 'My Balance: \$••••••',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: Icon(
                  state.balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: c.textSecondary,
                ),
                onPressed: state.toggleBalanceVisible,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 185,
          child: PageView(
            controller: _cardController,
            children: const [
              _VirtualCard(
                gradient: [Color(0xFF428BF9), Color(0xFF2352E0)],
                number: '1901  0330  6060  5555',
                holder: 'Marcus Aurelius',
                expiry: '03/29',
              ),
              _VirtualCard(
                gradient: [Color(0xFF232733), Color(0xFF14171F)],
                number: '4441  1120  8832  9012',
                holder: 'Dmutro Tomashuk',
                expiry: '08/28',
              ),
              _VirtualCard(
                gradient: [Color(0xFF1BC88A), Color(0xFF0E9F6E)],
                number: '5375  4141  0092  3311',
                holder: 'Coinmoney Virtual',
                expiry: '11/27',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _actionButtonsRow(context, c),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: c.cardShadow,
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: c.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Transactions History',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.search, color: c.textPrimary, size: 22),
                    const SizedBox(width: 14),
                    Icon(Icons.tune, color: c.textPrimary, size: 22),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: Divider(color: c.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 16, color: c.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            '15.06.2022',
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: Divider(color: c.border)),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.transactions.length,
                    itemBuilder: (_, i) {
                      final tx = state.transactions[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: c.secondarySurface,
                          child: _txIcon(tx.iconType, c),
                        ),
                        title: Text(
                          tx.title,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          tx.subtitle,
                          style:
                              TextStyle(color: c.textSecondary, fontSize: 13),
                        ),
                        trailing: Text(
                          tx.amountText,
                          style: TextStyle(
                            color: tx.isPositive
                                ? AppColors.positiveTextGreen
                                : c.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioTab(BuildContext context, AppColors c, AppState state) {
    final assets = state.portfolioCoins;
    return Column(
      children: [
        // Allocation percentage pills
        SizedBox(
          height: 32,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: const [
              _AllocBadge('BTC 46%', Color(0xFFFFC155)),
              _AllocBadge('ATOM 35%', Color(0xFF1BC88A)),
              _AllocBadge('ETH 10%', Color(0xFF0088C6)),
              _AllocBadge('CRO 7%', Color(0xFF7D5AEF)),
              _AllocBadge('ADA 2%', Color(0xFFF44E95)),
            ],
          ),
        ),
        if (!_assetsExpanded) ...[
          const SizedBox(height: 12),
          PortfolioDonutChart(
            balanceText: '\$${state.portfolioBalanceUsd.toStringAsFixed(2)}',
            changeText: '+2.60%',
            balanceVisible: state.balanceVisible,
            onToggleVisibility: state.toggleBalanceVisible,
            size: 195,
          ),
          const SizedBox(height: 12),
          _actionButtonsRow(context, c),
          const SizedBox(height: 14),
        ] else
          const SizedBox(height: 12),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: c.cardShadow,
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      setState(() => _assetsExpanded = !_assetsExpanded),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 3.5,
                        decoration: BoxDecoration(
                          color: c.textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'My Assets',
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _assetsExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: c.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.search, color: c.textPrimary, size: 22),
                          const SizedBox(width: 12),
                          Icon(Icons.tune, color: c.textPrimary, size: 22),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: assets.length,
                    separatorBuilder: (_, __) => Divider(color: c.border, height: 1),
                    itemBuilder: (_, i) {
                      final coin = assets[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        onTap: () {
                          state.selectCoin(coin.symbol);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CoinGraphScreen(initialCoin: coin),
                            ),
                          );
                        },
                        leading: CoinBadge(symbol: coin.symbol, size: 42),
                        title: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    coin.symbol,
                                    style: TextStyle(
                                      color: c.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '\$${coin.priceFormatted}',
                                    style: TextStyle(
                                      color: coin.isPositive
                                          ? AppColors.positiveTextGreen
                                          : AppColors.negativeTextRed,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                SparklineChart(
                                  points: coin.sparklinePoints,
                                  isPositive: coin.isPositive,
                                  width: 82,
                                  height: 22,
                                ),
                                Text(
                                  coin.formattedChange24h,
                                  style: TextStyle(
                                    color: coin.isPositive
                                        ? AppColors.positiveTextGreen
                                        : AppColors.negativeTextRed,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  coin.holdings.toString(),
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '\$${coin.holdingsUsd.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: coin.isPositive
                                        ? AppColors.positiveTextGreen
                                        : AppColors.negativeTextRed,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButtonsRow(BuildContext context, AppColors c) {
    final actions = [
      (Icons.add_box_outlined, 'Deposit', 0),
      (Icons.north_east_rounded, 'Send', 2),
      (Icons.south_west_rounded, 'Receive', 0),
      (Icons.attach_money_rounded, 'Withdraw', 3),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((item) {
          return GestureDetector(
            onTap: () => _openOperation(context, item.$3),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue,
                    border: Border.all(
                      color: AppColors.primaryBlueSoft.withValues(alpha: 0.4),
                      width: 3,
                    ),
                  ),
                  child: Icon(item.$1, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  item.$2,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _txIcon(String type, AppColors c) {
    switch (type) {
      case 'apple':
        return Icon(Icons.apple, color: c.textPrimary, size: 26);
      case 'netflix':
        return const Text(
          'N',
          style: TextStyle(
            color: Color(0xFFE50914),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        );
      default:
        return const CoinBadge(symbol: 'BTC', size: 32);
    }
  }
}

class _VirtualCard extends StatelessWidget {
  const _VirtualCard({
    required this.gradient,
    required this.number,
    required this.holder,
    required this.expiry,
  });

  final List<Color> gradient;
  final String number;
  final String holder;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              CoinmoneyLogo(
                iconSize: 20,
                fontSize: 17,
                color: Colors.white,
              ),
              Icon(Icons.wifi, color: Colors.white, size: 26),
            ],
          ),
          Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Holder',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    holder,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                'Expire $expiry',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllocBadge extends StatelessWidget {
  const _AllocBadge(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
