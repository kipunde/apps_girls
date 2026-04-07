import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../Services/AuthService.dart';
import '../main.dart';
import '../utils/AppColors.dart';
import '../utils/AppWidget.dart';
import 'DrawerWidget.dart';
import 'HomeScreen.dart';
import 'SignUpScreen.dart';

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

  /// ---------------- LOGIN FUNCTION ----------------
  void handleLogin() async {
    setState(() {
      loading = true;
      errorMessage = "";
    });

    try {
      final success = await authService.login(emailCont.text, passCont.text);

      if (success) {
        final userDetails = await authService.getUserAccessDetails();

        debugPrint(
            "LOGGED IN USER → name: ${userDetails?.name}, role: ${userDetails?.role}");

        appStore.setUserName(userDetails?.name ?? "Guest");

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

  /// ---------------- CLEANUP ----------------
  @override
  void dispose() {
    emailCont.dispose();
    passCont.dispose();
    passFocus.dispose();
    super.dispose();
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        /// Drawer
        drawer: DrawerWidget(),

        /// HEADER
        appBar: AppBar(
          backgroundColor: Color(0xffe91e63),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "WomenBiz 360",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        /// BODY
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TOP BANNER
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage("images/banner.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              25.height,

              /// PAGE TITLE
            Text(
            'Sign In',
            style: boldTextStyle(
            size: 24,
            color: const Color(0xffe91e63), // 👈 add this
            ),
),

              30.height,

              /// EMAIL FIELD
              TextFormField(
                controller: emailCont,
                style: primaryTextStyle(),
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(passFocus),
              ),

              16.height,

              /// PASSWORD FIELD
              TextFormField(
                controller: passCont,
                focusNode: passFocus,
                obscureText: obscureText,
                style: primaryTextStyle(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
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

              /// ERROR MESSAGE
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ).paddingSymmetric(vertical: 8),

              16.height,

              /// SIGN IN BUTTON
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xffe91e63),
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
                        'Sign In',
                        style: boldTextStyle(color: white, size: 18),
                      ),
              ).onTap(() {
                if (!loading &&
                    emailCont.text.isNotEmpty &&
                    passCont.text.isNotEmpty) {
                  handleLogin();
                }
              }),

              15.height,

              /// REGISTER LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: secondaryTextStyle(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Register",
                      style: boldTextStyle(color: const Color(0xffe91e63)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}