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
    
    scores.removeWhere((s) => 
      s.gameType == newScore.gameType && 
      s.contentType == newScore.contentType && 
      s.length == newScore.length
    );
    
    scores.add(newScore);
    
    await _prefs.setString(_scoresKey, json.encode(scores.map((s) => s.toJson()).toList()));
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
