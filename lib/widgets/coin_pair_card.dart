import 'package:flutter/material.dart';
import '../models/coin_model.dart';
import '../theme/app_theme.dart';
import 'charts/sparkline_painter.dart';

/// Shared market/favorites coin card with optional swipe-to-reveal actions
/// matching Market.jpg, Market Add to Favorites coin.jpg, and Favorites remove/move.jpg.
class CoinPairCard extends StatefulWidget {
  const CoinPairCard({
    super.key,
    required this.coin,
    required this.onTap,
    this.actionMode = CoinCardActionMode.addToFavorite,
    this.isFavorite = false,
    this.onAddFavorite,
    this.onMoveUp,
    this.onRemove,
  });

  final CoinModel coin;
  final VoidCallback onTap;
  final CoinCardActionMode actionMode;
  final bool isFavorite;
  final VoidCallback? onAddFavorite;
  final VoidCallback? onMoveUp;
  final VoidCallback? onRemove;

  @override
  State<CoinPairCard> createState() => _CoinPairCardState();
}

enum CoinCardActionMode { addToFavorite, moveAndRemove }

class _CoinPairCardState extends State<CoinPairCard> {
  double _revealOffset = 0.0;

  double get _maxReveal =>
      widget.actionMode == CoinCardActionMode.addToFavorite ? 132.0 : 156.0;

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _revealOffset = (_revealOffset - details.delta.dx).clamp(0.0, _maxReveal);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _revealOffset = _revealOffset > _maxReveal * 0.4 ? _maxReveal : 0.0;
    });
  }

  void _closeActions() {
    if (_revealOffset != 0) {
      setState(() => _revealOffset = 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final coin = widget.coin;
    final badgeColor =
        coin.isPositive ? AppColors.positiveGreen : AppColors.negativeRed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.actionMode == CoinCardActionMode.addToFavorite
                    ? [_buildAddFavoriteAction()]
                    : [_buildMoveAction(), _buildRemoveAction()],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(-_revealOffset, 0, 0),
              child: GestureDetector(
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                onTap: () {
                  if (_revealOffset > 0) {
                    _closeActions();
                  } else {
                    widget.onTap();
                  }
                },
                onLongPress: () {
                  setState(() {
                    _revealOffset = _revealOffset > 0 ? 0.0 : _maxReveal;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: c.cardDecoration(radius: 14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 34,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: coin.symbol,
                                    style: TextStyle(
                                      color: c.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/USDT',
                                    style: TextStyle(
                                      color: c.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Vol ${coin.volumeFormatted}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 32,
                        child: Column(
                          children: [
                            Text(
                              'Top price ${coin.topPriceFormatted}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            SparklineChart(
                              points: coin.sparklinePoints,
                              isPositive: coin.isPositive,
                              width: 84,
                              height: 24,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Low price ${coin.lowPriceFormatted}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 34,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                coin.priceFormatted,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                coin.formattedChange24h,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }

  Widget _buildAddFavoriteAction() {
    return GestureDetector(
      onTap: () {
        widget.onAddFavorite?.call();
        _closeActions();
      },
      child: Container(
        width: 132,
        color: AppColors.favoriteOrange,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isFavorite ? Icons.star : Icons.star_border,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              widget.isFavorite ? 'In Favorites' : 'Add to Favorites',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveAction() {
    return GestureDetector(
      onTap: () {
        widget.onMoveUp?.call();
        _closeActions();
      },
      child: Container(
        width: 78,
        color: AppColors.positiveGreen,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.unfold_more, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text(
              'Move',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveAction() {
    return GestureDetector(
      onTap: () {
        widget.onRemove?.call();
        _closeActions();
      },
      child: Container(
        width: 78,
        color: AppColors.negativeRed,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
