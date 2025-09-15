# Flutter + Linux GUI + VNC 開発環境 構築手順書
## 以下のリンク先で最新の手順内容を公開しています。こちらを参照してください。
## [https://fern-lint-66e.notion.site/Flutter-Linux-GUI-VNC-25e0cb61616b80e694ccfd9d6931fa56](https://fern-lint-66e.notion.site/Flutter-Linux-GUI-VNC-25e0cb61616b80e694ccfd9d6931fa56)

## 概要
この手順書は、VS Code Dev Containers機能とDockerを用いて、Flutter LinuxデスクトップアプリをVNC経由でGUI表示・開発できる環境の構築方法をまとめたものです。
Android/iOSに依存しない機能は、Flutter Linuxデスクトップアプリとしても動作確認が可能ですので、モバイルデバイスのエミュレーター確認操作を省略できます。

---

## 1. 前提条件
- インターネット接続環境
- 管理者権限のあるPC（WindowsまたはMac）
- Windowsの場合、5901ポートがファイアウォールで許可されていること
- **Macの場合はWSL（Windows Subsystem for Linux）相当の機能追加は不要です。 Windowsは、この手順でWSLを有効化します。**
- **パソコンにgitがインストールされていること。されていない場合は、この手順内でインストールします**

---


## 2. WSL2の有効化（Windowsのみ）

Docker DesktopでLinuxコンテナを利用するには、WSL2（Windows Subsystem for Linux 2）の有効化が必要です。

1. 「Windowsの機能の有効化または無効化」を開きます（以下のいずれかの方法で開けます）。
  - スタートメニューで「Windowsの機能」と入力し、検索結果から「Windowsの機能の有効化または無効化」をクリック
  - 「ファイル名を指定して実行」（Win + R）で optionalfeatures と入力してOKを押す
  その後、「Windows Subsystem for Linux」と「仮想マシンプラットフォーム」にチェックを入れてOKを押す
  ※「Windows Subsystem for Linux」は、環境によって「Linux 用 Windows サブシステム」や「WSL」などと表示されている場合があります。「Linux」や「WSL」で検索すると見つけやすいです。
2. PCを再起動しください

### Linuxディストリビューション（Ubuntu等のOS）のインストールという選択肢が途中にありますが、今回のようにDocker DesktopでLinuxコンテナを利用するだけなら選択不要です。
### 詳細はDocker公式ドキュメント（ https://docs.docker.com/desktop/wsl/ ）も参照してください。

## 3. Docker Desktopのインストール
### Windowsの場合
1. 公式サイト(https://www.docker.com/products/docker-desktop/) から「Docker Desktop for Windows」をダウンロード
2. インストーラーを実行し、画面の指示に従ってインストール
3. インストール後、PCを再起動
4. Docker Desktop初回起動時に「WSL2を有効にしますか？」と表示されたら「有効にする」を選択
5. Docker Desktop初回起動時に「WSL needs updating」のメッセージ画面が表示されたら、そこに示されている「wsl --update」のコマンドをコピーしてPowershellに張り付けて実行、WSLがupdateされます。そのあと、「WSL needs updating」のメッセージ画面に表示される「Restart」ボタンを押して、Docker Desktopを再起動してください。
6. 設定画面の「Resources」→「WSL Integration」で、WSL2が有効になっていることを確認
7. あとの手順でVScodeで Dev container をOpenしますが、DockerDesktopが起動中でないとエラーになりますのでご注意ください。

### Macの場合
1. 公式サイト(https://www.docker.com/products/docker-desktop/) から「Docker Desktop for Mac」をダウンロード
2. インストーラー（.dmg）を開き、アプリケーションフォルダにドラッグ
3. Docker Desktopを起動

#### M1 Mac（Apple Silicon）の場合の追加設定
M1 Mac環境でFlutter開発環境を最適に動作させるため、以下の設定を行ってください：

**Rosetta 2エミュレーションの有効化**
1. Docker Desktop → Settings（歯車アイコン）→ General
2. 「Use Rosetta for x86/amd64 emulation on Apple Silicon」にチェックを入れる
3. 「Apply & Restart」をクリック
4. これにより、x86_64 Flutterバイナリの実行性能が大幅に向上します

**リソース割り当ての調整**
1. Docker Desktop → Settings → Resources
2. 以下の設定を推奨します：
   - **CPU**: 最低4コア（8コア以上が理想）
   - **Memory**: 最低8GB（16GB以上が理想）
   - **Disk**: 最低32GB

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
1. 公式サイト（ https://code.visualstudio.com/ ) からVS Codeをダウンロード・インストール
2. VS Codeを起動
3. 左側の拡張機能（四角いアイコン）をクリック
4. 検索ボックスに「Dev Containers」と入力し、「Dev Containers（ms-vscode-remote.remote-containers）」をインストール

---

## 5. gitのインストール確認と設定

1. Macターミナル または WindowsPowerShell で以下を実行し、gitがインストールされているか確認します。
   ```
   git --version
   ```
   バージョン情報が表示されればインストール済みです。

2. インストールされていない場合は、以下の手順でインストールしてください。

   #### Windowsの場合
   - 公式サイト（ https://git-scm.com/ ）からインストーラーをダウンロードし、画面の指示に従ってインストール

   #### Macの場合
   - ターミナルで以下を実行
     ```
     xcode-select --install
     ```
     または、Homebrewを利用している場合は
     ```
     brew install git
     ```

3. インストール後、以下のコマンドで文字コードと改行コードの自動変換を無効化します。
   ```
   git config --global core.autocrlf false
   git config --global core.safecrlf false
   git config --global i18n.commitEncoding UTF-8
   git config --global i18n.logOutputEncoding UTF-8
   ```
---

## 6. Github Desktopのインストール
### Windows/Mac共通
1. 公式サイト(https://desktop.github.com/) からインストーラーをダウンロード
2. インストーラーを実行し、画面の指示に従ってインストール

---
## 7. リポジトリのクローン（Githubリポジトリ画面→Github Desktop）
1. パソコンからWebブラウザで対象のGithubリポジトリ（例：https://github.com/masatokg/container2025_test ) を開く
2. 緑色の「Code」ボタンをクリック
3. 「Open with Github Desktop」を選択
4. Github Desktopアプリが自動で起動し、リポジトリのコピーを配置したいクローン先のフォルダを選択して「Clone」をクリック
5. クローンが完了したら、ローカルPC上にリポジトリが作成されます

### プロジェクト用の設定変更(Apple Silicon Mac の場合)**
1. プロジェクトの `.devcontainer/.env` ファイルを編集
2. `ARCH=amd64` を `ARCH=arm64` に変更
```
ARCH=arm64
CONTAINER_NAME=CONTAINER_2025SD4_v01
```

---
## 8. Dev Containerの起動
1. Github DesktopでクローンしたフォルダをVS Codeで開く（「Open in Visual Studio Code」ボタンを利用）
2. コマンドパレット（Ctrl+Shift+P）で「Dev Containers: Reopen in Container」を選択
3. 自動でDockerイメージのビルド・コンテナ起動・依存パッケージのセットアップが行われます。もし途中で「press any key～～」というメッセージが出てログが止まったら、任意のキーを押してください。

---

## 9. Flutterプロジェクトの生成とアプリの起動
1. VS Codeのターミナルで以下を実行 (プロジェクト名 = my_appの場合の例)
```
flutter create my_app 
cd my_app
flutter run
```
2. 「Launching lib/main.dart on Linux in debug mode...」と表示されればOK

---

## 10. VNCでGUI画面を確認
1. パソコンでTigerVNC Viewerを起動
2. 接続ウィンドウに接続先: `localhost:5901` を入力して接続
3. パスワード不要（空欄でOK）
4. 仮想Linuxデスクトップのウィンドウとその中にFlutterアプリのウィンドウが表示されます

---

## 11. Flutterアプリのデバッグについて
Flutterアプリを起動すると、以下のようなメッセージが表示される場合があります。

```
A Dart VM Service on Linux is available at: http://127.0.0.1:43381/L3wW2Cu76v4=/
The Flutter DevTools debugger and profiler on Linux is available at:
http://127.0.0.1:9102?uri=http://127.0.0.1:43381/L3wW2Cu76v4=/
```

この場合、Webブラウザで上記の「Flutter DevTools」のURL（ 例: http://127.0.0.1:9102?... ）にアクセスすると、
Flutterアプリのデバッグやプロファイリングが可能です。

主な機能：
- Widgetツリーの確認・編集
- パフォーマンスの計測
- メモリ・CPUのモニタリング
- ログの確認

デバッグやパフォーマンス解析を行いたい場合は、表示されたURLをコピーしてブラウザで開いてください。

---

## 12. トラブルシューティング
- VNCで接続できない場合:
  - コンテナを再起動し、5901ポートがLISTENしているか確認
  - `tail -n 50 /tmp/x11vnc.log` でx11vncのログを確認
- Flutter runでDISPLAYエラーが出る場合:
  - ターミナルを再起動、または`export DISPLAY=:1`を実行

- Dev Containers: Reopen in Container でエラーが発生する場合:
  - キャッシュが影響している場合があります。コマンドパレット（Ctrl+Shift+P）で「Dev Containers: Rebuild and Reopen in Container」を選択し、キャッシュなしで再ビルドを試してください。

- Dockerコンテナの容量のクリーンアップ:
  - コンテナをたくさん作成したり、作成に失敗を重ねると、不要なコンテナが増えてPCのディスク容量が不足します。以下の手順をみて不要な容量を削除してください。
  - https://fern-lint-66e.notion.site/Flutter-Linux-GUI-VNC-25e0cb61616b80e694ccfd9d6931fa56?source=copy_link
---

## 13. 補足
- VNCサーバはstart-vnc.shで自動起動します
- x11vncは5901ポートで待ち受け
- Xvfbの仮想ディスプレイは:1

---

## 14. 参考
- Docker, VS Code Dev Containers公式ドキュメント
- Flutter公式ドキュメント
- VNC関連FAQ: http://www.karlrunge.com/x11vnc/faq.html
