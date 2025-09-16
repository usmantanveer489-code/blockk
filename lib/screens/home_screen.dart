import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:blockfoliox/screens/deposit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../Login/login_screen.dart';
import 'chart_screen.dart';
import 'trade_screen.dart';
import 'history_screen.dart';
import 'dashboard_screen.dart';
import 'kyc_screen.dart';
import 'transactions_screen.dart';
import 'language_screen.dart';
import 'social_screen.dart';
import 'setting_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> cryptoData = [];
  bool isLoading = true;
  int selectedIndex = 0;
  double balance = 0.0;
  double awardValue = 0.0;
  double investedValue = 0.0;

  String selectedCoin = "BTCUSDT";
  double selectedCoinPrice = 0;

  String userName = "Loading...";
  String userId = "-----";

  final String binanceApiKey = "t3nSt1SJD50Cs3c3CsgszRUxF4Fb";

  final Map<String, String> coinLogos = {
    "BCCUSDT": "assets/images/bcc.png",
    "NEOUSDT": "assets/images/neo.png",
    "LTCUSDT": "assets/images/ltc.png",
    "QTUMUSDT": "assets/images/qtum.png",
    "ADAUSDT": "assets/images/ada.png",
    "XRPUSDT": "assets/images/xrp.png",
    "BNBUSDT": "assets/images/bnb.png",
    "ETHUSDT": "assets/images/eth.png",
    "BTCUSDT": "assets/images/btc.png",
    "EOSUSDT": "assets/images/eos.png",
    "TUSDUSDT": "assets/images/tusd.png",
    "IOTAUSDT": "assets/images/iota.png",
  };



  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchCryptoData();
    fetchUserData();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> fetchCryptoData() async {
    setState(() => isLoading = true);
    final url = Uri.parse("https://api.binance.com/api/v3/ticker/24hr");

    try {
      final response = await http.get(url, headers: {'X-MBX-APIKEY': binanceApiKey});

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final filtered = data
            .where((c) => c['symbol']?.toString().endsWith("USDT") == true)
            .take(12)
            .toList();

        setState(() {
          cryptoData = filtered;
          final selected = filtered.firstWhere(
                (c) => c['symbol'] == selectedCoin,
            orElse: () => null,
          );
          if (selected != null) {
            selectedCoinPrice = double.tryParse(selected['lastPrice'] ?? "0") ?? 0;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching Binance data: $e");
      setState(() => isLoading = false);
    }
  }



  void _onNavItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }


  Future<void> _depositGift(double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentBalance = (data["balance"] ?? 0).toDouble();
      final currentAward = (data["awardValue"] ?? 0).toDouble();

      final updatedBalance = currentBalance + amount;
      final updatedAward = currentAward + 50;

      transaction.update(docRef, {
        "balance": updatedBalance,
        "awardValue": updatedAward,
      });

      setState(() {
        balance = updatedBalance;
        awardValue = updatedAward;
      });
    });
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            color: Colors.white,
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFE0E0E0),
                      backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(userName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text("id: $userId",
                        style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 6),
                    const Text("Verified",
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1976D2),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _drawerItem("assets/images/dashboard.png", "Dashboard",
                  () => _navigate(context, const DashboardScreen())),
          _drawerItem("assets/images/kyc.png", "KYC",
                  () => _navigate(context, const KycScreen())),
          _drawerItem("assets/images/transactions.png", "Transactions",
                  () => _navigate(context,  TransactionScreen())),
          _drawerItem("assets/images/language.png", "Language",
                  () => _navigate(context, const LanguageScreen())),
          _drawerItem("assets/images/social.png", "Social",
                  () => _navigate(context, SocialScreen())),
          const Divider(height: 1),
          _drawerItem("assets/images/settings.png", "Setting",
                  () => _navigate(context, SettingScreen())),
          _drawerItem("assets/images/about.png", "About",
                  () => _navigate(context, AboutScreen())),
          _drawerItem("assets/images/logout.png", "Logout",
                  () => _showLogoutConfirmationDialog(context)),
        ],
      ),
    );
  }

  Widget _drawerItem(String iconPath, String label, VoidCallback onTap) {
    return ListTile(
      leading: Image.asset(iconPath, height: 22, width: 22),
      title: Text(label,
          style: const TextStyle(fontSize: 14.5, color: Colors.black87)),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    const gradientColors = [
      Color(0xFF6E3C1B),
      Color(0xFFF8BE3B),
      Color(0xFF6E3C1B)
    ];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Are you Sure to Log out',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6)),
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12)),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: Color(0xFF6E3C1B),
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) =>  LoginScreen()),
                        (route) => false,
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    child: Text('Log Out',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      userId = user.uid.substring(0, 6);

      try {
        final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
        final doc = await docRef.get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final firstName = (data["firstName"] ?? "").toString().trim();
          final lastName = (data["lastName"] ?? "").toString().trim();

          setState(() {
            if (firstName.isNotEmpty || lastName.isNotEmpty) {
              userName = "$firstName $lastName".trim();
            } else if (user.displayName != null && user.displayName!.isNotEmpty) {
              userName = user.displayName!;
            } else if (user.email != null) {
              userName = user.email!.split("@").first;
            } else {
              userName = "User";
            }

            balance = (data["balance"] ?? 0).toDouble();
            awardValue = (data["awardValue"] ?? 0).toDouble();
          });
        } else {
          final displayName = user.displayName ?? "";
          final nameParts = displayName.split(" ");
          final firstName = nameParts.isNotEmpty ? nameParts.first : "";
          final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

          await docRef.set({
            "firstName": firstName.isNotEmpty ? firstName : user.email?.split("@").first ?? "New",
            "lastName": lastName,
            "email": user.email ?? "",
            "balance": 0.0,
            "awardValue": 0.0,
          });

          setState(() {
            userName = displayName.isNotEmpty
                ? displayName
                : (user.email?.split("@").first ?? "New User");
            balance = 0.0;
            awardValue = 0.0;
          });
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
        setState(() {
          userName = user.displayName ??
              (user.email?.split("@").first ?? "Guest User");
          balance = 0.0;
          awardValue = 0.0;
        });
      }
    } else {
      setState(() {
        userName = "Guest User";
        userId = "000000";
        balance = 0.0;
        awardValue = 0.0;
      });
    }
  }


  BottomNavigationBarItem _buildNavItem(
      String iconPath, String label, int index) {
    final bool isSelected = selectedIndex == index;
    const gradientColors = [
      Color(0xFF6E3C1B),
      Color(0xFFF8BE3B),
      Color(0xFF6E3C1B),
    ];

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isSelected
              ? ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: Image.asset(iconPath, height: 23, color: Colors.white),
          )
              : Image.asset(iconPath, height: 23, color: Colors.black),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: isSelected ? null : Colors.black,
              foreground: isSelected
                  ? (Paint()
                ..shader = const LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(
                  const Rect.fromLTWH(0, 0, 100, 20),
                ))
                  : null,
            ),
          ),
        ],
      ),
      label: '',
    );
  }

  Widget _buildAccountPage() {
    return RefreshIndicator(
      onRefresh: fetchCryptoData,
      color: const Color(0xFF6E3C1B),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6E3C1B), Color(0xFFF8BE3B), Color(0xFF6E3C1B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("#$userId", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 12),
                  Text("${balance.toStringAsFixed(2)} USD", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Invested Value\n${investedValue.toStringAsFixed(2)} USD",
                          style: const TextStyle(color: Colors.white, fontSize: 14)),
                      Text("Award Value\n${awardValue.toStringAsFixed(2)} USD",
                          style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  )

                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DepositScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      height: 45.0,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6E3C1B), Color(0xFFF8BE3B)],
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: const Center(
                        child: Text(
                          "Deposit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DepositScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      height: 45.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.black, width: 1.0),
                      ),
                      child: const Center(
                        child: Text(
                          "Withdraw",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Your Asset", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: cryptoData.map((coin) {
                final symbol = coin['symbol']?.toString() ?? 'Unknown';
                final lastPrice = double.tryParse(coin['lastPrice'] ?? "0") ?? 0.0;
                final change = double.tryParse(coin['priceChange'] ?? "0") ?? 0.0;
                final changePercent = double.tryParse(coin['priceChangePercent'] ?? "0") ?? 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFE0E0E0),
                        backgroundImage: coinLogos.containsKey(symbol)
                            ? AssetImage(coinLogos[symbol]!)
                            : AssetImage("assets/images/default.png"),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(symbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            const Text("Binance Market", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("\$${lastPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            "${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)",
                            style: TextStyle(fontSize: 12, color: changePercent >= 0 ? Colors.green : Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedPage() {
    switch (selectedIndex) {
      case 0:
        return _buildAccountPage();
      case 1:
        return ChartScreen(coin: selectedCoin);
      case 2:
        return TradeScreen(
          coin: selectedCoin,
          type: 'Buy',
          lot: 0.01,
          currentPrice: selectedCoinPrice,
        );
      case 3:
        return HistoryScreen();
      default:
        return _buildAccountPage();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          selectedIndex == 0
              ? "Account"
              : selectedIndex == 1
              ? "Charts"
              : selectedIndex == 2
              ? "Trade"
              : "History",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF4F4F4),
        onTap: _onNavItemTapped,
        items: [
          _buildNavItem("assets/images/wallet.png", "Account", 0),
          _buildNavItem("assets/images/chart.png", "Charts", 1),
          _buildNavItem("assets/images/trade.png", "Trade", 2),
          _buildNavItem("assets/images/history.png", "History", 3),
        ],
      ),
    );
  }
}


