import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../Services/AuthService.dart';
import '../main.dart';
import '../utils/AppColors.dart';
import '../utils/AppWidget.dart';
import 'DrawerWidget.dart';
import 'HomeScreen.dart';
import 'SignUpScreen.dart'; // Make sure you have this screen

class SignInScreen extends StatefulWidget {
  static String tag = '/SignInScreen';

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  bool obscureText = true;
  bool loading = false;
  String errorMessage = "";

  final emailCont = TextEditingController();
  final passCont = TextEditingController();
  final passFocus = FocusNode();

  final authService = AuthService();

  // ----------------- HANDLE LOGIN -----------------
  void handleLogin() async {
    setState(() {
      loading = true;
      errorMessage = "";
    });

    try {
      final success = await authService.login(emailCont.text, passCont.text);

      if (success) {
        // Get user details from secure storage
        final userDetails = await authService.getUserAccessDetails();

        debugPrint(
            "LOGGED IN USER → name: ${userDetails?.name}, role: ${userDetails?.role}");

        // Save user name in appStore (fallback to "Guest")
        appStore.setUserName(userDetails?.name ?? "Guest");

        // Navigate to Home screen
        HomeScreen().launch(context);
      } else {
        setState(() => errorMessage = "Invalid email or password");
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  // ----------------- LIFECYCLE -----------------
  @override
  void dispose() {
    emailCont.dispose();
    passCont.dispose();
    passFocus.dispose();
    super.dispose();
  }

  // ----------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar(context, 'Sign In'),
      drawer: DrawerWidget(),
      body: Center(
        child: Container(
          width: dynamicWidth(context),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sign In', style: boldTextStyle(size: 24)),
                30.height,

                // EMAIL
                TextFormField(
                  controller: emailCont,
                  style: primaryTextStyle(),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    contentPadding: EdgeInsets.all(16),
                    labelStyle: secondaryTextStyle(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: appColorPrimary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: appStore!.textSecondaryColor ?? Colors.blue),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(passFocus),
                  textInputAction: TextInputAction.next,
                ),
                16.height,

                // PASSWORD
                TextFormField(
                  obscureText: obscureText,
                  focusNode: passFocus,
                  controller: passCont,
                  style: primaryTextStyle(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    contentPadding: EdgeInsets.all(16),
                    labelStyle: secondaryTextStyle(),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: appColorPrimary)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                            color: appStore!.textSecondaryColor ?? Colors.blue)),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility),
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
                  Text(errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 14))
                      .paddingSymmetric(vertical: 8),

                // SIGN IN BUTTON
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: BoxDecoration(
                      color: appColorPrimary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: defaultBoxShadow()),
                  child: loading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Sign In',
                          style: boldTextStyle(color: white, size: 18)),
                ).onTap(() {
                  if (!loading &&
                      emailCont.text.isNotEmpty &&
                      passCont.text.isNotEmpty) {
                    handleLogin();
                  }
                }),

                10.height,

                // REGISTER LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: secondaryTextStyle(),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to your SignUp screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Register",
                        style: boldTextStyle(color: appColorPrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).center(),
        ),
      ),
    );
  }
}