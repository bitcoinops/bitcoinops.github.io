---
title: 'Bitcoin Optech Newsletter #356'
permalink: /ja/newsletters/2025/05/30/
name: 2025-05-30-newsletter-ja
slug: 2025-05-30-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、帰属障害がLNのプライバシーに影響を及ぼす可能性について掲載しています。
また、Bitcoin Stack Exchangeから厳選された質問とその回答や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの最近の更新など
恒例のセクションも含まれています。

## ニュース

- **帰属障害はLNのプライバシーを低下させる？**
  Carla Kirk-Cohenは、ネットワークが[失敗の帰属][topic attributable failures]、
  特に各ホップで支払いを転送するのにかかった時間を支払人に伝える場合、
  LNの支払人と受取人のプライバシーにどのような影響が及ぶ可能性があるかについての分析を
  Delving Bitcoinに[投稿しました][kirkcohen af]。
  彼女は複数の論文を引用しながら、2種類の非匿名化攻撃について説明しています:

  - 1つ以上の転送ノードを運用する攻撃者が、タイミングデータを使って
    支払い（[HTLC][topic htlc]）に使用されたホップ数を特定します。
    このデータと公開ネットワークのトポロジーに関する知識を組み合わせることで、
    受取人の可能性があるノードのセットを絞り込むことができます。

  - 攻撃者が、IPネットワークトラフィックフォワーダー（[<!--autonomous-->自律システム][autonomous system]）を使ってトラフィックを受動的に監視し、
    ノード間のIPネットワークのレイテンシー（つまりping時間）の知識と、
    公開ライトニングネットワークのトポロジー（およびその他の特性）に関する知識を組み合わせることができます。

  次に彼女は、以下の解決策を挙げています:

  - 受取人にHTLCの受け入れを小さなランダム時間分遅らせることを推奨し、
    受取人のノードを特定しようとするタイミング攻撃を防止する。

  - 支払人に失敗した支払い（または[MPP][topic multipath payments]の一部）の再送を
    小さなランダム時間分遅らせ、代替パスを使うことで、
    支払人のノードを特定しようとするタイミング攻撃や失敗攻撃を防止する。

  - MPPによる支払いの分割数を増やし、支払額の推測を困難にする。

  - 以前の提案のように（[<!--news-->ニュースレター #208][news208 slowln]参照）、
    支払人が支払いをより遅く転送されることを選択できるようにする。
    これは、LNDで既に実装されているHTLCバッチ処理と組み合わせることもできる（
    ランダム時間の遅延の追加によりプライバシーを強化できる）。

  - 小さなランダム遅延を追加する転送ノードへのペナルティを回避するため、
    原因となる失敗のタイムスタンプの精度を下げる。

  複数の参加者による議論では、懸念事項と提案された解決策をより詳細に評価し、
  その他の可能性のある攻撃と軽減策についても検討されました。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [どのトランザクションがblockreconstructionextratxnに取り込まれるのでしょうか？]({{bse}}116519)
  Glozowは、extrapoolのデータ構造（[ニュースレター #339][news339 extrapool]参照）が、
  ノードが拒否または置換したトランザクションをどのようにキャッシュするかについて説明し、
  除外と排除の基準をリストアップしています。

- [手数料は別として、なぜinscriptionよりOP_RETURNを使うのでしょうか？]({{bse}}126208)
  Sjors Provoostは、`OP_RETURN`の方が安価な場合があることに加え、
  `OP_RETURN`は、使用時に開示されるwitnessデータとは対照的に、
  トランザクションが使用される前に利用可能なデータが必要なプロトコルで使えると指摘しています。

- [私のBitcoinノードに着信接続がないのはどうしてですか？]({{bse}}126338)
  Lightlikeは、ネットワーク上の新しいノードのアドレスがP2Pネットワーク上で広く通知されるのには時間がかかる場合があり、
  ノードはIBDが完了するまでアドレスを通知しないと指摘しています。

- [<!--how-do-i-configure-my-node-to-filter-out-transactions-larger-than-400-bytes-->400 byteを超えるトランザクションをフィルタリングするようにノードを設定するにはどうすればいいですか？]({{bse}}126347)
  Antoine Poinsotは、Bitcoin Coreには標準トランザクションの最大サイズをカスタマイズする設定オプションがないことを確認しています。
  彼は、その値をカスタマイズしたいユーザーはソースコードを更新できると説明していますが、
  最大値を大きくする場合と小さくする場合の両方の潜在的なデメリットについても警告しています。

- [Bitcoin CoreのP2Pにおける「publicly routable」でないノードとは何を意味するのですか？]({{bse}}126225)
  Pieter WuilleとVasil Dimovは、グローバルインターネット上でルーティングできず、
  Bitcoin Coreの`netinfo`出力で「npr」バケットに表示される
  [Tor][topic anonymity networks]などのP2P接続の例を示しています。

- [<!--why-would-a-node-would-ever-relay-a-transaction-->なぜノードはトランザクションをリレーするのですか？]({{bse}}127391)
  Pieter Wuilleは、ノードオペレーターにとってトランザクションをリレーすることの利点として、
  自身のノードから自身のトランザクションをリレーする際のプライバシー、
  ユーザーがマイニングしている場合のブロックの伝播の高速化、
  ブロックのリレー以外の追加コストを最小限に抑えながらネットワークの分散性を向上させることを挙げています。

- [コンパクトブロックやFIBREでも、セルフィッシュマイニングは依然として選択肢となるのでしょうか？]({{bse}}49515)
  Antoine Poinsotは、2016年の質問に続けて、「はい。セルフィッシュマイニングは、
  ブロックの伝播が改善されたとしても、依然として最適化可能な手段です。
  セルフィッシュマイニングがもはや理論上の攻撃に過ぎないと結論付けるのは間違っています」と述べています。
  彼はまた、自身が作成した[マイニングシミュレーション][miningsimulation github]についても言及しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 25.05rc1][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。

- [LDK 0.1.3][]および[0.1.4][ldk 0.1.4]は、LN対応アプリケーションを構築するための
  この人気のライブラリのリリースです。バージョン0.1.3はGithub上では今週のリリースとしてタグ付けされていますが、
  リリース日は先月になっており、サービス拒否攻撃に対する修正が含まれています。
  最新リリースであるバージョン0.1.4では「極めて稀なケースで発生する資金窃盗の脆弱性を修正」しています。
  両リリースには、その他のバグ修正も含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31622][]は、署名ハッシュ（sighash）タイプが
  `SIGHASH_DEFAULT`または`SIGHASH_ALL`と異なる場合に、
  [PSBT][topic psbt]にそのフィールドを追加します。
  [MuSig2][topic musig]のサポートでは、全員が同じsighashタイプで署名する必要があるため、
  このフィールドはPSBTに必須です。さらに、`descriptorprocesspsbt` RPCコマンドは、
  `SignPSBTInput`関数を使用するように更新され、
  PSBTのsighashタイプがCLIで指定されたタイプと一致することを保証します（該当する場合）。

- [Eclair #3065][]は、[BOLTs #1044][]で定義されている
  帰属障害（ニュースレター[#224][news224 failures]参照）のサポートを追加します。
  仕様がまだ確定していないためデフォルトでは無効になっていますが、
  `eclair.features.option_attributable_failure = optional`を設定することで有効にできます。
  LDKとの相互互換性はテスト済みです。LDKの実装とこのプロトコルの動作に関する詳細については、
  ニュースレター[#349][news349 failures]をご覧ください。

- [LDK #3796][]は、チャネル残高チェックを強化し、
  資金提供者がコミットメントトランザクションの手数料、
  2つの330 satsの[アンカーアウトプット][topic anchor outputs]、
  そしてチャネルリザーブを賄うのに十分な資金を確保できるようにします。
  これまでは、資金提供者は、2つのアンカーを賄うためにチャネルリザーブを利用できました。

- [BIPs #1760][]は、SPVクライアントに対して悪用可能な
  [マークルツリーの脆弱性][topic merkle tree vulnerabilities]を防ぐため、
  （witnessデータを除いた）64-byteのトランザクションを禁止するコンセンサスソフトフォークルールを規定した
  [BIP53][]をマージしました。このPRは、
  [コンセンサスクリーンアップソフトフォーク][topic consensus cleanup]に含まれるものと同様の修正を提案しています。

- [BIPs #1850][]は、[Taproot][topic taproot]（P2TR）の導出用にスクリプトタイプの値3を予約した
  [BIP48][]の以前の更新（ニュースレター [#353][news353 bip48]参照）を元に戻しました。
  これは、[Tapscript][topic tapscript]に`OP_CHECKMULTISIG`がないため、
  [BIP48][]が依存する[BIP67][]で参照されているアウトプットスクリプトをP2TRで表現できないためです。
  このPRはまた[BIP48][]のステータスを`Final`としています。
  これはBIP導入時の目的が、新しい動作を規定することではなく、
  `m/48'` [HDウォレット][topic bip32]導出パスの業界における使用を定義することが目的であったことを反映しています。

- [BIPs #1793][]は、（アウトプットとインプット両方の）公開鍵が任意のデータにコミットしていることを確認できる
  [OP_CHECKCONTRACTVERIFY][topic matt]（OP_CCV） opcodeを提案する[BIP443][]をマージしました。
  この提案された[コベナンツ][topic covenants]の詳細については、ニュースレター[#348][news348 op_ccv]をご覧ください。

{% include snippets/recap-ad.md when="2025-06-03 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31622,3065,3796,1760,1850,1793,1044" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ldk 0.1.3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.3
[ldk 0.1.4]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.4
[news208 slowln]: /ja/newsletters/2022/07/13/#ln
[autonomous system]: https://ja.wikipedia.org/wiki/自律システム_(インターネット)
[kirkcohen af]: https://delvingbitcoin.org/t/latency-and-privacy-in-lightning/1723
[news224 failures]: /ja/newsletters/2022/11/02/#ln
[news349 failures]: /ja/newsletters/2025/04/11/#ldk-2256
[news353 bip48]: /ja/newsletters/2025/05/09/#bips-1835
[news348 op_ccv]: /ja/newsletters/2025/04/04/#op-checkcontractverify
[news339 extrapool]: /ja/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[miningsimulation github]: https://github.com/darosior/miningsimulation
