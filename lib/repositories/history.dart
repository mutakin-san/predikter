import 'dart:convert';

class History {
  final int? id;
  final DateTime date;
  final double weightEstimation;
  final double priceEstimation;
  final double bodyLength;
  final double waist;

  History({
    this.id,
    required this.date,
    required this.weightEstimation,
    required this.priceEstimation,
    required this.bodyLength,
    required this.waist,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "date": date.toUtc().toIso8601String(),
      "weightEstimation": weightEstimation,
      "priceEstimation": priceEstimation,
      "bodyLength": bodyLength,
      "waist": waist,
    };
  }

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      id: map["id"]?.toInt(),
      date: DateTime.parse(map["date"]).toLocal(),
      weightEstimation: map["weightEstimation"]?.toDouble(),
      priceEstimation: map["priceEstimation"]?.toDouble(),
      bodyLength: map["bodyLength"]?.toDouble(),
      waist: map["waist"]?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory History.fromJson(String source) =>
      History.fromMap(json.decode(source));

  History copyWith({
    int? id,
    DateTime? date,
    double? weightEstimation,
    double? priceEstimation,
    double? bodyLength,
    double? waist,
  }) {
    return History(
      id: id ?? this.id,
      date: date ?? this.date,
      weightEstimation: weightEstimation ?? this.weightEstimation,
      priceEstimation: priceEstimation ?? this.priceEstimation,
      bodyLength: bodyLength ?? this.bodyLength,
      waist: waist ?? this.waist,
    );
  }
}
