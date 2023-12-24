import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:predikter/utils/themes.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget(
      {super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final Function(int) onTap;

  Widget buildMenuItem(int index, bool isActive) {
    return index == 0
        ? Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(isActive
                      ? 'assets/images/home_filled.png'
                      : 'assets/images/home_outlined.png'),
                ),
              ),
            ),
            const Text("Utama",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ])
        : Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/history_outlined.png'),
                ),
              ),
            ),
            const Text("Riwayat",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ]);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBottomNavigationBar.builder(
      backgroundColor: accentColor,
      itemCount: 2,
      tabBuilder: (int index, bool isActive) {
        return buildMenuItem(index, isActive);
      },
      activeIndex: currentIndex,
      gapLocation: GapLocation.center,
      scaleFactor: 0,
      notchSmoothness: NotchSmoothness.defaultEdge,
      onTap: onTap,
    );
  }
}
