---
title: 'Bitcoin Optech Newsletter #196'
permalink: /ja/newsletters/2022/04/20/
name: 2022-04-20-newsletter-ja
slug: 2022-04-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinで量子安全な鍵交換を可能にする議論の要約と、
サービスやクライアントソフトウェア、リリースおよびリリース候補、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションを掲載しています。

## ニュース

- **<!--quantum-safe-key-exchange-->量子安全な鍵交換:** Erik Aronestyは、Bitcoin-Devメーリングリストに、
  高速な量子コンピューター（QC）が開発された場合に、
  Bitcoinを安全に保つための[量子耐性][topic quantum resistance]についての[スレッド][aronesty qc]を立ち上げました。
  高速なQCは、元の秘密鍵を知らなくてもBitcoinの公開鍵に対応する署名を生成できると予測されており、
  高速なQCを所有する誰かが他人のお金を使うことが出来るようになります。
  高速なQCが短期的な脅威であると信じしているセキュリティ研究者はほとんどいませんが、
  Bitcoinの既存の利用を大きく妨げることなく懸念材料を排除出来る方法であれば検討の余地があるかもしれません。

    Aronestyは、ユーザーが量子安全なアルゴリズムで保護された公開鍵で支払いを受けれるようにすること、
    また、既存のBitcoinの公開鍵でビットコインを保護することを提案しました。そうすると、
    暗号鍵の障害によってビットコインが盗まれる前に、両方の鍵アルゴリズムで悪用可能な問題を見つける必要があります。
    これには、ソフトフォークによるコンセンサスの変更が必要で、
    量子安全なwitnessデータはBitcoinで現在使用されているECDSAや[Schnorr][topic schnorr signatures]のwitnessデータよりも大きいことから、
    最悪の場合、ブロックあたりの有用なトランザクションの最大数が減少する可能性が高まります。

    Lloyd Fournierは、Taprootのアウトプットが通常のSchnorrの公開鍵に加えて、
    量子安全な公開鍵にもコミットできる標準的な方式を開発することを[提案しました][fournier qc]。
    量子安全な公開鍵は、現在使用できないかもしれませんが、
    Bitcoinユーザーが差し迫った高速なQCをより懸念するようになった場合、
    量子安全な支払いパスの使用を義務付けるコンセンサスの変更をソフトフォークで選択することができます。
    また、Fournierは、現在および将来の研究者のために、
    この問題と可能性のある解決策の詳細を[BitcoinProblems.org][]に[掲載する][qc issue]ことを提案しました。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Bitcoin.comがsegwitの送信を追加:**
  Bitcoin.comウォレットの[最近のアップデート][bitcoin.com segwit]で、
  ネイティブsegwit（[bech32][topic bech32]）アドレスへの送信がサポートされるようになりました。

- **KrakenがLightningをサポート:**
  Krakenは、LNDを使用して、0.1 BTCまでのLightningの入出金を[サポートしました][kraken lightning]。

- **Cash AppがLightningでの受け取りをサポート:**
  [LNの送信機能][news183 cash app ln send]に加えて、
  Cash AppはLightningネットワーク経由で支払いを受け取る機能の提供を開始しました。
  Cash Appは[Lightning Development Kit (LDK)][ldk website]を使用してLNの機能を実現しています。

- **BitPayがLightningでの受け取りをサポート:**
  ペイメントプロセッサーであるBitPayは、加盟店に対してLN支払いの受け入れの[サポートを発表しました][bitpay lightning]。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.14.3-beta][]は、この人気のあるLNノードソフトウェアのいくつかのバグ修正を含むリリースです。

- [Bitcoin Core 23.0 RC5][]は、この重要なフルノードソフトウェアの次のメジャーバージョンのリリース候補です。
  [リリースノートのドラフト][bcc23 rn]には、複数の改善点が記載されており、
  上級ユーザーとシステム管理者には最終リリース前の[テスト][test guide]が推奨されます。

- [Core Lightning 0.11.0rc3][]は、この人気のあるLNノードソフトウェアの次のメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [LND #5810][]は、支払いのメタデータの送信サポートを実装しています。
  インボイスに支払いのメタデータが含まれる場合、送信者はそのデータを受信者のTLVレコードとしてエンコードします。
  これは、送信者に提示したインボイスを、支払いの試行が受信者に届いた時に受信者が再生成することで、
  受信者がインボイスを保存しなくてすむようにする[ステートレスインボイス][topic stateless invoices]を可能にするためのもう1つのステップです。

- [LND #6212][]は、HTLCを受け入れるとオンチェーンですぐに、または短期間でチャネルを閉じる必要がある場合に、
  HTLCインターセプターを介して外部プロセスにHTLCが送信されるのを防ぎます。
  これは、HTLCの有効期限が直近のブロック近くにある場合に発生する可能性があります。

- [LND #6024][]は、`time_pref`経路探索パラメーターを追加し、
  より速く支払いを中継する可能性が高いと考えられるチャネルと、
  より手数料の少ないチャネルを経由する間のトレードオフを変更するのに使用することができます。

- [LND #6385][]は、新しい支払いを構築する際に、オリジナルのLNプロトコルのOnion支払いフォーマットを使用するオプションを削除し、
  ユーザーにTLVスタイルのOnionフォーマットの作成を要求します。
  TLV Onionは、2019年にプロトコルに追加され（[ニュースレター #55][news55 tlv]参照）、
  2年以上前からすべてのLNソフトウェアでデフォルトになっています。
  他のLNソフトウェアでも、[ニュースレター #158][news158 cl4646]で報告したCore Lightningのアップデートなど、
  古いOnionフォーマットのサポートを取りやめる同様の変更を行っています。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5810,6212,6024,6385" %}
[bitcoin core 23.0 rc5]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bcc23 rn]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Notes-draft
[test guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Candidate-Testing-Guide
[lnd 0.14.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.3-beta
[core lightning 0.11.0rc3]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.0rc3
[aronesty qc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020209.html
[fournier qc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020214.html
[qc issue]: https://github.com/bitcoin-problems/bitcoin-problems.github.io/issues/4
[bitcoinproblems.org]: https://bitcoinproblems.org/
[news55 tlv]: /en/newsletters/2019/07/17/#bolts-607
[news158 cl4646]: /ja/newsletters/2021/07/21/#c-lightning-4646
[bitcoin.com segwit]: https://support.bitcoin.com/en/articles/3919131-can-i-send-to-a-bc1-address
[kraken lightning]: https://blog.kraken.com/post/13502/kraken-now-supports-instant-lightning-network-btc-transactions/
[news183 cash app ln send]: /ja/newsletters/2022/01/19/#cash-app-lightning
[ldk website]: https://lightningdevkit.org/
[bitpay lightning]: https://bitpay.com/blog/bitpay-supports-lightning-network-payments/
