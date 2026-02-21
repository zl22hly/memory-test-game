import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/score.dart';

class ScoresPage extends StatefulWidget {
  const ScoresPage({super.key});

  @override
  State<ScoresPage> createState() => _ScoresPageState();
}

class _ScoresPageState extends State<ScoresPage> {
  StorageService? _storageService;
  List<Score> _scores = [];
  int _sprintLength = 6;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storageService = await StorageService.getInstance();
    _loadScores();
  }

  void _loadScores() {
    if (_storageService != null) {
      setState(() {
        _scores = _storageService!.getScores();
      });
    }
  }

  Future<void> _deleteScore(Score score) async {
    await _storageService?.deleteScore(score);
    _loadScores();
  }

  Future<void> _deleteAllByGameType(String gameType) async {
    await _storageService?.deleteAllByGameType(gameType);
    _loadScores();
  }

  Score? _getBestScore(String gameType, String contentType, {int? length}) {
    List<Score> filtered = _scores.where((s) => 
      s.gameType == gameType && 
      s.contentType == contentType && 
      (length == null || s.length == length)
    ).toList();
    
    if (filtered.isEmpty) return null;
    
    filtered.sort((a, b) => b.value.compareTo(a.value));
    return filtered.first;
  }

  Widget _buildScoreCard(String gameType, String title, {bool hasLengthSelector = false}) {
    List<String> contentTypes = ['纯数字', '纯字母', '数字 + 字母'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (hasLengthSelector) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('长度:'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _sprintLength,
                    items: List.generate(
                      15,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1} 位'),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _sprintLength = value!;
                      });
                    },
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            ...contentTypes.map((contentType) {
              Score? score = _getBestScore(
                gameType,
                contentType,
                length: hasLengthSelector ? _sprintLength : null,
              );
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '最佳纪录：$contentType',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (score != null)
                            Text(
                              hasLengthSelector
                                  ? '${score.value} 组｜$contentType｜${score.formattedDate}'
                                  : '${score.value} 位｜$contentType｜${score.formattedDate}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                    if (score != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () => _deleteScore(score),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _deleteAllByGameType(gameType),
              child: const Text('删除全部', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的记忆成绩'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildScoreCard('advanced', '进阶记忆挑战'),
            _buildScoreCard('endurance', '速记耐力挑战'),
            _buildScoreCard('sprint', '极速记忆冲刺', hasLengthSelector: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('返回游戏'),
            ),
          ],
        ),
      ),
    );
  }
}
