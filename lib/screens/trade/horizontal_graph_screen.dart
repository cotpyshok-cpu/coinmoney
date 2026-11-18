import 'package:flutter/material.dart';
import '../../models/coin_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/charts/candlestick_chart_widget.dart';

/// Fullscreen technical analysis chart matching horizontal view graph.png & -1.png.
class HorizontalGraphScreen extends StatefulWidget {
  const HorizontalGraphScreen({super.key, required this.coin});

  final CoinModel coin;

  @override
  State<HorizontalGraphScreen> createState() => _HorizontalGraphScreenState();
}

class _HorizontalGraphScreenState extends State<HorizontalGraphScreen> {
  String _mainIndicator = 'MA';
  String _subIndicator = 'MACD';
  int _selectedTool = 0;

  static const _tools = [
    Icons.add,
    Icons.edit_outlined,
    Icons.timeline,
    Icons.share_outlined,
    Icons.brush_outlined,
    Icons.text_fields,
    Icons.crop_square_outlined,
    Icons.sentiment_satisfied_alt_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final coin = widget.coin;

    return Scaffold(
      body: SafeArea(
        child: RotatedBox(
          quarterTurns: MediaQuery.of(context).size.width < 600 ? 1 : 0,
          child: Container(
            color: c.background,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              children: [
                // Top ticker strip
                Row(
                  children: [
                    Icon(Icons.settings_outlined,
                        color: c.textSecondary, size: 22),
                    const SizedBox(width: 14),
                    Text(
                      '${coin.pair}  \$${coin.priceFormatted}',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '+813.18  (${coin.formattedChange24h})',
                      style: const TextStyle(
                        color: AppColors.positiveTextGreen,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '24HH ${coin.topPriceFormatted}   24HL ${coin.lowPriceFormatted}',
                      style: TextStyle(color: c.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(Icons.close_fullscreen_rounded,
                          color: c.textSecondary, size: 22),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Divider(height: 1, color: c.border),
                const SizedBox(height: 4),
                Expanded(
                  child: Row(
                    children: [
                      // Left drawing tools rail
                      SizedBox(
                        width: 38,
                        child: ListView.builder(
                          itemCount: _tools.length,
                          itemBuilder: (_, i) {
                            final active = _selectedTool == i;
                            return IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                _tools[i],
                                size: 19,
                                color: active
                                    ? AppColors.primaryBlue
                                    : c.textSecondary,
                              ),
                              onPressed: () =>
                                  setState(() => _selectedTool = i),
                            );
                          },
                        ),
                      ),
                      VerticalDivider(width: 1, color: c.border),
                      // Main candlestick + MA + Volume chart pane
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 10,
                                children: const [
                                  Text('MA5:30,0113.80',
                                      style: TextStyle(
                                          color: Color(0xFFF5A623),
                                          fontSize: 10.5)),
                                  Text('MA10:30,0108.01',
                                      style: TextStyle(
                                          color: Color(0xFF16B14B),
                                          fontSize: 10.5)),
                                  Text('MA30:30,2113.50',
                                      style: TextStyle(
                                          color: Color(0xFF7B61FF),
                                          fontSize: 10.5)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) =>
                                      CandlestickChartWidget(
                                    candles: coin.candles,
                                    xLabels: const [
                                      '16:30',
                                      '16:45',
                                      '17:00',
                                      '17:15',
                                      '17:30',
                                      '17:45',
                                      '18:00'
                                    ],
                                    yLabels: const [
                                      '31000.00',
                                      '30500.00',
                                      '30000.00',
                                      '29500.00'
                                    ],
                                    showMovingAverages: _mainIndicator == 'MA',
                                    showBollinger: _mainIndicator == 'BOLL',
                                    showVolumePane: true,
                                    height: (constraints.maxHeight - 24)
                                        .clamp(120.0, 500.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      VerticalDivider(width: 1, color: c.border),
                      // Right indicators panel
                      SizedBox(
                        width: 78,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Main',
                                  style: TextStyle(
                                      color: c.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              ...['MA', 'BOLL'].map((ind) => _indicatorBtn(
                                    label: ind,
                                    active: _mainIndicator == ind,
                                    c: c,
                                    onTap: () =>
                                        setState(() => _mainIndicator = ind),
                                  )),
                              const SizedBox(height: 8),
                              Text('Sub',
                                  style: TextStyle(
                                      color: c.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              ...['MACD', 'KDJ', 'RSI', 'WR'].map((ind) =>
                                  _indicatorBtn(
                                    label: ind,
                                    active: _subIndicator == ind,
                                    c: c,
                                    onTap: () =>
                                        setState(() => _subIndicator = ind),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _indicatorBtn({
    required String label,
    required bool active,
    required AppColors c,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryBlue : c.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.primaryBlue : c.border),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : c.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
