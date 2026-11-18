import 'package:flutter/material.dart';
import '../../models/coin_model.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/coin_badge.dart';
import '../../widgets/illustrations/app_illustrations.dart';
import '../../widgets/primary_button.dart';

/// Unified Buy / Sell / Exchange / Withdraw flow matching operation with coin*.jpg,
/// Withdraw*.jpg, and Transaction Success*.jpg.
class CryptoOperationScreen extends StatefulWidget {
  const CryptoOperationScreen({
    super.key,
    this.initialTab = 0,
    this.coin,
  });

  /// 0: Buy, 1: Sell, 2: Exchange, 3: Withdraw
  final int initialTab;
  final CoinModel? coin;

  @override
  State<CryptoOperationScreen> createState() => _CryptoOperationScreenState();
}

class _CryptoOperationScreenState extends State<CryptoOperationScreen> {
  late int _tabIndex;
  int _flowStep = 0; // 0: Amount Keypad, 1: Confirmation, 2: Success
  String _amountText = '1000';
  String _paymentMethod = 'Coinmoney Wallet';
  String _fromSymbol = 'BTC';
  String _toSymbol = 'ETH';

  static const _tabs = ['Buy', 'Sell', 'Exchange', 'Withdraw'];

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab.clamp(0, 3);
    if (_tabIndex == 3) {
      _amountText = '400';
      _paymentMethod = 'monobank';
    }
    if (widget.coin != null) {
      _fromSymbol = widget.coin!.symbol;
    }
  }

  double get _usdValue => double.tryParse(_amountText) ?? 0.0;
  double get _feePercent =>
      _tabIndex == 3 ? 0.02 : (_tabIndex == 2 ? 0.0 : 0.0005);
  double get _feeAmount => _usdValue * _feePercent;
  double get _totalUsd => _usdValue + _feeAmount;

  String get _screenTitle {
    if (_flowStep == 1) {
      return _tabIndex == 3 ? 'Buy Crypto' : 'Confirmation';
    }
    if (_flowStep == 2) return 'Transaction Completed';
    switch (_tabIndex) {
      case 0:
        return 'Buy Crypto';
      case 1:
        return 'Sell Crypto';
      case 2:
        return 'Exchange Crypto';
      default:
        return 'Withdraw';
    }
  }

  void _onDigit(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amountText.length > 1) {
          _amountText = _amountText.substring(0, _amountText.length - 1);
        } else {
          _amountText = '0';
        }
      } else if (key == '.') {
        if (!_amountText.contains('.')) _amountText += '.';
      } else {
        _amountText = _amountText == '0' ? key : '$_amountText$key';
      }
    });
  }

  void _showPaymentPicker(AppColors c) {
    final methods = [
      ('Coinmoney Wallet', 'XXXX5555', Icons.apple),
      ('PayPal', 'XXXX5555', Icons.account_balance_wallet_outlined),
      ('monobank', 'XXXX5555', Icons.credit_card),
      ('Debit card', 'XXXX5555', Icons.payment),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: c.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose Payment Methods',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              ...methods.map((m) {
                final selected = _paymentMethod == m.$1;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: c.secondarySurface,
                    child: Icon(m.$3, color: AppColors.primaryBlue),
                  ),
                  title: Text(
                    m.$1,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(m.$2, style: TextStyle(color: c.textSecondary)),
                  trailing: selected
                      ? const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.positiveTextGreen,
                        )
                      : null,
                  onTap: () {
                    setState(() => _paymentMethod = m.$1);
                    setModal(() {});
                  },
                );
              }),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Continue',
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmOperation(AppState state) {
    final isPositive = _tabIndex == 0;
    state.recordTransaction(
      title: '${_tabs[_tabIndex]} $_fromSymbol',
      subtitle: _tabIndex == 2 ? 'To $_toSymbol' : _paymentMethod,
      amountText: _tabIndex == 3
          ? '-\$${_usdValue.toStringAsFixed(0)}'
          : '+\$${_usdValue.toStringAsFixed(0)}',
      iconType: 'btc',
      isPositive: isPositive,
      balanceDeltaUsd: _tabIndex == 3 ? -_totalUsd : (_tabIndex == 0 ? _usdValue : 0),
    );
    setState(() => _flowStep = 2);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final state = AppStateScope.of(context);

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
                    onPressed: () {
                      if (_flowStep > 0 && _flowStep < 2) {
                        setState(() => _flowStep--);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  Text(
                    _screenTitle,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline,
                        color: c.textSecondary, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: _flowStep == 0
                  ? _buildAmountStep(c, state)
                  : (_flowStep == 1
                      ? _buildConfirmationStep(c, state)
                      : _buildSuccessStep(c)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountStep(AppColors c, AppState state) {
    final coin = state.findCoin(_fromSymbol) ?? state.selectedCoin;
    final receiveCoin = state.findCoin(_toSymbol) ?? state.selectedCoin;
    final receiveQty =
        _tabIndex == 2 ? (_usdValue / receiveCoin.price) : (_usdValue / coin.price);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: c.secondarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final active = i == _tabIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _tabIndex = i;
                      if (i == 3) _paymentMethod = 'monobank';
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: active ? c.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _tabs[i],
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
          const SizedBox(height: 16),
          Text(
            _tabIndex == 2 ? 'You Convert' : 'You Pay',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$$_amountText',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _tabIndex == 3 ? 'Available Balance' : 'You Receive',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: c.cardDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity',
                        style: TextStyle(color: c.textSecondary, fontSize: 13)),
                    Text(
                      _tabIndex == 3
                          ? state.portfolioBalanceUsd.toStringAsFixed(2)
                          : receiveQty.toStringAsFixed(6),
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  _tabIndex == 3
                      ? 'USD'
                      : (_tabIndex == 2 ? _toSymbol : _fromSymbol),
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _tabIndex == 2
                  ? 'Exchange'
                  : (_tabIndex == 3
                      ? 'Withdraw to'
                      : 'Payment Methods Available'),
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_tabIndex == 2)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: c.cardDecoration(),
              child: Row(
                children: [
                  CoinBadge(symbol: _fromSymbol, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From',
                            style: TextStyle(
                                color: c.textSecondary, fontSize: 12)),
                        Text(coin.name,
                            style: TextStyle(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz,
                        color: AppColors.primaryBlue),
                    onPressed: () {
                      setState(() {
                        final tmp = _fromSymbol;
                        _fromSymbol = _toSymbol;
                        _toSymbol = tmp;
                      });
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('To',
                            style: TextStyle(
                                color: c.textSecondary, fontSize: 12)),
                        Text(receiveCoin.name,
                            style: TextStyle(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  CoinBadge(symbol: _toSymbol, size: 36),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () => _showPaymentPicker(c),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: c.cardDecoration(),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance,
                        color: AppColors.primaryBlue, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _paymentMethod,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text('XXXX5555',
                              style: TextStyle(
                                  color: c.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: c.textSecondary),
                  ],
                ),
              ),
            ),
          const Spacer(),
          _buildKeypad(c),
          const SizedBox(height: 12),
          PrimaryButton(
            label: _tabIndex == 2
                ? 'CONVERT'
                : _tabs[_tabIndex].toUpperCase(),
            enabled: _usdValue > 0,
            onPressed: () => setState(() => _flowStep = 1),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildKeypad(AppColors c) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];
    return Column(
      children: keys
          .map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: row.map((k) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Material(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () => _onDigit(k),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 44,
                            alignment: Alignment.center,
                            child: k == '⌫'
                                ? Icon(Icons.backspace_outlined,
                                    color: c.textPrimary, size: 20)
                                : Text(
                                    k,
                                    style: TextStyle(
                                      color: c.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildConfirmationStep(AppColors c, AppState state) {
    final coin = state.findCoin(_fromSymbol) ?? state.selectedCoin;
    final qty = (_usdValue / coin.price).toStringAsFixed(6);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            _tabIndex == 3
                ? 'Total Amount'
                : (_tabIndex == 2 ? 'You Convert' : 'You Pay'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${_tabIndex == 3 ? _totalUsd.toStringAsFixed(0) : _amountText}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _tabIndex == 3 ? 'Available Balance' : 'You Receive',
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: c.cardDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity',
                        style: TextStyle(color: c.textSecondary, fontSize: 13)),
                    Text(
                      _tabIndex == 3
                          ? state.portfolioBalanceUsd.toStringAsFixed(2)
                          : qty,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  _tabIndex == 3 ? 'USD' : _fromSymbol,
                  style: TextStyle(
                      color: c.textPrimary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Order',
            style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: c.cardDecoration(),
            child: Column(
              children: [
                _orderRow(
                  _tabIndex == 3 ? 'Bank Account' : 'Payment methods',
                  '$_paymentMethod XXXX5555',
                  c,
                ),
                Divider(height: 1, color: c.border),
                _orderRow(
                  _tabIndex == 3 ? 'Withdrawal Amount' : 'Amount',
                  _tabIndex == 3
                      ? '\$${_usdValue.toStringAsFixed(0)}'
                      : '$qty $_fromSymbol \$$_amountText',
                  c,
                ),
                Divider(height: 1, color: c.border),
                _orderRow(
                  'Transaction Fee (${(_feePercent * 100).toStringAsFixed(2)}%)',
                  '\$${_feeAmount.toStringAsFixed(1)}',
                  c,
                ),
                Divider(height: 1, color: c.border),
                _orderRow(
                  'Total',
                  '\$${_totalUsd.toStringAsFixed(0)}',
                  c,
                ),
              ],
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Confirm',
            onPressed: () => _confirmOperation(state),
          ),
        ],
      ),
    );
  }

  Widget _orderRow(String left, String right, AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: TextStyle(color: c.textSecondary, fontSize: 15)),
          Text(
            right,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(AppColors c) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          const OrbitalBadgeIllustration(isSuccess: true, size: 200),
          const SizedBox(height: 22),
          Text(
            _tabIndex == 2 ? 'Exchange Successful' : 'Transaction Success',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _tabIndex == 3
                ? 'We have processed your withdrawal request. The amount will be processed within 2-5 hours.'
                : 'You have successfully initiated the transaction. Amount will reflect in wallet within 1 hour.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: c.cardDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coinmoney Wallet',
                        style: TextStyle(color: c.textSecondary, fontSize: 13)),
                    Text(
                      '\$${_totalUsd.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: c.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.arrow_forward, color: c.textSecondary),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _tabIndex == 2 ? _toSymbol : _paymentMethod,
                      style: TextStyle(color: c.textSecondary, fontSize: 13),
                    ),
                    Text(
                      '\$$_amountText',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
