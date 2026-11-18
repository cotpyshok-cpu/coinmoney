import 'package:flutter/material.dart';
import '../../models/coin_model.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/charts/area_chart_widget.dart';
import '../../widgets/charts/candlestick_chart_widget.dart';
import '../../widgets/coin_badge.dart';
import '../operations/crypto_operation_screen.dart';
import 'horizontal_graph_screen.dart';

/// Coin Trading / Graph details screen matching Bitcoin Graph.png,
/// 1 Year Bitcoin Graph.jpg, Ethereum Graph.jpg, and Bitcoin Candles Graph.jpg.
class CoinGraphScreen extends StatefulWidget {
  const CoinGraphScreen({super.key, this.initialCoin});

  final CoinModel? initialCoin;

  @override
  State<CoinGraphScreen> createState() => _CoinGraphScreenState();
}

class _CoinGraphScreenState extends State<CoinGraphScreen> {
  late String _activeSymbol;
  int _timeframeIndex = 0; // 0: 1Hour, 1: 1Day, 2: 1Month, 3: 1Year
  bool _candleMode = false;

  static const _timeframes = ['1Hour', '1Day', '1Month', '1Year'];
  static const _popularSymbols = ['BTC', 'ETH', 'LTC', 'XRP'];

  @override
  void initState() {
    super.initState();
    _activeSymbol = widget.initialCoin?.symbol ?? 'BTC';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final state = AppStateScope.of(context);
    final coin = state.findCoin(_activeSymbol) ?? state.selectedCoin;
    final isYear = _timeframeIndex == 3;
    final chartPoints = isYear ? coin.yearlyChartPoints : coin.hourlyChartPoints;
    final xLabels = isYear
        ? const ['Mar', 'Apr', 'May', 'Jun', 'Jul']
        : const ['10:00', '12:00', '14:00', '16:00', '18:00'];
    final changeText = isYear
        ? '+${coin.change1Y.toStringAsFixed(2)}%'
        : coin.formattedChange24h;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: c.textSecondary, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Trading',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      state.isFavorite(coin.symbol)
                          ? Icons.star
                          : Icons.assignment_outlined,
                      color: state.isFavorite(coin.symbol)
                          ? AppColors.favoriteOrange
                          : c.textSecondary,
                      size: 24,
                    ),
                    onPressed: () => state.toggleFavorite(coin.symbol),
                  ),
                ],
              ),
            ),
            // Timeframe segmented selector
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
                  children: List.generate(_timeframes.length, (i) {
                    final active = i == _timeframeIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _timeframeIndex = i),
                        child: Container(
                          decoration: BoxDecoration(
                            color: active ? c.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              _timeframes[i],
                              style: TextStyle(
                                color: active ? c.textPrimary : c.textSecondary,
                                fontSize: 13.5,
                                fontWeight:
                                    active ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main Chart Card
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                      decoration: c.cardDecoration(radius: 16),
                      child: Column(
                        children: [
                          Row(
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
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
                                    '\$${coin.priceFormatted}',
                                    style: TextStyle(
                                      color: c.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    changeText,
                                    style: TextStyle(
                                      color: coin.isPositive || isYear
                                          ? AppColors.positiveTextGreen
                                          : AppColors.negativeTextRed,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (_candleMode)
                            CandlestickChartWidget(
                              candles: coin.candles,
                              xLabels: xLabels,
                              yLabels: _yLabelsFor(coin),
                              height: 175,
                            )
                          else
                            AreaChartWidget(
                              points: chartPoints,
                              xLabels: xLabels,
                              yLabels: _yLabelsFor(coin),
                              showYAxis: true,
                              showHorizontalGrid: true,
                              height: 175,
                            ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(Icons.track_changes,
                                  color: c.textSecondary, size: 22),
                              Icon(Icons.timeline,
                                  color: c.textSecondary, size: 22),
                              Icon(Icons.edit_outlined,
                                  color: c.textSecondary, size: 22),
                              IconButton(
                                icon: Icon(
                                  _candleMode
                                      ? Icons.show_chart_rounded
                                      : Icons.candlestick_chart_outlined,
                                  color: AppColors.primaryBlue,
                                  size: 24,
                                ),
                                onPressed: () =>
                                    setState(() => _candleMode = !_candleMode),
                              ),
                              IconButton(
                                icon: Icon(Icons.open_in_full_rounded,
                                    color: c.textSecondary, size: 22),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          HorizontalGraphScreen(coin: coin),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Popular Pairs',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _popularSymbols.map((sym) {
                          final active = sym == coin.symbol;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _activeSymbol = sym);
                                state.selectCoin(sym);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.primaryBlue
                                      : c.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: c.cardShadow,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$sym/USD',
                                  style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : c.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Trading History',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Price',
                            style: TextStyle(
                                color: c.textSecondary, fontSize: 13)),
                        Text('Amount',
                            style: TextStyle(
                                color: c.textSecondary, fontSize: 13)),
                        Text('Time',
                            style: TextStyle(
                                color: c.textSecondary, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...CoinMockData.tradingHistoryRows.map((row) {
                      final isSell = row['side'] == 'sell';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              row['price']!,
                              style: TextStyle(
                                color: isSell
                                    ? AppColors.negativeTextRed
                                    : AppColors.positiveTextGreen,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isSell
                                        ? AppColors.negativeRed
                                        : AppColors.positiveGreen)
                                    .withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                row['amount']!,
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              row['time']!,
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            // Sticky SELL / BUY buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CryptoOperationScreen(
                                initialTab: 1,
                                coin: coin,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.south_west_rounded,
                            color: AppColors.primaryBlue, size: 20),
                        label: const Text(
                          'SELL',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 1.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CryptoOperationScreen(
                                initialTab: 0,
                                coin: coin,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.north_east_rounded,
                            color: Colors.white, size: 20),
                        label: const Text(
                          'BUY',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _yLabelsFor(CoinModel coin) {
    if (coin.symbol == 'BTC') {
      return const ['32k', '31k', '30k', '29k', '28k', '27k'];
    }
    final p = coin.price;
    return [
      (p * 1.06).toStringAsFixed(p > 100 ? 0 : 2),
      (p * 1.03).toStringAsFixed(p > 100 ? 0 : 2),
      p.toStringAsFixed(p > 100 ? 0 : 2),
      (p * 0.97).toStringAsFixed(p > 100 ? 0 : 2),
      (p * 0.94).toStringAsFixed(p > 100 ? 0 : 2),
    ];
  }
}
