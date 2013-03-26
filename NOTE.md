READMEには書きたくないが、一応まとめないと困る何か
===============

なぜREADMEに書かないのか
---------------
システムの性質を考えればわかるじゃないですか・・・


一方で、複雑化してきたシステムに私の頭が追いつかなくなってきたし、
作者が追いつかないものを他の人が扱えるかというのも微妙なので、
「ここ」にメモっておく方向で

Data convert from old ROGv
---------------
- cd [old rogv dir]
- ruby script/export.rb
- data files export in dumo/export/[date].txt
- files copy to gagnrath/tmp (or /tmp, etc...)
- rails r bin/app/importer.rb [export file path]

詳しくはROGvとGagnrathそれぞれのスクリプトの使い方を参照

3つのモード
---------------
#### 本番モード（sample\_mode:false / view\_mode:false）
- 本番運用するためのモード
- 認証での保護に加え、クライアントからの更新もできる環境

 - Basic認証：有効
 - クライアントからの更新：可能
 - 管理系の利用：可能
 - 宣伝フッタ：非表示


#### 表示モード（sample\_mode:false / view\_mode:true）
- 本番データの表示のみをサポートしたモード
- 同盟先などとデータのみを共有する場合に使用

 - Basic認証：有効
 - クライアントからの更新：不能
 - 管理系の利用：不能
 - 宣伝フッタ：非表示


#### サンプルモード（sample\_mode:true）
- サンプル環境用モード
- http://ro.parrot-studio.com/rogvs/ で公開するためのモード

 - Basic認証：無効
 - クライアントからの更新：不能
 - 管理系の利用：不能
 - 宣伝フッタ：表示


config/settings.yml
---------------
#### 概要
- YAML形式で記述
- クローズドに運用する前提でPASS等は平文で書くようになっている。他のシステムと共有しないこと
 - ブラウザツールバー等でPASSが漏れるリスクはあることも留意すべき
 - システムがhttpsで運用されるといいのだけど、趣味のシステムでそこまでは・・・
- env/secret\_key\_baseを指定しないと起動時にエラーになるので注意

#### 詳細
- env : 環境設定
 - secret\_key\_base : Railsのセッション生成に使われる文字列。"rake secret"を実行して文字列を生成
 - server\_name : RO的な意味でのサーバ名。表示に使う
 - gvtype: "FE"を指定するとFE/SEモード、"TE"を指定するとTEモードで動作
 - sample\_mode view\_mode : モード説明参照
 - attention\_minitues : 砦viewで強調表示するためのuptime。現在交戦中の可能性が高い場所を区別
 - data\_size/recently : 集計で「最近のn週」のnに入る値
 - data\_size/min\_size data\_size/max\_size : 集計表示の最小/最大データ数。負荷を考えて指定
 - timeline/span\_max\_size : 期間タイムラインにおいて指定可能な最大データ数。負荷を考えて指定
- memcache : memcachedへの接続情報
 - server : memcachedのサーバ（例：localhost:11211）
 - header : memcached上の名前空間。同じものを指定するとキャッシュが混在する
 - expire : キャッシュ有効時間（分）
- auth : 認証情報
 - basic : Basic認証情報。ページアクセスそのものを制御
 - admin : 管理ページ用認証情報
 - update_key : サーバ更新用key。Basic認証のIDとは別の長いものを設定する（※平文で扱われるので注意）
 - delete_key : データを削除するためのkey（※平文で扱われるので注意）
- viewer : rogv_viewerへの接続情報（設定不要）


スクリプト（bin/app/以下）
---------------
#### 概要
- cronで各種処理を実行するためのもの
- 「rails r」コマンドで実行する
- 管理系で同じことができるが、cronが使えるなら自動化できる
- 「RAILS_ENV=production」指定のかわりに「-e production」指定が可能
- おそらく設置ディレクトリにcdしてから実行しないとおかしくなるかも

#### dumper.rb
MariaDB(MySQL)のデータをdumpして固める。データは「dump/」以下に保存される。古いdumpの削除は管理系から

- -e ENV/--env=ENV：実行環境指定（デフォルトはdevelopment）

#### add_total.rb
未集計の新しい週データを集計する。
日付関係を未指定の場合、「最新の結果より新しい未集計日」を集計（古いデータは処理されない）

- -e ENV/--env=ENV：実行環境指定（デフォルトはdevelopment）
- -d DATE/--date=DATE：日付指定集計
- -f DATE/--from=DATE：この日移行全て（あるいはtoまで）のデータを集計
- -t DATE/--to=DATE：この日以前の全て（あるいはfromまで）のデータを集計

#### importer.rb
旧ROGvで移行用出力したデータをimportする。
データが置かれた「ディレクトリ」を引数で指定。
データが「/tmp/hoge/export/[date].txt」にあるとすると、
「rails r bin/app/importer.rb /tmp/hoge/export」と実行。
その後、add_totalで集計が必要。
なお、手動入力結果データは--dateオプションを指定すると読み込まれない。

- -e ENV/--env=ENV：実行環境指定（デフォルトはdevelopment）
- -d DATE/--date=DATE：指定日のみをimport（指定がなければディレクトリに存在する全て）


その他
---------------
- セキュリティに関してはかなりザル運用なので注意
 - クローズドで活用されることを前提にしているため
 - 万が一不正アクセスされても、被害は「ROでの優位性が損なわれる」レベルのため
- Basic認証をかけている以上、不正アクセスは犯罪です
- PASS等を他システムと共有することで起こるリスクはシステムの範囲外です


TODO
---------------
- 共有ファイルUpload（リプレイなど）
- dumpの外部送信（メール等）
- cookieにunion選択履歴を保存して選択できるように
- viewerを一から再構築（TEのも見られるように）
