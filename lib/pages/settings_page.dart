import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/score.dart';
import 'game_page.dart';

class SettingsPage extends StatefulWidget {
  final String gameType;

  const SettingsPage({super.key, required this.gameType});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _contentType = '纯数字';
  int _length = 6;
  StorageService? _storageService;
  Score? _bestScore;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storageService = await StorageService.getInstance();
    _loadBestScore();
  }

  void _loadBestScore() {
    if (_storageService != null) {
      setState(() {
        _bestScore = _storageService!.getBestScore(
          widget.gameType,
          _contentType,
          length: widget.gameType == 'sprint' ? _length : null,
        );
      });
    }
  }

  String get _gameTitle {
    switch (widget.gameType) {
      case 'advanced':
        return '进阶记忆挑战';
      case 'endurance':
        return '速记耐力挑战';
      case 'sprint':
        return '极速记忆冲刺';
      default:
        return '游戏';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_gameTitle - 设置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '内容类型',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _contentType == '纯数字' ? Colors.blue : null,
                              foregroundColor: _contentType == '纯数字' ? Colors.white : null,
                            ),
                            onPressed: () {
                              setState(() {
                                _contentType = '纯数字';
                              });
                              _loadBestScore();
                            },
                            child: const Text('纯数字'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _contentType == '纯字母' ? Colors.blue : null,
                              foregroundColor: _contentType == '纯字母' ? Colors.white : null,
                            ),
                            onPressed: () {
                              setState(() {
                                _contentType = '纯字母';
                              });
                              _loadBestScore();
                            },
                            child: const Text('纯字母'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _contentType == '数字 + 字母' ? Colors.blue : null,
                        foregroundColor: _contentType == '数字 + 字母' ? Colors.white : null,
                      ),
                      onPressed: () {
                        setState(() {
                          _contentType = '数字 + 字母';
                        });
                        _loadBestScore();
                      },
                      child: const Text('数字 + 字母'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '初始长度',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _length,
                      items: List.generate(
                        15,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1} 位'),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _length = value!;
                        });
                        _loadBestScore();
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '最好成绩',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_bestScore != null)
                      Text(
                        widget.gameType == 'sprint'
                            ? '${_bestScore!.value} 组 | $_contentType | ${_bestScore!.formattedDate}'
                            : '${_bestScore!.value} 位 | $_contentType | ${_bestScore!.formattedDate}',
                        style: const TextStyle(fontSize: 14),
                      )
                    else
                      Text(
                        '暂无记录',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GamePage(
                      gameType: widget.gameType,
                      contentType: _contentType,
                      initialLength: _length,
                    ),
                  ),
                );
              },
              child: const Text('开始游戏'),
            ),
          ],
        ),
      ),
    );
  }
}
