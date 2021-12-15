---
title: 'Bitcoin Optech Newsletter #179'
permalink: /ja/newsletters/2021/12/15/
name: 2021-12-15-newsletter-ja
slug: 2021-12-15-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、場合によっては値がゼロのアウトプットのトランザクションのリレーを可能にする提案と、
PTLCの採用に向けたLNの準備に関する議論のまとめを掲載しています。
また、サービスやクライアントソフトウェアの最近の変更のリストや、
Bitcoin Stack Exchangeで人気のある質問、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点などの恒例のセクションも含まれています。

## ニュース

- **<!--adding-a-special-exception-for-certain-uneconomical-outputs-->特定の経済合理性のないアウトプット用の特別な例外の追加:**
  [ニュースレター #162][news162 unec]の掲載以来、Jeremy RubinはBitcoin-Devメーリングリストで、
  トランザクションが[dust limit][topic uneconomical outputs]以下の値のアウトプットを作成することを認めることについて、
  議論を[更新しました][rubin unec]。dust limitは、
  ユーザーに経済的に意味のないUTXOの作成を思いとどまらせるために
  ノードが使用するトランザクションのリレーポリシーです。
  UTXOは使用されるまで、少なくともいくつかのフルノードで保管され、
  場合によっては迅速に取得できるため、*経済合理性のないアウトプット*を許可すると、
  正当な理由もなく問題が発生する可能性があります。

    しかし[CPFP][topic cpfp]による手数料の引き上げにおいては、
    手数料を引き上げるトランザクションの資金を使用できない場合、
    [eltoo][topic eltoo]みたいに、手数料の引き上げに使用される資金を別のUTXOから取得する必要がある場合、
    ゼロ値のアウトプットを使うことができるかもしれません。
    Ruben Somsenはまた、ゼロ手数料アウトプットが（one-wayペグのサイドチェーンの一種である）spacechainにどう役立つかの例も示しました。

    この記事を書いている時点では、議論に明確な結論は出ていません。

- **PLTC用のLNの準備:** Bastien Teinturierは、Lightning-Devメーリングリストで、
  ノードが[PTLC][topic ptlc]を使用するようアップグレードするために必要な、
  LNの通信プロトコルの最小限の[変更][ln docs 16]に関する[スレッド][teinturier post]を立ち上げました。
  PTLCは、現在使用中の[HTLC][topic htlc]よりもプライベート性が高く、ブロックスペースも少なくて済みます。

    Teinturierは、提案中の`option_simplified_update`
    [プロトコルの変更][bolts #867]（[ニュースレター #120][news120 opt_simp_update]参照）と同時に実行できる一連の変更を作成しようとしています。
    2つめの目標は、通信プロトコルを[ニュースレター #152][news152 ff]に掲載した
    fast-forwardベースのPTLCプロトコルと互換性のあるものにすることです。
    これによりノードは、最初にHTLCで`option_simplified_update`を使用して、
    次にPTLC、それからfast-forwardへ段階的にアップグレードすることができるようになります。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Simple Bitcoin WalletがTaprootへの送金をサポート:**
  SBWのバージョン [2.4.22][sbw 2.4.22]では、ユーザーがTaprootアドレスに送金できるようになりました。

- **Trezor SuiteがTaprootをサポート:**
  Trezorは、Trezor Suiteのバージョン21.12.2で[Taproot][topic taproot]をサポートすると[発表しました][trezor taproot blog]。
  最新のクライアントとファームウェアをダウンロードすると、ユーザーは新しいTaprootアカウントを作成することができます。

- **BlueWalletがTaprootへの送金をサポート:**
  BlueWallet [v6.2.14][bluewallet 6.2.14]はTaprootアドレスへの送金をサポートしました。

- **Cash AppがTaprootへの送金をサポート:**
  [2021年12月1日][cash app bech32m]より、Cash Appユーザーは[bech32m][topic bech32]アドレスに送金できるようになりました。

- **SwanがTaprootへの送金をサポート:**
  Swanは、Taprootでの引き出し（送金）のサポートを[発表しました][swan taproot tweet]。

- **Wallet of SatoshiがTaprootへの送金をサポート:**
  モバイルのBitcoinおよびLightningウォレットである[Wallet of Satoshi][wallet of satoshi website]が、
  Taprootへの送金のサポートを[発表しました][wallet of satoshi tweet]。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--what-is-the-script-assembly-and-execution-in-p2tr-spend-spend-from-taproot-->P2TR支払い（Taprootからの支払い）におけるScriptの組み立てや実行とは？]({{bse}}111098)
  Pieter Wuilleは、[BIP341][]の簡略化した例で、Taprootアウトプットの構築、keypathを使った支払い、
  scriptpathを使った支払い、支払いの検証について詳細な解説をしています。

- [<!--how-can-i-find-samples-for-p2tr-transactions-on-mainnet-->mainnetでP2TRトランザクションのサンプルを見つけるにはどうしたらいいですか？]({{bse}}110995)
  Murchは、最初のP2TRトランザクション、scriptpathとkeypathをインプットとした最初のトランザクション、
  複数のkeypathインプットを持つ最初のトランザクション、2-of-2のマルチシグのscriptpathでの最初の支払いトランザクション、
  新しい[Tapscript][topic tapscript]の`OP_CHECKSIGADD` opcodeを最初に使用しているトランザクションに関する
  [ブロックエクスプローラー][topic block explorers]のリンクを示しています。

- [<!--does-a-miner-adding-transactions-to-a-block-while-mining-reset-the-block-s-pow-->マイナーがマイニング中にブロックにトランザクションを追加すると、ブロックのPoWはリセットされますか？]({{bse}}110903)
  Pieter Wuilleは、マイニングには[進捗というものがない][oconnor blog]と説明しています。
  ブロックを解くための各ハッシュの試行は、現在マイニング中のブロックに新しいトランザクションが追加された場合も含めて、
  これまでに行われた作業から独立しています。

- [<!--can-schnorr-aggregate-signatures-be-nested-inside-other-schnorr-aggregate-signatures-->Schnorrの集約署名を他のSchnorrの集約署名内にネストすることは可能ですか？]({{bse}}110862)
  Pieter Wuilleは、[Schnorr署名][topic schnorr signatures]を用いた鍵の集約スキームの実現可能性について
  「署名者に'姪/甥'の鍵の知識がなくても、鍵を階層的に集約することができる」と説明しています。
  彼は、[MuSig2][topic musig]がネストと互換性を持つように設計されており、
  セキュリティの証明は存在しないものの、このユースケースに合わせて変更することができると述べています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23716][]は、Bitcoin CoreのテストコードにRIPEMD-160のネイティブなPython実装を追加しています。
  これにより、Bitcoin Coreは、OpenSSLのRIPEMD-160実装をラップしたPythonの`hashlib`ライブラリのRIPEMD-160関数を使用しなくなりました。
  OpenSSLの新しいバージョンでは、デフォルトでRIPEMD-160のサポートが提供されなくなったため、別途有効にする必要があります。

- [Bitcoin Core #20295][]は、新しいRPC `getblockfrompeer`を追加し、
  特定のピアから特定のブロックを手動で要求できるようになりました。
  このRPCの用途は、フォークの監視や研究目的で、古くなったchaintipを取得することです。

- [Bitcoin Core #14707][]は、複数のRPCを更新し、
  マイナーのコインベーストランザクションのアウトプットから受信したビットコインを含めるようにしました。
  RPCの新しい`include_immature_coinbase`オプションにより、
  成熟する（コンセンサスルールにより最も早く使用可能になる100承認）前のコインベーストランザクションを
  含めるかどうかを切り替えられるようになりました。

- [Bitcoin Core #23486][]は、ScriptがP2SHもしくはP2WSHで使用できる場合にのみ、
  ScriptのP2SHアドレスもしくはP2WSHアドレスを返すよう`decodescript` RPCを更新しました。

- [BOLTs #940][]は、`node_announcements`でTor v2 onionのアナウンスとパースを非推奨にしました。
  [Rust-Lightning #1204][]も、今週マージされ、この仕様に従うように実装を更新しています。

- [BOLTs #918][]は、pingメッセージのレート制限を削除しました。`ping`メッセージは、
  主にピアの接続がまだ生きているかどうかを確認するために使われます。
  このマージ以前は、`ping`メッセージは、最大で30秒に1回送信されるものでした。
  多くのノードでは、高品質のサービスを保証するために、`ping`によるハートビートメッセージをより頻繁に送信することが有用です。
  他のLightningメッセージはレート制限されていないため、`ping`メッセージの30秒のレート制限も撤廃されました。

- [BOLTs #906][]では、[ニュースレター #165][news165 channel_type]に掲載した、
  `channel_type`機能に新しいfeature bitが追加されています。
  このbitを追加することで、将来のノードが新機能を理解したピアだけを選択することが簡単になります。

## 年末年始の発行スケジュール

Happy holiday! 今号が年内最後の定期的なニュースレターになります。
来週は、毎年恒例の1年を振り返る特別号を発行します。
1月5日（水）からは通常の発行に戻ります。

{% include references.md %}
{% include linkers/issues.md issues="867,23716,20295,14707,23486,940,906,1204,918" %}
[news162 unec]: /ja/newsletters/2021/08/18/#dust-limit
[rubin unec]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-December/019635.html
[somsen unec]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-December/019637.html
[teinturier post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-December/003377.html
[ln docs 16]: https://github.com/t-bast/lightning-docs/pull/16
[news120 opt_simp_update]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[news152 ff]: /ja/newsletters/2021/06/09/#receiving-ln-payments-with-a-mostly-offline-private-key-ln
[news165 channel_type]: /ja/newsletters/2021/09/08/#bolts-880
[sbw 2.4.22]: https://github.com/btcontract/wallet/releases/tag/2.4.22
[bluewallet 6.2.14]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.2.14
[cash app bech32m]: https://cash.app/help/us/en-us/20211114-bitcoin-taproot-upgrade
[trezor taproot blog]: https://blog.trezor.io/trezor-suite-and-firmware-updates-december-2021-d1e74c3ea283
[swan taproot tweet]: https://twitter.com/SwanBitcoin/status/1468318386916663298
[wallet of satoshi website]: https://www.walletofsatoshi.com/
[wallet of satoshi tweet]: https://twitter.com/walletofsatoshi/status/1459782761472872451
[oconnor blog]: http://r6.ca/blog/20180225T160548Z.html
