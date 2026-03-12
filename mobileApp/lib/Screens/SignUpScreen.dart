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

  final authService = AuthService(); // You can add register function here

  // ----------------- HANDLE SIGN UP -----------------
  void handleSignUp() async {
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
      // Replace this with your PHP register endpoint
      final response = await authService.register(
        fullnameCont.text,
        emailCont.text,
        mobileCont.text,
        passwordCont.text,
        locationCont.text,
      );

      if (response) {
        // Show success message
        toast("Registration successful! Please login.");

        // Navigate to SignInScreen
        SignInScreen().launch(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, 'Sign Up'),
      body: Center(
        child: Container(
          width: dynamicWidth(context),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Account', style: boldTextStyle(size: 24)),
                30.height,

                // FULLNAME
                TextFormField(
                  controller: fullnameCont,
                  style: primaryTextStyle(),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                16.height,

                // EMAIL
                TextFormField(
                  controller: emailCont,
                  style: primaryTextStyle(),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                16.height,

                // MOBILE
                TextFormField(
                  controller: mobileCont,
                  style: primaryTextStyle(),
                  decoration: InputDecoration(
                    labelText: 'Mobile',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                16.height,

                // LOCATION
                TextFormField(
                  controller: locationCont,
                  style: primaryTextStyle(),
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                16.height,

                // PASSWORD
                TextFormField(
                  controller: passwordCont,
                  focusNode: passFocus,
                  obscureText: obscureText,
                  style: primaryTextStyle(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                  ),
                ),
                16.height,

                // ERROR MESSAGE
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ).paddingSymmetric(vertical: 8),

                // SIGN UP BUTTON
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: appColorPrimary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: defaultBoxShadow(),
                  ),
                  child: loading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Sign Up',
                          style: boldTextStyle(color: white, size: 18),
                        ),
                ).onTap(() {
                  if (!loading) handleSignUp();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}