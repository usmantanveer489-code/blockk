import 'dart:convert';
import 'package:blockfoliox/screens/deposit.dart';
import 'package:blockfoliox/screens/social_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ChartData> _btcData = [];
  double _currentPrice = 0.0;
  bool _loading = true;

  final List<Color> gradientColors = const [
    Color(0xFF6E3C1B),
    Color(0xFFF8BE3B),
    Color(0xFF6E3C1B),
  ];

  bool isRealSelected = true;
  bool isArchiveChecked = false;

  @override
  void initState() {
    super.initState();
    _fetchBtcChart();
  }

  Future<void> _fetchBtcChart() async {
    const url =
        'https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prices = data['prices'] as List<dynamic>;

        List<ChartData> chartData = prices
            .map((point) => ChartData(
          DateTime.fromMillisecondsSinceEpoch(point[0]),
          point[1],
        ))
            .toList();

        setState(() {
          _btcData = chartData;
          _currentPrice = chartData.isNotEmpty ? chartData.last.price : 0.0;
          _loading = false;
        });
      } else {
        throw Exception('Failed to load BTC data');
      }
    } catch (e) {
      debugPrint('Error fetching BTC data: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double cardSpacing = 12.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo.png',
          height: 50,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: gradientColors[1]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_none, color: gradientColors[0]),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Your finances at a glance: Net Deposit, Wallet Total, and Reward Points Summary",
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 16),

          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc('T3nh9ADdqlM8NJnbJqo4FCcGAR83')
                .collection('financial data')
                .doc('YsRBxBVPzsSLyF6vct1l')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text("No financial data available");
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              final double wallet = (data['wallet'] ?? 0.0).toDouble();
              final double tradeAccount = (data['tradeAccount'] ?? 0.0).toDouble();
              final double netDeposit = (data['netDeposit'] ?? 0.0).toDouble();
              final int pointsEarned = (data['pointsEarned'] ?? 0).toInt();
              final double totalWithdraw = (data['totalWithdraw'] ?? 0.0).toDouble();

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _OverviewCardWithImage(
                    title: "IN WALLET",
                    value: "${wallet.toStringAsFixed(2)} USD",
                    imagePath: 'assets/images/wallet_icon.png',
                    gradientColors: gradientColors,
                  ),
                  _OverviewCardWithImage(
                    title: "Trade Account",
                    value: "${tradeAccount.toStringAsFixed(2)} USD",
                    imagePath: 'assets/images/trade_icon.png',
                    gradientColors: gradientColors,
                  ),
                  _OverviewCardWithImage(
                    title: "NET DEPOSIT",
                    value: "${netDeposit.toStringAsFixed(2)} USD",
                    imagePath: 'assets/images/deposit.png',
                    gradientColors: gradientColors,
                  ),
                  _OverviewCardWithImage(
                    title: "POINTS EARNED",
                    value: "$pointsEarned",
                    imagePath: 'assets/images/points.png',
                    gradientColors: gradientColors,
                  ),
                  _OverviewCardWithImage(
                    title: "Total Withdraw",
                    value: "${totalWithdraw.toStringAsFixed(2)} USD",
                    imagePath: 'assets/images/withdraw.png',
                    gradientColors: gradientColors,
                  ),
                ],
              );
            },
          ),


          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Trading Accounts",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _GradientButton(
                  text: "Open Account",
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> DepositScreen()));
                  },
                  height: 36,
                  gradientColors: gradientColors),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Manage and Diversify Your Investments With Your Existing Trading Account",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                _TabButton(
                  text: "Real",
                  isSelected: isRealSelected,
                  onTap: () {
                    setState(() {
                      isRealSelected = true;
                    });
                  },
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                  gradientColors: gradientColors,
                ),
                _TabButton(
                  text: "Demo",
                  isSelected: !isRealSelected,
                  onTap: () {
                    setState(() {
                      isRealSelected = false;
                    });
                  },
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                  gradientColors: gradientColors,
                ),
              ]),
              Row(
                children: [
                  GradientCheckbox(
                    value: isArchiveChecked,
                    onChanged: (v) {
                      setState(() {
                        isArchiveChecked = v;
                      });
                    },
                    gradientColors: gradientColors,
                  ),
                  const SizedBox(width: 8),
                  const Text('Archive',
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          _AccountDetailSection(
            btcData: _btcData,
            currentPrice: _currentPrice,
            gradientColors: gradientColors,
            loading: _loading,
          ),

          const SizedBox(height: 28),

          _InviteSection(gradientColors: gradientColors),
        ]),
      ),
    );
  }
}

class ChartData {
  final DateTime time;
  final double price;
  ChartData(this.time, this.price);
}

class _OverviewCardWithImage extends StatelessWidget {
  final String title;
  final String value;
  final String imagePath;
  final List<Color> gradientColors;

  const _OverviewCardWithImage({
    required this.title,
    required this.value,
    required this.imagePath,
    required this.gradientColors,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.of(context).size.width - 48) / 2;

    return SizedBox(
      width: cardWidth,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagePath, width: 24, height: 24),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.of(context).size.width - 48) / 2;

    return SizedBox(
      width: cardWidth,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 22, color: const Color(0xFF6E3C1B)),
          const SizedBox(height: 10),
          Text(value,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ]),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final List<Color> gradientColors;

  const _TabButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
    required this.borderRadius,
    required this.gradientColors,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final unselectedBorderColor = Colors.grey.shade300;
    final selectedTextColor = Color(0xFF6E3C1B);
    final unselectedTextColor = Colors.grey.shade600;

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: borderRadius,
        )
            : BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          border: Border.all(color: unselectedBorderColor),
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? selectedTextColor : unselectedTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class GradientCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final List<Color> gradientColors;
  final double size;

  const GradientCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.gradientColors,
    this.size = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: value
              ? LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
              : null,
          border: Border.all(
            color: value ? Colors.transparent : Colors.grey.shade400,
            width: 1.5,
          ),
          color: value ? null : Colors.white,
        ),
        child:
        value ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final List<Color> gradientColors;
  const _GradientButton({
    required this.text,
    required this.onPressed,
    this.height = 40,
    required this.gradientColors,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child:
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ),
    );
  }
}

class _AccountDetailSection extends StatelessWidget {
  final List<ChartData> btcData;
  final double currentPrice;
  final List<Color> gradientColors;
  final bool loading;

  const _AccountDetailSection({
    required this.btcData,
    required this.currentPrice,
    required this.gradientColors,
    required this.loading,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3))
      ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: const [
                Icon(Icons.person_outline),
                SizedBox(width: 6),
                Text("335000", style: TextStyle(fontWeight: FontWeight.bold)),
              ]),
            ],
          ),
          const SizedBox(height: 4),
          const Text("BlockFolioX Account", style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Crypto Gain: \$${currentPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16)),
                child: const Text("This week", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : SfCartesianChart(
              series: <LineSeries<ChartData, DateTime>>[
                LineSeries<ChartData, DateTime>(
                  dataSource: btcData,
                  xValueMapper: (d, _) => d.time,
                  yValueMapper: (d, _) => d.price,
                  color: gradientColors[0],
                  width: 2,
                )
              ],
              primaryXAxis: DateTimeAxis(isVisible: false),
              primaryYAxis: NumericAxis(isVisible: false),
              plotAreaBorderWidth: 0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _AccountMetric(label: "Balance", value: "-\$3.00"),
              _AccountMetric(label: "Equity", value: "00.77 USD"),
              _AccountMetric(label: "Unrealized P/L", value: "00.00 USD"),
            ],
          ),
        ],
      ),
    );
  }
}

class _InviteSection extends StatelessWidget {
  final List<Color> gradientColors;
  const _InviteSection({required this.gradientColors, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFF6F2E9), borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 40),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Invite Friends, Earn Rewards",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 6),
                  Text(
                    "Invite your friends to join us and unlock a world of rewards. Sharing has never been more rewarding!",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ]),
          ),
          Positioned(
            bottom: 4,
            right: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SocialScreen(), // your existing screen
                  ),
                );
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: gradientColors)),
                child: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountMetric extends StatelessWidget {
  final String label;
  final String value;
  const _AccountMetric({
    required this.label,
    required this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 12, color: Colors.black54)),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    ]);
  }
}





