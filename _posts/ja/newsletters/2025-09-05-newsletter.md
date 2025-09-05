---
title: 'Bitcoin Optech Newsletter #370'
permalink: /ja/newsletters/2025/09/05/
name: 2025-09-05-newsletter-ja
slug: 2025-09-05-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---

今週のニュースレターでは、Bitcoinのコンセンサスルールの変更に関する議論のまとめと、
新しいリリースとリリース候補の発表、人気のBitcoinインフラストラクチャソフトウェアの注目すべき更新など
恒例のセクションを掲載しています。

## ニュース

_今週は、どの[情報源][optech sources]からも重要なニュースは見つかりませんでした。_

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **Simplicityの設計に関する詳細:** Russell O'Connorは、
  「[Simplicity言語][topic simplicity]の哲学と設計」について、
  これまで3つの投稿（[1][sim1]、[2][sim2]、[3][sim3]）をDelving Bitcoinに投稿しています。
  これらの投稿では、「基本的な演算を複雑な演算に変換するための3つの主要な合成形式」、
  「Simplicityの型システム、コンビネーター、基本式」、
  そして「計算可能なSimplicityコンビネーターのみを使用して、
  bitからSHA-256やSchnorr署名検証などの暗号演算に至るまでの論理演算を構築する方法」について考察しています。

  最新の投稿では、このシリーズの今後の投稿が予定されていることを示しています。

- **Tapscriptに楕円曲線の演算を追加するためのBIPドラフト:**
  Olaoluwa Osuntokunは、スクリプトの評価スタック上で楕円曲線の演算を実行できるようにする
  いくつかのopcodeを[Tapscript][topic tapscript]に追加するための[BIPドラフト][osuntokun bip]のリンクを
  Bitcoin-Devメーリングリストに[投稿しました][osuntokun ec]。これらのopcodeは、
  イントロスペクション系のopcodeと組み合わせて使用することで[コベナンツ][topic covenants]プロトコルの作成や強化、
  その他の進化を目的としています。

  Jeremy Rubinは、追加機能を有効にするための追加opcodeと、
  提案で提供される機能の一部をより便利にする[他のopcode][rubin ec2]の提案を[しました][rubin ec1]。

- **OP_TWEAKADD用のBIPドラフト:** Jeremy Rubinは、
  [Tapscript][topic tapscript]に`OP_TWEAKADD`を追加するための[BIPドラフト][rubin bip]を
  Bitcoin-Devメーリングリストに[投稿しました][rubin ta1]。
  また、このopcodeの追加によって有効化されるスクリプトの注目すべきサンプルも[投稿しました][rubin ta2]。
  これには、[Taproot][topic taproot]のtweakを明らかにするスクリプト、
  トランザクションの署名順序の証明（例：アリスはボブより前に署名する必要がある）、
  [署名の委任][topic signer delegation]などが含まれます。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning v25.09][]は、この人気のLNノード実装の新しいメジャーバージョンのリリースです。
  このリリースには、[BIP353][]アドレスおよびシンプルな[オファー][topic offers]への支払い用の
  `xpay`コマンドのサポートが追加され、ブックキーパーのサポート、
  プラグインの依存関係の管理が改善され、その他の新機能とバグ修正も含まれています。

- [Bitcoin Core 29.1rc2][]は、この主要なフルノード実装のメンテナンスバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [LDK #3726][]は、[ブラインドパス][topic rv routing]上のダミーホップのサポートを追加しました。
  これにより、受信者はルーティング目的ではなくデコイとして機能する任意のホップを追加できます。
  ダミーホップの数は毎回ランダムに追加されますが、`MAX_DUMMY_HOPS_COUNT`で定義されている10個までに制限されます。
  ホップ数を増やすと、受信者ノードまでの距離やIDの特定が著しく困難になります。

- [LDK #4019][]は、仕様で義務付けられているとおり、
  [スプライシング][topic splicing]トランザクションを初期化する前にチャネル状態の静止を要求することで、
  スプライシングと[静止プロトコル][topic channel commitment upgrades]を統合します。

- [LND #9455][]は、仕様で許可され、EclairやCore Lightningなどの他の実装でもサポートされているとおり（
  ニュースレター[#212][news212 dns]、[#214][news214 dns]、[#178][news178 dns]参照）、
  有効なDNSドメイン名をライトニングノードのIPアドレスと公開鍵に関連付ける機能をアナウンスメッセージでサポートしました。

- [LND #10103][]では、新しい`gossip.peer-msg-rate-bytes`オプション（デフォルト値は51200）が導入されまました。
  これは、各ピアが送信[ゴシップメッセージ][topic channel announcements]に使用する送信帯域幅を制限します。
  この値は平均帯域幅速度（byte/秒）を制限し、ピアがこの閾値を超過した場合、
  LNDはそのピアへのメッセージをキューに入れて遅延させます。この新しいオプションにより、
  [LND #10096][]で導入された、`gossip.msg-rate-bytes`で定義されたグローバル帯域幅を単一のピアがすべて消費するのを防止します。
  ゴシップリクエストのリソース管理に関するLNDの関連作業については、
  ニュースレター[#366][news366 gossip]および[#369][news369 gossip]をご覧ください。

- [HWI #795][]では、`bitbox02`ライブラリをバージョン 7.0.0にアップグレードすることで
  BitBox02 Novaをサポートしました。またいくるかのCLIの更新も行われています。

{% include snippets/recap-ad.md when="2025-09-09 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3726,4019,9455,10103,795,10096" %}
[bitcoin core 29.1rc2]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[core lightning v25.09]: https://github.com/ElementsProject/lightning/releases/tag/v25.09
[sim1]: https://delvingbitcoin.org/t/delving-simplicity-part-three-fundamental-ways-of-combining-computations/1902
[sim2]: https://delvingbitcoin.org/t/delving-simplicity-part-combinator-completeness-of-simplicity/1935
[sim3]: https://delvingbitcoin.org/t/delving-simplicity-part-building-data-types/1956
[osuntokun ec]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAO3Pvs-Cwj=5vJgBfDqZGtvmoYPMrpKYFAYHRb_EqJ5i0PG0cA@mail.gmail.com/
[osuntokun bip]: https://github.com/bitcoin/bips/pull/1945
[rubin ec1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/f118d974-8fd5-42b8-9105-57e215d8a14an@googlegroups.com/
[rubin ec2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/1c2539ba-d937-4a0f-b50a-5b16809322a8n@googlegroups.com/
[rubin ta1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bc9ff794-b11e-47bc-8840-55b2bae22cf0n@googlegroups.com/
[rubin ta2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/c51c489c-9417-4a60-b642-f819ccb07b15n@googlegroups.com/
[rubin bip]: https://github.com/bitcoin/bips/pull/1944
[news212 dns]: /ja/newsletters/2022/08/10/#bolts-911
[news214 dns]: /ja/newsletters/2022/08/24/#eclair-2234
[news178 dns]: /ja/newsletters/2021/12/08/#c-lightning-4829
[news366 gossip]: /ja/newsletters/2025/08/08/#lnd-10097
[news369 gossip]: /ja/newsletters/2025/08/29/#lnd-10102
[optech sources]: /ja/internal/sources