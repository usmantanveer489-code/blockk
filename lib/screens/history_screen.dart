import 'package:flutter/material.dart';
import 'trade_manager.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (mounted) setState(() {});
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final trades = TradeManager.closedPositions;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummary(),

            SizedBox(height: 20),

            Expanded(
              child: trades.isEmpty
                  ? Center(
                child: Text(
                  "No closed trades yet",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: trades.length,
                itemBuilder: (context, index) {
                  final trade = trades[index];
                  return _buildTransactionItem(trade);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final profit = TradeManager.closedPositions.fold(
      0.0,
          (sum, trade) => sum + trade.profitLoss,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Balance:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
          profit.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: profit >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Position trade) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${trade.symbol}, ${trade.type}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "${trade.entryPrice.toStringAsFixed(2)} → ${trade.exitPrice?.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                "${trade.closeTime?.toString().split('.')[0]}",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),

          Text(
            trade.profitLoss.toStringAsFixed(2),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: trade.profitLoss >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}