import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'account tab/b.o.account_page.dart';
import 'home_tab/main/Business_Owner_Home_Page.dart';

class BusinessOwnerHomePage extends StatefulWidget {
  const BusinessOwnerHomePage({Key? key}) : super(key: key);

  @override
  _BusinessOwnerHomePageState createState() => _BusinessOwnerHomePageState();
}

class _BusinessOwnerHomePageState extends State<BusinessOwnerHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    BHomeScreen(),
    BAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Add WillPopScope to handle back button presses
      onWillPop: _onBackPressed,
      // Call _onBackPressed function when back button is pressed
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: Container(
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
            child: GNav(
              backgroundColor: Colors.blue,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.blue.shade300,
              gap: 8, // Adjust the gap between buttons
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              padding: const EdgeInsets.all(16),
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Account',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    // Function to show confirmation dialog when back button is pressed
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(
              'Exit',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  void main() {
    runApp(MaterialApp(
      home: BusinessOwnerHomePage(),
    ));
  }
}
