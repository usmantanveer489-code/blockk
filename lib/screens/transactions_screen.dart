import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023, 1),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);
        } else {
          _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: 45,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Transactions",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: const [
                      Text("Help",
                          style: TextStyle(color: Colors.blue, fontSize: 16)),
                      SizedBox(width: 6),
                      Icon(Icons.help_outline, color: Colors.blue),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 8),

            TabBar(
              controller: _tabController,
              indicator: const GradientTabIndicator(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6E3C1B),
                    Color(0xFFF8BE3B),
                    Color(0xFF6E3C1B),
                  ],
                ),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Wallet Transactions"),
                Tab(text: "Account Transactions"),
              ],
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt_outlined, color: Colors.black54),
                  const SizedBox(width: 8),
                  const Text("Filter",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                    child: Text("Clear Filter",
                        style: TextStyle(color: Colors.orange.shade700)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(isStart: true),
                      child: buildDateBox(
                        label: "Start Date",
                        date: _startDate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(isStart: false),
                      child: buildDateBox(
                        label: "End Date",
                        date: _endDate,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildTransactionList("wallet"),
                  buildTransactionList("account"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDateBox({required String label, DateTime? date}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date != null
                ? "${date.day}/${date.month}/${date.year}"
                : label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const Icon(Icons.calendar_today_outlined,
              size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget buildTransactionList(String category) {
    if (user == null) {
      return const Center(child: Text("User not logged in"));
    }

    Query query = FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("transactions")
        .where("category", isEqualTo: category);

    if (_startDate != null) {
      query = query.where("date", isGreaterThanOrEqualTo: _startDate);
    }
    if (_endDate != null) {
      query = query.where("date", isLessThanOrEqualTo: _endDate);
    }

    query = query.orderBy("date", descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No transactions found."));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            return transactionItem(
              type: data["type"] ?? "",
              date: data["date"] != null
                  ? (data["date"] as Timestamp).toDate().toString()
                  : "",
              txId: docs[index].id,
              from: data["from"] ?? "",
              to: data["to"] ?? "",
              status: data["status"] ?? "",
              amount: (data["amount"] ?? 0).toString(),
              note: data["note"],
            );
          },
        );
      },
    );
  }

  Widget transactionItem({
    required String type,
    required String date,
    required String txId,
    required String from,
    required String to,
    required String status,
    required String amount,
    String? note,
  }) {
    bool isRejected = status == "Rejected";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(type,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const Icon(Icons.north_east, color: Colors.red),
            ],
          ),
          const SizedBox(height: 4),

          Text(date,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          Text("Tx ID $txId",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.account_balance_wallet,
                  size: 20, color: Colors.orange),
              const SizedBox(width: 8),
              Text(from),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18, color: Colors.black54),
              const SizedBox(width: 8),
              const Icon(Icons.account_balance, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              Text(to),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status,
                  style: TextStyle(
                      color: isRejected ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Text("$amount USD",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black)),
            ],
          ),

          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                note,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            )
          ]
        ],
      ),
    );
  }
}

class GradientTabIndicator extends Decoration {
  final LinearGradient gradient;
  final double indicatorHeight;

  const GradientTabIndicator({
    required this.gradient,
    this.indicatorHeight = 3,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _GradientPainter(gradient, indicatorHeight);
  }
}

class _GradientPainter extends BoxPainter {
  final LinearGradient gradient;
  final double indicatorHeight;

  _GradientPainter(this.gradient, this.indicatorHeight);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Rect rect = Offset(offset.dx, cfg.size!.height - indicatorHeight) &
    Size(cfg.size!.width, indicatorHeight);
    final Paint paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }
}
