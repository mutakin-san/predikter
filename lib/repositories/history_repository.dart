// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'history.dart';

const tableHistory = "histories";
const historyId = "id";
const historyDate = "date";
const historyBodyLength = "bodyLength";
const historyChestGirth = "chestGirth";
const historyWeightEstimation = "weightEstimation";
const historyPricePerKg = "pricePerKg";
const historyCarcassPercentage = "carcassPercentage";
const historyCowType = "cowType";
const historyImagePath = "imagePath";
const historyPriceEstimation = "priceEstimation";

class HistoryRepository {
  late Database db;

  static HistoryRepository? _historyRepository;

  HistoryRepository._internal() {
    _historyRepository = this;
  }

  factory HistoryRepository() =>
      _historyRepository ?? HistoryRepository._internal();

  Future open() async {
    final path = await getDatabasesPath();

    db = await openDatabase(join(path, "histories.db"), version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        create table $tableHistory ( 
          $historyId integer primary key autoincrement, 
          $historyDate datetime not null,
          $historyBodyLength double not null,
          $historyChestGirth double not null,
          $historyWeightEstimation double not null,
          $historyPricePerKg double not null,
          $historyCarcassPercentage double not null,
          $historyCowType text not null,
          $historyImagePath text not null,
          $historyPriceEstimation double not null
          )
      ''');
    });
  }

  Future<List<History>> getHistories() async {
    final List<Map<String, dynamic>> results = await db.query(tableHistory);

    final histories =
        results.map((history) => History.fromMap(history)).toList();
    histories.sort((a, b) => b.date.compareTo(a.date));
    return histories;
  }

  Future<History> insert(History history) async {
    final historyId = await db.insert(tableHistory, history.toMap());
    final History historyCopy = history.copyWith(id: historyId);
    return historyCopy;
  }

  Future<History?> getHistory(int id) async {
    List<Map<String, dynamic>> maps = await db.query(tableHistory,
        where: '$historyId = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return History.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db
        .delete(tableHistory, where: '$historyId = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    return await db.delete(tableHistory);
  }

  Future<int> update(History history) async {
    return await db.update(tableHistory, history.toMap(),
        where: '$historyId = ?', whereArgs: [history.id]);
  }

  Future close() async => db.close();
}
