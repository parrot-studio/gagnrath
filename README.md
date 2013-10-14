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
- http://ro.parrot-studio.com/rogvs/
- http://ro.parrot-studio.com/kafragarten/

Install
---------------
- git clone https://github.com/parrot-studio/gagnrath
- cd gagnrath
- vi config/setting.yml
- (DB setting)
- vi config/database.yml
- (vi config/mail.yml)
- bundle
- rake db:migrate
- rails s

EAQ(Expected Asked Questions)
---------------
### 前のROGvと何が違うのですか？

- アーキテクチャを一から見直し
- データ設計を一から見直し
- その結果高速に
- しかも管理も簡単に
 - なぜ最初からこうしなかったщ(ﾟДﾟщ)

### データはどこから持ってくるのですか？

https://github.com/parrot-studio/rogv_client

### 旧ROGvと互換性はありますか？

https://github.com/parrot-studio/rogv_server

アーキテクチャが違うので直接の互換性はありませんが、データをexport/importして移動させることは可能です。
詳しくはNOTEを参照。

### Ruby1.9系では動かないのですか？

キーワード引数等、2.0の機能を使っているので、1.9系ではエラーになります。
高速化の恩恵も薄くなるので、1.9系に対応する予定はありません。

### 「View Mode」とはなんですか？

データの更新はできないが、データの閲覧はできる状態を指します。

例えば、自ギルド用のAという環境があったとして、
同盟先にはデータの閲覧だけ許可したい場合、
AのDBのみを共有した、Bという閲覧専用環境を立てることが可能です。

同盟が切れたとしても、Bの環境を破棄するだけで、
自ギルドメンバーは引き続きAを使い続けることができます。

### β版のうちは使いたくありませんが、1.0はいつリリースされますか？

Rail4（およびその関連gem）が正式リリースされ、対応が完了したら1.0になります。

beta1とrc1でも結構な差があり、細かい修正が多発しているため、
気になる場合は少なくともRails4リリース版をお待ちください。
ただし、現時点でも十分運用できています。

（ver0.4b）Rails4正式版がリリースされたため、とりあえず単純に適用しました。
しばらく運用し、バグがないかを確認してからver1.0となる予定です。

(ver1.0)リリースしました。

### "Gagnrath"とはなんと読みますか？

「がぐんらーず」です。数多くあるオーディンの別名の一つで、「勝利を決める者」という意味です。
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
