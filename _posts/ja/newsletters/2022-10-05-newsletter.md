---
title: 'Bitcoin Optech Newsletter #220'
permalink: /ja/newsletters/2022/10/05/
name: 2022-10-05-newsletter-ja
slug: 2022-10-05-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、新しいオプトイン型のトランザクションリレールールの提案と、
LNチャネルのバランスを保つための研究の要約を掲載しています。
また、新しいソフトウェアリリースおよびリリース候補のリストや、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **LNのペナルティ用に設計された新しいトランザクションリレーポリシーの提案:**
  Gloria Zhaoは、トランザクションにオプトインで、
  トランザクションリレーポリシーのセットの変更を可能にする提案を、Bitcoin-Devメーリングリストに[投稿しました][zhao tx3]。
  バージョンパラメータに`3`をセットしたトランザクションは以下のようになります:

  - より高い手数料率と総手数料を支払うトランザクションによって未承認のトランザクションは置換できる（現在の主な[RBF][topic rbf]ルール）

  - そのトランザクションが未承認である限り、その子孫のトランザクションもすべてv3トランザクションであることを要求する。
    このルールに違反する子孫は、デフォルトでリレー、マイニングされない。

  - v3の未承認の祖先が既に他の子孫をmempoolに持っている（もしくは、
    このトランザクションが[パッケージ][topic package relay]にある）場合は、拒否される。

  - 未承認のv3の祖先を持つ場合、1,000バイト以下であることをが要求される。

  この提案されたルールに付随して、以前提案されたパッケージリレールール（[ニュースレター #167][news167 packages]参照）が簡略化されました。

  v3リレールールと更新されたパッケージリレールールは、
  LNのコミットメントトランザクションが最小限の手数料（場合によっては手数料ゼロ）で、
  子トランザクションによって実際の手数料が支払われ、かつ[Pinning][topic transaction pinning]攻撃を防止するよう設計されています。
  ほぼ全てのLNノードは既にこのような仕組み[アンカー・アウトプット][topic anchor outputs]を使用していますが、
  提案されているアップグレードにより、コミットメントトランザクションの承認がよりシンプルで堅牢なものになるはずです。

  Greg Sandersは、2つの提案を[返信しました][sanders tx3]:

  - *一時的なdust:* ゼロ値（もしくは経済的合理性のない値）のアウトプットに支払いをするトランザクションは、
    そのトランザクションがdustアウトプットを使用するパッケージの一部である場合、
    [dustポリシー][topic uneconomical outputs]が免除されるべきるである。

  - *標準OP_TRUE:* `OP_TRUE`のみで構成されるアウトプットに支払いをするトランザクションはデフォルトでリレーされるべきである。
    そのようなアウトプットは、誰もが使用でき、セキュリティはない。
    LNチャネルのいずれかの参加者（もしくは第三者）が、その`OP_TRUE`アウトプットを使用するトランザクションによる手数料の引き上げを容易にする。
    `OP_TRUE`アウトプットを使用するのにスタックに入れるデータは必要ないため、コスト効率よく使用できる。

  これらのいずれも、v3トランザクションのリレーの実装と同時に行う必要はありませんが、
  スレッドの回答者の中には、提案されたすべての変更に賛成している人もいるようです。

- **<!--ln-flow-control-->LNのフロー制御:** Rene Pickhardtは、
  フロー制御のバルブとして`htlc_maximum_msat`を使用することについて行った[最近の研究][pickhardt bitmex valve]の概要を
  Lightning-Devメーリングリストに[投稿しました][pickhardt ml valve]。
  BOLT7で[以前定義された][bolt7 htlc_max]ように、`htlc_maximum_msat`は、
  ノードが個々の支払いパーツ（[HTLC][topic htlc]）で、特定のチャネルで次のホップに転送する最大額です。
  Pickhardtは、一方向に他方より多くの金額が流れ、最終的にその方向に流れる資金がなくなるチャネルが多いという問題に対処します。
  彼は、過度に使用される方向の最大値を制限することで、チャネルのバランスを保つことができると提案しています。
  たとえば、あるチャネルが、最初はどちらかの方向に1,000 satの送金を許可していた場合、
  バランスが悪くなると、使いすぎた方向の１回の送金額の上限を800 satに下げてみるのです。
  Pickhardtの研究は、実際に適切な`htlc_maximum_msat`の値を計算するのに使用できるいくつかのコードスニペットを提供しています。

  またPickhardtは[別のメール][pickhardt ratecards]で、
  以前の*手数料レートカード*のアイディア（[先週のニュースレター][news219 ratecards]参照）が代わりに、
  *転送毎の最大金額レートカード*になる可能性を示唆しています。
  少額の支払いには低い手数料率が、高額の支払いには高い手数料が課されます。
  元のレートカードの提案とは異なり、それらは絶対額で、チャネルの現在の残高に対する相対的なものではありません。
  Anthony Townsは、`htlc_maximum_msat`の調整に基づくフロー制御では問題にならない、
  元のレートカードのいくつかの課題について[説明しました][towns ratecards]。

  ZmnSCPxjは、このアイディアのいくつかの面を[批判し][zmnscpxj valve]、
  支払人は最大レートの低いチャネルを介して同じ量の金額を送ることができ、
  全体の支払いをさらに小さなパーツに分割することで、再びバランスが取れなくなることを指摘しました。
  Townsは、レート制限によってこれに対処できる可能性があることを示唆しました。

  この要約が書かれた時点では、この議論は継続中のようですが、
  ノートオペレーターが各チャネルの`htlc_maximum_msat`パラメーターを使って実験し始めると、
  今後数週間から数ヶ月の間に、いくつかの新しい洞察が得られると予想されます。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 24.0 RC1][]は、ネットワークで最も広く使われているフルノード実装の次期バージョンの最初のリリース候補です。
  [テストのガイド][bcc testing]が利用できるようになっています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Eclair #2435][]は、[トランポリンリレー][topic trampoline payments]使用時の、
  *非同期支払い*の基本形式のオプションサポートを追加しました。
  [ニュースレター #171][news171 async]に掲載したように、非同期支払いにより、
  資金を持つ第三者を信頼することなくオフラインノード（モバイルウォレットのような）への支払いを可能にするでしょう。
  非同期支払いの理想的な仕組みは[PTLC][topic ptlc]に依存しますが、
  部分的な実装はオフラインノードがオンラインになるまで資金の転送を遅らせるだけで済みます。
  トランポリンノードは、その遅延を提供できるため、このPRはそれらを利用した非同期支払いの実験を可能にします。

- [BOLTs #962][]は、元の固定長のOnionデータフォーマットのサポートを仕様から削除しました。
  アップグレードされた可変長のフォーマットは、3年以上前に仕様に追加され、
  コミットメッセージで言及されているテスト結果では、古いフォーマットを使用している人はほとんどいないことを示しています。

- [BIPs #1370][]は、現在提案中の実装を反映するために[BIP330][]（reconciliationベースのトランザクション通知[Erlay][topic erlay]）を改訂しました。
  変更点は次のとおりです:

  - トランザクションIDを削除し、トランザクションのWTXIDを使用するようになりました。
    これは、ノードが既存の`inv`および`getdata`メッセージを使用できることを意味し、
    `invtx`および`gettx`メッセージが削除されました。

  - `sendrecon`が`sendtxrcncl`に、`reqreconcil`が`reqrecon`に、`reqbisec`が`reqsketchtext`にリネームされました。

  - `sendtxrcncl`を使用したネゴシエーションのサポートの詳細が追加されました。

- [BIPs #1367][]は、BIP [340][bip340]と[341][bip341]を参照することで、
  可能な限り[BIP118][]の[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]の記述を簡略化しました。

- [BIPs #1349][]は、[BIP47][bip47]と[Silent Payment][topic silent payments]に触発された暗号プロトコルを定義した
  「Private Payment」というタイトルの[BIP351][]を追加しました。
  このBIPは、新しいPayment Code形式を導入し、参加者が公開鍵の次にサポートされるアウトプットタイプを指定します。
  BIP47と同様に、送信者は通知トランザクションを使用して、受信者のPayment Codeに基いて受信者との共有シークレットを確立します。
  送信者は、受信者が使用時に通知トランザクションの情報から得られる共有シークレットから導出可能な一意のアドレスに複数の支払いを送信できます。
  BIP47では、複数の送信者が受信者毎に同じ通知アドレスを再利用していましたが、この提案では、
  検索キー`PP`と送信者と受信者のペア固有の通知コードでラベル付されたOP_RETURNアウトプットを使用して、
  受信者の注意を引き、プライバシーを改善するための共有シークレットを確立します。

- [BIPs #1293][]は、"Pay-to-contract tweak fields for PSBT"というタイトルの[BIP372][]を追加しました。
  このBIPは、[Pay-to-Contract][topic p2c]プロトコルに参加するために必要なコントラクトのコミットメントデータ（[ニュースレター #184][news184 psbt]参照）
  を署名デバイスに提供する追加の[PSBT][topic psbt]フィールドを含めるための標準を提案しています。

- [BIPs #1364][]は、[Drivechain][topic sidechains]の[BIP300][]の仕様に、さらなる詳細を追加しています。
  また、Drivechainのブラインドマージマイニングルールを適用する[BIP301][]の関連仕様も更新されています。

{% include references.md %}
{% include linkers/issues.md v=2 issues="2435,962,1370,1367,1349,1293,1364" %}
[bitcoin core 24.0 rc1]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bolt7 htlc_max]: https://github.com/lightning/bolts/blob/48fed66e26b80031d898c6492434fa9926237d64/07-routing-gossip.md#requirements-3
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[zhao tx3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020937.html
[news167 packages]: /ja/newsletters/2021/09/22/#mempool-rbf
[sanders tx3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020938.html
[pickhardt ml valve]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003686.html
[pickhardt bitmex valve]: https://blog.bitmex.com/the-power-of-htlc_maximum_msat-as-a-control-valve-for-better-flow-control-improved-reliability-and-lower-expected-payment-failure-rates-on-the-lightning-network/
[pickhardt ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003696.html
[news219 ratecards]: /ja/newsletters/2022/09/28/#ln
[towns ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003695.html
[zmnscpxj valve]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003703.html
[news171 async]: /ja/newsletters/2021/10/20/#paying-offline-ln-nodes-ln
[news184 psbt]: /ja/newsletters/2022/01/26/#p2c-psbt
