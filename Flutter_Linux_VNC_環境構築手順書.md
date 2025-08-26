# Flutter + Linux GUI + VNC 開発環境 構築手順書

## 概要
この手順書は、VS Code Dev Containers機能とDockerを用いて、Flutter LinuxデスクトップアプリをVNC経由でGUI表示・開発できる環境の構築方法をまとめたものです。
Android/iOSに依存しない機能は、Flutter Linuxデスクトップアプリとしても動作確認が可能ですので、エミュレーター確認操作を総略できます。

---

## 1. 前提条件
- インターネット接続環境
- 管理者権限のあるPC（WindowsまたはMac）
- Windowsの場合、5901ポートがファイアウォールで許可されていること

---


## 2. WSL2の有効化（Windowsのみ）

Docker DesktopでLinuxコンテナを利用するには、WSL2（Windows Subsystem for Linux 2）の有効化が必要です。

1. 「Windowsの機能の有効化または無効化」を開きます（以下のいずれかの方法で開けます）。
  - スタートメニューで「Windowsの機能」と入力し、検索結果から「Windowsの機能の有効化または無効化」をクリック
  - 「ファイル名を指定して実行」（Win + R）で optionalfeatures と入力してOKを押す
  その後、「Windows Subsystem for Linux」と「仮想マシンプラットフォーム」にチェックを入れてOKを押す
  ※「Windows Subsystem for Linux」は、環境によって「Linux 用 Windows サブシステム」や「WSL」などと表示されている場合があります。「Linux」や「WSL」で検索すると見つけやすいです。
2. PCを再起動しください

※Linuxディストリビューション（Ubuntu等のOS）のインストールという選択肢が途中にありますが、今回のようにDocker DesktopでLinuxコンテナを利用するだけなら選択不要です。
※詳細はDocker公式ドキュメント（https://docs.docker.com/desktop/wsl/）も参照してください。

## 3. Docker Desktopのインストール
### Windowsの場合
1. 公式サイト(https://www.docker.com/products/docker-desktop/) から「Docker Desktop for Windows」をダウンロード
2. インストーラーを実行し、画面の指示に従ってインストール
3. インストール後、PCを再起動
4. Docker Desktop初回起動時に「WSL2を有効にしますか？」と表示されたら「有効にする」を選択
5. 設定画面の「Resources」→「WSL Integration」で、WSL2が有効になっていることを確認

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

## 6. リポジトリのクローン（Githubリポジトリ画面→Github Desktop）
1. パソコンからWebブラウザで対象のGithubリポジトリ（例：https://github.com/masatokg/container2025_test ) を開く
2. 緑色の「Code」ボタンをクリック
3. 「Open with Github Desktop」を選択
4. Github Desktopアプリが自動で起動し、リポジトリのコピーを配置したいクローン先のフォルダを選択して「Clone」をクリック
5. クローンが完了したら、ローカルPC上にリポジトリが作成されます

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
1. パソコンでTigerVNC Viewerを起動
2. 接続ウィンドウに接続先: `localhost:5901` を入力して接続
3. パスワード不要（空欄でOK）
4. 仮想Linuxデスクトップのウィンドウとその中にFlutterアプリのウィンドウが表示されます

---


## 10. Flutterアプリのデバッグについて
Flutterアプリを起動すると、以下のようなメッセージが表示される場合があります。

```
A Dart VM Service on Linux is available at: http://127.0.0.1:43381/L3wW2Cu76v4=/
The Flutter DevTools debugger and profiler on Linux is available at:
http://127.0.0.1:9102?uri=http://127.0.0.1:43381/L3wW2Cu76v4=/
```

この場合、Webブラウザで上記の「Flutter DevTools」のURL（例: http://127.0.0.1:9102?...）にアクセスすると、
Flutterアプリのデバッグやプロファイリングが可能です。

主な機能：
- Widgetツリーの確認・編集
- パフォーマンスの計測
- メモリ・CPUのモニタリング
- ログの確認

デバッグやパフォーマンス解析を行いたい場合は、表示されたURLをコピーしてブラウザで開いてください。

---

## 11. トラブルシューティング
- VNCで接続できない場合:
  - コンテナを再起動し、5901ポートがLISTENしているか確認
  - `tail -n 50 /tmp/x11vnc.log` でx11vncのログを確認
- Flutter runでDISPLAYエラーが出る場合:
  - ターミナルを再起動、または`export DISPLAY=:1`を実行

- Dev Containers: Reopen in Container でエラーが発生する場合:
  - キャッシュが影響している場合があります。コマンドパレット（Ctrl+Shift+P）で「Dev Containers: Rebuild and Reopen in Container」を選択し、キャッシュなしで再ビルドを試してください。

---

## 12. 補足
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
