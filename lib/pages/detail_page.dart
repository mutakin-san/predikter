import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:predikter/repositories/history.dart';
import 'package:predikter/widgets/appbar_widget.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({
    super.key,
    required this.history,
  });

  final History history;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(context, titleText: "PREDIKTER"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hasil Prediksi Bobot\n& Harga",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Visibility(
                visible: true,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey,
                      image: DecorationImage(
                          image: FileImage(File(history.imagePath)),
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Lingkar Dada"),
                      Text(
                        "${history.chestGirth.toStringAsFixed(2)}cm",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Panjang Badan"),
                      Text(
                        "${history.bodyLength.toStringAsFixed(2)}cm",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${history.weightEstimation.toStringAsFixed(2)}kg",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const Text("Hasil Estimasi Bobot"),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.compactCurrency()
                            .format(history.priceEstimation),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const Text("Hasil Harga"),
                      Text(
                        "Harga Per Kg ${NumberFormat.compactCurrency().format(history.pricePerKg)}",
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  )
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "Perhitungan Bobot Karkas untuk jenis sapi ${history.cowType.name}",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${history.carcassPercentage}%",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          const Text("Persentase Bobot Karkas"),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${(history.weightEstimation - (history.weightEstimation * (history.carcassPercentage / 100))).toStringAsFixed(2)}kg",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          const Text("Bobot Karkas"),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
