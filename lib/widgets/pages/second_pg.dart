import 'package:flutter/material.dart';
import 'package:flutter_frontend/widgets/bottom_nav.dart';
import 'package:flutter_frontend/widgets/drawer_nav.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer(
        builder: (context, ref, _) {
          // ref.watch(authVmProvider);

          return Scaffold(
            appBar: AppBar(),
            endDrawer: const NavDrawer(),
            body: const Center(child: Text("Second Page")),
            bottomNavigationBar: const BottomNavBar(
              currentIndex: 1,
            ),
          );
        },
      ),
    );
  }
}
