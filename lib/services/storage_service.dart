import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/score.dart';

class StorageService {
  static const String _scoresKey = 'scores';
  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<Score> getScores() {
    final String? scoresJson = _prefs.getString(_scoresKey);
    if (scoresJson == null) return [];
    final List<dynamic> list = json.decode(scoresJson);
    return list.map((item) => Score.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> saveScore(Score newScore) async {
    List<Score> scores = getScores();
    
    // 找到同类型、同内容、同长度的旧成绩
    Score? oldScore;
    try {
      oldScore = scores.firstWhere(
        (s) => s.gameType == newScore.gameType && 
               s.contentType == newScore.contentType && 
               s.length == newScore.length,
      );
    } catch (e) {
      // 没有找到旧成绩
      oldScore = null;
    }
    
    // 判断是否需要更新成绩
    bool shouldUpdate = false;
    
    if (oldScore == null) {
      // 没有旧成绩，直接添加
      shouldUpdate = true;
    } else {
      // 根据游戏类型的不同规则判断
      if (newScore.gameType == 'sprint') {
        // 极速记忆冲刺：当前成绩个数大于记录的成绩个数时更新
        shouldUpdate = newScore.value > oldScore.value;
      } else {
        // 进阶记忆挑战和速记耐力挑战：当前位数大于记录的位数时更新
        shouldUpdate = newScore.value > oldScore.value;
      }
    }
    
    if (shouldUpdate) {
      // 移除旧成绩（如果存在）
      if (oldScore != null) {
        scores.remove(oldScore);
      }
      // 添加新成绩
      scores.add(newScore);
      // 保存到存储
      await _prefs.setString(_scoresKey, json.encode(scores.map((s) => s.toJson()).toList()));
    }
  }

  Future<void> deleteScore(Score score) async {
    List<Score> scores = getScores();
    scores.removeWhere((s) => 
      s.gameType == score.gameType && 
      s.contentType == score.contentType && 
      s.dateTime == score.dateTime && 
      s.length == score.length
    );
    await _prefs.setString(_scoresKey, json.encode(scores.map((s) => s.toJson()).toList()));
  }

  Future<void> deleteAllByGameType(String gameType) async {
    List<Score> scores = getScores();
    scores.removeWhere((s) => s.gameType == gameType);
    await _prefs.setString(_scoresKey, json.encode(scores.map((s) => s.toJson()).toList()));
  }

  Score? getBestScore(String gameType, String contentType, {int? length}) {
    List<Score> scores = getScores();
    List<Score> filtered = scores.where((s) => 
      s.gameType == gameType && 
      s.contentType == contentType && 
      (length == null || s.length == length)
    ).toList();
    
    if (filtered.isEmpty) return null;
    
    filtered.sort((a, b) => b.value.compareTo(a.value));
    return filtered.first;
  }
}
