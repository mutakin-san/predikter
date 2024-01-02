import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:predikter/utils/themes.dart';
import 'package:predikter/widgets/appbar_widget.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({
    super.key,
    required this.weightEstimationResult,
    required this.priceEstimationResult,
    required this.waist,
    required this.bodyLength,
  });

  final double weightEstimationResult;
  final double priceEstimationResult;
  final double waist;
  final double bodyLength;
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
                visible: false,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey,
                      image: const DecorationImage(
                          image: AssetImage("assetName"), fit: BoxFit.cover),
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
                        "${waist.toStringAsFixed(2)}cm",
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
                        "${bodyLength.toStringAsFixed(2)}cm",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${weightEstimationResult.toStringAsFixed(2)}kg",
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
                            .format(priceEstimationResult),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const Text("Hasil Harga"),
                    ],
                  )
                ],
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  label: const Text("Kembali Ke Halaman Utama"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
