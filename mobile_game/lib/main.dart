import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_game/homepage.dart';
import 'package:mobile_game/screens/signup.dart';
import 'package:flutter/src/material/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const FirstPage(),
  );
}

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      home:  Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool isloading = false;
  late DateTime x;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 221, 198, 227))
              ),
            )
          : Form(
              key: formkey,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light,
                child: Stack(
                  children: [
                    Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: const Color.fromARGB(255, 221, 198, 227),
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
                            TextFormField(
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
                                hintText: 'Email',
                                prefixIcon: Icon(
                                  Icons.alternate_email_rounded,
                                  color: Color.fromARGB(255, 58, 3, 68),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
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
                            ),
                            const SizedBox(height: 80),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: const Color.fromARGB(255, 58, 3, 68),
                                onPrimary: Colors.white
                                ),
                              child: const Text('Log in'),
                              onPressed: () async {
                                if (formkey.currentState!.validate()) {
                                  setState(() {
                                    isloading = true;
                                  });
                                  try {
                                    final newUser =
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
                                        content: Text('${e.message}'),
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
                                    print(e);
                                  }
                                  setState(() {
                                    isloading = false;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SignUp(),
                                  ),
                                );
                              },
                              child: Row(
                                children: const [
                                  Text(
                                    "Don't have an Account ?",
                                    style: TextStyle(
                                        fontSize: 20, color: Color.fromARGB(255, 58, 3, 68)),
                                  ),
                                  SizedBox(width: 10),
                                  Hero(
                                    tag: '1',
                                    child: Text(
                                      'Sign up',
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 58, 3, 68)),
                                    ),
                                  )
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
            ),
    );
  }
}
