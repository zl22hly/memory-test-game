import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'scores_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showHelpDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记忆测试游戏'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScoresPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            _buildGameCard(
              context,
              '进阶记忆挑战',
              '字符显示时长随长度增加，挑战你的极限记忆！',
              'advanced',
              '''
游戏规则：
• 显示时长 = 字符长度（6位显示6秒...
• 正确刷新新字符
• 连续2次正确：长度+1
• 连续2次错误：游戏结束
              ''',
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              '速记耐力挑战',
              '固定8秒显示，挑战记忆耐力！',
              'endurance',
              '''
游戏规则：
• 固定8秒显示
• 正确刷新新字符
• 连续2次正确：长度+1
• 连续2次错误：游戏结束
              ''',
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              '极速记忆冲刺',
              '1分钟限时，挑战速度！',
              'sprint',
              '''
游戏规则：
• 60秒倒计时
• 字符长度固定
• 点击回答隐藏数字、暂停倒计时
• 提交后继续
• 60秒结束游戏
              ''',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String title,
    String subtitle,
    String gameType,
    String helpContent,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(gameType: gameType),
                        ),
                      );
                    },
                    child: const Text('开始游戏'),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => _showHelpDialog(context, title, helpContent),
            ),
          ],
        ),
      ),
    );
  }
}
