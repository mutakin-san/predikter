import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:predikter/pages/detail_page.dart';
import 'package:predikter/pages/history_page.dart';
import 'package:predikter/pages/home_page.dart';
import 'package:predikter/providers/history_provider.dart';
import 'package:predikter/providers/main_provider.dart';
import 'package:predikter/repositories/history.dart';
import 'package:predikter/utils/constant.dart';
import 'package:predikter/utils/themes.dart';
import 'package:predikter/widgets/bottom_navigation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/appbar_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var currentIndex = 0;
  final pageController = PageController();
  static const platform = MethodChannel("com.mutakindv.predikter");

  Future<void> _didTapButton() async {
    var status = await Permission.camera.status;
    if (await ArCoreController.checkArCoreAvailability() &&
        await ArCoreController.checkIsArCoreInstalled()) {
      if (!status.isGranted) {
        status = await Permission.camera.request();
        if (status.isGranted) {
          await moveToArPage();
        }
      } else {
        await moveToArPage();
      }
    }
  }

  Future<void> moveToArPage() async {
    final navigator = Navigator.of(context);
    final prefs = await SharedPreferences.getInstance();
    final pricePreference = prefs.getInt(PRICE_PREFERENCE_KEY);
    if (pricePreference == null || pricePreference == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Silahkan atur harga daging terlebih dahulu")));
        return;
      }
    }
    final result = await platform.invokeMethod("moveToArPage", pricePreference);

    debugPrint("Data From AR : $result");
    if (result != null) {
      final history = await saveHistory(
          imagePath: result['imagePath'],
          chestSize: result['chestSize'],
          bodyLength: result['bodyLength'],
          bodyWeight: result['bodyWeight'],
          priceEstimation: result['priceEstimation']);
      navigator.push(MaterialPageRoute(
        builder: (context) => DetailPage(history: history),
      ));
    }
  }

  Future<dynamic> _methodHandler(MethodCall call) async {
    switch (call.method) {
      case "sendData":
        return Future.value("data");
    }
  }

  Future<History> saveHistory({
    required String imagePath,
    required double chestSize,
    required double bodyLength,
    required double bodyWeight,
    required double priceEstimation,
  }) async {
    final historyProvider = context.read<HistoryProvider>();
    final mainProvider = context.read<MainProvider>();
    await mainProvider.getPreferences();

    // final priceEstimation = bodyWeight * (mainProvider.pricePerKg);
    final history = History(
      date: DateTime.now(),
      weightEstimation: bodyWeight,
      pricePerKg: mainProvider.pricePerKg,
      carcassPercentage: mainProvider.carcassPercentage,
      cowType: mainProvider.cowType,
      imagePath: imagePath,
      priceEstimation: priceEstimation,
      bodyLength: bodyLength,
      chestGirth: chestSize,
    );

    historyProvider.save(history);
    return history;
  }

  @override
  void initState() {
    super.initState();

    platform.setMethodCallHandler(_methodHandler);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(context, titleText: 'PREDIKTER'),
      body: PageView(
        onPageChanged: (idx) {
          setState(() {
            currentIndex = idx;
          });
        },
        controller: pageController,
        children: [
          HomePage(
            onSeeHistoryTap: () {
              pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            },
          ),
          const HistoryPage()
        ],
      ),
      floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          onPressed: _didTapButton,
          child: const Icon(Icons.camera_alt)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationWidget(
          currentIndex: currentIndex,
          onTap: (idx) {
            setState(() {
              pageController.animateToPage(idx,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
              currentIndex = idx;
            });
          }),
    );
  }
}
