import 'package:flutter/material.dart';
import '../../models/coin_model.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/coin_pair_card.dart';
import '../trade/coin_graph_screen.dart';

/// Market screen matching Market.jpg, Market Search.jpg, and
/// Market Add to Favorites coin.jpg (+ dark -1 variants).
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  int _selectedFilter = 0; // 0: All Coins, 1: Most Trade, 2: Most Lose, 3: New Coin
  bool _sortAsc = false;
  bool _isSearchFocused = false;

  static const _filters = ['All Coins', 'Most Trade', 'Most Lose', 'New Coin'];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      if (mounted) setState(() => _isSearchFocused = _searchFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<CoinModel> _filteredCoins(AppState state) {
    final q = _searchCtrl.text.trim().toLowerCase();
    var list = state.allCoins.where((c) => c.symbol != 'USDT').toList();

    if (q.isNotEmpty) {
      list = list
          .where((c) =>
              c.symbol.toLowerCase().contains(q) ||
              c.name.toLowerCase().contains(q))
          .toList();
    } else {
      switch (_selectedFilter) {
        case 1:
          list.sort((a, b) => b.volume24h.compareTo(a.volume24h));
          break;
        case 2:
          list = list.where((c) => c.change24h < 0).toList();
          break;
        case 3:
          list = list.where((c) => c.isNew).toList();
          break;
      }
    }

    if (_sortAsc) {
      list.sort((a, b) => a.change24h.compareTo(b.change24h));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final state = AppStateScope.of(context);
    final coins = _filteredCoins(state);
    final showSearchHistory = _isSearchFocused || _searchCtrl.text.isNotEmpty;

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
                  onPressed: () {
                    if (showSearchHistory) {
                      _searchCtrl.clear();
                      _searchFocus.unfocus();
                      setState(() {});
                    } else {
                      state.setBottomTab(0);
                    }
                  },
                ),
                Text(
                  'Market',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_alt_outlined,
                      color: c.textSecondary, size: 24),
                  onPressed: () => setState(() => _sortAsc = !_sortAsc),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 46,
              decoration: c.cardDecoration(radius: 12),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: (_) => setState(() {}),
                onSubmitted: (val) => state.addSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Cryptocoin search',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  prefixIcon: Icon(
                    Icons.search,
                    color: showSearchHistory ? AppColors.primaryBlue : c.textMuted,
                    size: 24,
                  ),
                  suffixIcon: showSearchHistory
                      ? IconButton(
                          icon: Icon(Icons.cancel_outlined,
                              color: c.textSecondary, size: 20),
                          onPressed: () {
                            _searchCtrl.clear();
                            _searchFocus.unfocus();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (showSearchHistory)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search History',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: state.searchHistory
                        .map(
                          (term) => ActionChip(
                            backgroundColor: c.surface,
                            side: BorderSide(color: c.border),
                            label: Text(
                              term,
                              style: TextStyle(
                                color: c.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              _searchCtrl.text = term;
                              setState(() {});
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            )
          else ...[
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final active = i == _selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primaryBlue : c.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: c.cardShadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _filters[i],
                          style: TextStyle(
                            color: active ? Colors.white : c.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 60,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pair',
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'USDT ↕',
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 20,
                    child: Text(
                      'Last\nPrice',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 20,
                    child: GestureDetector(
                      onTap: () => setState(() => _sortAsc = !_sortAsc),
                      child: Text(
                        '24H\nChange ↕',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: coins.length,
              itemBuilder: (context, index) {
                final coin = coins[index];
                final isFav = state.isFavorite(coin.symbol);
                return CoinPairCard(
                  coin: coin,
                  actionMode: CoinCardActionMode.addToFavorite,
                  isFavorite: isFav,
                  onTap: () {
                    state.selectCoin(coin.symbol);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CoinGraphScreen(initialCoin: coin),
                      ),
                    );
                  },
                  onAddFavorite: () {
                    state.toggleFavorite(coin.symbol);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFav
                              ? '${coin.symbol} removed from Favorites'
                              : '${coin.symbol} added to Favorites',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
