import 'package:flutter/material.dart';
import 'package:predikter/widgets/history_list.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onSeeHistoryTap});

  final VoidCallback onSeeHistoryTap;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<HistoryProvider>().getHistories(),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sistem Informasi \nPrediksi Bobot &\nHarga Sapi",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                "Cara mudah mengetahui bobot sapi dan kisaran harga yang sesuai",
                style: TextStyle(
                  color: Color(0xFF929292),
                ),
              ),
              Image.asset(
                "assets/images/cattle_body_measure_aspects.png",
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Riwayat Terbaru",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: onSeeHistoryTap,
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Lihat Semua"),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const HistoryList(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
