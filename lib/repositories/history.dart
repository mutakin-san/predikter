import 'dart:convert';

import 'package:predikter/utils/dialog_helper.dart';

class History {
  final int? id;
  final DateTime date;
  final double weightEstimation;
  final int pricePerKg;
  final double carcassPercentage;
  final CowType cowType;
  final double priceEstimation;
  final double bodyLength;
  final double chestGirth;

  History({
    this.id,
    required this.date,
    required this.weightEstimation,
    required this.pricePerKg,
    required this.carcassPercentage,
    required this.cowType,
    required this.priceEstimation,
    required this.bodyLength,
    required this.chestGirth,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "date": date.toUtc().toIso8601String(),
      "weightEstimation": weightEstimation,
      "pricePerKg": pricePerKg,
      "carcassPercentage": carcassPercentage,
      "cowType": cowType.name,
      "priceEstimation": priceEstimation,
      "bodyLength": bodyLength,
      "chestGirth": chestGirth,
    };
  }

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      id: map["id"]?.toInt(),
      date: DateTime.parse(map["date"]).toLocal(),
      weightEstimation: map["weightEstimation"]?.toDouble(),
      pricePerKg: map["pricePerKg"]?.toInt(),
      carcassPercentage: map["carcassPercentage"]?.toDouble(),
      cowType: CowType.values.firstWhere((element) => element.name == map["cowType"]),
      priceEstimation: map["priceEstimation"]?.toDouble(),
      bodyLength: map["bodyLength"]?.toDouble(),
      chestGirth: map["chestGirth"]?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory History.fromJson(String source) =>
      History.fromMap(json.decode(source));

  History copyWith({
    int? id,
    DateTime? date,
    double? weightEstimation,
    int? pricePerKg,
    double? carcassPercentage,
    CowType? cowType,
    double? priceEstimation,
    double? bodyLength,
    double? chestGirth,
  }) {
    return History(
      id: id ?? this.id,
      date: date ?? this.date,
      weightEstimation: weightEstimation ?? this.weightEstimation,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      carcassPercentage: carcassPercentage ?? this.carcassPercentage,
      cowType: cowType ?? this.cowType,
      priceEstimation: priceEstimation ?? this.priceEstimation,
      bodyLength: bodyLength ?? this.bodyLength,
      chestGirth: chestGirth ?? this.chestGirth,
    );
  }
}
