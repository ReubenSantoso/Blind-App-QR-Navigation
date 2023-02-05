import 'package:flutter/material.dart';
import 'create_qr.dart';
import 'library_qr.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: const FirebaseOptions(
      apiKey: "AIzaSyAK3SzFdz0pJL2nwinwoCLk2sA4PukGOHY",
      appId: "1:963246929571:web:972f8e36d98831d69df116",
      messagingSenderId: "963246929571",
      projectId: "blind-navigation-app-68681",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0; //changing value based on user click
  final screen = [
    //changing content inside each page
    const CreateQR(),
    const LibraryQR(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        //IndexedStack keeps all widgets inside the widget tree
        index: currentIndex, //only current index is displayed
        children: screen,
        //keeps the screen alive, meaning state is kept even when page changes
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, //on click animation
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        selectedFontSize: 12,
        unselectedItemColor: Colors.white60, //white with opacity
        iconSize: 35,
        currentIndex: currentIndex, //determine which pages shown based on index
        onTap: (index) => //to update UI page shown on click
            setState(() => currentIndex = index),
        //"(index)" calls back the item index on what user click,
        // then set state of variable, resulting a change in the page shown
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_sharp),
              label: 'Create',
              backgroundColor: Colors.blue),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_sharp),
              label: 'Library',
              backgroundColor: Colors.blue)
        ],
      ),
    );
  }
}
