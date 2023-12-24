import 'package:flutter/material.dart';
import 'package:predikter/providers/history_provider.dart';
import 'package:provider/provider.dart';

import '../pages/detail_page.dart';
import 'history_item_widget.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({super.key, required this.shrinkWrap, this.physics});

  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, _) {
        if (historyProvider.histories.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
                child: Column(
              children: [
                Container(
                  width: 100,
                  height: 60,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/cow.png"),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Belum ada riwayat pengukuran"),
              ],
            )),
          );
        } else {
          return ListView.builder(
            shrinkWrap: shrinkWrap,
            physics: physics,
            itemCount: historyProvider.histories.length,
            itemBuilder: (ctx, index) {
              final history = historyProvider.histories[index];
              return HistoryItemWidget(
                id: history.id ?? -1,
                date: history.date,
                weightEstimationResult: history.weightEstimation,
                priceEstimationResult: history.priceEstimation,
                waist: history.waist,
                bodyLength: history.bodyLength,
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => DetailPage(
                        bodyLength: history.bodyLength,
                        waist: history.waist,
                        priceEstimationResult: history.priceEstimation,
                        weightEstimationResult: history.weightEstimation,
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
