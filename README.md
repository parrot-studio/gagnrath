Gagnrath - ROGv : Forts Watching System
===============

Description
---------------
ROのGvGにおいて、「現状」を把握するためのシステム「ROGv」の新バージョンです。
見た目や機能はほぼ同じですが、一から設計し直しました。

- Ruby(2.0.0以上で1.9系は未対応)
- Rails4
- MariaDB（MySQLでも可）
- memcached（以前と違い必須）

Sample Site
---------------
http://ro.parrot-studio.com/rogvs/

Install
---------------
- git clone https://github.com/parrot-studio/gagnrath
- cd gagnrath
- vi config/setting.yml
- vi config/database.yml
- bundle
- rails s

EAQ(Expected Asked Questions)
---------------
### 前のROGvと何が違うのですか？

- アーキテクチャを一から見直し
- データ設計を一から見直し
- その結果高速に
- しかも管理も簡単に
 -なぜ最初からこうしなかったщ(ﾟДﾟщ)

### データはどこから持ってくるのですか？

https://github.com/parrot-studio/rogv_client

### 旧ROGvと互換性はありますか？

アーキテクチャが違うので直接の互換性はありませんが、データをexport/importして移動させることは可能です。
詳しくはNOTEを参照。

### "Gagnrath"とはなんと読みますか？

「がぐんらーず」です。数多くあるオーディンの別名で、「勝利を決める者」という意味です。
（正しくは"Gagnráðr"）

### そんな名前をつけて恥ずかしくないのですか？

中二的な名前で何が悪い( ﾟДﾟ)y─~~

ChangeLog
---------------
ChangeLog.md 参照

License
---------------
The MIT License

see LICENSE file for detail

Author
---------------
ぱろっと(@parrot_studio / parrot.studio.dev at gmail.com)
