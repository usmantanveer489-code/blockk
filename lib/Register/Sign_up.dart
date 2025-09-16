import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Login/login_screen.dart';
import 'agreement_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rePasswordController = TextEditingController();

  final firstNameFocus = FocusNode();
  final lastNameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final rePasswordFocus = FocusNode();

  String tradingType = "ISM";
  bool termsAccepted = false;

  bool _obscurePassword = true;
  bool _obscureRePassword = true;
  bool _isLoading = false;

  void _handleTermsTap() async {
    final agreed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AgreementScreen()),
    );
    if (agreed == true) setState(() => termsAccepted = true);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('agree_terms'.tr())),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
          "email": emailController.text.trim(),
          "tradingType": tradingType,
          "balance": 0.0,
          "createdAt": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('register_now'.tr())),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registration failed")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();

    firstNameFocus.dispose();
    lastNameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    rePasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.asset('assets/images/logo.png', height: 80),
                  const SizedBox(height: 20),
                  Text('register_now'.tr(),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: _buildGradientTextField(
                          controller: firstNameController,
                          hint: 'first_name'.tr(),
                          validator: (v) =>
                          v!.isEmpty ? '${'first_name'.tr()} required' : null,
                          focusNode: firstNameFocus,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildGradientTextField(
                          controller: lastNameController,
                          hint: 'last_name'.tr(),
                          validator: (v) =>
                          v!.isEmpty ? '${'last_name'.tr()} required' : null,
                          focusNode: lastNameFocus,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  _buildGradientTextField(
                    controller: emailController,
                    hint: 'email'.tr(),
                    validator: (v) {
                      if (v == null || v.isEmpty) return '${'email'.tr()} required';
                      final emailRegex = RegExp(r"^[^@]+@[^@]+\.[^@]+");
                      if (!emailRegex.hasMatch(v)) return 'Enter valid email';
                      return null;
                    },
                    focusNode: emailFocus,
                  ),
                  const SizedBox(height: 15),

                  _buildGradientTextField(
                    controller: passwordController,
                    hint: 'password'.tr(),
                    obscure: _obscurePassword,
                    validator: (v) =>
                    v!.isEmpty ? '${'password'.tr()} required' : null,
                    focusNode: passwordFocus,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black45,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildGradientTextField(
                    controller: rePasswordController,
                    hint: 're_password'.tr(),
                    obscure: _obscureRePassword,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return '${'re_password'.tr()} required';
                      }
                      if (v != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    focusNode: rePasswordFocus,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureRePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black45,
                      ),
                      onPressed: () =>
                          setState(() => _obscureRePassword = !_obscureRePassword),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('choose_trading_type'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildTradingType('manual'.tr()),
                      const SizedBox(width: 100),
                      _buildTradingType('ism'.tr()),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (!termsAccepted) {
                            _handleTermsTap();
                          } else {
                            setState(() => termsAccepted = false);
                          }
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.3),
                            gradient: termsAccepted
                                ? const LinearGradient(
                              colors: [
                                Color(0xFF6E3C1B),
                                Color(0xFFF8BE3B),
                                Color(0xFF6E3C1B)
                              ],
                            )
                                : null,
                          ),
                          child: termsAccepted
                              ? const Icon(Icons.check,
                              color: Colors.white, size: 14)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: _handleTermsTap,
                          child: Text(
                            'agree_terms'.tr(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
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
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                            color: Colors.white)
                            : Text(
                          'submit'.tr(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('already_account'.tr() + " "),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => LoginScreen())),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Color(0xFFC59E52),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientTextField({
    required TextEditingController controller,
    required String hint,
    required FocusNode focusNode,
    String? Function(String?)? validator,
    bool obscure = false,
    Widget? suffix,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        String? errorMessage;

        void validate(String? val) {
          final result = validator?.call(val);
          setState(() => errorMessage = result);
        }

        return Focus(
          focusNode: focusNode,
          child: AnimatedBuilder(
            animation: focusNode,
            builder: (context, _) {
              final isFocused = focusNode.hasFocus;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: isFocused
                          ? const LinearGradient(
                        colors: [
                          Color(0xFF6E3C1B),
                          Color(0xFFF8BE3B),
                          Color(0xFF6E3C1B),
                        ],
                      )
                          : null,
                      boxShadow: isFocused
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                          : [],
                    ),
                    padding:
                    isFocused ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: controller,
                        obscureText: obscure,
                        onChanged: (val) => validate(val),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) => validator?.call(val),
                        decoration: InputDecoration(
                          hintText: hint,
                          suffixIcon: suffix,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  if (errorMessage != null && errorMessage!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTradingType(String type) {
    final selected = tradingType == type;

    return GestureDetector(
      onTap: () => setState(() => tradingType = type),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: selected
                  ? const LinearGradient(
                colors: [
                  Color(0xFF6E3C1B),
                  Color(0xFFF8BE3B),
                  Color(0xFF6E3C1B),
                ],
              )
                  : null,
              border: selected
                  ? null
                  : Border.all(color: Colors.grey.shade500, width: 1.5),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: selected
                    ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF6E3C1B),
                        Color(0xFFF8BE3B),
                        Color(0xFF6E3C1B),
                      ],
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(type, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
