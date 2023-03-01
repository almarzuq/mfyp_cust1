import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../includes/global.dart';
import '../includes/models/user.model.inc.dart';
import '../includes/utilities/colors.dart';
import '../includes/utilities/dialog.util.dart';
import '../includes/utilities/textfield.util.dart';
import 'home.scr.dart';
import 'register.scr.dart';

class MFYPLogin extends StatefulWidget {
  const MFYPLogin({Key? key}) : super(key: key);

  @override
  State<MFYPLogin> createState() => MFYPLoginState();
}

class MFYPLoginState extends State<MFYPLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Sign in',
            style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: AppColor.primaryColor,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBar: bottom(),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          // Section 1 - Header
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 12),
            child: const Text(
              'Welcome Back! 😁',
              style: TextStyle(
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: Text(
              "This page enables registered user to sign in into the project!",
              style: TextStyle(
                  color: AppColor.primaryColor.withOpacity(0.7),
                  fontSize: 12,
                  height: 150 / 100),
            ),
          ),
          // Section 2 - Form
          // Email
          TextFieldCustom(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            hintText: 'Email Address',
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.email_outlined,
                color: AppColor.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 25),
          // Password
          TextFieldCustom(
            controller: passwordController,
            obscureText: true,
            hintText: 'Password',
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.lock_person_outlined,
                color: AppColor.primaryColor,
              ),
            ),
            //
          ),
          const SizedBox(height: 24),
          // Sign In button
          ElevatedButton(
            onPressed: () {
              validate();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
              backgroundColor: AppColor.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  fontFamily: 'poppins'),
            ),
          ),
        ],
      ),
    );
  }

  validate() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      snackBarMessage("A valid credential is required.", context);
    } else if (passwordController.text.isEmpty) {
      snackBarMessage("Password is invalid", context);
    } else if (emailController.text.contains(regex) &&
        passwordController.text.isNotEmpty) {
      providerLogin();
    } else {
      snackBarMessage("Bad format!", context);
    }
  }

  providerLogin() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return const MFYPDialog(
            message: "Logging in...",
          );
        });
    try {
      final User? credential =
          (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      ))
              .user;
      if (credential != null) {
        currentFirebaseUser = fAuth.currentUser;
        DatabaseReference databaseReference = FirebaseDatabase.instance
            .ref()
            .child("users")
            .child(currentFirebaseUser!.uid);
        databaseReference.once().then((data) {
          if (data.snapshot.value != null) {
            UserModel.readUserInfo();
          }
          Future.delayed(
              const Duration(seconds: 3),
              () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const MFYPHomeScreen())));
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Navigator.of(context).pop();
        snackBarMessage("No user found for that email.", context);
      } else if (e.code == 'wrong-password') {
        Navigator.of(context).pop();
        snackBarMessage("Wrong password provided for that user.", context);
      }
    } catch (e) {
      fAuth.signOut;
      snackBarMessage(e.toString(), context);
    }
  }

  Widget bottom() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 48,
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const MFYPSignUpScreen()));
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColor.primaryColor.withOpacity(0.1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dont have an account?',
              style: TextStyle(
                color: AppColor.primaryColor.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              ' Sign up',
              style: TextStyle(
                color: AppColor.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
