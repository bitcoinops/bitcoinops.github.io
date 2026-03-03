---
title: 'Bitcoin Optech Newsletter #369'
permalink: /ja/newsletters/2025/08/29/
name: 2025-08-29-newsletter-ja
slug: 2025-08-29-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、BitcoinとLN実装の差分ファジングに関する最新情報の共有と、
アカウンタブルコンピューティングコントラクト用のGarbled Lockに関する新しい論文のリンクを掲載しています。
また、Bitcoin Stack Exchangeで人気の質問とその回答や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき更新など
恒例のセクションも含まれています。

## ニュース

- **BitcoinとLN実装の差分ファジングに関する最新情報:** Bruno Garciaは、
  Bitcoinベースのソフトウェアおよびライブラリの[ファジングテスト][fuzz testing]用のライブラリと関連データである
  [bitcoinfuzz][]の最新の進捗と成果についてDelving Bitcoinに[投稿しました][garcia fuzz]。
  成果には、「btcd、rust-bitcoin、rust-miniscript、Embit、Bitcoin Core、
  Core Lightning、[および] LNDなどのプロジェクトで35件以上のバグの発見」が含まれています。
  LN実装間の矛盾の発見は、バグの発見だけでなく、LN仕様の明確化にもつながりました。
  Bitcoinプロジェクトの開発者は、自身のソフトウェアをbitcoinfuzzのサポート対象とすることを検討することをお勧めします。

- **アカウンタブルコンピューティング用のGarbled Lock:**
  Liam Eagenは、[Garbled Circuit][garbled circuits]に基づく
  [アカウンタブルコンピューティングコントラクト][topic acc]を作成するための新しい仕組みに関する
  [論文][eagen paper]をBitcoin-Devメーリングリストに[投稿しました][eagen glock]。
  これはBitVMでGarbled Circuitを使用する最近の他の独立した研究（[ニュースレター
  #359][news359 delbrag]参照）と類似していますが、異なるものです。
  Eagenの投稿では、「（彼の見解では）単一の署名で不正を証明する初の実用的なGarbled Lockであり、
  BitVM2と比較してオンチェーンデータを550分の1以上削減できる」と主張しています。
  本稿執筆時点では、この投稿に対する返信はありませんでした。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--is-it-possible-to-recover-a-private-key-from-an-aggregate-public-key-under-strong-assumptions-->強力な仮定の下で、集約公開鍵から秘密鍵を復元することは可能ですか？]({{bse}}127723)
  Pieter Wuilleは、[MuSig2][topic musig]スクリプトレス[マルチシグ][topic multisignature]に関する
  現状および仮設的なセキュリティ仮定について説明しています。

- [すべてのTaprootアドレスは量子コンピューターに対して脆弱ですか？]({{bse}}127660)
  Hugo NguyenとMurchは、スクリプトパスのみで使用可能なように構築された[Taproot][topic taproot]アウトプットであっても、
  [量子コンピューター][topic quantum resistance]に対して脆弱であると指摘しています。
  Murchはさらに、「興味深いことに、アウトプットスクリプトを生成した当事者は、
  内部鍵がNUMSポイントであることを示すことができ、量子コンピューターで復号されたことが証明できるでしょう」と述べています。

- [chainstateの難読化鍵はなぜ設定できないのですか？]({{bse}}127814)
  Ava Chowは、`blocksdir`のディスク上の内容を難読化する鍵（[ニュースレター #339][news339 blocksxor]参照）は、
  `chainstate`の内容を難読化する鍵（[Bitcoin Core #6650][]参照）とは異なることを指摘しています。

- [<!--is-it-possible-to-revoke-a-spending-branch-after-a-block-height-->あるブロック高以降に使用条件を取り消すことは可能ですか？]({{bse}}127683)
  Antoine Poinsotは、期限切れの支払い条件、つまり「逆タイムロック」は不可能であり、
  おそらく望ましくさえないことを確認する[以前の回答]({{bse}}122224)を指摘しています。

- [IPv4およびIPv6のノードに加えて、Onionノードを使用するようにBitcoin Coreを設定するにはどうしたらいいですか？]({{bse}}127727)
  Pieter Wuilleは、`onion`設定オプションの設定はアウトバウンドピア接続にのみ適用されることを明確にしています。
  さらに、インバウンド接続用に[Tor][topic anonymity networks]と`bitcoind`を設定する方法についても概説しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 29.1rc2][]は、主要なフルノードソフトウェアのメンテナンスバージョンのリリース候補です。

- [Core Lightning v25.09rc4][]は、この人気のLNノード実装の新しいメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31802][]は、プロセス間通信（IPC）をデフオルトで有効化（`ENABLE_IPC`）し、
  Windowsを除くすべてのシステムのリリースビルドに`bitcoin-node`および
  `bitcoin-gui`マルチプロセスバイナリを追加しました。これにより、
  ブロックテンプレートを作成、管理、送信する外部の[Stratum v2][topic pooled mining]マイニングサービスが、
  カスタムビルドなしでマルチプロセスレイアウトを試すことができます。
  マルチプロセスプロジェクトと`bitcoin-node`バイナリの詳細については、
  ニュースレター[#99][news99 ipc]、[#147][news147 ipc]、[#320][news320 ipc]、
  [#323][news323 ipc]をご覧ください。

- [LDK #3979][]は、スプライス・アウトのサポートを追加しました。
  これにより、LDKノードはスプライス・アウトトランザクションを開始するだけでなく、
  相手方からの要求を受け入れることも可能になります。
  [LDK #3736][]で既にスプライス・インがサポートされているため、
  これでLDKの[スプライシング][topic splicing]実装は完了です。
  このPRでは、`SpliceContribution`列挙型を追加しています。
  これはインとアウトの両方のシナリオをカバーし、手数料とチャネルリザーブ要件を考慮した後の
  スプライスアウトトランザクションのアウトプットの金額がユーザーのチャネル残高を超えないことを保証します。

- [LND #10102][]は、`gossip.ban-threshold`オプション（デフォルトは100、無効化は0）を追加します。
  これにより、無効な[ゴシップ][topic channel announcements]メッセージを送信したピアを禁止するスコアの閾値を設定できます。
  ピアの禁止システムは以前導入され、[ニュースレター #319][news319 ban]で取り上げています。
  このPRは、バックログゴシップクエリ要求への応答として不要なノードおよび
  [チャネルアナウンス][topic channel announcements]メッセージが送信される問題も解決します。

- [Rust Bitcoin #4907][]は、`Script`と`ScriptBuf`に新しい汎用タグパラメーター`T`を追加することで
  スクリプトのタグ付けを導入し、コンパイル時のロールの安全性のためにシールされた`Tag`
  traitでサポートされている型エイリアス `ScriptPubKey`、`ScriptSig`、`RedeemScript`、
  `WitnessScript`および`TapScript`を定義します。

{% include snippets/recap-ad.md when="2025-09-02 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31802,3979,10102,4907,6650,3736" %}
[bitcoin core 29.1rc2]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[core lightning v25.09rc4]: https://github.com/ElementsProject/lightning/releases/tag/v25.09rc4
[garcia fuzz]: https://delvingbitcoin.org/t/the-state-of-bitcoinfuzz/1946
[bitcoinfuzz]: https://github.com/bitcoinfuzz
[fuzz testing]: https://en.wikipedia.org/wiki/Fuzzing
[eagen glock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Aq_-LHZtVdSN5nODCryicX2u_X1yAQYurf9UDZXDILq6s4grUOYienc4HH2xFnAohA69I_BzgRCSKdW9OSVlSU9d1HYZLrK7MS_7wdNsLmo=@protonmail.com/
[eagen paper]: https://eprint.iacr.org/2025/1485
[garbled circuits]: https://en.wikipedia.org/wiki/Garbled_circuit
[news359 delbrag]: /ja/newsletters/2025/06/20/#bitvm
[news339 blocksxor]: /ja/newsletters/2025/01/31/#blocks-dat-blocksxor
[news99 ipc]: /en/newsletters/2020/05/27/#bitcoin-core-18677
[news147 ipc]: /ja/newsletters/2021/05/05/#bitcoin-core-19160
[news320 ipc]: /ja/newsletters/2024/09/13/#bitcoin-core-30509
[news323 ipc]: /ja/newsletters/2024/10/04/#bitcoin-core-30510
[news319 ban]: /ja/newsletters/2024/09/06/#lnd-9009