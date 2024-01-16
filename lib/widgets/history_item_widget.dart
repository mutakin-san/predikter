import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:predikter/providers/history_provider.dart';
import 'package:predikter/utils/dialog_helper.dart';
import 'package:predikter/utils/external_file_helper.dart';
import 'package:provider/provider.dart';

class HistoryItemWidget extends StatelessWidget {
  const HistoryItemWidget(
      {super.key,
      required this.id,
      required this.date,
      required this.weightEstimationResult,
      required this.priceEstimationResult,
      required this.chestGirth,
      required this.imagePath,
      required this.bodyLength,
      required this.onClick});
  final int id;
  final DateTime date;
  final double weightEstimationResult;
  final double priceEstimationResult;
  final double chestGirth;
  final String imagePath;
  final double bodyLength;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat.yMMMMEEEEd().format(date)),
                  GestureDetector(
                    onTap: () {
                      showDeleteConfirmationDialog(context,
                          title: "Apakah kamu yakin akan menghapus data ini?",
                          positifCallback: () {
                        deleteFileFromExternalStorage(imagePath);
                        context.read<HistoryProvider>().delete(id);
                      });
                    },
                    child: const Icon(Icons.delete_forever),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${weightEstimationResult.toStringAsFixed(2)}Kg",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const Text(
                        "Hasil Estimasi Bobot",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.compactSimpleCurrency()
                            .format(priceEstimationResult),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const Text(
                        "Hasil Harga",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Lingkar Dada",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            size: 16,
                          ),
                          Text(
                            "${chestGirth.toStringAsFixed(2)}cm",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Panjang Badan",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            size: 16,
                          ),
                          Text(
                            "${bodyLength.toStringAsFixed(2)}cm",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
