import 'package:flutter/widgets.dart';
import 'package:predikter/utils/dialog_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constant.dart';

class MainProvider extends ChangeNotifier {
  int _pricePerKg = 0;
  double _carcassPercentage = 0.0;
  CowType _cowType = CowType.bali;

  int get pricePerKg => _pricePerKg;
  double get carcassPercentage => _carcassPercentage;
  CowType get cowType => _cowType;

  void changeCowType(CowType pCowType) {
    _cowType = pCowType;
    if (_cowType == CowType.bali) {
      _carcassPercentage = 53.26;
    } else if (_cowType == CowType.po) {
      _carcassPercentage = 46.9;
    } else if (_cowType == CowType.acc) {
      _carcassPercentage = 51.27;
    }
  }

  void changePrice(int price) {
    _pricePerKg = price;
  }

  Future<bool> savePreferences() async {
    final pref = await SharedPreferences.getInstance();
    final isPriceSaved = await pref.setInt(PRICE_PREFERENCE_KEY, _pricePerKg);
    final isCarcassPercentageSaved =
        await pref.setDouble(CARCASS_PREFERENCE_KEY, _carcassPercentage);
    final isCowTypeSaved =
        await pref.setString(COWTYPE_PREFERENCE_KEY, _cowType.name);

    return isPriceSaved && isCarcassPercentageSaved && isCowTypeSaved;
  }

  Future<void> getPreferences() async {
    final pref = await SharedPreferences.getInstance();

    final price = pref.getInt(PRICE_PREFERENCE_KEY);
    if (price != null && price > 0) {
      _pricePerKg = price;
    }

    final mCowType = pref.getString(COWTYPE_PREFERENCE_KEY);
    if (mCowType != null && mCowType.isNotEmpty) {
      _cowType = CowType.values.firstWhere((e) => e.name == mCowType);
    }

    final mCarcassPercentage = pref.getDouble(CARCASS_PREFERENCE_KEY);
    if (mCarcassPercentage != null && mCarcassPercentage != 0.0) {
      _carcassPercentage = mCarcassPercentage;
    }

    notifyListeners();
  }
}
