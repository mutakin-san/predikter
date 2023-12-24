import 'package:flutter/material.dart';
import 'package:predikter/utils/dialog_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constant.dart';

class AppBarWidget extends AppBar {
  AppBarWidget(BuildContext mContext, {super.key, required this.titleText})
      : context = mContext;

  final String titleText;

  final BuildContext context;

  @override
  bool? get centerTitle => true;

  @override
  Widget? get title => Text(
        titleText,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(),
      );

  @override
  List<Widget>? get actions => [
        IconButton(
          onPressed: () {
            showPricePreferenceDialog(
              context,
              title: "Pengaturan Harga",
              onSave: (price) async {
                final pref = await SharedPreferences.getInstance();
                return await pref.setInt(PRICE_PREFERENCE_KEY, price ?? 0);
              },
            );
          },
          icon: const Icon(Icons.settings),
        )
      ];
}
