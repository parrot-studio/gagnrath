Gagnrath - ROGv : Forts Watching System
===============

ChangeLog
---------------
### ver0.2b
- 修正：Rails4のバージョンをβ1からRC1に変更
- 修正：gemを更新
- 修正：Railsのメソッドと競合したメソッド名を変更
- 修正：結果の手動入力時、Situationも登録するように修正

### ver0.1b（ROGv:ver5.1からの変更点）

- アーキテクチャ関連
 - Ruby2.0.0以上専用に変更
 - PadrinoからRails4に変更
 - MongoDBからMariaDB(MySQL)に変更
 - データ構造を全面的に見直し
 - memcachedの使用が必須に

- 機能関連
 - 全体に高速化（アーキテクチャ・データ設計等の見直しによるもの）
 - デザインを微調整
 - Result周りの用語をわかりやすく整理（データ自体は同一）
 - 特定の日のコール回数を表示する機能を追加（"Result for Date"の先）
 - dump時にそのファイルをメールで送信する機能/設定を追加
 - 閲覧したギルド/勢力履歴から、ギルド選択する機能を追加（cookieを使用）
 - 管理系セッションが抱えていた問題点を修正
 - 旧ROGvからのデータimport機能を追加

- 設定関連
 - setting.yml / database.yml / mail.yml の3ファイルに分離
 - 内容の詳細はNOTE.mdを参照
