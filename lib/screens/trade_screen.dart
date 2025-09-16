import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'trade_manager.dart';

class TradeScreen extends StatefulWidget {
  final String? coin;
  final String? type;
  final double? lot;
  final double? currentPrice;

  const TradeScreen({super.key, this.coin, this.type, this.lot, this.currentPrice});

  @override
  _TradeScreenState createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  double balance = 0.0;
  double equity = 0.0;
  double margin = 0.0;
  double freeMargin = 0.0;

  Timer? pnlTimer;

  @override
  void initState() {
    super.initState();
    _listenWalletBalance();

    pnlTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      TradeManager.updateAllPositions();
      setState(() {});
    });
  }

  @override
  void dispose() {
    pnlTimer?.cancel();
    super.dispose();
  }

  void _listenWalletBalance() {
    final userUid = "USER_ID";
    FirebaseFirestore.instance
        .collection("users")
        .doc(userUid)
        .collection("wallet")
        .doc("mainWallet")
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          balance = (data["balance"] ?? 0.0).toDouble();
          equity = balance;
          margin = 0.0;
          freeMargin = balance - margin;
        });
      } else {
        setState(() {
          balance = 0.0;
          equity = 0.0;
          margin = 0.0;
          freeMargin = 0.0;
        });
      }
    });
  }

  void _showClosePositionDialog(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Close Position"),
        content: const Text("Are you sure you want to close this position?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              TradeManager.closePosition(index);
              setState(() {});
            },
            child: const Text("Yes, Close"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _balanceRow("Balance", balance),
                _balanceRow("Equity", equity),
                _balanceRow("Margin", margin),
                _balanceRow("Free Margin", freeMargin),
              ],
            ),
          ),
          const Divider(thickness: 1),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Positions",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
            ),
          ),

          Expanded(
            child: TradeManager.allPositions.isEmpty
                ? const Center(
              child: Text(
                "No active positions",
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: TradeManager.allPositions.length,
              itemBuilder: (context, index) {
                final pos = TradeManager.allPositions[index];
                return PositionTile(
                  symbol: pos.symbol,
                  positionType: pos.type,
                  entryPrice: pos.entryPrice,
                  currentPrice: pos.currentPrice,
                  profitLoss: pos.profitLoss,
                  onLongPress: () => _showClosePositionDialog(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
          Text(value.toStringAsFixed(2),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }
}

class PositionTile extends StatelessWidget {
  final String symbol;
  final String positionType;
  final double entryPrice;
  final double currentPrice;
  final double profitLoss;
  final VoidCallback onLongPress;

  const PositionTile({
    super.key,
    required this.symbol,
    required this.positionType,
    required this.entryPrice,
    required this.currentPrice,
    required this.profitLoss,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3), blurRadius: 5, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(symbol,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(positionType,
                        style: TextStyle(
                            color: positionType == "Buy" ? Colors.green : Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 6),
                Text("${entryPrice.toStringAsFixed(2)} → ${currentPrice.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
            Row(
              children: [
                Text(profitLoss.toStringAsFixed(2),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: profitLoss < 0 ? Colors.red : Colors.green)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
