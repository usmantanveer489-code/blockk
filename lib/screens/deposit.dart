import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;
  String _selectedMethod = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _createDeposit(double amount) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    try {
      final walletDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wallet')
          .doc('mainWallet');

      await walletDocRef.set({
        'balance': 0.0,
        'currency': 'USD',
      }, SetOptions(merge: true));

      await walletDocRef.collection('transactions').add({
        'type': 'Deposit',
        'amount': amount,
        'from': 'USD Tether',
        'to': 'FUNDING',
        'status': 'Pending',
        'date': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deposit request created')));
      _amountController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showDepositPopup() {
    String? selectedUserId;
    String selectedCurrency = "USD";

    final List<String> userIds = ["User1", "User2"]; // dummy users
    final List<String> currencies = ["USD", "EUR", "GBP", "JPY", "AUD"];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Funds with USD Tether",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, // prevents overflow
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select User *",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: userIds
                        .map((id) => DropdownMenuItem(value: id, child: Text(id)))
                        .toList(),
                    value: selectedUserId,
                    onChanged: (value) {
                      selectedUserId = value;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Currency *",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    value: selectedCurrency,
                    onChanged: (value) {
                      if (value != null) selectedCurrency = value;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Amount *",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () {
                        final amount = double.tryParse(_amountController.text);
                        if (selectedUserId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Select a user")));
                          return;
                        }
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Enter a valid amount")));
                          return;
                        }

                        Navigator.of(ctx).pop();
                        _showConfirmDepositPopup(amount);

                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6E3C1B),
                              Color(0xFFF8BE3B),
                              Color(0xFF6E3C1B)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Next Step",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  File? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showConfirmDepositPopup(double amount) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Confirm Deposit",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Amount To Receive"),
                      Text("\$${amount.toStringAsFixed(2)}"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Fee"),
                      Text("0 USD", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Amount To Send"),
                      Text("\$${amount.toStringAsFixed(2)}"),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Deposit Methods",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Binance ID: 0xd285fb4f2c5cea1a09327afaf1fe8fc0b1448f05",
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                onPressed: () {
                                  Clipboard.setData(const ClipboardData(
                                      text:
                                      "0xd285fb4f2c5cea1a09327afaf1fe8fc0b1448f05"));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Binance ID copied")));
                                },
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6E3C1B),
                                        Color(0xFFF8BE3B),
                                        Color(0xFF6E3C1B),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                    child: const Text(
                                      "Copy",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: _pickImage,
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6E3C1B),
                              Color(0xFFF8BE3B),
                              Color(0xFF6E3C1B),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: const Text(
                            "Upload Image",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () async {
                        setState(() => _isProcessing = true);

                        await _createDeposit(amount);

                        setState(() => _isProcessing = false);
                        Navigator.of(ctx).pop();
                        _showDepositPopup();
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6E3C1B),
                              Color(0xFFF8BE3B),
                              Color(0xFF6E3C1B),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            _isProcessing ? "Processing..." : "Submit",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showDepositPopup();
                    },
                    child: const Center(
                      child: Text(
                        "Back to Previous",
                        style: TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddPaymentPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change Payment Method"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.account_balance, color: Colors.amber),
                title: const Text("Fiat"),
                trailing: Radio(
                  value: "Fiat",
                  groupValue: "Fiat",
                  onChanged: (value) {
                    Navigator.pop(context);
                    // Handle Fiat selection
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.currency_bitcoin, color: Colors.amber),
                title: const Text("Crypto"),
                trailing: Radio(
                  value: "Crypto",
                  groupValue: "Crypto",
                  onChanged: (value) {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
  void _showBankDepositPopup() {
    final TextEditingController _depositAmountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bank Deposit",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _depositAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter Amount (USD)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_depositAmountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter amount")));
                      return;
                    }

                    double depositAmount = double.tryParse(_depositAmountController.text) ?? 0;
                    if (depositAmount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Enter a valid amount")));
                      return;
                    }

                    Navigator.pop(context);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => UsePaypal(
                          sandboxMode: true,
                          clientId: "AXwVZ1ZQ0TXIexOnsUFsz83UGCzUelQmKfz2hPMDs5ThkgkEGh5R0NOovlsfLKUz4ObKtU3iLlJ1KOuU",
                          secretKey: "EBbpXs8TIN1HFaq05aw60tsVkqpZROHU5mho1i1y2JtEzdYNVhHFsHGOP_Tt669_N13b0wDgUCdtNlyq",
                          returnURL: "https://example.com/success",
                          cancelURL: "https://example.com/cancel",
                          transactions: [
                            {
                              "amount": {
                                "total": depositAmount.toStringAsFixed(2),
                                "currency": "USD",
                                "details": {
                                  "subtotal": depositAmount.toStringAsFixed(2),
                                  "shipping": '0'
                                }
                              },
                              "description": "Wallet Deposit",
                              "item_list": {
                                "items": [
                                  {
                                    "name": "Wallet Deposit",
                                    "quantity": 1,
                                    "price": depositAmount.toStringAsFixed(2),
                                    "currency": "USD"
                                  }
                                ]
                              }
                            }
                          ],
                          note: "Deposit to wallet",
                          onSuccess: (Map params) async {
                            final userUid = FirebaseAuth.instance.currentUser!.uid;
                            final walletDocRef = FirebaseFirestore.instance
                                .collection("users")
                                .doc(userUid)
                                .collection("wallet")
                                .doc("mainWallet");

                            await walletDocRef.set({
                              "balance": 0.0,
                              "currency": "USD"
                            }, SetOptions(merge: true));

                            await walletDocRef.update({
                              "balance": FieldValue.increment(depositAmount)
                            });

                            await walletDocRef.collection("transactions").add({
                              "type": "deposit",
                              "amount": depositAmount,
                              "currency": "USD",
                              "method": "paypal",
                              "status": "success",
                              "timestamp": FieldValue.serverTimestamp(),
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Deposit Successful! +\$${depositAmount.toStringAsFixed(2)}")));
                          },
                          onError: (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("PayPal Error: $error")));
                          },
                          onCancel: (params) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Payment Cancelled")));
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text("Proceed to PayPal"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Image.asset("assets/images/logo.png", height: 40),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Image.asset("assets/images/funding.png", width: 30, height: 30),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("450.00"),
                          Text("USD", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),
                      const Text("FUNDING"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Image.asset("assets/images/partner.png", width: 30, height: 30),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("450.00"),
                          Text("USD", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),
                      const Text("PARTNER"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Image.asset("assets/images/sociall.png", width: 30, height: 30),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("450.00"),
                          Text("USD", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),
                      const Text("SOCIAL"),
                    ],
                  ),
                ],
              ),
            ),

            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(width: 2, color: Colors.black),
              ),
              tabs: const [
                Tab(text: "Deposit"),
                Tab(text: "Transfer"),
                Tab(text: "Withdraw"),
                Tab(text: "Payment"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Deposit Methods",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 6,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset("assets/images/binance.png",
                                      width: 40, height: 40),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Crypto Deposit",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedMethod = "Crypto";
                                    });
                                    _showDepositPopup();
                                  },
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF6E3C1B), Color(0xFFF8BE3B), Color(0xFF6E3C1B)],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      child: const Text(
                                        "Deposit via Crypto",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 6,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset("assets/images/bank_icon.png",
                                      width: 40, height: 40),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Bank Account",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedMethod = "bank";
                                    });
                                    _showBankDepositPopup();
                                  },
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF6E3C1B), Color(0xFFF8BE3B), Color(0xFF6E3C1B)],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      child: const Text(
                                        "Deposit via Bank",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),


                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Transfer",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: '1234567',
                          decoration: InputDecoration(
                            labelText: "Transferring From *",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: ['1234567', '2345678']
                              .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                              .toList(),
                          onChanged: (value) {
                            // Handle if needed
                          },
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Amount *",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: '1234567',
                          decoration: InputDecoration(
                            labelText: "Transferring To *",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: ['1234567', '2345678']
                              .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                              .toList(),
                          onChanged: (value) {
                          },
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Fee:",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "0 USD",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Amount To Be Transferred:",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              _amountController.text.isEmpty
                                  ? "0 USD"
                                  : "${_amountController.text} USD",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Transfer submitted")),
                              );
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6E3C1B),
                                    Color(0xFFF8BE3B),
                                    Color(0xFF6E3C1B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: const Text(
                                  "Submit Transfer",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Withdraw Funds",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: 'Select',
                          decoration: InputDecoration(
                            labelText: "Wallet *",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: ['Select', 'Wallet 1', 'Wallet 2']
                              .map((wallet) => DropdownMenuItem(
                            value: wallet,
                            child: Text(wallet),
                          ))
                              .toList(),
                          onChanged: (value) {
                          },
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Fee *",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: 'USD',
                          decoration: InputDecoration(
                            labelText: "Currency *",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: ['USD', 'EUR', 'JPY', 'GBP']
                              .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ))
                              .toList(),
                          onChanged: (value) {
                          },
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.all(0),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Processing your withdrawal..."),
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              Future.delayed(const Duration(seconds: 1), () {
                                DefaultTabController.of(context)?.animateTo(2); // Payment tab index
                              });
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6E3C1B),
                                    Color(0xFFF8BE3B),
                                    Color(0xFF6E3C1B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: const Text(
                                  "Confirm",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        String? selectedMethod;

                        void _showAddPaymentPopup() {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (_) {
                              return StatefulBuilder(
                                builder: (context, modalSetState) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Add Payment Method",
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 12),
                                        const Text("Currency Type",
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 6),
                                        const Text("Select a currency type",
                                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        const SizedBox(height: 20),

                                        ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: selectedMethod == "fiat"
                                                  ? Colors.blue
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                          title: const Text("Fiat"),
                                          subtitle: const Text("Add payment method like banks or credit cards"),
                                          leading: const Icon(Icons.account_balance),
                                          onTap: () {
                                            modalSetState(() => selectedMethod = "fiat");
                                          },
                                        ),
                                        const SizedBox(height: 12),

                                        ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: selectedMethod == "crypto"
                                                  ? Colors.blue
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                          title: const Text("Crypto"),
                                          subtitle: const Text("Add payment method like wallets"),
                                          leading: const Icon(Icons.currency_bitcoin),
                                          onTap: () {
                                            modalSetState(() => selectedMethod = "crypto");
                                          },
                                        ),
                                        const SizedBox(height: 20),

                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: selectedMethod == null
                                                ? null
                                                : () {
                                              setState(() {}); // update parent UI if needed
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Next"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Payment Methods",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/images/bank_icon.png",
                                    width: 40,
                                    height: 40,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text("Bank (USD)",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 2),
                                      Text("Nayapay = 875439526",
                                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _showAddPaymentPopup();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text("Add Payment Method"),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            )

          ],
        ));
  }
}

