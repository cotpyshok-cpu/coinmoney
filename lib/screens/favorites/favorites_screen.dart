import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/coin_pair_card.dart';
import '../trade/coin_graph_screen.dart';

/// Favorites screen matching Favorites.jpg and Favorites remove/move.jpg
/// (+ dark -1 variants). Swipe left on any row to reveal Move & Remove.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _sortAsc = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final state = AppStateScope.of(context);
    final favs = state.favoriteCoins.toList();
    if (_sortAsc) {
      favs.sort((a, b) => a.change24h.compareTo(b.change24h));
    }

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
                  'Favorites',
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 60,
                  child: Column(
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
          Expanded(
            child: favs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_border, size: 52, color: c.textMuted),
                        const SizedBox(height: 10),
                        Text(
                          'No favorite coins yet',
                          style: TextStyle(color: c.textSecondary, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => state.setBottomTab(2),
                          child: const Text('Browse Market'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: favs.length,
                    itemBuilder: (context, index) {
                      final coin = favs[index];
                      return CoinPairCard(
                        coin: coin,
                        actionMode: CoinCardActionMode.moveAndRemove,
                        onTap: () {
                          state.selectCoin(coin.symbol);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CoinGraphScreen(initialCoin: coin),
                            ),
                          );
                        },
                        onMoveUp: () => state.moveFavoriteUp(coin.symbol),
                        onRemove: () => state.removeFavorite(coin.symbol),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
