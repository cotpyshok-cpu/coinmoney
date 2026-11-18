import 'package:flutter/material.dart';

/// Represents a single OHLC candle bar for candlestick charts.
class CandlePoint {
  const CandlePoint({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  bool get isBullish => close >= open;
}

/// Core cryptocurrency asset and market pair model.
class CoinModel {
  const CoinModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.pair,
    required this.price,
    required this.priceFormatted,
    required this.change24h,
    required this.change1Y,
    required this.volume24h,
    required this.volumeFormatted,
    required this.topPriceFormatted,
    required this.lowPriceFormatted,
    required this.holdings,
    required this.holdingsUsd,
    required this.portfolioPercent,
    required this.brandColor,
    required this.sparklinePoints,
    required this.hourlyChartPoints,
    required this.yearlyChartPoints,
    required this.candles,
    this.isNew = false,
  });

  final String id;
  final String symbol;
  final String name;
  final String pair;
  final double price;
  final String priceFormatted;
  final double change24h;
  final double change1Y;
  final double volume24h;
  final String volumeFormatted;
  final String topPriceFormatted;
  final String lowPriceFormatted;
  final double holdings;
  final double holdingsUsd;
  final int portfolioPercent;
  final Color brandColor;
  final List<double> sparklinePoints;
  final List<double> hourlyChartPoints;
  final List<double> yearlyChartPoints;
  final List<CandlePoint> candles;
  final bool isNew;

  bool get isPositive => change24h >= 0;

  String get formattedChange24h {
    final sign = change24h >= 0 ? '+' : '';
    return '$sign${change24h.toStringAsFixed(2)}%';
  }
}

/// Represents a wallet or card transaction item.
class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amountText,
    required this.dateLabel,
    required this.iconType,
    this.isPositive = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String amountText;
  final String dateLabel;
  final String iconType;
  final bool isPositive;
}

/// Represents an open spot order on the Trade screen.
class OpenOrderItem {
  const OpenOrderItem({
    required this.id,
    required this.pair,
    required this.side,
    required this.orderType,
    required this.price,
    required this.amount,
    required this.totalUsdt,
    required this.timeLabel,
  });

  final String id;
  final String pair;
  final String side;
  final String orderType;
  final double price;
  final double amount;
  final double totalUsdt;
  final String timeLabel;
}

/// Provides rich mock market, portfolio, orderbook, and history data matching Figma.
class CoinMockData {
  CoinMockData._();

  static List<CandlePoint> _generateCandles(double base, {int count = 38}) {
    const offsets = [
      -0.018, -0.012, -0.015, -0.008, -0.004, -0.011, -0.017, -0.022,
      -0.016, -0.006, 0.002, 0.012, 0.024, 0.031, 0.021, 0.016,
      0.028, 0.034, 0.019, 0.009, 0.002, -0.008, -0.003, 0.006,
      0.011, 0.001, -0.007, -0.014, -0.005, 0.008, 0.021, 0.026,
      0.015, 0.007, 0.001, 0.009, 0.019, 0.027,
    ];
    final result = <CandlePoint>[];
    for (var i = 0; i < count; i++) {
      final prev = offsets[i == 0 ? 0 : i - 1];
      final curr = offsets[i % offsets.length];
      final open = base * (1 + prev * 0.8);
      final close = base * (1 + curr);
      final top = (open > close ? open : close) + base * (0.006 + (i % 3) * 0.003);
      final bottom = (open < close ? open : close) - base * (0.005 + (i % 4) * 0.002);
      final vol = 415.0 + ((i * 37) % 90);
      result.add(
        CandlePoint(open: open, high: top, low: bottom, close: close, volume: vol),
      );
    }
    return result;
  }

  static final List<CoinModel> coins = [
    CoinModel(
      id: 'btc',
      symbol: 'BTC',
      name: 'Bitcoin',
      pair: 'BTC/USDT',
      price: 30113.80,
      priceFormatted: '30,113.80',
      change24h: 2.76,
      change1Y: 12.13,
      volume24h: 394897432.26,
      volumeFormatted: '55 431 281,89',
      topPriceFormatted: '69,221.89',
      lowPriceFormatted: '1.115',
      holdings: 0.042148,
      holdingsUsd: 1270.10,
      portfolioPercent: 46,
      brandColor: const Color(0xFFF7931A),
      sparklinePoints: const [0.35, 0.58, 0.50, 0.65, 0.45, 0.55, 0.72, 0.62, 0.82, 0.78, 0.90],
      hourlyChartPoints: const [
        28800, 29100, 29400, 29050, 28500, 28900, 30400, 31200,
        31050, 31100, 29450, 29350, 29750, 28750, 29900, 30850,
        29400, 29350, 30800,
      ],
      yearlyChartPoints: const [
        30400, 29900, 30750, 30600, 29650, 29750, 30350, 29850,
        30450, 29600, 29900, 30950, 30550, 30750, 29950, 30200,
        30900, 29750, 30350, 29900, 31150, 30900, 31000, 30750,
      ],
      candles: _generateCandles(30113.80),
    ),
    CoinModel(
      id: 'sol',
      symbol: 'SOL',
      name: 'Solana',
      pair: 'SOL/USDT',
      price: 40.11,
      priceFormatted: '0.060',
      change24h: 0.72,
      change1Y: 18.40,
      volume24h: 150897992.26,
      volumeFormatted: '51 431 281,89',
      topPriceFormatted: '118,12',
      lowPriceFormatted: '1,001',
      holdings: 0.0,
      holdingsUsd: 0.0,
      portfolioPercent: 0,
      brandColor: const Color(0xFF28C3A9),
      sparklinePoints: const [0.55, 0.35, 0.25, 0.42, 0.75, 0.65, 0.78, 0.85, 0.78],
      hourlyChartPoints: const [38.2, 38.8, 39.4, 38.9, 39.7, 40.5, 40.1, 40.8, 40.11],
      yearlyChartPoints: const [24, 28, 32, 29, 35, 38, 36, 41, 40.11],
      candles: _generateCandles(40.11),
    ),
    CoinModel(
      id: 'eth',
      symbol: 'ETH',
      name: 'Ethereum',
      pair: 'ETH/USDT',
      price: 1801.10,
      priceFormatted: '1,801.10',
      change24h: -1.02,
      change1Y: 9.40,
      volume24h: 19900200.19,
      volumeFormatted: '19 900 200,19',
      topPriceFormatted: '2,600.30',
      lowPriceFormatted: '0,395116',
      holdings: 0.014914,
      holdingsUsd: 270.10,
      portfolioPercent: 10,
      brandColor: const Color(0xFF627EEA),
      sparklinePoints: const [0.75, 0.82, 0.78, 0.68, 0.85, 0.62, 0.40, 0.52, 0.32, 0.28, 0.38],
      hourlyChartPoints: const [
        1840, 1855, 1835, 1860, 1825, 1810, 1822, 1795, 1785, 1805, 1790, 1801.10,
      ],
      yearlyChartPoints: const [
        1620, 1690, 1740, 1710, 1820, 1780, 1860, 1830, 1790, 1815, 1801.10,
      ],
      candles: _generateCandles(1801.10),
    ),
    CoinModel(
      id: 'atom',
      symbol: 'ATOM',
      name: 'Cosmos',
      pair: 'ATOM/USDT',
      price: 8.87,
      priceFormatted: '8,87',
      change24h: 2.05,
      change1Y: 7.80,
      volume24h: 12450112.40,
      volumeFormatted: '12 450 112,40',
      topPriceFormatted: '14,20',
      lowPriceFormatted: '6,10',
      holdings: 108.427,
      holdingsUsd: 961.75,
      portfolioPercent: 35,
      brandColor: const Color(0xFF50576A),
      sparklinePoints: const [0.40, 0.45, 0.50, 0.62, 0.56, 0.70, 0.65, 0.78, 0.84],
      hourlyChartPoints: const [8.4, 8.5, 8.65, 8.55, 8.75, 8.82, 8.79, 8.87],
      yearlyChartPoints: const [7.2, 7.9, 8.1, 8.4, 8.2, 8.7, 8.87],
      candles: _generateCandles(8.87),
    ),
    CoinModel(
      id: 'cro',
      symbol: 'CRO',
      name: 'Cronos',
      pair: 'CRO/USDT',
      price: 0.11765,
      priceFormatted: '0,11765',
      change24h: 2.38,
      change1Y: 5.15,
      volume24h: 8120311.00,
      volumeFormatted: '8 120 311,00',
      topPriceFormatted: '0,185',
      lowPriceFormatted: '0,095',
      holdings: 1616.914,
      holdingsUsd: 190.23,
      portfolioPercent: 7,
      brandColor: const Color(0xFF3E4C73),
      sparklinePoints: const [0.35, 0.48, 0.42, 0.60, 0.52, 0.72, 0.66, 0.80],
      hourlyChartPoints: const [0.112, 0.114, 0.113, 0.116, 0.115, 0.118, 0.11765],
      yearlyChartPoints: const [0.095, 0.102, 0.108, 0.111, 0.114, 0.11765],
      candles: _generateCandles(0.11765),
    ),
    CoinModel(
      id: 'ada',
      symbol: 'ADA',
      name: 'Cardano',
      pair: 'ADA/USDT',
      price: 0.49,
      priceFormatted: '0,49',
      change24h: -1.24,
      change1Y: 4.10,
      volume24h: 22911800.12,
      volumeFormatted: '22 911 800,12',
      topPriceFormatted: '0,82',
      lowPriceFormatted: '0,38',
      holdings: 138.8775,
      holdingsUsd: 68.05,
      portfolioPercent: 2,
      brandColor: const Color(0xFF3468D1),
      sparklinePoints: const [0.80, 0.72, 0.68, 0.75, 0.52, 0.45, 0.48, 0.38],
      hourlyChartPoints: const [0.51, 0.505, 0.498, 0.501, 0.494, 0.488, 0.49],
      yearlyChartPoints: const [0.42, 0.46, 0.53, 0.51, 0.48, 0.49],
      candles: _generateCandles(0.49),
    ),
    CoinModel(
      id: 'bnb',
      symbol: 'BNB',
      name: 'BNB',
      pair: 'BNB/USDT',
      price: 214.95,
      priceFormatted: '214,95',
      change24h: 2.01,
      change1Y: 14.50,
      volume24h: 35431281.89,
      volumeFormatted: '35 431 281,89',
      topPriceFormatted: '690,13',
      lowPriceFormatted: '209,10',
      holdings: 0.0,
      holdingsUsd: 0.0,
      portfolioPercent: 0,
      brandColor: const Color(0xFFF3BA2F),
      sparklinePoints: const [0.30, 0.42, 0.55, 0.50, 0.62, 0.74, 0.70, 0.88],
      hourlyChartPoints: const [210, 211.5, 212.2, 211.8, 213.4, 214.1, 214.95],
      yearlyChartPoints: const [190, 200, 205, 212, 208, 214.95],
      candles: _generateCandles(214.95),
    ),
    CoinModel(
      id: 'ltc',
      symbol: 'LTC',
      name: 'Litecoin',
      pair: 'LTC/USDT',
      price: 44.24,
      priceFormatted: '44.24',
      change24h: 2.40,
      change1Y: 8.12,
      volume24h: 7431281.89,
      volumeFormatted: '7 431 281,89',
      topPriceFormatted: '412,96',
      lowPriceFormatted: '42,15',
      holdings: 0.0,
      holdingsUsd: 0.0,
      portfolioPercent: 0,
      brandColor: const Color(0xFF345D9D),
      sparklinePoints: const [0.58, 0.40, 0.35, 0.52, 0.78, 0.72, 0.76, 0.88],
      hourlyChartPoints: const [42.8, 43.1, 42.9, 43.6, 44.0, 44.24],
      yearlyChartPoints: const [38.0, 40.5, 42.1, 41.8, 43.5, 44.24],
      candles: _generateCandles(44.24),
    ),
    CoinModel(
      id: 'trx',
      symbol: 'TRX',
      name: 'TRON',
      pair: 'TRX/USDT',
      price: 0.068,
      priceFormatted: '0.068',
      change24h: 1.05,
      change1Y: 6.40,
      volume24h: 9120400.10,
      volumeFormatted: '9 120 400,10',
      topPriceFormatted: '1,125',
      lowPriceFormatted: '0,058',
      holdings: 0.0,
      holdingsUsd: 0.0,
      portfolioPercent: 0,
      brandColor: const Color(0xFFEB0029),
      sparklinePoints: const [0.40, 0.52, 0.44, 0.60, 0.50, 0.68, 0.62, 0.78],
      hourlyChartPoints: const [0.065, 0.066, 0.067, 0.066, 0.068],
      yearlyChartPoints: const [0.055, 0.060, 0.064, 0.068],
      candles: _generateCandles(0.068),
      isNew: true,
    ),
    CoinModel(
      id: 'egame',
      symbol: 'EGAME',
      name: 'EveryGame',
      pair: 'EGAME/USDT',
      price: 0.013,
      priceFormatted: '0,013',
      change24h: -2.20,
      change1Y: -4.15,
      volume24h: 7431281.89,
      volumeFormatted: '7 431 281,89',
      topPriceFormatted: '0,01316',
      lowPriceFormatted: '0,000116',
      holdings: 0.0,
      holdingsUsd: 0.0,
      portfolioPercent: 0,
      brandColor: const Color(0xFFE65100),
      sparklinePoints: const [0.60, 0.65, 0.78, 0.72, 0.35, 0.42, 0.30, 0.36],
      hourlyChartPoints: const [0.0135, 0.0138, 0.0132, 0.0129, 0.013],
      yearlyChartPoints: const [0.015, 0.014, 0.0132, 0.013],
      candles: _generateCandles(0.013),
      isNew: true,
    ),
    CoinModel(
      id: 'link',
      symbol: 'LINK',
      name: 'Chainlink',
      pair: 'LINK/USDT',
      price: 6.27,
      priceFormatted: '6,27',
      change24h: 13.50,
      change1Y: 22.40,
      volume24h: 9900200.19,
      volumeFormatted: '9 900 200,19',
      topPriceFormatted: '6,28',
      lowPriceFormatted: '0,395116',
      holdings: 0.0,
      holdingsUsd: 0.0,
      portfolioPercent: 0,
      brandColor: const Color(0xFF2A5ADA),
      sparklinePoints: const [0.30, 0.48, 0.42, 0.62, 0.55, 0.70, 0.64, 0.85],
      hourlyChartPoints: const [5.6, 5.8, 5.95, 6.1, 6.05, 6.27],
      yearlyChartPoints: const [4.8, 5.2, 5.9, 6.1, 6.27],
      candles: _generateCandles(6.27),
    ),
    CoinModel(
      id: 'farm',
      symbol: 'FARM',
      name: 'Harvest Finance',
      pair: 'FARM/USDT',
      price: 36.43,
      priceFormatted: '36,43',
      change24h: 20.10,
      change1Y: 31.20,
      volume24h: 5431281.89,
      volumeFormatted: '5 431 281,89',
      topPriceFormatted: '2.228,65',
      lowPriceFormatted: '0,002186',
      holdings: 0.0,
      holdingsUsd: 0.0,
      portfolioPercent: 0,
      brandColor: const Color(0xFF00A86B),
      sparklinePoints: const [0.28, 0.55, 0.60, 0.50, 0.65, 0.58, 0.80, 0.72, 0.90],
      hourlyChartPoints: const [30.2, 31.5, 33.4, 34.8, 35.9, 36.43],
      yearlyChartPoints: const [25.0, 29.0, 32.5, 36.43],
      candles: _generateCandles(36.43),
      isNew: true,
    ),
    CoinModel(
      id: 'xrp',
      symbol: 'XRP',
      name: 'Ripple',
      pair: 'XRP/USDT',
      price: 0.52,
      priceFormatted: '0.52',
      change24h: 1.45,
      change1Y: 11.20,
      volume24h: 18500300.00,
      volumeFormatted: '18 500 300,00',
      topPriceFormatted: '0.74',
      lowPriceFormatted: '0.31',
      holdings: 0.0,
      holdingsUsd: 0.0,
      portfolioPercent: 0,
      brandColor: const Color(0xFF23292F),
      sparklinePoints: const [0.42, 0.48, 0.55, 0.51, 0.64, 0.70, 0.76],
      hourlyChartPoints: const [0.49, 0.50, 0.51, 0.508, 0.52],
      yearlyChartPoints: const [0.41, 0.45, 0.48, 0.52],
      candles: _generateCandles(0.52),
    ),
    CoinModel(
      id: 'usdt',
      symbol: 'USDT',
      name: 'Tether',
      pair: 'USDT/USD',
      price: 1.02,
      priceFormatted: '1.02',
      change24h: 0.01,
      change1Y: 0.05,
      volume24h: 95000000.00,
      volumeFormatted: '95 000 000,00',
      topPriceFormatted: '1.03',
      lowPriceFormatted: '0.99',
      holdings: 1.0,
      holdingsUsd: 1.02,
      portfolioPercent: 0,
      brandColor: const Color(0xFF26A17B),
      sparklinePoints: const [0.55, 0.45, 0.35, 0.52, 0.72, 0.65, 0.80, 0.86],
      hourlyChartPoints: const [1.00, 1.01, 1.00, 1.02],
      yearlyChartPoints: const [1.00, 1.01, 1.02],
      candles: _generateCandles(1.02),
    ),
  ];

  static final List<double> portfolioBalanceHistory = [
    2410, 2480, 2500, 2410, 2360, 2470, 2670, 2735,
    2725, 2720, 2520, 2515, 2580, 2430, 2620, 2710,
    2520, 2510, 2760.23,
  ];

  static final List<TransactionItem> defaultTransactions = [
    const TransactionItem(
      id: 'tx_1',
      title: 'Apple',
      subtitle: 'Payment for subscription',
      amountText: '-8.99\$',
      dateLabel: '15.06.2022',
      iconType: 'apple',
    ),
    const TransactionItem(
      id: 'tx_2',
      title: 'Netflix',
      subtitle: 'Payment for subscription',
      amountText: '-12.99\$',
      dateLabel: '15.06.2022',
      iconType: 'netflix',
    ),
    const TransactionItem(
      id: 'tx_3',
      title: 'Bitcoin Deposit',
      subtitle: 'Coinmoney Wallet',
      amountText: '+0.0142 BTC',
      dateLabel: '12.06.2022',
      iconType: 'btc',
      isPositive: true,
    ),
  ];

  static final List<Map<String, String>> tradingHistoryRows = [
    {'price': '30,113.84', 'amount': '1,76676', 'side': 'sell', 'time': '09:41:13'},
    {'price': '30,114.84', 'amount': '9,29631', 'side': 'sell', 'time': '09:41:13'},
    {'price': '30,112.16', 'amount': '2,18599', 'side': 'buy', 'time': '09:41:10'},
    {'price': '30,113.81', 'amount': '6,33200', 'side': 'buy', 'time': '09:41:07'},
    {'price': '30,114.81', 'amount': '3,00018', 'side': 'sell', 'time': '09:41:07'},
    {'price': '30,113.45', 'amount': '4,49994', 'side': 'buy', 'time': '09:41:01'},
    {'price': '30,113.89', 'amount': '1,16627', 'side': 'sell', 'time': '09:40:58'},
    {'price': '30,113.66', 'amount': '1,93398', 'side': 'buy', 'time': '09:40:56'},
    {'price': '30,113.80', 'amount': '9,43359', 'side': 'buy', 'time': '09:40:34'},
    {'price': '30,113.88', 'amount': '1,18708', 'side': 'sell', 'time': '09:40:23'},
  ];

  static final List<Map<String, dynamic>> askOrders = [
    {'price': 30113.84, 'amount': '1,76676', 'fill': 0.85},
    {'price': 30114.84, 'amount': '2,20046', 'fill': 0.65},
    {'price': 30113.97, 'amount': '9,25320', 'fill': 0.45},
    {'price': 30113.87, 'amount': '6,98019', 'fill': 0.30},
    {'price': 30114.71, 'amount': '6,14111', 'fill': 0.55},
    {'price': 30114.22, 'amount': '2,21189', 'fill': 0.62},
    {'price': 30114.41, 'amount': '3,00018', 'fill': 0.42},
    {'price': 30114.36, 'amount': '9,92881', 'fill': 0.35},
    {'price': 30113.89, 'amount': '1,18708', 'fill': 0.72},
    {'price': 30113.88, 'amount': '4,49994', 'fill': 0.78},
  ];

  static final List<Map<String, dynamic>> bidOrders = [
    {'price': 30113.79, 'amount': '9,70443', 'fill': 0.82},
    {'price': 30113.70, 'amount': '9,29631', 'fill': 0.65},
    {'price': 30113.66, 'amount': '6,28200', 'fill': 0.74},
    {'price': 30112.45, 'amount': '2,18599', 'fill': 0.60},
    {'price': 30112.95, 'amount': '2,74875', 'fill': 0.70},
    {'price': 30113.55, 'amount': '7,14339', 'fill': 0.48},
    {'price': 30113.75, 'amount': '1,93398', 'fill': 0.55},
    {'price': 30113.66, 'amount': '9,43359', 'fill': 0.38},
    {'price': 30113.80, 'amount': '1,16627', 'fill': 0.52},
    {'price': 30113.80, 'amount': '2,93046', 'fill': 0.66},
  ];
}
