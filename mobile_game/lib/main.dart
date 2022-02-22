import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_game/homepage.dart';
import 'package:mobile_game/screens/signup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  runApp(
    const FirstPage(),
  );
}

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //key to hold state of form
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 203, 162, 211))),
            )
          : Form(
              key: formkey,
              child: Stack(
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Color.fromARGB(255, 242, 227, 245),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 120),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Log in!",
                            style: TextStyle(
                                fontSize: 70,
                                color: Color.fromARGB(255, 58, 3, 68),
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            height: 90,
                            width: 370,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  email = value;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter your email address";
                                  }
                                },
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintTextDirection: TextDirection.ltr,
                                  hintText: 'Email',
                                  prefixIcon: Icon(
                                    Icons.alternate_email_rounded,
                                    color: Color.fromARGB(255, 58, 3, 68),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                              height: 90,
                              width: 370,
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  child: TextFormField(
                                    obscureText: true,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Please enter your password";
                                      }
                                    },
                                    onChanged: (value) {
                                      password = value;
                                    },
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                        hintText: 'Password',
                                        prefixIcon: Icon(
                                          Icons.lock_outline_rounded,
                                          color: Color.fromARGB(255, 58, 3, 68),
                                        )),
                                  ))),
                          const SizedBox(height: 80),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: const Color.fromARGB(255, 58, 3, 68),
                                onPrimary: Colors.white),
                            child: const Text('Log in'),
                            onPressed: () async {
                              if (formkey.currentState!.validate()) {
                                setState(() {
                                  isloading = true;
                                });
                                try {
                                  await _auth.signInWithEmailAndPassword(
                                      email: email, password: password);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => const MyApp(),
                                    ),
                                  );
                                  setState(() {
                                    isloading = false;
                                  });
                                } on FirebaseAuthException catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Login Failed"),
                                      content: Text(e.message.toString()),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: const Text('Okay'),
                                        )
                                      ],
                                    ),
                                  );
                                  // ignore: avoid_print
                                  print(e);
                                }
                                setState(() {
                                  isloading = false;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          Container(
                            child: Row(
                              children: [
                                const Text(
                                  "Don't have an Account ?",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Color.fromARGB(255, 58, 3, 68)),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: const Color.fromARGB(
                                            255, 58, 3, 68),
                                        onPrimary: Colors.white),
                                    child: const Text('Sign up'),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUp()));
                                    })
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
