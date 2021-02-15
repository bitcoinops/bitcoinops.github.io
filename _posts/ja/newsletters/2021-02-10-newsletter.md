---
title: 'Bitcoin Optech Newsletter #135'
permalink: /ja/newsletters/2021/02/10/
name: 2021-02-10-newsletter-ja
slug: 2021-02-10-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、先週のTaprootのアクティベーションミーティングの要約へのリンクと、
来週に予定されている次のミーティングの告知、さらに最近のDiscreet Log Contractsの進捗状況と、
それを議論するための新しいメーリングリストについて説明します。また、Bitcoin Core PR Review Club
のミーティングの要約、リリースとリリース候補の説明および人気のBitcoinインフラストラクチャソフトウェアの
注目すべき変更点のリストなどの通常のセクションも掲載しています。

## ニュース

- **Taprootのアクティベーションミーティングの要約とフォローアップ:**
  Michael Folksonは、Taprootのアクティベーション方法について議論するために予定されていたミーティング
  （[ニュースレター #133][news133 taproot meeting]参照）の[要約][folkson1]を投稿しました。
  参加者の間では、アクティベーションコードを含むBitcoin Coreの最初のリリースから最速で約２ヶ月後にアクティベーションされ、
  最も遅いアクティベーションは最初のデプロイメントから約１年後とする[BIP8][]アクティベーション方式が支持されているようでした。

  より議論を呼んだのは、`LockinOnTimeout` (LOT) パラメーターのデフォルトを*true*にするか
  （マイナーは最終的に新しいルールを支持するシグナルを出すか、チェーン分岐のリスクを冒すかのどちらかを要求されます）、
  *false*にするか（マイナーはすぐに結論を出す必要がなく、好きなようにシグナルを送ることができ、
  一部のユーザーは後から`LOT=true`を有効にすることができます）ということでした。
  Folksonは、メーリングリストに[２つめの投稿][folkson2]を行い、２つの異なるオプションについてみられた議論の要約と、
  それら（およびあまり議論の余地のない問題）について議論するためのフォローアップミーティングを2月16日19:00 UTCから
  Freenodeの##taproot-activationチャンネルで開催することを発表しました。

- **Discreet Log Contractsの新しいメーリングリスト:**
  Nadav Kohenは、Discreet Log Contracts (DLC)に関連するトピックを議論するための
  [新しいメーリングリスト][dlc list]の作成を[発表しました][kohen post]。
  彼はまた、複数の互換性のある実装、ECDSA[アダプター署名][topic adaptor signatures]の使用や、
  数値の結果を条件とするDLCに対する効果的な圧縮アルゴリズム、"オラクル間である程度の制限のある差異が許可される数値のケースもサポートする"
  オラクルからのk-fo-nしきい値署名のサポートなど、DLCの開発の現状を要約しました。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Only support compact blocks with witnesses][review club #20799]は、
[BIP152][] Compact Blockの[非Segwitバージョンのサポートの削除][nonsegwit]を提案する
John NewberyのPR（[#20799][Bitcoin Core #20799]）です。

Review Clubの議論では、コードの変更に飛び込む前に、Compact Block、高帯域幅モードと低帯域幅モードおよび
バージョン管理と互換性の理解に焦点が当てられました。

{% include functions/details-list.md
  q0="<!--q0-->Compact Blockとは？"
  a0="[BIP152][]で定義されているCompact Blockは、BitcoinのP2Pネットワークネットワークを介して、
     帯域幅の使用量を抑えてブロックを中継する方法です。それは、トランザクションの伝播中に、
     ピアが受信したブロックに含まれるほとんどのトランザクションを既に知っているという事実を利用しています。
     Compact Blockは、高帯域幅モードもしくは低帯域幅モードで中継することができます。
     高帯域幅モードで中継する場合、Compact Blockはブロックの伝播を高速化することもできます。"

  q1="<!--q1-->Compact Blockを機能させるために必要なことは何ですか？"
  a1="受信者はブロックに含まれる可能性が高いトランザクションを含むmempoolを持っていなければなりません。
     そのため、Compact Blockはブロックチェーンの先端もしくはその近くのブロックを中継する場合にのみ有用です。
     古いブロックの場合、受信者はmempoolにトランザクションを持っておらず`getblocktxn`メッセージを使ってそれらを要求する必要があります。
     このようなケースでは、ブロック全体を要求するだけの方が効率的です。"

  q2="<!--q2-->Compact Blocksはどうやって帯域幅を節約しているのですか？"

  a2="完全なトランザクションIDの代わりに、Compact Blockには、
     サイズは小さくともトランザクションを一意に識別するのに十分な短縮IDが含まれています。
     Compact Blockを受信したノードは、各短縮IDをmempool内のトランザクションと一致させて完全なブロックを再構築します。
     これによりブロックリレーの帯域幅が大幅に削減されます。"

  a2link="https://bitcoincore.reviews/20799#l-90"

  q3="<!--q3-->\"高帯域幅\"モードと\"低帯域幅\"モードの違いは何ですか？"

  a3="高帯域幅モードでは、Compact Blockは一方的に送信され、より高い帯域幅を使ってレイテンシーを向上させます。
     一方、低帯域幅モードでは、`inv`メッセージまたは`headers`メッセージを受信後に要求に応じて送信されます。
     高帯域幅モードでは、完全な検証の前にCompact Blockメッセージを中継することができ、
     中継する前にブロックヘッダーが有効である必要があるだけです。"

  a3link="https://bitcoincore.reviews/20799#l-156"

  q4="<!--q4-->高帯域幅モードのピアをどうやって選択するのでしょうか？"
  a4="最近、新しい有効なブロックを送信したピアを[最大３つ][three]選択します。
     このロジックはnet processing関数`MaybeSetPeerAsAnnouncingHeaderAndIDs`にあります。"
  a4link="https://bitcoincore.reviews/20799#l-219"

  q5="<!--q5-->なぜバージョン１のCompact Blockのサポートをやめることができるのでしょうか？"

  a5="BIP152は、バージョン１（witnessなし）とバージョン２（witnessあり）の２つのバージョンをサポートしています。
     バージョン２はSegwitブロックの再構築に必要です。Segwitは2017年8月にアクティベーションされたため、
     ピアにバージョン１のSegwit前のCompact Blockを提供することはもはや有用ではありません。
     witnessがないと、ピアはブロックがコンセンサスルールに従っていることを検証することができません。"

  a5link="https://bitcoincore.reviews/20799#l-104"

  q6="<!--q6-->実際、バージョン１のサポートをどうやってやめることができるのでしょうか？"
  a6="バージョン１の`sendcmpct`メッセージを無視し、バージョン１のサポートを示す`sendcmpct`を送信しないようにし、
     `NODE_WITNESS`ピアへの`sendcmpct`メッセージの送信のみを行い、`sendcmpct`メッセージおよび`blocktxn`
     メッセージには、witnessシリアライズされたブロックおよびトランザクションで応答するようにします。"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.12.1-beta.rc1][]は、LNDのメンテナンスリリースのリリース候補です。
  誤ってチャネルが閉鎖される可能性があるエッジケースと、一部の支払いが不必要に失敗する可能性があるバグの修正に加えて、
  いくつかのマイナーな改善とバグ修正が行われています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、
[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #19509][]では、ノード間のピア毎のメッセージのキャプチャと、それらのログからJSON出力を生成する機能が追加されています。
  新しく導入されたコマンドライン引数`-capturemessages`を使用すると、ノードが送受信する全てのメッセージがログに記録されます。
  同様の機能を持つツールは[長い歴史][bitcoin dissector]がありますが、今回の追加により、
  あまり積極的にメンテナンスされていないオプションに代わるネイティブな選択肢が提供されます。

- [Bitcoin Core #20764][]では、`bitcoin-cli -netinfo`を使って生成される出力に追加情報が追加されました。
  新しい詳細情報には、ピアの種類（フルリレーやブロックオンリーなど）、手動で追加されたピアの数、
  [BIP152][]"高帯域幅"（高速）ブロックリレーモードを使用しているピア、
  [I2P][]匿名ネットワーク（[別のPR][bitcoin core #20685]で作業中）を使用しているピアなどが含まれます。

- [Rust-Lightning #774][]では、Bitcoin CoreのRESTおよびRPCインターフェースからブロックとヘッダーをフェッチするサポートが追加されています。
  さらに、`BlockSource`インターフェースが追加され、カスタムソースで動作するよう拡張することができます。

- [HWI #433][]は、OP_RETURNアウトプットを持つPSBTへの署名のサポートを追加しています。

- [BIPs #1021][]では、[BIP8][]ソフトフォークアクティベーション方式が更新され、
  *lockin on timeout*機能の強制を選択したノードの動作が変更されました。
  以前は、強制的なアクティベーション期間中にアクティベーションのシグナルを出さなかったブロックは、ノードによって拒否されていました。
  この変更後は、アクティベーションを保証するのが可能な最大数まで非シグナリングブロックを許容するようになりました。
  これにより不必要に拒否される可能性のあるブロックの数が減り、マイナーとノードオペレータ間の誤通信の可能性が減ります。

- [BIPs #1020][]は、[最近追加された][BIPs #950]*Must Signal*期間に必要なシグナリングを使って
  アクティベーションを保証できるようになったため、*Locked In*期間中のシグナリングを不要とするようBIP8を更新しました。

- [BIPs #1048][]では、数週間前にメーリングリストで提案された（[ニュースレター#130][news130 bip322]参照）
  [generic message signing][topic generic signmessage]のための[BIP322][]の提案の大部分を書き換えました。
  この変更により、完全なチェックセットを実装していないウォレットは、理解できないスクリプトを使用する署名に対して、
  "不確定"の状態を返すことができるようになりました。また、実装手順を明確にし、署名のシリアライゼーションに不要なデータを削除しています。

- [BIPs #1056][]では、以前メーリングリストで議論されていた（[ニュースレター#131][news131 bech32m]参照）
  bech32の変更された仕様（bech32m）である[BIP350][]を追加しています。
  [BIP173][]の[bech32][topic bech32]アドレスのこの修正版は、計画されているTaprootのアドレスと、
  Segwitのwitness scriptを使用する今後の改善に適用されます。

- [BIPs #988][]では、 空のインプットフィールドを初期化する既存の要件と同様に、
  *Creator*ロールで動作するプログラムが空のアウトプットフィールドを初期化するよう[PSBT][topic psbt]の仕様[BIP174][]を更新しています。
  Bitcoin Coreのような既存のPSBT Creatorは既にこれを行っています。

- [BIPs #1055][]は、独自仕様の拡張の形式を明確にするため[BIP174][]を更新し、
  フィールドの表を異なるバージョンのPSBTでどのように適用されるかを示す行で拡張し、
  PSBTのオリジナルバージョン 0についてBIPをFinalとしてマークします。

- [BIPs #1040][]では、親の[BIP32][]キーチェーンから、鍵とキーチェーンを作成するための仕様[BIP85][]を更新しました。
  今回の更新では、親のキーチェーンを使用して、GPG互換のスマートカードにロード可能なRSAベースのPGP署名鍵を作成する方法について説明しています。

- [BIPs #1054][]では、Segwitのコンセンサスの変更の仕様[BIP141][]を更新し、`OP_CHECKMULTISIG`および`OP_CHECKMULTISIGVERIFY`
  を使用した場合の署名操作（sigops）のカウント方法を明確にしました。以前の文章では、これらはP2SHを使用した時と同じようにカウントされると
  記載されていましたが、今回の更新では直観的ではない特殊性が説明されています:
  "公開鍵の総数が1から16の場合、CHECKMULTISIGはそれぞれ１から16のsigopsとしてカウントされ、
  公開鍵の総数が17から20の場合、20 sigopsとカウントされます。"

- [BIPs #1047][]は、フレーズから[BIP32][]シードを決定論的に生成する仕様[BIP39][]を更新し、
  英語以外の単語リストの使用は広くサポートされていないため実装には推奨しない、という警告を追加しています。

{% include references.md %}
{% include linkers/issues.md issues="433,19509,1021,1020,20764,1048,1056,988,1040,1054,1047,774,950,20685,1055,20799" %}
[LND 0.12.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.1-beta.rc1
[folkson1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018379.html
[folkson2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018380.html
[news133 taproot meeting]: /ja/newsletters/2021/01/27/#taproot
[kohen post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018372.html
[dlc list]: https://mailmanlists.org/mailman/listinfo/dlc-dev
[i2p]: https://en.wikipedia.org/wiki/I2P
[news131 bech32m]: /ja/newsletters/2021/01/13/#bech32m
[news130 bip322]: /en/newsletters/2021/01/06/#proposed-updates-to-generic-signmessage
[bitcoin dissector]: https://en.bitcoinwiki.org/wiki/Bitcoin_Dissector
[nonsegwit]: https://bitcoincore.reviews/20799#l-197
[unsolicited]: https://bitcoincore.reviews/20799#l-156
[three]: https://bitcoincore.reviews/20799#l-159
