import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/score.dart';

class GamePage extends StatefulWidget {
  final String gameType;
  final String contentType;
  final int initialLength;

  const GamePage({
    super.key,
    required this.gameType,
    required this.contentType,
    required this.initialLength,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final TextEditingController _controller = TextEditingController();
  final Random _random = Random();

  String _currentString = '';
  int _currentLength = 0;
  int _displayTimer = 0;
  int _totalTimer = 60;
  bool _isShowing = false;
  bool _isPaused = false;
  bool _isInputting = false;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _consecutiveCorrect = 0;
  int _consecutiveWrong = 0;
  int _scoreValue = 0;
  Timer? _displayTimerObj;
  Timer? _totalTimerObj;
  StorageService? _storageService;

  @override
  void initState() {
    super.initState();
    _currentLength = widget.initialLength;
    _initStorage();
    _startGame();
  }

  Future<void> _initStorage() async {
    _storageService = await StorageService.getInstance();
  }

  String _generateString() {
    String chars = '';
    if (widget.contentType.contains('纯数字') || widget.contentType.contains('数字')) {
      chars += '0123456789';
    }
    if (widget.contentType.contains('纯字母') || widget.contentType.contains('字母')) {
      chars += 'abcdefghijklmnopqrstuvwxyz';
    }
    return List.generate(_currentLength, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  void _startGame() {
    _generateNewString();
    if (widget.gameType == 'sprint') {
      _startTotalTimer();
    }
  }

  void _generateNewString() {
    setState(() {
      _currentString = _generateString();
      _isShowing = true;
      _isInputting = false;
      _controller.clear();
    });
    _startDisplayTimer();
  }

  void _startDisplayTimer() {
    int duration = widget.gameType == 'endurance' ? 8 : _currentLength;
    _displayTimer = duration;
    _displayTimerObj?.cancel();
    _displayTimerObj = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _displayTimer--;
      });
      if (_displayTimer <= 0) {
        timer.cancel();
        if (widget.gameType != 'sprint') {
          _hideAndStartInput();
        }
      }
    });
  }

  void _startTotalTimer() {
    _totalTimer = 60;
    _totalTimerObj?.cancel();
    _totalTimerObj = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _totalTimer--;
        });
        if (_totalTimer <= 0) {
          timer.cancel();
          setState(() {
            _isPaused = true;
            _isShowing = false;
            _isInputting = true;
          });
        }
      }
    });
  }

  void _hideAndStartInput() {
    setState(() {
      _isShowing = false;
      _isInputting = true;
    });
  }

  void _onAnswerClick() {
    setState(() {
      _isShowing = false;
      _isPaused = true;
      _isInputting = true;
    });
    _displayTimerObj?.cancel();
  }

  void _submitAnswer() {
    String userAnswer = _controller.text;
    bool correct = userAnswer == _currentString;

    if (correct) {
      _correctCount++;
      _consecutiveCorrect++;
      _consecutiveWrong = 0;

      if (widget.gameType == 'sprint') {
        _scoreValue++;
      } else {
        _scoreValue = _currentLength;
      }

      if (_consecutiveCorrect >= 2 && widget.gameType != 'sprint') {
        _currentLength++;
        _consecutiveCorrect = 0;
      }

      if (widget.gameType == 'sprint' && _totalTimer > 0) {
        setState(() {
          _isPaused = false;
        });
        _generateNewString();
      } else if (widget.gameType != 'sprint') {
        _generateNewString();
      }
    } else {
      _wrongCount++;
      _consecutiveWrong++;
      _consecutiveCorrect = 0;

      if (_consecutiveWrong >= 2 && widget.gameType != 'sprint') {
        _endGame();
      } else if (widget.gameType == 'sprint' && _totalTimer > 0) {
        setState(() {
          _isPaused = false;
        });
        _generateNewString();
      } else if (widget.gameType != 'sprint' && _totalTimer > 0) {
        _generateNewString();
      }
    }

    if (widget.gameType == 'sprint' && _totalTimer <= 0) {
      _endGame();
    }
  }

  void _endGame() async {
    _displayTimerObj?.cancel();
    _totalTimerObj?.cancel();

    Score newScore = Score(
      gameType: widget.gameType,
      contentType: widget.contentType,
      value: _scoreValue,
      dateTime: DateTime.now(),
      length: widget.gameType == 'sprint' ? widget.initialLength : null,
    );

    await _storageService?.saveScore(newScore);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('游戏结束'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('正确: $_correctCount 次'),
            Text('错误: $_wrongCount 次'),
            const SizedBox(height: 8),
            Text(
              widget.gameType == 'sprint'
                  ? '最终成绩: $_scoreValue 组'
                  : '最终成绩: $_scoreValue 位',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('返回'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            child: const Text('再来一局'),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _currentLength = widget.initialLength;
      _displayTimer = 0;
      _totalTimer = 60;
      _isShowing = false;
      _isPaused = false;
      _isInputting = false;
      _correctCount = 0;
      _wrongCount = 0;
      _consecutiveCorrect = 0;
      _consecutiveWrong = 0;
      _scoreValue = 0;
      _controller.clear();
    });
    _startGame();
  }

  @override
  void dispose() {
    _displayTimerObj?.cancel();
    _totalTimerObj?.cancel();
    _controller.dispose();
    super.dispose();
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
        title: Text(_gameTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('当前长度'),
                        Text('$_currentLength 位', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (widget.gameType != 'sprint')
                      Column(
                        children: [
                          const Text('显示剩余'),
                          Text('$_displayTimer 秒', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    if (widget.gameType == 'sprint')
                      Column(
                        children: [
                          const Text('总倒计时'),
                          Text('$_totalTimer 秒', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isShowing)
                        Text(
                          _currentString,
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 8),
                        )
                      else
                        const Text(
                          '请输入你记住的内容',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      if (_isInputting) ...[
                        const SizedBox(height: 24),
                        TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '输入答案',
                          ),
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submitAnswer(),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _submitAnswer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('提交'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (widget.gameType == 'sprint' && _isShowing)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: _onAnswerClick,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('回答'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
