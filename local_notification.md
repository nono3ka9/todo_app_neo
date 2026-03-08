- flutter runの流れ（Android 開発環境）
  1. dartコードを書く
  2. そのdartコードを、中間表現に変換する。
  3. 「中間表現」 + 「JavaのファイルやAndroid Manifest.xmlなど」を、Gradleがまとめて処理
  4. APKが作られる
  5. そのAPKをエミュがインストール
  6. アプリ起動
- 専門用語
  - APK
    - ファイル形式の一種。Androidでは、スマホがAPKファイルをインストールすることでアプリが起動する。すなわち、APKとは、アプリそのもの
    - Windowsでいう、.exeに近い
    - すなわちAndroidの場合、flutter runの最終目標は、APKを作って、それをエミュがインストールすること。
  - 中間表現
    - dartコードを、コンピュータが理解しやすいような形にしたもの
  - Gradle
    - Android開発で用いられるビルド自動化ツール。コンパイルとかを自動でやってくれる。。APKを作っている張本人。
  - AndroidManifest.xml
    - Androidアプリの設定をまとめたファイル。Flutterに限らず、いかなるAndroidアプリにも必要不可欠。アイコンやアプリ名などを記述。
    - xml
      - htmlと同じく、タグを用いて記述するマークアップ言語。ブラウザで表示するhtmlとは違い、データフォーマットとして扱われる
      - よく使われるデータフォーマットとして、他にCSVやJSONなどがある
- APKを作る材料
  - 「中間表現」+「JavaのファイルやAndroidManifest.xmlなど」
  - なぜ、Java（プログラミング言語の一種）のファイル（正確にはJavaとKotlin）が出てくるのか？
  - AndroidのOSにアクセスできるのはJavaとKotlinだけだから（Android OSがJavaとKotlin向けにAPIを提供している）
- desugaring
  - Javaのバージョンが上がって登場した新しいコードの文法を、従来の文法だけで表現するためのツール。Android開発では、新しいJavaの書き方を、古いAndroidバージョンでも動かせるようにするために用いられる
