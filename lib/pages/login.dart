import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Wigets/progresDialogue.dart';
import '../service/google_map.dart';

class LoginSignUp extends StatefulWidget {
  const LoginSignUp({Key? key}) : super(key: key);

  @override
  _LoginSignUpState createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> {
  final userRef = FirebaseFirestore.instance.collection("users");

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool signUpPage = true;
  String btnText = "SignUp";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: navigationOption(),
              ),
              SizedBox(
                height: 30,
              ),
              logoText(),
              SizedBox(
                height: 20,
              ),
              Visibility(
                visible: signUpPage,
                child: Column(
                  children: [
                    userNameTextField(),
                    phoneTextField(),
                  ],
                ),
              ),
              emailTextField(),
              passwordTextField(),
              SizedBox(
                height: 20,
              ),
              signInSignUp(),
            ],
          ),
        ),
      ),
    );
  }

  Widget navigationOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              signUpPage = true;
              btnText = "S'inscrire";
            });
          },
          child: const Text(
            "S'inscrire",
            style: TextStyle(color: Colors.grey, fontSize: 25),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              signUpPage = false;
              btnText = "Connexion";
            });
          },
          child: const Text(
            "Connexion",
            style: TextStyle(color: Colors.grey, fontSize: 25),
          ),
        ),
      ],
    );
  }

  Widget logoText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/taxi.png',
          height: 100,
          width: 100,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          "SenTaxi",
          style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.w700,
              color: Colors.yellow[700]),
        )
      ],
    );
  }

  Widget userNameTextField() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        alignment: Alignment.centerLeft,
        height: 60,
        decoration: kBoxDecor,
        child: TextFormField(
          controller: userNameController,
          keyboardType: TextInputType.text,
          style: TextStyle(color: Colors.yellow[700]),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(
              Icons.account_circle,
              color: Colors.yellow[700],
            ),
            hintText: "Entrez votre nom d'utilisateur",
          ),
        ),
      ),
    );
  }

  Widget phoneTextField() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        alignment: Alignment.centerLeft,
        height: 60,
        decoration: kBoxDecor,
        child: TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: Colors.yellow[700]),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(
              Icons.phone,
              color: Colors.yellow[700],
            ),
            hintText: "Entrez votre numéro de téléphone",
          ),
        ),
      ),
    );
  }

  Widget emailTextField() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        alignment: Alignment.centerLeft,
        height: 60,
        decoration: kBoxDecor,
        child: TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: Colors.yellow[700]),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(
              Icons.email,
              color: Colors.yellow[700],
            ),
            hintText: "Entrez votre e-mail",
          ),
        ),
      ),
    );
  }

  Widget passwordTextField() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        alignment: Alignment.centerLeft,
        height: 60,
        decoration: kBoxDecor,
        child: TextFormField(
          controller: passwordController,
          keyboardType: TextInputType.text,
          obscureText: true,
          style: TextStyle(color: Colors.yellow[700], fontFamily: 'Opensans'),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(
              Icons.lock,
              color: Colors.yellow[700],
            ),
            hintText: "Entrez votre mot de passe",
          ),
        ),
      ),
    );
  }

  Widget signInSignUp() {
    return ElevatedButton(
        onPressed: () {
          (signUpPage) ? _register() : _login();
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: Colors.yellow[700],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Text(
            btnText,
            style: TextStyle(fontSize: 24),
          ),
        ));
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _register() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: "veuillez patienter");
        });

    final User? user = (await _auth
            .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim())
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMsg(context, "$errMsg", "Error");
      print("Our Error message: $errMsg");
    }))
        .user;
    if (user != null) {
      userRef
          .doc(user.uid)
          .set({
            "name": userNameController.text.trim(),
            "email": emailController.text.trim(),
            "phone": phoneController.text.trim()
          })
          .then((value) => null)
          .catchError((onError) {});
      Navigator.pop(context);
      displayToastMsg(context, "Congratulations, account created", "Success");
      print("User created successly");
      setState(() {
        signUpPage = false;
        btnText = "Login";
      });
    } else {
      Navigator.pop(context);
      displayToastMsg(context, "User account creation failed", "Failed");
      print("User account creation failed");
    }
  }

  void _login() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: "veuillez patienter");
        });

    final User? user = (await _auth
            .signInWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim())
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMsg(context, "$errMsg", "Error");
      print("Our Error message: $errMsg");
    }))
        .user;
    if (user != null) {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => GoogleMapService()));
      print("Login Successful");
    } else {
      Navigator.pop(context);
      displayToastMsg(context, "Login failed", "Failed");
      print("Login failed");
    }
  }

  final kBoxDecor = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6.0,
          offset: Offset(0, 2),
        )
      ]);
}

Future<void> displayToastMsg(
    BuildContext context, String msg, String title1) async {
  return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("$title1"),
          content: Text("$msg"),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}
