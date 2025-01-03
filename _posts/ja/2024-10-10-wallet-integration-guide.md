---
title: "Bitcoin Core 28.0のポリシーを採用するウォレット用ガイド"
permalink: /ja/bitcoin-core-28-wallet-integration-guide/
name: 2024-10-10-bitcoin-core-28-wallet-integration-guide-ja
type: posts
layout: post
lang: ja
slug: 2024-10-10-bitcoin-core-28-wallet-integration-guide-ja

excerpt: >
  Bitcoin Core 28.0には新しいP2Pとmempoolポリシーの機能が含まれており、多くのウォレットやトランザクションタイプに有用です。
  この記事では、Gregory Sandersが機能のセットと、それらを個別もしくは一緒に使用する方法を紹介します。
---

{:.post-meta}
*[Gregory Sanders][]による*

[Bitcoin Core 28.0][bc 28.0]には新しいP2Pとmempoolポリシーの[機能][bc 28.0 release notes]が含まれており、
多くのウォレットやトランザクションタイプに有用です。この記事では、Gregory Sandersが機能のセットと、それらを個別もしくは一緒に使用する方法を紹介します。

## 1P1C（One Parent One Child）リレー

Bitcoin Core 28.0より前のバージョンでは、各トランザクションは、
ローカルノードのmempoolの動的最小手数料率を満たすか、超えなければ、mempoolに入ることができませんでした。
この値は、トランザクションの混雑状況によって上下し、支払いを伝搬するための変動する下限を作り出します。
これは、[代替][topic rbf]トランザクションに署名できず、
トランザクションを決済する際に将来の下限値がどうなるか予測しなければならない、
署名済みトランザクションを扱うウォレットにとって非常に困難なことです。
これは数分間でも十分困難ですが、数ヶ月単位では明らかに不可能です。

[パッケージリレー][topic package relay]は、
手数料の引き上げオプションなしでトランザクションがスタックするリスクを軽減するために、
ネットワークに長年求められてきた機能です。適切に開発され、ネットワーク上に広く展開されれば、
ウォレット開発者は関連トランザクションを介してトランザクションに手数料を持ち込むことができ、
手数料の低い祖先をmempoolに入れることができます。

Bitcoin Core 28.0では、1つの親と1つの子（「1P1C」）で構成される
パッケージ用のパッケージリレーの限定版が実装されました。1P1Cでは、mempoolの動的な最小手数料率に関係なく、
単一の子トランザクションと単純な[CPFP（Child Pays For Parent）][topic cpfp]による手数料の引き上げを使用して
単一の親トランザクションをmempoolに入れることができます。
子トランザクションに別の未承認の親トランザクションがある場合、これらのトランザクションは正常に伝播しません。
この制限により実装が大幅に簡素化され、[クラスターmempool][topic cluster mempool]などの他のmempoolの研究は、
多数のユースケースを対象にしながらも、粛々と継続できるようになりました。

トランザクションが[TRUCトランザクション][topic v3 transaction relay]（後述）でない限り、
すべてのトランザクションは1仮想byteあたり1 satoshiの*固定*の最小値を満たす必要があります。

この機能の最後の注意点は、このリリースの伝播の保証も制限されていることです。
Bitcoin Coreノードが十分に執拗な敵対者と接続されている場合、
彼らに親子トランザクションのペアの伝播を妨害される可能性があります。
パッケージリレーのさらなる強化は、進行中の[プロジェクト][package relay tracking issue]として継続しています。

一般的なパッケージリレーは将来の課題として残っており、
限定的なパッケージリレーとそのネットワーク上での展開から得られたデータによって方向付けられます。

以下は、regtest環境で1P1Cリレーをデモンストレーションするウォレットをセットアップするためのコマンドです:

```hack
bitcoin-cli -regtest createwallet test
{
  "name": "test"
}
```

```hack
# 自分宛の送金先アドレスを取得
bitcoin-cli -regtest -rpcwallet=test getnewaddress
bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3
```

```hack
# 「minrelay」以上の低手数料トランザクションを作成
bitcoin-cli -regtest -rpcwallet=test -generate 101
{
[
...
]
}

bitcoin-cli -regtest -rpcwallet=test listunspent
[
  {
    "txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b",
    "vout": 0,
    ...
    "amount": 50.00000000,
    ...
  }
]

# mempoolのminfeeとminrelayは同じで、この機能をより簡単にテストするために、
# TRUCトランザクションを使用して、1P1Cリレーを必要とする手数料0のトランザクションを可能にする。
# フルRBFも有効で、28.0ではデフォルトで有効。
bitcoin-cli -regtest getmempoolinfo
{
  "loaded": true,
  ...
  "mempoolminfee": 0.00001000,
  "minrelaytxfee": 0.00001000,
  ...
  “fullrbf”: true,
}

# まずv2トランザクションを作成し
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "50.00000000"}]'

02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# 先頭の02をTRUCのバージョン03に置き換え
03000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# 署名し、送信
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 03000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000
{
  "hex": "030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true
}

bitcoin-cli -regtest sendrawtransaction 030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

error code: -26
error message:
min relay fee not met, 0 < 110

# 単一のアウトプットを使用するパッケージリレーとCPFPが必要
bitcoin-cli -regtest decoderawtransaction 030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

{
  "txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
  "hash": "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
  "version": 3,
  "size": 191,
  "vsize": 110,
  ...
  "vout": [
    ...
    "scriptPubKey": {
      "hex": "001400991cdadccdf30cb5a04663b0371cb433a095b4",
    ...
}

# CPFPの手数料用のsatsを残しておく
bitcoin-cli -regtest createrawtransaction '[{"txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99994375"}]'
0200000001de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# 作成したトランザクションのTRUC版に署名し、1P1Cパケージとして送信
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 0300000001de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000 '[{"txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de", "vout": 0, "scriptPubKey": "001400991cdadccdf30cb5a04663b0371cb433a095b4", "amount": "50.00000000"}]'
{
  "hex": "03000000000101de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220685a6d76db97b2c27950f267b70d606f1864002ff6b4617cd2e29afd5ddfac83022037be8bb2ebe8194b4263f16a634e5c00a5f6c4eef0968d12994ed66dcf15b9ac0121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000",
  "complete": true
}

bitcoin-cli -regtest -rpcwallet=test submitpackage '["030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000", "03000000000101de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220685a6d76db97b2c27950f267b70d606f1864002ff6b4617cd2e29afd5ddfac83022037be8bb2ebe8194b4263f16a634e5c00a5f6c4eef0968d12994ed66dcf15b9ac0121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000"]'
{
  "package_msg": "success",
  "tx-results": {
    "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf": {
      "txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
      "vsize": 110,
      "fees": {
        "base": 0.00000000,
        "effective-feerate": 0.00025568,
        "effective-includes": [
          "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
          "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55"
        ]
      }
    },
    "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55": {
      "txid": "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de",
      "vsize": 110,
      "fees": {
        "base": 0.00005625,
        "effective-feerate": 0.00025568,
        "effective-includes": [
          "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
          "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55"
        ]
      }
    }
  },
  "replaced-transactions": [
  ]
}
```

親トランザクションがminrelay手数料率を下回っているにもかかわらず、
1P1Cパッケージは、vBあたり25.568 satsの実効手数料率でローカルのmempoolに入りました。成功です！

## TRUCトランザクション

v3トランザクションとしても知られているTRUC（Topologically Restricted Until Confirmation）トランザクションは、
トランザクションの堅牢なRBF（Replace-by-Fee）を可能にし、
手数料関連のトランザクション[Pinning][topic transaction pinning]や
パッケージ制限のPinningの両方を軽減することを目的とした、新しいオプトインの[mempoolポリシー][policy series]です。
その中心にある哲学は、 **多くの機能は、すべてのトランザクションに対しては実現不可能だが、
限定されたトポロジーを持つパッケージに対しては実装可能である**　というものです。
TRUCは、トポロジーの制限に加えて、このようなより強固なポリシーのセットにオプトインする方法を作り出します。

要するに、TRUCトランザクションはnVersionが3のトランザクションで、
トランザクションを最大10 kvBのシングルトンか、1 kvBを上限とする1つのTRUCのトランザクションの子に制限します。
TRUCトランザクションは未承認の非TRUCトランザクションを消費することはできず、その逆も同様です。
すべてのTRUCトランザクションは、[BIP125][]のシグナリングに関係なく、オプトインRBFとみなされます。
競合しない別のTRUCの子トランザクションが親TRUCトランザクションに追加された場合、
それは元の子トランザクションとの[競合][topic kindred rbf]として扱われ、
手数料率と総手数料額のチェックを含む通常のRBFの解決ルールが適用されます。

TRUCトランザクションは、その子トランザクションがパッケージ全体の手数料率を十分に引き上げる場合に限り、
手数料が0であることも許されます。

この限定されたトポロジーも、署名されたトランザクションのすべてのバージョンがTRUCであると仮定すると、
取引相手が何をしようと、1P1Cのリレーパラダイムにきれいに収まります。

TRUC支払いは置換可能であるため、取引者が少なくとも一部のインプットを所有していないトランザクションの場合、
二重使用が可能になります。言い換えると、ゼロ承認のTRUC支払いを受け取ることは、
非TRUCの支払いを受け取ることよりも安全ではありません。

## 1P1CトポロジーのパッケージRBF

1P1Cパッケージの親がmempool内の親と衝突することがあります。
これは、複数のバージョンの親トランザクションが事前署名されている場合に起こり得ます。
これまでは、新しい親トランザクションはRBFのみで考慮され、手数料が低すぎる場合は破棄されていました。

1P1CトポロジーのパッケージRBFでは、新しい子トランザクションもRBFのチェックの考慮対象に含まれるため、
ウォレット開発者は、どのバージョンのトランザクションがローカルのmempoolに到達したかに関わらず、
1P1CパッケージをP2Pネットワークを通じて確実に送信できます。

現在のところ、競合するトランザクションは、すべてシングルトンであるか、
または他の依存関係を持たない1P1Cトランザクションパッケージでなければなりません。
そうでない場合、置換は拒否されます。このようなクラスターはいくつでも競合させることができます。
これは、クラスターmempoolの結果として、将来のリリースで緩和される予定です。

実行中の1P1Cの例の続きで、今回は非TRUCトランザクションパッケージを使用して、
既存の1P1Cに対してパッケージRBFを実行します:

```hack
# 親子のTRUCペア
bitcoin-cli -regtest getrawmempool
[
  "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
  "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de"
]

# 新しいv2 1P1Cパッケージで親を二重使用する
# 親の手数料はminrelayを超えているものの、パッケージRBFするには不十分
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99999"}]'

02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# 署名し、送信（失敗）
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000
{
  "hex": "020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true
}

bitcoin-cli -regtest sendrawtransaction 020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

error code: -26
error message:
insufficient fee, rejecting replacement f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59, less fees than conflicting txs; 0.00001 < 0.00005625

# 子を介して新しいパッケージに手数料を追加し、古いパッケージに勝つ
bitcoin-cli -regtest createrawtransaction '[{"txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99234375"}]'

020000000159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# 署名し、パッケージとして送信
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 020000000159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000 '[{"txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59", "vout": 0, "scriptPubKey": "001400991cdadccdf30cb5a04663b0371cb433a095b4", "amount": "49.99999"}]'
{
  "hex": "0200000000010159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402205d086fa617bdbf5a3df3a15cc9a927ad884c714d46d9ef6762ad2fa6a259740c022032c60b4fe5d533d990489c27dc3283d8b3999b97f6c12986ac8159b92cb6de820121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000",
  "complete": true
}

bitcoin-cli -regtest -rpcwallet=test submitpackage '["020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000", "0200000000010159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402205d086fa617bdbf5a3df3a15cc9a927ad884c714d46d9ef6762ad2fa6a259740c022032c60b4fe5d533d990489c27dc3283d8b3999b97f6c12986ac8159b92cb6de820121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000"]'
{
  "package_msg": "success",
  "tx-results": {
    "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313": {
      "txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59",
      "vsize": 110,
      "fees": {
        "base": 0.00001000,
        "effective-feerate": 0.03480113,
        "effective-includes": [
          "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313",
          "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c"
        ]
      }
    },
    "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c": {
      "txid": "858fe07b01bc7c1c1dda50ba16a33b164c0bc03d0eff8f9546558c088e087f60",
      "vsize": 110,
      "fees": {
        "base": 0.00764625,
        "effective-feerate": 0.03480113,
        "effective-includes": [
          "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313",
          "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c"
        ]
      }
    }
  },
  "replaced-transactions": [
    "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
    "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de"
  ]
}

```

## Pay To Anchor (P2A)

[アンカー][topic anchor outputs]は、
子トランザクションがそのトランザクションをCPFPできるようにするためだけに追加されるアウトプットのことです。
これらのアウトプットは支払いではないため、satoshiの額は低く、「ダスト」に近く、すぐに使用されます。

新しいアウトプットスクリプトタイプ[Pay To Anchor (P2A)][topic ephemeral anchors]が追加され、
アンカーの最適化された「キーレス」バージョンが可能になりました。
このアウトプットスクリプトは「OP_1 <4e73>」で、使用するのにwitnessデータを必要としないため、
既存のアンカーアウトプットと比べて手数料が削減されます。また、誰でもCPFPトランザクションを作成できます。

P2Aは、TRUCトランザクションや1P1Cとは独立して使用できます。
P2Aアウトプットがあるものの子を持たないトランザクションはブロードキャストできますが、
そのP2Aアウトプットは簡単に使用できます。同様に、パッケージとTRUCトランザクションは、
新しい手数料引き上げ機能を使用するためにP2Aアウトプットを持つ必要はありません。

この新しいアウトプットタイプには、240 satoshiのダスト制限があります。
このダストを下回るP2Aアウトプットは、たとえパッケージで使用されたとしても、伝播されません。
これは、[ダスト][topic uneconomical outputs]制限がポリシーで強制されているためです。
この提案は、以前はエフェメラルダストと関連付けられていましたが、現在はそうではありません。

P2Aの作成と使用の例:

```hack
# P2Aアドレスは、regtestでは「bcrt1pfeesnyr2tx」、mainnetでは“bc1pfeessrawgf”
bitcoin-cli -regtest getaddressinfo bcrt1pfeesnyr2tx
{
  "address": "bcrt1pfeesnyr2tx",
  "scriptPubKey": "51024e73",
  "ismine": false,
  "solvable": false,
  "iswatchonly": false,
  "isscript": true,
  "iswitness": true,
  "ischange": false,
  "labels": [
  ]
}

# Segwitアウトプット、タイプは「anchor」
bitcoin-cli -regtest decodescript 51024e73
{
  "asm": "1 29518",
  "desc": "addr(bcrt1pfeesnyr2tx)#swxgse0y",
  "address": "bcrt1pfeesnyr2tx",
  "type": "anchor"
}

# 最小額のP2WPKHアウトプットとP2Aアウトプットを持つトランザクションの作成
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "0.00000294"}, {"bcrt1pfeesnyr2tx": "0.00000240"}]'
02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7300000000

# P2Aアウトプットを持つトランザクションに署名し
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7300000000
{
  "hex": "020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7302473044022002c7e756b15135a3c0a061df893a857b42572fd816e41d3768511437baaeee4102200c51fcce1e5afd69a28c2d48a74fd5e58b280b7aa2f967460673f6959ab565e80121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true

# 手数料チェックをオフにして送信
bitcoin-cli -regtest -rpcwallet=test sendrawtransaction 020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7302473044022002c7e756b15135a3c0a061df893a857b42572fd816e41d3768511437baaeee4102200c51fcce1e5afd69a28c2d48a74fd5e58b280b7aa2f967460673f6959ab565e80121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000 "0"
fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b

# 以前のパッケージを置き換える
bitcoin-cli -regtest getrawmempool
[
  "fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b"
]

# 子については、金額をすべて手数料にし、tx-size-smallエラーを回避するためOP_RETURNを持つ65 vbyteのトランザクションを作成
bitcoin-cli -regtest createrawtransaction '[{"txid": "fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b", "vout": 1}]' '[{"data": "feeeee"}]'
02000000014b421aa4622233390cdb87ea39e91760e69eeb10db4222e31cf354536a3beefd0100000000fdffffff010000000000000000056a03feeeee00000000

# 署名は不要; witnessが不要なsegwit
bitcoin-cli -regtest -rpcwallet=test sendrawtransaction 02000000014b421aa4622233390cdb87ea39e91760e69eeb10db4222e31cf354536a3beefd0100000000fdffffff010000000000000000056a03feeeee00000000
8d092b61ef3c1a58c24915671b91fbc6a89962912264afabc071a4dbfd1a484e

```

## ユーザーストリー

より一般的なリリースノートレベル機能の説明から移って、いくつかの一般的なウォレットのパターンと、
ウォレットが積極的に変更を加えるかどうかに関わらず、これらのアップデートからどのようなメリットが得られるか説明します。

### シンプルな支払い

ユーザーが直面する問題の1つは、ビットコインの受取人が支払いから任意のトランザクションチェーンを作り、
ユーザーをPinningすることができないという確信をもってRBFを行えないことです。
ユーザーがより予測可能なRBF動作を望む場合、1つの方法はTRUCトランザクションをオプトインすることでしょう。
また、入金のアウトプットを1 kvB以内で使用することで、入金の手数料を確実に引き上げることも可能です。

採用する場合、ウォレットは:

- バージョンを3に設定する
- 承認済みのアウトプットのみ使用する
- 10 kvB以内に抑える（非TRUCの100 kvBの制限とは対照的）
  - この制限された状況でも、より大きなバッチ支払いをサポートします。
  - ウォレットが未承認のインプットを使用するしかない場合、そのインプットはTRUCトランザクションでなければならず、
    この新しいトランザクションは1 kvB以下である必要があります。

### Coinjoin

プライバシーが重視されているものの[Coinjoin][topic coinjoin]を秘密裏に行おうとしないCoinjoinのシナリオでは、
Coinjoin自体にTRUCトランザクションを適用する価値があるかもしれません。
Coinjoinは、ブロックチェーンに格納するのに十分な手数料率を持たない可能性があり、
手数料の引き上げが必要になる場合があります。

TRUCトランザクションと共に、P2Aアウトプットを追加することで、
ウォッチタワーのような分離されたウォレットがトランザクション手数料のみを支払うことが可能になります。

他の参加者が未承認のアウトプットを使用した場合、TRUCによる兄弟の排除が発生する可能性があります。
兄弟の排除は、TRUCのトポロジー制限を維持しつつ、より高い手数料率のCPFPの追加を可能にします。
新しい子トランザクションは、競合するインプットを使用せずに前のトランザクションを「置換」することができます。
これにより、Coinjoinの全参加者は常にトランザクションにCPFPを適用できます。

Pinningに関する注意点: Coinjoinの参加者は、自身のインプットを二重使用することで、
トランザクションに経済的な妨害を行う可能性があります。これにより、
Coinjoinは妨害者の最初のトランザクションをRBFで置換する必要があります。

### ライトニングネットワーク

ライトニングネットワークプロトコルで生成されるトランザクションは、主に以下の種類で構成されます:

1. ファンディングトランザクション: コントラクトをセットアップするため1人もしくは両者によって資金提供されます。
承認に対する時間的な制約は比較的少ない。
2. コミットメントトランザクション: ペイメントチャネルの最新の状態にコミットするトランザクション。
これらのトランザクションは非対称で、現在は、ファンディングアウトプットの内どれだけを手数料に充てるかを更新するのに
双方向の「update_fee」メッセージが必要です。手数料は最新バージョンのコミットメントトランザクションを
マイナーのmempoolに伝播させるのに十分な額である必要があります。
3. HTLC事前署名トランザクション

1P1CリレーとパッケージRBFにより、Bitcoin Coreノードをアップグレードすることで、
ライトニングネットワークのセキュリティが大幅に向上します。ライトニングの一方的なチャネル閉鎖は、
mempoolのminfee手数料率を下回る手数料のコミットメントトランザクションや、
ブロックに速やかに格納されない別の低手数料のコミットメントトランザクションパッケージと競合するもので実現できます。

このアップグレードを最大限に活用するために、ウォレットやバックエンドは、
Bitcoin CoreのRPCコマンド**submitpackage**と統合する必要があります:

```hack
bitcoin-cli submitpackage ‘[“<commitment_tx_hex>”, “<anchor_spend_hex>”]’
```

ウォレット実装は、コミットメントトランザクションとアンカー子トランザクションの支払により、
適切な手数料率でマイナーのmempoolに確実に取り込まれるようにするために、
このコマンドとソフトウェアを統合する必要があります。

注意: RPCエンドポイントは、単一の親と多数の子からなるパッケージを送信した場合でも成功を返しますが、
これらは1P1Cリレーのアップデート下では伝播しません。

ネットワーク上で十分な数のノードがアップグレードされた後、LNプロトコルが更新され、
「update_fee」メッセージが削除される可能性があります。このメッセージは、
これまで何年も手数料の急上昇時に不要な強制閉鎖の原因となっていました。
このプロトコルメッセージを削除すると、コミットメントトランザクションの手数料率を
固定の1 sat/vbyteに設定することができます。TRUCトランザクションを使用すると、
アンカーの使用を伴う競合するコミットメントトランザクションがネットワーク上で互いにRBFを実行でき、
同じコミットメントトランザクションから競合するアウトプットの使用がある場合、
どのアウトプットが使用されていてもRBFが発生することを保証できます。
TRUCトランザクションの手数料は0も許可されるため、仕様の複雑さを軽減することができます。
TRUCの兄弟の排除により、各参加者が1つのアウトプットを自分で使用できる限り、
未承認のアウトプットが使用されることを過度に心配する必要がなくなるため、
1ブロックのCSVタイムロックも削除できます。

TRUC + P2Aアンカーにより、現在の2つのアンカーによるブロックスペースの使用量を、
1つキーレスアンカーに削減できます。このアンカーは、公開鍵や署名へのコミットメントを必要とせず、
ブロックスペースを節約します。手数料の引き上げも、特権的な鍵情報を持たない他のエージェントにアウトソースできます。
アンカーは、P2Aの代わりに、取引相手間で共有される鍵情報を持つ単一のアウトプットで構成することもできますが、
一方的な閉鎖の場合、追加のvbyteがかかります。

スプライシングのような高度な機能を実装する際にも、同様の戦略を採用してRBF Pinningのリスクを軽減できます。
たとえば、サイズが1 kvB未満のTRUCチャネルのスプライシングは、手数料の引き上げをRBFのPinningにさらすことなく、
別のチャネルの一方的な閉鎖をCPFPできます。その後の手数料の引き上げは、
チャネルのスプライシングトランザクションだけを置換することで連続的に行うことができます。
これは、スプライシング中にTRUCトランザクションタイプを明らかにするという代償を伴います。

ご覧のとおり、各トランザクションが1P1Cパラダイムに適合できれば、
更新された機能により大幅な複雑さの回避と節約を実現できます。

### Ark

すべてのトランザクションパターンが1P1Cパラダイムに適合するわけではありません。
この代表的な例が[Ark][topic ark]アウトプットです。これは、共有UTXOを展開するための
事前署名（またはコベナンツでコミットメントされた）トランザクションのツリーにコミットします。

ASP（Ark Service Provider）がオフラインになるか、トランザクションを処理する場合、
ユーザーは一方的な退出を選択できます。これには、
ユーザーがトランザクションツリー内の自分のブランチの位置を展開するための一連のトランザクションを提出することが含まれ、
O(logn)のトランザクションが必要になります。他のクライアントもツリーから離脱しようとしている場合、
mempoolのチェーン制限を超えたり、
ブロックにタイムリーに格納するためには手数料が不十分な競合トランザクションを作成したりすると、
問題が発生する可能性があります。特に長い時間が経過しても取り込まれない場合、
ASPがすべての資金を一方的に回収できるため、ユーザーの資金損失につながります。

理想的には、Arkツリーの一方的な閉鎖は以下のようになります:

1. ベースとなる仮想UTXO（vUTXO）へのマークルブランチ全体の公開
2. これらのトランザクションはすべて手数料0とし、手数料予測や誰が事前に手数料を支払うか決定する必要性を回避する
3. 最終的なリーフトランザクションが0値のアンカーを使用し、CPFPで
マイナーのmempoolにマークツリー全体の公開とブロックに格納するための手数料を支払う

この理想を適切に実行するためには、いくつか不足しているものがあります:

1. 一般的なパッケージリレー。現在これらの手数料のないトランザクションチェーンを
P2Pネットワーク上で確実に伝播する方法はありません。
2. 低手数料率で多くのブランチが公開されると、子孫数の制限によるPinningにより
ユーザーが自身のブランチを迅速に公開できなくなる可能性があります。これは、
理想化されたArkシナリオのように、取引相手の数が多くなると壊滅的な結果をもたらす可能性があります。
3. 一般的な兄弟の排除が必要です。金額なしのアンカー用の0値アウトプットのサポートがありません。

代わりに、追加の手数料を犠牲にして、必要なトランザクション構造を可能な限り1P1Cパラダイムに適合させてみましょう。
ルートから始まるすべてのArkツリートランザクションはTRUCトランザクションとし、
最小のsatoshiの額のP2Aアウトプットを追加します。

Arkからの一方的な退出を選択した場合、ユーザーはルートトランザクションと、手数料のためにP2Aを使用し、
承認を待ちます。承認後、ユーザーはマークルブランチ内の次のトランザクションを、
CPFPのために使用される独自のP2Aと共に送信します。これは、マークルブランチ全体が公開され、
資金がArkツリーから安全に抽出されるまで続きます。同じArkの他のユーザーが悪意を持って、もしくは偶然に、
同じ内部ノードトランザクションを低すぎる手数料率で送信する可能性がありますが、兄弟の排除により、
1 kvB未満の正直な子トランザクションは、他のすべてのアウトプットをロックしたり、
複数のアンカーを必要したりすることなく、競合する子をRBFできることが保証されます。

二分木を仮定すると、これは理想化されたArkに対して、最初のユーザーについてほぼ100% vbyteのオーバーヘッドコストがかかり、
ツリー全体が展開された場合は約50%のオーバーヘッドがかかります。四分木の場合、これはツリー全体で約25%に減少します。

### LNスプライシング

他のトポロジーも、より高度なライトニングネットワークの構造で出現し、
1P1Cリレーに適合するには若干の作業が必要かもしれません。

ライトニングネットワークの[スプライシング][topic splicing]は新たな標準で、既に一般的に使用されています。
各スプライシングは、元のファンディングアウトプットを使用して、新しいファンディングアウトプットに再デポジットし、
以前と同じ事前署名されたコミットメントトランザクションチェーンを持ちます。
未承認の間は、元のチャネル状態と新しいチャネル状態が同時に署名され、追跡されます。

1P1Cパラダイムを超える例として、以下のようなケースがあります:

1. アリスとボブがチャネルに資金を提供します。
2. アリスはキャロルが管理するオンチェーンアドレスにいくらかの資金をスプライスアウトします。
キャロルはコールドな鍵セットを使用しているためCPFPできません。このスプライスアウトは数時間以内の承認を目指しています。
3. ボブのノードがオフラインになるか、何らかの理由で強制閉鎖します。
4. （おそらくトークンのローンチにより）手数料率が急騰し、スプライスアウトトランザクションの承認が遅延します。

アリスは、キャロルへのオンチェーン支払いが行われることを望んでいるため、
スプライシングされないコミットメントトランザクションがオンチェーンに行かないようにします。
つまり、splice_tx->commitment_tx->anchor_spendが、伝播に必要なパッケージになることを意味します。

代わりに、不要な場合にvbyteを無駄にすることなく、1P1Cパラダイムに適合させる方法を考えてみましょう。
LNウォレットは、オンチェーン支払い毎に1つのスプライスアウトを実行する代わりに、
競合する2つのスプライスアウトを実行することができます。1つのバージョンは、
手数料推定により選択された比較的保守的な手数料率を使用します。もう1つのバージョンは、
240 satoshiの（将来的には[エフェメラルダスト][topic ephemeral anchors]により0 satoshi）P2Aアウトプットを含むことができます。

まず、アンカーのないスプライスアウトをブロードキャストします。

手数料イベントが起きない場合、それは承認され、アリスは必要に応じて通常どおり強制閉鎖を続行できます。

最初のスプライスアウトが長くかかるような手数料イベントが起きた場合は、
アンカーの使用と共にアンカー付きの1P1Cスプライスをブロードキャストし、パッケージRBFを使用して
最初のスプライスアウトを置換します。この手数料の引き上げにより承認とキャロルへの支払いが可能になり、
必要に応じて強制閉鎖を続行できます。

スプライスアウトのコピーをさまざまな手数料レベルでさらに発行することもできますが、
各コピーには、コミットメントトランザクションとすべての未処理のオファーされたHTLCに対する
追加の署名セットが必要になることに注意してください。

{% include references.md %}

[Gregory Sanders]: https://github.com/instagibbs
[bc 28.0]: https://github.com/bitcoin/bitcoin/releases/tag/v28.0
[bc 28.0 release notes]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-28.0.md
[package relay tracking issue]: https://github.com/bitcoin/bitcoin/issues/27463
[policy series]: /ja/blog/waiting-for-confirmation/
