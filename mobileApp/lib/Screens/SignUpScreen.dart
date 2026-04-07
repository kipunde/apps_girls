import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../Services/AuthService.dart';
import '../utils/AppColors.dart';
import '../utils/AppWidget.dart';
import 'SignInScreen.dart';

class SignUpScreen extends StatefulWidget {
  static String tag = '/SignUpScreen';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool obscureText = true;
  bool loading = false;
  String errorMessage = "";

  final fullnameCont = TextEditingController();
  final emailCont = TextEditingController();
  final mobileCont = TextEditingController();
  final locationCont = TextEditingController();
  final passwordCont = TextEditingController();
  final passFocus = FocusNode();

  final authService = AuthService();

  /// ---------------- HANDLE SIGN UP -----------------
  Future<void> handleSignUp() async {
    if (fullnameCont.text.isEmpty ||
        emailCont.text.isEmpty ||
        passwordCont.text.isEmpty ||
        mobileCont.text.isEmpty) {
      setState(() => errorMessage = "All fields are required");
      return;
    }

    setState(() {
      loading = true;
      errorMessage = "";
    });

    try {
      final response = await authService.register(
        fullnameCont.text.trim(),
        emailCont.text.trim(),
        mobileCont.text.trim(),
        passwordCont.text,
        locationCont.text.trim(),
      );

      if (response) {
        toast("Registration successful! Please login.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SignInScreen()),
        );
      } else {
        setState(() => errorMessage = "Registration failed");
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    fullnameCont.dispose();
    emailCont.dispose();
    mobileCont.dispose();
    locationCont.dispose();
    passwordCont.dispose();
    passFocus.dispose();
    super.dispose();
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        /// HEADER
        appBar: AppBar(
          backgroundColor: const Color(0xffe91e63),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "WomenBiz 360",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TOP BANNER
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage("images/banner.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              25.height,

              /// PAGE TITLE
              const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Color(0xffe91e63))),
              30.height,

              /// FULLNAME
              TextFormField(
                controller: fullnameCont,
                style: primaryTextStyle(),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              16.height,

              /// EMAIL
              TextFormField(
                controller: emailCont,
                style: primaryTextStyle(),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              16.height,

              /// MOBILE
              TextFormField(
                controller: mobileCont,
                style: primaryTextStyle(),
                decoration: const InputDecoration(
                  labelText: 'Mobile',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
                keyboardType: TextInputType.phone,
              ),
              16.height,

              /// LOCATION
              TextFormField(
                controller: locationCont,
                style: primaryTextStyle(),
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              16.height,

              /// PASSWORD
              TextFormField(
                controller: passwordCont,
                focusNode: passFocus,
                obscureText: obscureText,
                style: primaryTextStyle(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: IconButton(
                    icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() => obscureText = !obscureText);
                    },
                  ),
                ),
              ),
              16.height,

              /// ERROR MESSAGE
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ).paddingSymmetric(vertical: 8),

              16.height,

              /// SIGN UP BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffe91e63),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}