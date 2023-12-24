import 'package:flutter/material.dart';
import 'package:predikter/providers/history_provider.dart';
import 'package:predikter/utils/dialog_helper.dart';
import 'package:predikter/widgets/history_list.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Riwayat",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                GestureDetector(
                  onTap: () {
                    showDeleteConfirmationDialog(context,
                        title: "Apakah kamu yakin akan menghapus semua data?",
                        positifCallback: () {
                      context.read<HistoryProvider>().deleteAll();
                    });
                  },
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Hapus Semua"),
                      SizedBox(width: 2),
                      Icon(
                        Icons.clear_all_outlined,
                        size: 14,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: HistoryList(shrinkWrap: false))
        ],
      ),
    );
  }
}
