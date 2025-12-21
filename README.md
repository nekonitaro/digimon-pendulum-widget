# Digimon Pendulum Widget App

デジモンペンデュラム風の育成ウィジェットアプリ

## 機能
- スマホウィジェット上でデジモンが冒険
- 育成・進化システム
- ジョグレス進化
- バトルシステム

## 開発環境
- Flutter 3.16.0+
- Dart 3.0+

## セットアップ
```bash
# 依存パッケージのインストール
flutter pub get

# アプリ起動
flutter run

# テスト実行
flutter test
```

## ブランチ戦略
- `main`: 本番リリース用
- `develop`: 開発用
- `feature/*`: 機能開発用

## コミット規約
Conventional Commitsに従う

# プロジェクト情報
flutter doctor -v                  # 環境の詳細確認
flutter devices                    # 接続デバイス一覧

# 開発
flutter run                        # アプリ起動
flutter run -d <device_id>         # 特定デバイスで起動
flutter clean                      # ビルドキャッシュクリア

# テスト
flutter test                       # 全テスト実行
flutter test --coverage            # カバレッジ付きテスト
flutter test test/specific_test.dart  # 特定テスト実行

# パッケージ管理
flutter pub get                    # パッケージインストール
flutter pub upgrade                # パッケージ更新
flutter pub outdated               # 古いパッケージ確認

# ビルド（リリース用）
flutter build apk                  # Android APK
flutter build appbundle            # Android App Bundle

# 分析
flutter analyze                    # コード静的解析
dart format lib/ test/            # コードフォーマット