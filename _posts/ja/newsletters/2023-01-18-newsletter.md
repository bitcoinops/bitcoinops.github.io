---
title: 'Bitcoin Optech Newsletter #234'
permalink: /ja/newsletters/2023/01/18/
name: 2023-01-18-newsletter-ja
slug: 2023-01-18-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、新しいVault専用のopcodeの提案に加えて、
クライアントやサービスの興味深いアップデートや、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションを掲載しています。

## ニュース

- **新しいVault専用opcodeの提案:** James O'Beirneは、
  Bitcoin-Devメーリングリストに、`OP_VAULT`と`OP_UNVAULT`という
  新しい2つのopcodeを追加するソフトフォークの[提案][obeirne paper]を[投稿しました][obeirne op_vault]。

  - `OP_VAULT` は、信頼性の高い支払いパスへのコミットメント、
    [遅延期間][topic timelocks]、信頼性の低い支払いパスへのコミットメントの、3つのパラメーターを受け入れます。

  - `OP_UNVAULT` も3つのパラメーターを受け入れます。
    O'Beirneが想定しているVaultでは、3つのパラメーターは、
    同じ信頼性の高い支払いパスへのコミットメントと、同じ遅延期間、
    後のトランザクションに含める1つ以上のアウトプットへのコミットメントになります。

  [Vault][topic vaults]（金庫）を作成するために、アリスは信頼性の高い支払いパスを選択します。
  これは、たとえば複数の署名デバイスや別々の場所に保管されているコールドウォレットへのアクセスを要求するマルチシグのような支払いパスです。
  また、彼女のホットウォレットから単一の署名で使用可能な信頼性の低い支払いパスも選択します。
  最後に、[BIP68][]と同じデータ型で遅延時間を選択します。数分から1年までの時間を指定できます。
  パラメーターを選択したら、自分のVaultに資金を受け取るための通常のBitcoinアドレスを作成します。
  このアドレスは、`OP_VAULT`を使用したスクリプトにコミットしています。

  自分のVaultアドレスで受け取った資金を使用する場合、アリスはまず最終的に支払いをするアウトプットを決めます（
  たとえば、ボブに支払いをし、お釣りがあれば自分のVaultに戻すなど）。通常の使用法では、
  アリスは、信頼性の低い支払いパスの条件を満たし（ホットウォレットから署名を提供するなど）、
  保管されたすべての資金を1つのアウトプットに支払うトランザクションを作成します。
  このアウトプットには、信頼性の高い支払いパスと遅延の同じパラメーターを持つ`OP_UNVAULT`が含まれています。
  3つめのパラメーターは、アリスが最終的に支払いたいアウトプットへのコミットメントです。
  アリスは、トランザクションの構築を完了させます。これには、
  [手数料スポンサーシップ][topic fee sponsorship]や、[アンカー・アウトプット][topic anchor outputs]タイプ、
  その他の仕組みを使用した手数料の添付も含まれます。

  アリスは、トランザクションをブロードキャストし、その後ブロックに格納されます。
  これにより、誰もが保管の解除の試みが進行中であることを観察することができます。
  アリスのソフトウェアは、これが自分の保管された資金であることを検出し、
  承認されたトランザクションの`OP_UNVAULT`アウトプットの3つめのパラメーターが、
  アリスが以前作成したコミットメントと正確に一致するか検証します。
  一致した場合、アリスはここで遅延期間が終わるのを待ち、その後、
  `OP_UNVAULT`のUTXOを彼女が以前コミットしたアウトプット（たとえば、ボブとお釣り用のアウトプット）へ
  支払うトランザクションをブロードキャストすることができます。
  これは、アリスの資金を、彼女の信頼性の低い支払いパス（ホットウォレットのみを使うような）を使って
  支払いに成功したことになります。

  しかし、アリスのソフトウェアが承認された保管解除の試みを確認して、それが自身によるものではないと認識した場合、
  アリスのソフトウェアは、遅延期間中に資金を凍結する機会を得ます。ソフトウェアは、
  `OP_UNVAULT`アウトプットを以前のコミットメントの対象である信頼性の高いアドレスに支払うトランザクションを作成します。
  遅延期間が終わる前にこの凍結トランザクションが承認される限り、
  アリスの資金は信頼性の低い支払いパスによる侵害から保護されます。資金がアリスの信頼性の高い支払いパスに転送された後、
  アリスはそのパスの条件を満たして（たとえば、コールドウォレットを使用して）、
  いつでも資金を使用できます。`OP_VAULT`の提案の利点として、以下の点が挙げられています:

  - *witnessがより小さく:* 提案中の[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]を使用するような
    柔軟なCovenantは、保管を解除するトランザクションのwitnessに、
    トランザクション内の他の場所に含まれる大量のデータのコピーを含める必要があり、
    トランザクションサイズと手数料のコストが肥大化します。`OP_VAULT`では、
    オンチェーンに含まれるスクリプトとwitnessがとても少なくなります。

  - *<!--fewer-steps-for-spending-->支払いのステップが少ない:*
    現在利用可能な事前署名トランザクションに基づく柔軟性の低いCovenantの提案は、
    最終的な宛先に送信する前に所定のアドレスに資金を引き出す必要があります。
    このような提案では、通常、受け取ったアウトプットを
    他の受け取ったアウトプットとは別のトランザクションで使用する必要があり、
    [支払いのバッチ処理][topic payment batching]をすることができません。
    これにより、関連するトランザクションの数が増え、支払いのサイズとコストも膨れ上がります。

    `OP_VAULT`は、通常、単一のアウトプットを使用する場合に必要なトランザクション数が少なく、
    複数のアウトプットを使用または凍結する際のバッチ処理もサポートします。
    これにより大量のスペースが節約される可能性があり、安全のためにアウトプットを統合する必要が生じる前に、
    Vaultが多くのトランザクションを受け取れるようにすることができます。

  このアイディアの関する議論において、Greg Sandersは、
  （[O'Beirneが要約したように][obeirne scripthash]）少し異なる構成を提案しました。
  「Vaultのライフサイクルにおけるすべてのアウトプットを[P2TR][topic taproot]にすることができ、
  たとえば、Vaultの操作を隠すことができます。これは非常に優れた機能です。」

  これとは別に、Anthony Townsは、この提案により、Vaultのユーザーは、
  信頼性の高い支払いパスのアドレスに資金を送信するだけで、いつでも資金を凍結でき、
  ユーザーは後で資金の凍結を解除できるようになると[指摘しています][towns op_vault]。
  これは、盗難の試みを阻止するために、コールドウォレットのような特別に保護された鍵にアクセスする必要がないため、
  Vaultのオーナーにとってメリットがあります。しかし、アドレスを知った第三者も、
  ユーザーの資金を凍結することができ（そのためにはトランザクション手数料を支払う必要がありますが）、
  ユーザーにとって不都合が生じます。多くの軽量ウォレットが、オンチェーントランザクションを特定するために、
  第三者にアドレスを開示してることを考えると、そのようなウォレット上に構築されたVaultは、
  意図せず第三者にVaultユーザーに迷惑をかける能力を与えてしまう可能性があります。
  Townsは、凍結条件の代替案として、凍結を開始するため非秘密情報を追加で提供するよう要求し、
  この方式の利点を維持しつつ、ウォレットが不必要に第三者に資金の凍結能力を与えて
  ユーザーに不都合を生じさせるリスクを低減することを提案しています。
  Townsはまた、バッチ処理をサポートする可能性を示唆し、Taprootのサポートを検討しています。

  いくつかの返信で、`OP_UNVAULT`は、CTVを直接使用するよりオンチェーンコストは高くなるものの
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)提案の機能の多くを提供することができると述べています
  （[ニュースレター #185][news185 ctv-dlc]で以前説明した[DLC][topic dlc]の利点も含む）。

  この記事の執筆時点では、議論はまだ活発でした。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **KrakenがTaprootアドレスへの送信を発表:**
  最近の[ブログ記事][kraken bech32m]で、Krakenは[bech32m][topic bech32]アドレスへの引き出し（送信）をサポートすることを発表しました。

- **Whirlpoolがcoinjoin Rustクライアントライブラリを発表:**
  [Samourai Whirlpool Client][whirlpool rust client]は、
  Whirlpool [coinjoin][topic coinjoin]プラットフォームと対話するためのRustライブラリです。

- **Ledgerがminiscriptをサポート:**
  Ledgerのハードウェア署名デバイス用のBitcoin firmware v2.1.0リリースは、
  [以前][ledger miniscript]発表したように[miniscript][topic miniscript]をサポートしています。

- **Lianaウォレットのリリース:**
  Lianaウォレットの最初のバージョンが[発表されました][liana blog]。
  このウォレットは、[タイムロックされた][topic timelocks]リカバリーキーを持つシングルシグのウォレットをサポートしています。
  将来的には、[Taproot][topic taproot]やマルチシグウォレット、時間減衰型のマルチシグ機能を実装する予定です。

- **Electrum 4.3.3リリース:**
  [Electrum 4.3.3][electrum 4.3.3]では、Lightning、[PSBT][topic psbt]、
  ハードウェアウォレットのサポートおよびビルドシステムの改良が含まれてます。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [HWI 2.2.0][]は、ソフトウェアウォレットとハードウェア署名デバイスのインターフェースとなるこのアプリケーションのリリースです。
  このリリースでは、BitBox02ハードウェア署名デバイスを使用した[P2TR][topic taproot]のkeypath支払いのサポートや、
  その他の機能およびバグ修正が追加されています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。

- [Core Lightning #5751][]は、P2SHでラップされたSegwitアドレスの新規作成のサポートを非推奨にしました。

- [BIPs #1378][]は、[v2暗号化P2Pトランスポートプロトコル][topic v2 p2p transport]用の
  [BIP324][]を追加しました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5751,1378" %}
[hwi 2.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.0
[obeirne op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021318.html
[obeirne paper]: https://jameso.be/vaults.pdf
[obeirne scripthash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021329.html
[news185 ctv-dlc]: /ja/newsletters/2022/02/02/#script-dlc
[towns op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021328.html
[kraken bech32m]: https://blog.kraken.com/post/16740/bitcoin-taproot-address-now-supported-on-kraken/
[whirlpool rust client]: https://github.com/straylight-orbit/whirlpool-client-rs
[ledger miniscript]: https://blog.ledger.com/miniscript-is-coming/
[liana blog]: https://wizardsardine.com/blog/liana-announcement/
[electrum 4.3.3]: https://github.com/spesmilo/electrum/blob/4.3.3/RELEASE-NOTES
