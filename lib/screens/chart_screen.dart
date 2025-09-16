import 'dart:async';
import 'dart:convert';
import 'package:blockfoliox/screens/trade_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class ChartScreen extends StatefulWidget {
  final String coin;
  const ChartScreen({super.key, required this.coin});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String selectedBaseSymbol = "BTC";
  String selectedSymbolFull = "BTCUSDT";
  List<CandleData> candleData = [];
  CandleData? latest;
  Map<String, dynamic> topTrades = {};
  double lot = 0.05;
  String selectedTimeframe = "1W";

  final Map<String, String> coinToSymbol = {
    "bitcoin": "BTC",
    "ethereum": "ETH",
    "solana": "SOL",
    "ripple": "XRP",
    "cardano": "ADA",
    "dogecoin": "DOGE",
    "polkadot": "DOT",
    "litecoin": "LTC",
    "binancecoin": "BNB",
    "chainlink": "LINK",
  };

  final Map<String, String> timeframeToInterval = {
    "12H": "12h",
    "1D": "1d",
    "1W": "1w",
    "1M": "1M",
    "1Y": "1M",
  };

  final List<String> trackedCoins = [
    "bitcoin",
    "ethereum",
    "solana",
    "ripple",
    "cardano",
    "dogecoin",
    "polkadot",
    "litecoin",
    "binancecoin",
    "chainlink",
  ];

  @override
  void initState() {
    super.initState();
    final base = coinToSymbol[widget.coin.toLowerCase()] ?? widget.coin.toUpperCase();
    selectedBaseSymbol = base;
    selectedSymbolFull = base.endsWith("USDT") ? base : "${base}USDT";

    fetchCandleData();
    fetchTopTrades();

    Timer.periodic(const Duration(seconds: 10), (_) {
      fetchCandleData();
      fetchTopTrades();
    });
  }

  Future<void> fetchCandleData() async {
    final interval = timeframeToInterval[selectedTimeframe] ?? "1d";
    final url = Uri.parse(
        "https://api.binance.com/api/v3/klines?symbol=$selectedSymbolFull&interval=$interval&limit=50");
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        final List<CandleData> loaded = data.map((c) {
          return CandleData(
            time: DateTime.fromMillisecondsSinceEpoch(c[0]),
            open: double.parse(c[1]),
            high: double.parse(c[2]),
            low: double.parse(c[3]),
            close: double.parse(c[4]),
          );
        }).toList();

        setState(() {
          candleData = loaded;
          latest = loaded.isNotEmpty ? loaded.last : null;
        });
      }
    } catch (e) {
      debugPrint("Candle fetch error: $e");
      _showErrorDialog("Error fetching candle data. Please try again.");
    }
  }

  Future<void> fetchTopTrades() async {
    const quote = "USDT";
    try {
      final res = await http.get(Uri.https('api.binance.com', '/api/v3/ticker/24hr'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        final Map<String, dynamic> tradeMap = {};
        final targetSymbols = trackedCoins
            .map((c) => (coinToSymbol[c.toLowerCase()] ?? c.toUpperCase()) + quote)
            .toSet();

        for (var item in data) {
          final symbol = item['symbol'] as String;
          if (!targetSymbols.contains(symbol)) continue;

          final coinName = trackedCoins.firstWhere((c) {
            final base = coinToSymbol[c.toLowerCase()] ?? c.toUpperCase();
            return "$base$quote" == symbol;
          });

          final baseSym = coinToSymbol[coinName.toLowerCase()] ?? coinName.toUpperCase();

          tradeMap[coinName] = {
            'symbol': symbol,
            'base': baseSym,
            quote: double.tryParse(item['lastPrice']?.toString() ?? '0') ?? 0,
            "changePercent": double.tryParse(item['priceChangePercent']?.toString() ?? '0') ?? 0,
          };
        }

        setState(() => topTrades = tradeMap);
      }
    } catch (e) {
      debugPrint("Top trades fetch error: $e");
      _showErrorDialog("Error fetching top trades. Please try again.");
    }
  }

  void _openTrade(String type) {
    if (latest == null) {
      _showErrorDialog("No data available for trading.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TradeScreen(
          coin: selectedBaseSymbol,
          type: type,
          lot: lot,
          currentPrice: latest!.close,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const quote = "USDT";
    double open = latest?.open ?? 0;
    double high = latest?.high ?? 0;
    double low = latest?.low ?? 0;
    double close = latest?.close ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (latest == null) {
                          _showErrorDialog("No data available for selling.");
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TradeScreen(
                              coin: selectedBaseSymbol,
                              type: 'Sell',
                              lot: lot,
                              currentPrice: latest!.close,
                            ),
                          ),
                        );
                      },
                      child: _gradientButton(
                          "Sell", latest != null ? latest!.close.toStringAsFixed(2) : "--"),
                    ),
                  ),

                  SizedBox(width: 110, child: _lotBox()),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (latest == null) {
                          _showErrorDialog("No data available for buying.");
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TradeScreen(
                              coin: selectedBaseSymbol,
                              type: 'Buy',
                              lot: lot,
                              currentPrice: latest!.close,
                            ),
                          ),
                        );
                      },
                      child: _gradientButton(
                          "Buy", latest != null ? latest!.close.toStringAsFixed(2) : "--"),
                    ),
                  ),


                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Top Trades",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(
              height: 155,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: trackedCoins.map((coinName) {
                  final base = coinToSymbol[coinName.toLowerCase()] ?? coinName.toUpperCase();
                  final sym = "$base$quote";

                  final item = topTrades[coinName];
                  final price = item != null ? (item[quote] as double).toStringAsFixed(2) : "--";
                  final change = item != null ? (item["changePercent"] as double) : 0.0;
                  final changeStr = "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} %";

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBaseSymbol = base;
                        selectedSymbolFull = "$base$quote";
                      });
                      fetchCandleData();
                    },
                    child: _topTradeCard(
                      sym,
                      "$quote $price",
                      changeStr,
                      change >= 0 ? Colors.green : Colors.red,
                    ),
                  );
                }).toList(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.currency_bitcoin, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedBaseSymbol),
                          const Text("USDT", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "\$${latest?.close.toStringAsFixed(2) ?? '--'}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("2.05 $selectedBaseSymbol"),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: candleData.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : SfCartesianChart(
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePinching: true,
                    enablePanning: true,
                    zoomMode: ZoomMode.xy,
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  primaryXAxis: DateTimeAxis(
                    intervalType: DateTimeIntervalType.hours,
                    dateFormat: DateFormat.Hm(),
                    majorGridLines: const MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    opposedPosition: true,
                    majorGridLines: const MajorGridLines(dashArray: [4, 4]),
                  ),
                  series: <CandleSeries<CandleData, DateTime>>[
                    CandleSeries<CandleData, DateTime>(
                      dataSource: candleData,
                      xValueMapper: (data, _) => data.time,
                      lowValueMapper: (data, _) => data.low,
                      highValueMapper: (data, _) => data.high,
                      openValueMapper: (data, _) => data.open,
                      closeValueMapper: (data, _) => data.close,
                    ),
                  ],
                ),
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _statBox("Open", open),
                  const SizedBox(width: 10),
                  _statBox("Close", close),
                  const SizedBox(width: 10),
                  _statBox("High", high),
                  const SizedBox(width: 10),
                  _statBox("Low", low),
                ],
              ),
            ),

            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: timeframeToInterval.keys.map((label) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedTimeframe = label);
                      fetchCandleData();
                    },
                    child: _timeButton(label, selected: selectedTimeframe == label),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, double value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _gradientButton(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6E3C1B), Color(0xFFF8BE3B), Color(0xFF6E3C1B)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _lotBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_sharp, size: 35),
              onPressed: () {
                setState(() {
                  if (lot > 0.01) lot -= 0.01;
                });
              },
            ),
            Text(lot.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_up_sharp, size: 35),
              onPressed: () {
                setState(() {
                  lot += 0.01;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeButton(String label, {bool selected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.red : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? Colors.red : Colors.grey.shade300),
      ),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.black)),
    );
  }

  Widget _topTradeCard(String coin, String price, String change, Color color) {
    return Container(
      width: 110,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, spreadRadius: 1)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.token, size: 28, color: Colors.black),
          const SizedBox(height: 6),
          Text(coin, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(price, style: const TextStyle(fontSize: 13)),
          Text(change, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class CandleData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  CandleData({required this.time, required this.open, required this.high, required this.low, required this.close});
}
