import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:oler/maps.dart';
import 'package:oler/widgets/constants.dart';
import 'package:oler/widgets/roundButton.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'RegistrationScreen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool progressHud = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: progressHud,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('asset/images/car.png'),
                  ),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              TextField(
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kInputDecoration.copyWith(hintText: 'Enter your email'),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  password = value;
                },
                decoration:
                    kInputDecoration.copyWith(hintText: 'Enter your password'),
              ),
              const SizedBox(
                height: 24.0,
              ),
              RoundButton(
                text: 'Register',
                color: Colors.blueAccent,
                childTextColor: Colors.white,
                onPressed: () async {
                  try {
                    setState(() {
                      progressHud = true;
                    });
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    if (newUser != null) {
                      Navigator.pushNamed(context, MapScreen.id);
                      setState(() {
                        progressHud = false;
                      });
                    }
                  } catch (e) {
                    setState(() {
                      progressHud = false;
                    });
                    Alert(
                      context: context,
                      type: AlertType.error,
                      title: "Invalid Credentials",
                      desc: e.toString(),
                      style: const AlertStyle(
                        backgroundColor: Colors.white,
                        alertBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                      ),
                      buttons: [
                        DialogButton(
                          onPressed: () => Navigator.pop(context),
                          width: 120,
                          child: const Text(
                            "Try Again",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        )
                      ],
                    ).show();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
