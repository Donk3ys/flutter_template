import 'package:flutter/material.dart';
import 'package:flutter_frontend/widgets/bottom_nav.dart';
import 'package:flutter_frontend/widgets/drawer_nav.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer(
        builder: (context, ref, _) {
          // ref.watch(authVmProvider);

          return Scaffold(
            appBar: AppBar(),
            endDrawer: const NavDrawer(),
            body: const Center(child: Text("Home Page")),
            bottomNavigationBar: const BottomNavBar(
              currentIndex: 0,
            ),
          );
        },
      ),
    );
  }
}
