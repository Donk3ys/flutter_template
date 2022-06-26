import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // ref.watch(authVMProvider);

        return BottomNavigationBar(
          backgroundColor: kColorBackgroundDark,
          selectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: currentIndex,
          unselectedItemColor: Colors.white,
          onTap: (index) async {
            if (currentIndex != 0 && index == 0) {
              context.go("/");
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(builder: (context) => const HomePage()),
              // );
            }
            if (index == 1 && currentIndex != 1) {
              context.push("/pg2");
            }
            if (index == 2 && currentIndex != 2) {
              context.go("/");
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 0 ? Icons.home : Icons.home_outlined,
              ),
              label: "Home",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: "Create",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              label: "Search",
            ),
          ],
        );
      },
    );
  }
}
