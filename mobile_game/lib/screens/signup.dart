import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  //key to hold state of form
  final formkey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool loading = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // app bar to display app name 
      // as well as a back button to go back to the login page
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 221, 198, 227),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,color: Color.fromARGB(255, 58, 3, 68), size:30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: loading ? const Center(
        child: CircularProgressIndicator(
          valueColor:AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 221, 198, 227))
        ),
      )
      :Form(
        key: formkey,
        child: Stack(
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: const Color.fromARGB(255, 242, 227, 245),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 120),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Sign Up!",
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
                              child: 
                    TextFormField(keyboardType: TextInputType.emailAddress,
                    onChanged: (value){
                      // set email variable to the inputted value
                      email=value.toString().trim();
                    },
                    validator: (value) {
                                  if (value!.isEmpty) {
                                    // prompt user to input email if one is not inputted 
                                    return "Please enter your email address";
                                  }
                                },
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      // show the word email in text box along with the email icon
                      hintText: "Email",
                      prefixIcon:  Icon(
                        Icons.email,
                        color: Colors.black,
                      ),
                      ),
                    ),)),
                    
                    const SizedBox(height: 30,),
                    SizedBox(
                            height: 90,
                            width: 370,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              child: 
                    TextFormField(
                      obscureText: true,
                      validator: (value){
                        if(value!.isEmpty){
                          // prompt user to input password if one is not inputted
                          return"Please enter a password.";
                        }
                      },
                      onChanged: (value){
                        // set password to the inputted value 
                        password = value;
                      },
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        // show the word password in text box along with icon of lock
                        hintText: "Password",
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.black,
                        )),
                    ),)),
                    const SizedBox(height: 80),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                              primary: const Color.fromARGB(255, 58, 3, 68),
                              onPrimary: Colors.white),
                      child: const Text('Sign up'),
                      onPressed: () async {
                        //validate form data 
                        if(formkey.currentState!.validate()){
                          setState(() {
                            loading = true;
                          });
                          try{
                            // create a new user 
                            await auth.createUserWithEmailAndPassword(
                              email: email,
                              password: password
                            );
                            // snackbar message to prompt user to sign in, now that they have been registered 
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(backgroundColor: Color.fromARGB(255, 221, 198, 227), 
                              content: Padding(
                                padding: EdgeInsets.all(8.0),
                                child:  Text('You have successfully signed up, you can now log in!'),
                                
                                ),
                                duration: Duration(seconds: 5),
                                ),

                                );
                                Navigator.of(context).pop();
                                setState(() {
                                  loading=false;
                                });
                        } on FirebaseAuthException catch (e) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title:
                                            const Text('Registration Failed'),
                                            //prints error message if registration fails
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
                                  }
                                  setState(() {
                                    loading = false;
                                  });
                                }
                              },
                            ),
                    ]
                    )
                    )
                       
      )])));
  }
}