import 'package:flutter/material.dart';
import '../models/coin_model.dart';

/// Central reactive application state for theme, navigation tabs, favorites,
/// wallet portfolio, and user profile.
class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  int _currentBottomTab = 0;
  int _walletSegmentIndex = 0; // 0: Cards, 1: Portfolio
  String _selectedCoinSymbol = 'BTC';
  bool _balanceVisible = true;
  double _portfolioBalanceUsd = 2760.23;

  String _userEmail = 'tomashuk.dima.1992@gmail.com';
  String _userName = 'Dmutro';
  bool _isVerified = true;
  bool _touchIdEnabled = false;

  final List<CoinModel> _allCoins = List.of(CoinMockData.coins);
  final List<String> _favoriteSymbols = ['EGAME', 'LINK', 'BNB', 'LTC', 'FARM'];
  final List<String> _searchHistory = ['DOGE', 'KRB', 'QMALL'];
  final List<TransactionItem> _transactions = List.of(CoinMockData.defaultTransactions);
  final List<OpenOrderItem> _openOrders = [];

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  int get currentBottomTab => _currentBottomTab;
  int get walletSegmentIndex => _walletSegmentIndex;
  String get selectedCoinSymbol => _selectedCoinSymbol;
  bool get balanceVisible => _balanceVisible;
  double get portfolioBalanceUsd => _portfolioBalanceUsd;

  String get userEmail => _userEmail;
  String get userName => _userName;
  bool get isVerified => _isVerified;
  bool get touchIdEnabled => _touchIdEnabled;

  List<CoinModel> get allCoins => List.unmodifiable(_allCoins);
  List<String> get favoriteSymbols => List.unmodifiable(_favoriteSymbols);
  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  List<TransactionItem> get transactions => List.unmodifiable(_transactions);
  List<OpenOrderItem> get openOrders => List.unmodifiable(_openOrders);

  List<CoinModel> get favoriteCoins => _favoriteSymbols
      .map(findCoin)
      .whereType<CoinModel>()
      .toList();

  List<CoinModel> get portfolioCoins =>
      _allCoins.where((c) => c.holdings > 0).toList();

  List<CoinModel> get marketMovers =>
      ['BTC', 'SOL', 'ATOM'].map(findCoin).whereType<CoinModel>().toList();

  CoinModel get selectedCoin => findCoin(_selectedCoinSymbol) ?? _allCoins.first;

  CoinModel? findCoin(String symbol) {
    final upper = symbol.toUpperCase();
    for (final c in _allCoins) {
      if (c.symbol.toUpperCase() == upper) return c;
    }
    return null;
  }

  void toggleDarkMode(bool dark) {
    final next = dark ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == next) return;
    _themeMode = next;
    notifyListeners();
  }

  void setBottomTab(int index, {int? walletSegment}) {
    _currentBottomTab = index.clamp(0, 4);
    if (walletSegment != null) {
      _walletSegmentIndex = walletSegment.clamp(0, 1);
    }
    notifyListeners();
  }

  void setWalletSegment(int index) {
    _walletSegmentIndex = index.clamp(0, 1);
    notifyListeners();
  }

  void selectCoin(String symbol) {
    _selectedCoinSymbol = symbol.toUpperCase();
    notifyListeners();
  }

  void toggleBalanceVisible() {
    _balanceVisible = !_balanceVisible;
    notifyListeners();
  }

  bool isFavorite(String symbol) =>
      _favoriteSymbols.contains(symbol.toUpperCase());

  void toggleFavorite(String symbol) {
    final upper = symbol.toUpperCase();
    if (_favoriteSymbols.contains(upper)) {
      _favoriteSymbols.remove(upper);
    } else {
      _favoriteSymbols.insert(0, upper);
    }
    notifyListeners();
  }

  void addToFavorites(String symbol) {
    final upper = symbol.toUpperCase();
    if (!_favoriteSymbols.contains(upper)) {
      _favoriteSymbols.insert(0, upper);
      notifyListeners();
    }
  }

  void removeFavorite(String symbol) {
    _favoriteSymbols.remove(symbol.toUpperCase());
    notifyListeners();
  }

  void moveFavoriteUp(String symbol) {
    final upper = symbol.toUpperCase();
    final idx = _favoriteSymbols.indexOf(upper);
    if (idx > 0) {
      final item = _favoriteSymbols.removeAt(idx);
      _favoriteSymbols.insert(idx - 1, item);
    } else if (idx == 0 && _favoriteSymbols.length > 1) {
      final item = _favoriteSymbols.removeAt(0);
      _favoriteSymbols.add(item);
    }
    notifyListeners();
  }

  void addSearchQuery(String query) {
    final trimmed = query.trim().toUpperCase();
    if (trimmed.isEmpty) return;
    _searchHistory.remove(trimmed);
    _searchHistory.insert(0, trimmed);
    if (_searchHistory.length > 6) {
      _searchHistory.removeLast();
    }
    notifyListeners();
  }

  void updateProfile({
    String? email,
    String? name,
    bool? verified,
    bool? touchId,
  }) {
    if (email != null && email.trim().isNotEmpty) _userEmail = email.trim();
    if (name != null && name.trim().isNotEmpty) _userName = name.trim();
    if (verified != null) _isVerified = verified;
    if (touchId != null) _touchIdEnabled = touchId;
    notifyListeners();
  }

  void recordTransaction({
    required String title,
    required String subtitle,
    required String amountText,
    required String iconType,
    bool isPositive = false,
    double balanceDeltaUsd = 0,
  }) {
    _portfolioBalanceUsd =
        (_portfolioBalanceUsd + balanceDeltaUsd).clamp(0.0, 9999999.0);
    _transactions.insert(
      0,
      TransactionItem(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        subtitle: subtitle,
        amountText: amountText,
        dateLabel: 'Today',
        iconType: iconType,
        isPositive: isPositive,
      ),
    );
    notifyListeners();
  }

  void addOpenOrder(OpenOrderItem order) {
    _openOrders.insert(0, order);
    notifyListeners();
  }
}

/// Provides [AppState] down the widget tree without external packages.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}
