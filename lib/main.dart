import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moodalyse/screens/auth/register.dart';
import 'package:moodalyse/screens/dashboard/dashboard.dart';
import 'package:moodalyse/screens/history/history.dart';
import 'package:moodalyse/screens/settings/settings.dart';

import 'firebase_options.dart';
import 'helpers/notification-helpers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationHelpers.initializeNotifications();
  runApp(const Moodalyse());
}

class Moodalyse extends StatelessWidget {
  const Moodalyse({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const Main(title: 'Moodalyse'),
    );
  }
}

class Main extends StatefulWidget {
  const Main({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  void _setPageIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 250), curve: Curves.ease);
    });
  }

  void _setPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        final String? uid = snapshot.data?.uid;
        final String name = snapshot.data?.displayName ?? 'Signed out';

        Widget selectedFlow;

        if (uid != null) {
          selectedFlow = Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                Center(
                  child: Text(name),
                ),
                IconButton(
                  onPressed: () => {_setPageIndex(2)},
                  icon: const Icon(Icons.account_circle),
                ),
              ],
              title: Text(widget.title),
            ),
            body: Align(
              alignment: Alignment.topLeft,
              child: PageView(
                controller: _pageController,
                onPageChanged: _setPageChanged,
                children: const [
                  Dashboard(title: 'Dashboard'),
                  History(title: 'History'),
                  Settings(title: 'Settings'),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
              currentIndex: _selectedIndex,
              backgroundColor: Colors.pink,
              unselectedItemColor: Colors.white,
              selectedItemColor: Colors.amberAccent,
              onTap: _setPageIndex,
            ),
          );
        } else {
          selectedFlow = const Register();
        }

        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: selectedFlow,
        );
      },
    );
  }
}
