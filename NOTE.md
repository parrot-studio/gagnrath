READMEには書きたくないが、一応まとめないと困る何か
===============

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


#### サンプルモード（sample\_mode:true / time_lock:false）
- サンプル環境用モード
- http://ro.parrot-studio.com/rogvs/ で公開するためのモード

 - Basic認証：無効
 - クライアントからの更新：不能
 - 管理系の利用：不能
 - 宣伝フッタ：表示
 - Gv時間中の閲覧：可能

#### 時間制限付きサンプルモード（sample\_mode:true / time_lock:true）
- サンプルデータの閲覧をGv前後だけ制限するモード
- サンプル公開用に本番データを使っているので、Gv時間に見せたくない場合等に使用
- development環境においては時間と無関係に、configだけで判断して適用される

 - Basic認証：無効
 - クライアントからの更新：不能
 - 管理系の利用：不能
 - 宣伝フッタ：表示
 - Gv時間中の閲覧：不可能（development環境では常に不可能）

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
 - app\_path : サーバroot以外に設置した場合、そのpathを記述（例：/sample）
 - secret\_key\_base : Railsのセッション生成に使われる文字列。"rake secret"を実行して文字列を生成
 - server\_name : RO的な意味でのサーバ名。表示にのみ使用
 - gvtype: "FE"を指定するとFE/SEモード、"TE"を指定するとTEモードで動作
 - sample\_mode view\_mode : モード説明参照
 - time\_lock : サンプルの閲覧をGv時間中だけ遮断するかしないか。サンプルモード以外では適用されない
 - attention\_minitues : 砦viewで強調表示するためのuptime。現在交戦中の可能性が高い場所を区別
 - data\_size/recently : 集計で「最近のn週」のnに入る値
 - data\_size/min\_size data\_size/max\_size : 集計表示の最小/最大データ数。負荷を考えて指定
 - timeline/span\_max\_size : 期間タイムラインにおいて指定可能な最大データ数。負荷を考えて指定
 - use\_mail : メール送信を使用するかの設定。mail.ymlの設定が必須
 - union\_history/max\_size : ギルド/勢力履歴の最大サイズ。大きくしすぎるとcookieに収まらない（4KB制限）
 - union\_history/only\_union : ギルド/勢力履歴で複数ギルドのみを格納するか。falseだと単体ギルドも履歴に含む
 - dump\_generation : バックアップ世代数。1以上の場合、その数だけバックアップファイルを保持し、残りを削除する
- memcache : memcachedへの接続情報
 - server : memcachedのサーバ（例：localhost:11211）
 - header : memcached上の名前空間。同じものを指定するとキャッシュが混在する
 - expire : キャッシュ有効時間（分）
- auth : 認証情報
 - basic : Basic認証情報。ページアクセスそのものを制御
 - admin : 管理ページ用認証情報
 - update_key : サーバ更新用key。Basic認証のIDとは別の長いものを設定する（※平文で扱われるので注意）
 - delete_key : データを削除するためのkey（※平文で扱われるので注意）


config/mail.yml
---------------
#### 概要
- setting.ymlで「use\_mail:true」の場合のみ設定必須
- YAML形式で記述
- デフォルトでGmailを利用する場合の設定を記述済み
 - user\_name : 自分のGmailアドレスを記述
 - password : 自分のGmailパスワードを記述（二段階認証の場合はアプリケーションPASS）
 - admin/from admin/to : 自分のGmailアドレスを記述
- bin/app/mail_env_test.rbで動作確認可能
 - メールが届けばOK
- 詳しくはRailsの説明参照 http://guides.rubyonrails.org/action_mailer_basics.html
- それでもわからなければメール機能は使わない方が

#### 詳細
- delivery_method : smtp / sendmail / test から選択
- smtp_settings : smtpを指定した場合の設定項目。それ以外の場合は項目自体が不要
- sendmail_settings : sendmailを指定した場合の設定項目。それ以外の場合は項目自体が不要
- admin/from admin/to : 送信元・送信先メールアドレス。通常は両方とも管理者のメールアドレス


config/viewer.yml
---------------
設定不要。旧rogv_viewerへの転送に使用。後日削除予定


スクリプト（bin/app/以下）
---------------
#### 概要
- cronで各種処理を実行するためのもの
- 「rails r」コマンドで実行する
 - "rails r bin/app/mail_env_test.rb -e production" 等
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

#### mail_env_test.rb
テストメールを送信する。設定の確認に使用

- -e ENV/--env=ENV：実行環境指定（デフォルトはdevelopment）


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
- viewerを一から再構築（TEのも見られるように）
- dumpが一定数を超えたら古いものから削除
