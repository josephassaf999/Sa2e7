import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import '../business owner pages/Business_Owner_Page.dart';
import '../user pages/user_homepage.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedAccountType = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Sign up',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.blue,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Text(
                    'Sign up',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Create an account for free',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    inputFile(
                        labelText: "Username", controller: _usernameController),
                    inputFile(
                      labelText: "Email",
                      controller: _emailController,
                    ),
                    inputFile(
                        labelText: "Password",
                        obscureText: true,
                        controller: _passwordController),
                    inputFile(
                        labelText: "Confirm Password",
                        obscureText: true,
                        controller: _confirmPasswordController),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 0, left: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: const Border(
                    bottom: BorderSide(color: Colors.black),
                    top: BorderSide(color: Colors.black),
                    left: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.black),
                  ),
                ),
                child: MaterialButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Choose Account Type'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: () async {
                                    selectedAccountType = 'User';
                                    Navigator.pop(context);
                                    await saveUserData(selectedAccountType);
                                  },
                                  child: const Text('User'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    selectedAccountType = 'Business Owner';
                                    Navigator.pop(context);
                                    await saveUserData(selectedAccountType);
                                  },
                                  child: const Text('Business Owner'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                  minWidth: double.infinity,
                  height: 60,
                  color: const Color(0xff0095FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Already have an account?",
                    style: TextStyle(fontFamily: 'Roboto'),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      " Login",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color(0xff0095FF),
                      ),
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

  Widget inputFile(
      {String? labelText,
      bool obscureText = false,
      TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          labelText!,
          style: const TextStyle(
            fontFamily: "Roboto",
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: (value) {
            if (labelText == 'Username') {
              if (value!.isEmpty) {
                return 'Please enter a username';
              }
            } else if (labelText == 'Email') {
              if (value!.isEmpty) {
                return 'Please enter an email address';
              } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email address';
              }
            } else if (labelText == 'Password') {
              if (value!.isEmpty) {
                return 'Please enter a password';
              } else if (value.length < 6) {
                return 'Password must be at least 6 characters long';
              }
            } else if (labelText == 'Confirm Password') {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade400,
              ),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade400,
              ),
            ),
            errorStyle: TextStyle(color: Colors.red),
          ),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }

  Future<void> saveUserData(String selectedAccountType) async {
    try {
      // Check if the username already exists
      QuerySnapshot usernameCheck = await FirebaseFirestore.instance
          .collection(selectedAccountType)
          .where('username', isEqualTo: _usernameController.text)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        // Username already exists, display error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Username Already Taken'),
              content: Text('Please choose a different username.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return; // Exit the function
      }

      // Username is available, proceed with creating the account
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Get the user ID of the newly created user
      String userId = userCredential.user!.uid;

      // Save additional user data to Firestore
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection(selectedAccountType)
          .doc(userId);

      Map<String, dynamic> userData = {
        'userId': userId,
        'username': _usernameController.text,
        'email': _emailController.text,
        // You should avoid saving passwords directly to the database
        // Instead, use Firebase Authentication for user login
        'password': _passwordController.text,
      };

      // Add messages subcollection if the account type is User
      if (selectedAccountType == 'User') {
        // Set additional data for the User collection
        userData['messages'] = {}; // Initialize empty messages subcollection

        // Create the messages subcollection within the user document
        await userDocRef.collection('messages').doc().set({
          'placeholder':
              true // Add a placeholder document to initialize the subcollection
        });
      }

      await userDocRef.set(userData);

      // Navigate to the appropriate homepage based on the selected account type
      navigateToHomePage(selectedAccountType == 'User'
          ? const UserHomePage()
          : const BusinessOwnerHomePage());
    } catch (e) {
      print('Error creating user account: $e');
      // Handle error
    }
  }

  void navigateToHomePage(Widget homePage) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => homePage,
      ),
    );
  }
}
