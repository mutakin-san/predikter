import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:predikter/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'themes.dart';

void showDeleteConfirmationDialog(BuildContext context,
    {required String title, required VoidCallback positifCallback}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (ctx) => AlertDialog.adaptive(
      backgroundColor: Colors.white,
      title: Text(title,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "Data tidak bisa dikembalikan setelah dihapus!",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      positifCallback();
                      Navigator.pop(context);
                    },
                    child: const Text("YA")),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("BATAL")),
              )
            ],
          )
        ],
      ),
    ),
  );
}

void showPricePreferenceDialog(BuildContext context,
    {required String title, required Future<bool> Function(int?) onSave}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (ctx) {
      final priceController = TextEditingController();
      return FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            debugPrint(snapshot.connectionState.name);
            if (snapshot.connectionState == ConnectionState.done) {
              final price = snapshot.data?.getInt(PRICE_PREFERENCE_KEY);
              if (price != null && price > 0) {
                priceController.text = price.toString();
              }
              return AlertDialog.adaptive(
                backgroundColor: Colors.white,
                title: Text(title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16, fontWeight: FontWeight.normal)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Text(
                            "Harga daging perkilo",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: priceController,
                            maxLines: 1,
                            keyboardType:
                                const TextInputType.numberWithOptions(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              prefixText: "Rp ",
                              hintText: 'Harga daging per kg',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                final navigator = Navigator.of(context);
                                final isSuccess = await onSave(
                                    int.tryParse(priceController.text));
                                if (isSuccess) {
                                  navigator.pop();
                                }
                              },
                              child: const Text("Simpan")),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("BATAL")),
                        )
                      ],
                    )
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          });
    },
  );
}
