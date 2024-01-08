import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:predikter/providers/main_provider.dart';
import 'package:provider/provider.dart';

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

enum CowType { bali, po, acc }

void showPricePreferenceDialog(
  BuildContext context, {
  required String title,
}) {
  context.read<MainProvider>().getPreferences();
  CowType cowType = CowType.bali;

  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return Consumer<MainProvider>(builder: (context, provider, child) {
          cowType = provider.cowType;
          final priceController =
              TextEditingController(text: provider.pricePerKg.toString());

          return AlertDialog.adaptive(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Harga daging perkilo",
                        style: GoogleFonts.roboto(),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        maxLines: 1,
                        keyboardType: const TextInputType.numberWithOptions(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          prefixText: "Rp ",
                          hintText: 'Harga daging per kg',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Jenis Sapi",
                        style: GoogleFonts.roboto(),
                      ),
                      const SizedBox(height: 8),
                      StatefulBuilder(
                        builder: (context, setState) => DropdownButton(
                          padding: const EdgeInsets.all(8),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                                value: CowType.bali, child: Text("Sapi Bali")),
                            DropdownMenuItem(
                                value: CowType.po,
                                child: Text("Sapi PO (Peranakan Ongole)")),
                            DropdownMenuItem(
                                value: CowType.acc,
                                child: Text(
                                    "Sapi ACC (AUSTRALIAN COMMERCIAL CROSS)")),
                          ],
                          value: cowType,
                          onChanged: (value) {
                            setState(() {
                              cowType = value!;
                            });
                          },
                        ),
                      )
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
                            provider.changePrice(
                                int.tryParse(priceController.text) ?? 0);
                            provider.changeCowType(cowType);

                            final isSuccess = await context
                                .read<MainProvider>()
                                .savePreferences();

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
        });
      });
}
