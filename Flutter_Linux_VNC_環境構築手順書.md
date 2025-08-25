# Flutter + Linux GUI + VNC 開発環境 構築手順書

## 概要
この手順書は、VS Code Dev Containers機能とDockerを用いて、Flutter LinuxデスクトップアプリをVNC経由でGUI表示・開発できる環境の構築方法をまとめたものです。

---

## 1. 前提条件
- インターネット接続環境
- 管理者権限のあるPC（WindowsまたはMac）
- Windowsの場合、5901ポートがファイアウォールで許可されていること

---

## 2. Dockerのインストール
### Windowsの場合
1. 公式サイト(https://www.docker.com/products/docker-desktop/) から「Docker Desktop for Windows」をダウンロード
2. インストーラーを実行し、画面の指示に従ってインストール
3. インストール後、PCを再起動

### Macの場合
1. 公式サイト(https://www.docker.com/products/docker-desktop/) から「Docker Desktop for Mac」をダウンロード
2. インストーラー（.dmg）を開き、アプリケーションフォルダにドラッグ
3. Docker Desktopを起動

---

## 3. TigerVNCクライアントのインストール
### Windowsの場合
1. 公式サイト(https://tigervnc.org/) の「Downloads」からWindows用インストーラー（例：tigervnc64-*.exe）をダウンロード
2. インストーラーを実行し、画面の指示に従ってインストール

### Macの場合
1. 公式サイト(https://tigervnc.org/) の「Downloads」からMac用パッケージ（例：TigerVNC-*-x86_64.dmg）をダウンロード
2. .dmgファイルを開き、アプリケーションフォルダにコピー

---

## 4. VS CodeのインストールとDev Containers拡張の追加
### Windows/Mac共通
1. 公式サイト(https://code.visualstudio.com/) からVS Codeをダウンロード・インストール
2. VS Codeを起動
3. 左側の拡張機能（四角いアイコン）をクリック
4. 検索ボックスに「Dev Containers」と入力し、「Dev Containers（ms-vscode-remote.remote-containers）」をインストール

---

## 5. Github Desktopのインストール
### Windows/Mac共通
1. 公式サイト(https://desktop.github.com/) からインストーラーをダウンロード
2. インストーラーを実行し、画面の指示に従ってインストール

---

## 6. リポジトリのクローン（Github Desktop経由）
1. Github Desktopを起動
2. メニューから「File」→「Clone repository...」を選択
3. 「URL」タブにリポジトリのURL（例：https://github.com/masatokg/container2025_test ）を貼り付け
4. 「Clone」をクリック
5. クローン先のフォルダを選択し、完了

---

## 7. Dev Containerの起動
1. Github DesktopでクローンしたフォルダをVS Codeで開く（「Open in Visual Studio Code」ボタンを利用）
2. コマンドパレット（Ctrl+Shift+P）で「Dev Containers: Reopen in Container」を選択
3. 自動でDockerイメージのビルド・コンテナ起動・依存パッケージのセットアップが行われます

---

## 8. Flutterアプリの起動
1. VS Codeのターミナルで以下を実行
```
cd my_app
flutter run
```
2. 「Launching lib/main.dart on Linux in debug mode...」と表示されればOK

---

## 9. VNCでGUI画面を確認
1. TigerVNC Viewerを起動
2. 接続先: `localhost:5901` で接続
3. パスワード不要（空欄でOK）
4. LinuxデスクトップとFlutterアプリのウィンドウが表示されます

---

## 10. トラブルシューティング
- VNCで接続できない場合:
  - コンテナを再起動し、5901ポートがLISTENしているか確認
  - `tail -n 50 /tmp/x11vnc.log` でx11vncのログを確認
- Flutter runでDISPLAYエラーが出る場合:
  - ターミナルを再起動、または`export DISPLAY=:1`を実行

---

## 11. 補足
- VNCサーバはstart-vnc.shで自動起動します
- x11vncは5901ポートで待ち受け
- Xvfbの仮想ディスプレイは:1

---

## 12. 参考
- Docker, VS Code Dev Containers公式ドキュメント
- Flutter公式ドキュメント
- VNC関連FAQ: http://www.karlrunge.com/x11vnc/faq.html

---

以上
