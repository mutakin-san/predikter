import 'package:flutter/material.dart';
import 'package:predikter/utils/dialog_helper.dart';

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
              title: "Pengaturan Parameter Pengukuran",
            );
          },
          icon: const Icon(Icons.settings),
        )
      ];
}
