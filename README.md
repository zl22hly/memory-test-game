# 记忆测试游戏

一个功能完整的Flutter记忆测试游戏，包含三种游戏模式，支持数据持久化存储成绩。

## 功能特点

- 🎮 **三种游戏模式**
  - 进阶记忆挑战：显示时长随长度增加
  - 速记耐力挑战：固定8秒显示
  - 极速记忆冲刺：60秒限时挑战

- 📝 **丰富的设置选项**
  - 内容类型：纯数字 / 纯字母 / 数字+字母
  - 初始长度：可自定义（默认6位）
  - 实时显示最好成绩

- 🏆 **完整的成绩系统**
  - 按游戏类型和内容类型分类
  - 自动记录最佳成绩
  - 支持单独删除和批量删除

- 🎨 **优雅的界面设计**
  - 浅色简约风格
  - 卡片式布局
  - 流畅的动画效果

## 游戏规则

### 1. 进阶记忆挑战
- 显示时长 = 字符长度（6位显示6秒，7位显示7秒...）
- 显示后隐藏，玩家输入答案提交
- 正确：刷新新字符
- 连续2次正确：长度+1，时长同步+1
- 连续2次错误：游戏结束，记录成绩
- 未达成连续2次正确就出错：直接结束

### 2. 速记耐力挑战
- 显示时长固定8秒
- 正确：刷新新字符
- 连续2次正确：长度+1，时间仍为8秒
- 连续2次错误：游戏结束，记录成绩

### 3. 极速记忆冲刺
- 总时长：1分钟倒计时
- 字符长度全程不变（使用设置里的长度）
- 点击【回答】：数字隐藏，倒计时暂停
- 提交答案：倒计时继续，刷新新数字
- 60秒结束：答完最后一题，游戏结束
- 成绩：60秒内正确答对的组数

## 技术栈

- **框架**：Flutter 3.9+
- **语言**：Dart
- **数据存储**：shared_preferences
- **架构**：MVC模式

## 如何运行

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd web
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行项目**
   ```bash
   flutter run
   ```

## 项目结构

```
lib/
├── main.dart                    # 主入口
├── models/
│   └── score.dart              # 成绩数据模型
├── services/
│   └── storage_service.dart    # 存储服务（数据持久化）
└── pages/
    ├── home_page.dart          # 首页
    ├── settings_page.dart      # 设置页
    ├── game_page.dart          # 游戏页
    └── scores_page.dart        # 成绩页
```

## 注意事项

- 游戏数据存储在本地，卸载应用会丢失成绩
- 支持iOS、Android和Web平台
- 建议在移动设备上运行以获得最佳体验

## 如何发布

### Web平台发布

1. **构建Web版本**
   ```bash
   flutter build web
   ```

2. **部署到静态网站托管服务**
   - **GitHub Pages**：将 `build/web` 目录内容推送到GitHub仓库的 `gh-pages` 分支
   - **Vercel**：直接导入Flutter项目，Vercel会自动构建和部署
   - **Netlify**：上传 `build/web` 目录，或连接到GitHub仓库自动部署
   - **Firebase Hosting**：使用Firebase CLI部署
     ```bash
     firebase init
     firebase deploy
     ```

3. **配置注意事项**
   - 确保网站支持SPA（单页应用）路由
   - 对于GitHub Pages，可能需要添加 `.nojekyll` 文件到 `build/web` 目录

### 移动平台发布

#### Android发布

1. **生成签名密钥**
   ```bash
   keytool -genkey -v -keystore memory_test_game.keystore -alias memory_test_game -keyalg RSA -keysize 2048 -validity 10000
   ```

2. **配置签名信息**
   - 在 `android/app/build.gradle` 文件中添加签名配置

3. **构建发布版本**
   ```bash
   flutter build appbundle
   # 或
   flutter build apk
   ```

4. **上传到Google Play Console**
   - 创建应用并上传 `appbundle` 文件
   - 完成发布流程

#### iOS发布

1. **配置Xcode项目**
   - 打开 `ios/Runner.xcworkspace`
   - 配置应用信息和签名

2. **构建发布版本**
   ```bash
   flutter build ios
   ```

3. **通过Xcode上传到App Store Connect**
   - 使用Xcode的Archive功能
   - 上传到App Store Connect
   - 完成发布流程

### 发布前检查清单

- [ ] 测试所有游戏模式功能
- [ ] 验证成绩存储功能
- [ ] 检查不同设备和屏幕尺寸的适配性
- [ ] 优化应用大小和性能
- [ ] 添加适当的应用图标和启动画面
- [ ] 编写清晰的应用描述和更新日志

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request！

---

**祝你游戏愉快！** 🧠✨
