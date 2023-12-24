import 'package:flutter/widgets.dart';
import 'package:predikter/repositories/history.dart';
import 'package:predikter/repositories/history_repository.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider() {
    historyRepository = HistoryRepository();
    historyRepository.open().then((_){
      getHistories();
    });
  }

  late HistoryRepository historyRepository;

  List<History>? _histories;
  List<History> get histories => _histories ?? [];

  Future<void> save(History history) async {
    debugPrint("Method Save called");
    await historyRepository.insert(history);
    getHistories();
  }

  Future<void> update(History history) async {
    await historyRepository.update(history);
    getHistories();
  }

  Future<void> delete(int id) async {
    await historyRepository.delete(id);
    getHistories();
  }

  Future<void> deleteAll() async {
    await historyRepository.deleteAll();
    getHistories();
  }

  Future<History?> getHistory(int id) async {
    return await historyRepository.getHistory(id);
  }

  Future<void> getHistories() async {
    _histories = await historyRepository.getHistories();
    notifyListeners();
  }
}
