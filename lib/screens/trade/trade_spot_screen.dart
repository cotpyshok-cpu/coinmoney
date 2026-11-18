import 'package:flutter/material.dart';
import '../../models/coin_model.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../operations/crypto_operation_screen.dart';
import 'coin_graph_screen.dart';

/// Spot Trading screen matching Spot.png with live order book, limit/market
/// order builder, percentage slider, and Open Orders list.
class TradeSpotScreen extends StatefulWidget {
  const TradeSpotScreen({super.key});

  @override
  State<TradeSpotScreen> createState() => _TradeSpotScreenState();
}

class _TradeSpotScreenState extends State<TradeSpotScreen> {
  int _tradeMode = 0; // 0: Spot, 1: Margin, 2: Grid, 3: Fiat
  bool _isBuy = true;
  String _orderType = 'Limit';
  int _depthCount = 10;
  String _precision = '0.00001';
  double _sliderPercent = 0;

  late TextEditingController _priceCtrl;
  late TextEditingController _amountCtrl;

  static const _modes = ['Spot', 'Margin', 'Grid', 'Fiat'];

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(text: '30113.80');
    _amountCtrl = TextEditingController(text: '0.015');
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  double get _priceVal =>
      double.tryParse(_priceCtrl.text.replaceAll(',', '')) ?? 30113.80;
  double get _amountVal =>
      double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0.0;
  double get _totalUsdt => _priceVal * _amountVal;

  void _stepPrice(double delta) {
    final next = (_priceVal + delta).clamp(0.01, 999999.0);
    setState(() => _priceCtrl.text = next.toStringAsFixed(2));
  }

  void _stepAmount(double delta) {
    final next = (_amountVal + delta).clamp(0.0, 1000.0);
    setState(() => _amountCtrl.text = next.toStringAsFixed(4));
  }

  void _applyPercent(double pct, double availableUsdt) {
    setState(() {
      _sliderPercent = pct;
      if (_priceVal > 0) {
        final amount = (availableUsdt * (pct / 100)) / _priceVal;
        _amountCtrl.text = amount.toStringAsFixed(5);
      }
    });
  }

  void _placeOrder(AppState state, CoinModel coin) {
    if (_amountVal <= 0) return;
    state.addOpenOrder(
      OpenOrderItem(
        id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
        pair: coin.pair,
        side: _isBuy ? 'Buy' : 'Sell',
        orderType: _orderType,
        price: _priceVal,
        amount: _amountVal,
        totalUsdt: _totalUsdt,
        timeLabel: 'Just now',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_isBuy ? "Buy" : "Sell"} $_orderType order placed: ${_amountVal.toStringAsFixed(4)} ${coin.symbol}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final state = AppStateScope.of(context);
    final coin = state.selectedCoin;
    const availableUsdt = 1000.0;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: c.textSecondary, size: 20),
                    onPressed: () => state.setBottomTab(0),
                  ),
                  Text(
                    'Trade',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.assignment_outlined,
                        color: c.textSecondary, size: 24),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CryptoOperationScreen(
                            initialTab: 0,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Spot | Margin | Grid | Fiat selector
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
                  children: List.generate(_modes.length, (i) {
                    final active = i == _tradeMode;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tradeMode = i),
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
                              _modes[i],
                              style: TextStyle(
                                color: active ? c.textPrimary : c.textSecondary,
                                fontSize: 14,
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
            // Pair selector + Chart shortcut
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PopupMenuButton<String>(
                          color: c.surface,
                          onSelected: (sym) {
                            state.selectCoin(sym);
                            final next = state.findCoin(sym);
                            if (next != null) {
                              _priceCtrl.text = next.price.toStringAsFixed(2);
                            }
                          },
                          itemBuilder: (_) => ['BTC', 'ETH', 'SOL', 'BNB', 'LTC']
                              .map((s) => PopupMenuItem(
                                    value: s,
                                    child: Text('$s/USDT'),
                                  ))
                              .toList(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                coin.pair,
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down, color: c.textPrimary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              coin.priceFormatted,
                              style: const TextStyle(
                                color: AppColors.positiveTextGreen,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '≈\$${coin.priceFormatted}',
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
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
                  IconButton(
                    icon: Icon(Icons.show_chart_rounded,
                        color: c.textSecondary, size: 28),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CoinGraphScreen(initialCoin: coin),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Order Book (Left) + Trade Panel (Right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Book Left Column
                  Expanded(
                    flex: 44,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order bk No.',
                                style: TextStyle(
                                    color: c.textSecondary, fontSize: 12)),
                            Text('Unit',
                                style: TextStyle(
                                    color: c.textSecondary, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _MiniDropdown(
                                label: '$_depthCount',
                                onTap: () => setState(() =>
                                    _depthCount = _depthCount == 10 ? 6 : 10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: _MiniDropdown(
                                label: _precision,
                                onTap: () => setState(() => _precision =
                                    _precision == '0.00001' ? '0.001' : '0.00001'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Price',
                                style: TextStyle(
                                    color: c.textSecondary, fontSize: 12)),
                            Text('Amount',
                                style: TextStyle(
                                    color: c.textSecondary, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...CoinMockData.askOrders
                            .take(_depthCount)
                            .map((row) => _orderBookRow(row, true, c)),
                        const SizedBox(height: 6),
                        ...CoinMockData.bidOrders
                            .take(_depthCount)
                            .map((row) => _orderBookRow(row, false, c)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Order Entry Right Column
                  Expanded(
                    flex: 56,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 38,
                          decoration: c.cardDecoration(radius: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isBuy = true),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _isBuy
                                          ? AppColors.primaryBlue
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Buy',
                                        style: TextStyle(
                                          color: _isBuy
                                              ? Colors.white
                                              : c.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isBuy = false),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: !_isBuy
                                          ? AppColors.negativeRed
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Sell',
                                        style: TextStyle(
                                          color: !_isBuy
                                              ? Colors.white
                                              : c.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: c.cardDecoration(radius: 10),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _orderType,
                              isExpanded: true,
                              dropdownColor: c.surface,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Limit', child: Text('Limit')),
                                DropdownMenuItem(value: 'Market', child: Text('Market')),
                                DropdownMenuItem(
                                    value: 'Stop-Limit', child: Text('Stop-Limit')),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _orderType = v);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Available:',
                            style:
                                TextStyle(color: c.textSecondary, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          '1000 USDT',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _StepperField(
                          controller: _priceCtrl,
                          unit: 'USDT',
                          onMinus: () => _stepPrice(-50),
                          onPlus: () => _stepPrice(50),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        _StepperField(
                          controller: _amountCtrl,
                          unit: coin.symbol,
                          onMinus: () => _stepAmount(-0.005),
                          onPlus: () => _stepAmount(0.005),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: c.cardDecoration(radius: 8),
                            child: Text(
                              '${_sliderPercent.round()}%',
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primaryBlue,
                            inactiveTrackColor: c.border,
                            thumbColor: AppColors.primaryBlue,
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _sliderPercent,
                            min: 0,
                            max: 100,
                            divisions: 4,
                            onChanged: (v) => _applyPercent(v, availableUsdt),
                          ),
                        ),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: c.cardDecoration(radius: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _totalUsdt.toStringAsFixed(2),
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'USDT',
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _placeOrder(state, coin),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: _isBuy
                                  ? AppColors.primaryBlue
                                  : AppColors.negativeRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              '${_isBuy ? "Buy" : "Sell"} ${coin.symbol}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
            const SizedBox(height: 18),
            // Open Orders section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Open Orders (${state.openOrders.length})',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CryptoOperationScreen(
                            initialTab: 0,
                          ),
                        ),
                      );
                    },
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
            ),
            if (state.openOrders.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Column(
                  children: state.openOrders
                      .map(
                        (ord) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: c.cardDecoration(radius: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${ord.side} ${ord.pair} (${ord.orderType})',
                                    style: TextStyle(
                                      color: ord.side == 'Buy'
                                          ? AppColors.positiveTextGreen
                                          : AppColors.negativeTextRed,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Price: ${ord.price.toStringAsFixed(2)} • Amt: ${ord.amount.toStringAsFixed(4)}',
                                    style: TextStyle(
                                        color: c.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                              Text(
                                '\$${ord.totalUsdt.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _orderBookRow(
      Map<String, dynamic> row, bool isAsk, AppColors c) {
    final price = (row['price'] as double);
    final amount = row['amount'] as String;
    final fill = row['fill'] as double;
    final priceColor =
        isAsk ? AppColors.negativeTextRed : AppColors.positiveTextGreen;
    final bgColor =
        (isAsk ? AppColors.negativeRed : AppColors.positiveGreen)
            .withValues(alpha: 0.16);

    return GestureDetector(
      onTap: () => setState(() => _priceCtrl.text = price.toStringAsFixed(2)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            FractionallySizedBox(
              widthFactor: fill * 0.55,
              child: Container(height: 17, color: bgColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price.toStringAsFixed(2),
                  style: TextStyle(
                    color: priceColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniDropdown extends StatelessWidget {
  const _MiniDropdown({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: c.cardDecoration(radius: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: c.textPrimary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _StepperField extends StatelessWidget {
  const _StepperField({
    required this.controller,
    required this.unit,
    required this.onMinus,
    required this.onPlus,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String unit;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: c.cardDecoration(radius: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMinus,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.remove, color: c.textSecondary, size: 18),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: onPlus,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.add, color: c.textSecondary, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
