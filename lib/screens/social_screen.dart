import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});


  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  String? selectedCountry;
  String? selectedUserId;
  DateTime? startDate;
  DateTime? endDate;
  String? currentUserId;

  final List<String> userIds = ['372879', '948687'];

  final List<String> countries = [
    'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Argentina', 'Armenia',
    'Australia', 'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados',
    'Belarus', 'Belgium', 'Belize', 'Benin', 'Bhutan', 'Bolivia', 'Bosnia', 'Botswana',
    'Brazil', 'Brunei', 'Bulgaria', 'Burkina Faso', 'Burundi', 'Cambodia', 'Cameroon',
    'Canada', 'Cape Verde', 'Central African Republic', 'Chad', 'Chile', 'China', 'Colombia',
    'Comoros', 'Congo', 'Costa Rica', 'Croatia', 'Cuba', 'Cyprus', 'Czech Republic',
    'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic', 'Ecuador', 'Egypt', 'El Salvador',
    'Equatorial Guinea', 'Eritrea', 'Estonia', 'Eswatini', 'Ethiopia', 'Fiji', 'Finland',
    'France', 'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana', 'Greece', 'Grenada',
    'Guatemala', 'Guinea', 'Guyana', 'Haiti', 'Honduras', 'Hungary', 'Iceland', 'India',
    'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel', 'Italy', 'Jamaica', 'Japan', 'Jordan',
    'Kazakhstan', 'Kenya', 'Kiribati', 'Kuwait', 'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon',
    'Lesotho', 'Liberia', 'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Madagascar',
    'Malawi', 'Malaysia', 'Maldives', 'Mali', 'Malta', 'Mauritania', 'Mauritius', 'Mexico',
    'Moldova', 'Monaco', 'Mongolia', 'Montenegro', 'Morocco', 'Mozambique', 'Myanmar',
    'Namibia', 'Nepal', 'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria',
    'North Korea', 'North Macedonia', 'Norway', 'Oman', 'Pakistan', 'Palau', 'Panama',
    'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines', 'Poland', 'Portugal', 'Qatar',
    'Romania', 'Russia', 'Rwanda', 'Saint Kitts', 'Saint Lucia', 'Saint Vincent', 'Samoa',
    'San Marino', 'Sao Tome', 'Saudi Arabia', 'Senegal', 'Serbia', 'Seychelles',
    'Sierra Leone', 'Singapore', 'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia',
    'South Africa', 'South Korea', 'Spain', 'Sri Lanka', 'Sudan', 'Suriname', 'Sweden',
    'Switzerland', 'Syria', 'Taiwan', 'Tajikistan', 'Tanzania', 'Thailand', 'Togo', 'Tonga',
    'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan', 'Tuvalu', 'Uganda',
    'Ukraine', 'UAE', 'UK', 'USA', 'Uruguay', 'Uzbekistan', 'Vanuatu', 'Vatican',
    'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe'
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        currentUserId = currentUser.uid;
      });
    }
  }

  Future<void> pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF6E3C1B),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(picked)) endDate = null;
        } else {
          endDate = picked;
          if (startDate != null && startDate!.isAfter(picked)) startDate = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Image.asset('assets/images/logo.png', height: 50),
                    const Icon(Icons.help_outline, color: Colors.blue),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Referrals',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _ReferralCard(userId: currentUserId!),
                const SizedBox(height: 24),
                _FilterSection(
                  countries: countries,
                  selectedCountry: selectedCountry,
                  onCountryChanged: (value) => setState(() => selectedCountry = value),
                  userIds: userIds,
                  selectedUserId: selectedUserId,
                  onUserIdChanged: (value) => setState(() => selectedUserId = value),
                  startDate: startDate,
                  endDate: endDate,
                  onStartDateTap: () => pickDate(context, true),
                  onEndDateTap: () => pickDate(context, false),
                  onClear: () {
                    setState(() {
                      selectedCountry = null;
                      selectedUserId = null;
                      startDate = null;
                      endDate = null;
                    });
                  },
                ),
                const SizedBox(height: 24),
                const _UserListHeader(),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('referredBy', isEqualTo: currentUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text("No referrals yet"),
                      );
                    }

                    final users = snapshot.data!.docs;

                    return Column(
                      children: users.map((user) {
                        final data = user.data() as Map<String, dynamic>? ?? {};
                        final name =
                            "${data['firstName'] ?? 'No'} ${data['lastName'] ?? 'Name'}";
                        final id = data['userId'] ?? user.id;
                        final status = (data['tradingType'] != null && data['tradingType'] != '')
                            ? "Active"
                            : "Non-Active";

                        return _UserListItem(name: name, id: id, status: status);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final String userId;
  const _ReferralCard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        final name = "${data['firstName'] ?? 'No'} ${data['lastName'] ?? 'Name'}";
        final totalRegistrations = (data['totalRegistrations'] ?? 0).toString();
        final activeAccounts = (data['activeAccounts'] ?? 0).toString();
        final totalDeposits = (data['totalDeposits'] ?? 0).toString();
        final lotSize = (data['lotSize'] ?? 0).toString();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatColumn(title: "Total Registrations", value: totalRegistrations),
                  _StatColumn(title: "Active Accounts", value: activeAccounts),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatColumn(title: "Total Deposits", value: totalDeposits),
                  _StatColumn(title: "Lot Size", value: lotSize),
                ],
              ),
              const SizedBox(height: 16),
              _GradientButton(
                text: "Copy URL",
                icon: Icons.copy,
                onPressed: () {
                  final referralUrl = "https://yourapp.com/referral?uid=$userId";

                  Clipboard.setData(ClipboardData(text: referralUrl));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Referral URL copied:\n$referralUrl"),
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green[600],
                    ),
                  );
                },
              ),

            ],
          ),
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String title;
  final String value;

  const _StatColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      ],
    );
  }
}

class _FilterSection extends StatelessWidget {
  final List<String> countries;
  final String? selectedCountry;
  final ValueChanged<String?> onCountryChanged;

  final List<String> userIds;
  final String? selectedUserId;
  final ValueChanged<String?> onUserIdChanged;

  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final VoidCallback onClear;

  const _FilterSection({
    required this.countries,
    required this.selectedCountry,
    required this.onCountryChanged,
    required this.userIds,
    required this.selectedUserId,
    required this.onUserIdChanged,
    required this.startDate,
    required this.endDate,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade400),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tune, size: 20),
            const SizedBox(width: 6),
            const Text("Filter", style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(
              onPressed: onClear,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF6E3C1B),
                    Color(0xFFF8BE3B),
                    Color(0xFF6E3C1B),
                  ],
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: const Text(
                  "Clear Filter",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          ],
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select Country',
            filled: true,
            fillColor: Colors.white,
            border: inputBorder,
            focusedBorder: inputBorder.copyWith(
              borderSide: const BorderSide(color: Color(0xFF6E3C1B)),
            ),
          ),
          dropdownColor: Colors.white,
          value: selectedCountry,
          items: countries
              .map((country) => DropdownMenuItem(
            value: country,
            child: Text(country),
          ))
              .toList(),
          onChanged: onCountryChanged,
        ),
        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select User ID',
            filled: true,
            fillColor: Colors.white,
            border: inputBorder,
            focusedBorder: inputBorder.copyWith(
              borderSide: const BorderSide(color: Color(0xFF6E3C1B)),
            ),
          ),
          dropdownColor: Colors.white,
          value: selectedUserId,
          items: userIds
              .map((id) => DropdownMenuItem(
            value: id,
            child: Text(id),
          ))
              .toList(),
          onChanged: onUserIdChanged,
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onStartDateTap,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      hintText:
                      startDate != null ? "${startDate!.toLocal()}".split(' ')[0] : 'Start Date',
                      suffixIcon: const Icon(Icons.calendar_today, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: inputBorder,
                      focusedBorder: inputBorder.copyWith(
                        borderSide: const BorderSide(color: Color(0xFF6E3C1B)),
                      ),
                    ),
                    style: TextStyle(
                      color: startDate != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: onEndDateTap,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      hintText: endDate != null ? "${endDate!.toLocal()}".split(' ')[0] : 'End Date',
                      suffixIcon: const Icon(Icons.calendar_today, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: inputBorder,
                      focusedBorder: inputBorder.copyWith(
                        borderSide: const BorderSide(color: Color(0xFF6E3C1B)),
                      ),
                    ),
                    style: TextStyle(
                      color: endDate != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _GradientButton(
          text: "Apply",
          icon: Icons.check,
          onPressed: null,
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;

  const _GradientButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6E3C1B),
            Color(0xFFF8BE3B),
            Color(0xFF6E3C1B),
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: TextButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        onPressed: onPressed,
      ),
    );
  }
}

class _UserListHeader extends StatelessWidget {
  const _UserListHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(flex: 2, child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }
}

class _UserListItem extends StatelessWidget {
  final String name;
  final String id;
  final String status;

  const _UserListItem({required this.name, required this.id, required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == "Active" ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(name)),
          Expanded(child: Text(id)),
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
