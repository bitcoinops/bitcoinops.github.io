---
title: 'Bitcoin Optech Newsletter #318'
permalink: /ja/newsletters/2024/08/30/
name: 2024-08-30-newsletter-ja
slug: 2024-08-30-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinのマイニングについて議論するための新しいメーリングリストを発表します。
また、Bitcoin Stack Exchangeで人気のある質問とその回答や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの最近の変更など恒例のセクションも含まれています。

## ニュース

- **新しいBitcoinマイニング開発メーリングリスト:** Jay Beddictは、「Bitcoinのマイニング技術のアップデートや、
  Bitcoin関連のソフトウェアやプロトコルの変更がマイニングに与える影響について議論する」ための新しいメーリングリストを
  [発表しました][beddict mining-dev]。

  Mark "Murch" Erhardtは、[testnet4][topic testnet]に導入された[タイムワープ][topic time warp]の修正が
  mainnetにも導入された場合（[クリーンアップソフトフォーク][topic consensus cleanup]の一部などで）、
  マイナーが無効なブロックを作成する可能性があるかどうかをメーリングリストに[投稿しました][erhardt warp]。
  Mike Schmidtは、メーリングリストの読者に、Bitcoin-Devメーリングリストの
  [不明瞭なシェア][topic block withholding]（[ニュースレター #315][news315 oblivious]参照）に関する
  [スレッド][towns oblivious]を紹介しました。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [すべてのトランザクションを知らないノードが検証前にBIP152コンパクトブロックを送信することはできますか？]({{bse}}123858)
  Antoine Poinsotは、ブロックヘッダーにコミットされたすべてのトランザクションを検証する前に
  [コンパクトブロック][topic compact block relay]を転送することはサービス拒否のベクトルになると指摘しています。

- [Segwit (BIP141)は、BIP62に記載されているすべてのtxidのマリアビリティの問題を解消していますか？]({{bse}}124074)
  Vojtěch Strnadは、txidが不正に操作されるさまざまな方法、segwitがマリアビリティに対処した方法、
  意図しないマリアビリティとは何か、ポリシー関連のプルリクエストについて説明しています。

- [<!--why-are-the-checkpoints-still-in-the-codebase-in-->なぜチェックポイントは2024年になってもコードベースに残っているのですか？]({{bse}}123768)
  Lightlikeは、[「Headers Presync」][news216 headers presync]の追加により、
  Bitcoin Coreのコードベースにはチェックポイントに対する _既知の_ 要件がないと指摘していますが、
  チェックポイントが防御している _未知の_ 攻撃ベクトルが存在する可能性があることを強調しています。

- [Bulletproof++はSNARKsのような汎用ZKPですか？]({{bse}}119556)
  Liam Eagenは、現在使用されているような簡潔な非対話型知識証明（SNARKs）の種類と、
  Bulletproofや[BitVM][topic acc]、[OP_CAT][topic op_cat]を使用して
  Bitcoin Scriptでそのような証明を検証する方法について詳しく説明しています。

- [OP_CATはどのようにして追加のコベナンツを実装できるのでしょうか？]({{bse}}123829)
  Brandon - Reardenは、提案中のOP_CAT opcodeがBitcoin
  Scriptに[コベナンツ][topic covenants]の機能を提供する方法について説明しています。

- [一部のbech32ビットコインアドレスに大量の'q'が含まれるのはなぜですか？]({{bse}}123902)
  Vojtěch Strnadは、OLGAプロトコルが任意のデータをP2WSHアウトプットにエンコードする際、
  そのスキームの一部でゼロパディングが必要になることを明らかにしました（[bech32][topic bech32]では、
  0は'q'としてエンコードされます）。

- [<!--how-does-a-0-conf-signature-bond-work-->0-conf署名ボンドはどのように機能しますか？]({{bse}}124022)
  Matt Blackは、OP_CATベースのコベナンツにロックされた資金が、
  支払人に[RBF][topic rbf]による手数料の引き上げを行わないようにするインセンティブを与え、
  ゼロ承認トランザクションの受け入れを増やす可能性があることを概説しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 24.08rc2][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。

- [LND v0.18.3-beta.rc1][]は、この人気のLNノード実装の軽微なバグ修正リリースのリリース候補です。

- [BDK 1.0.0-beta.2][]は、ウォレットやその他のBitcoin対応アプリケーションを構築するためのこのライブラリのリリース候補です。
  元の`bdk` Rustクレートの名前が`bdk_wallet`変更され、 低レイヤーのモジュールは、
  `bdk_chain`、`bdk_electrum`、`bdk_esplora`、`bdk_bitcoind_rpc`などの独自のクレートに抽出されました。
  `bdk_wallet`クレートは、「安定した 1.0.0 API を提供する最初のバージョンです」。

- [Bitcoin Core 28.0rc1][]は、主要なフルノード実装の次期メジャーバージョンのリリース候補です。
  [テストガイド][bcc testing]は準備中です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [LDK #3263][]は、`ResponseInstruction`構造体からメッセージタイプパラメーターを削除し、
  更新された`ResponseInstruction`に基づいて、[ブラインド][topic rv routing]応答パスと非ブラインド応答パスの両方を処理できる
  新しい`MessageSendInstructions`列挙型を導入することで、[Onionメッセージ][topic onion messages]の応答の処理方法を簡素化します。
  `send_onion_message`メソッドは、`MessageSendInstructions`を使用するようになったため、
  ユーザーは自分で経路探索を行うことなく応答パスを指定できます。
  新しいオプションである`MessageSendInstructions::ForReply`を使用すると、
  メッセージハンドラーはコード内で循環依存関係を作成することなく、後で応答を送信できます。
  ニュースレター[#303][news303 onion]をご覧ください。

- [LDK #3247][]は、チャネル残高を取得するためのより直接的で正確なアプローチを提供する
  `ChannelMonitor::get_claimable_balances`メソッドを優先し、
  `AvailableBalances::balance_msat`メソッドを非推奨にします。
  非推奨となったメソッドのロジックは、残高に保留中のHTLC（後で取り消される可能性のあるもの）が含まれている場合に
  アンダーフローが発生する問題を処理するために設計されたものであったため、今となっては旧式なものです。

- [BDK #1569][]では、`bdk_core`クレートが追加され、`bdk_chain`からいくつかの型（
  `BlockId`、`ConfirmationBlockTime`、`CheckPoint`、`CheckPointIter`、`tx_graph::Update`、
  `spk_client`）が移動されました。`bdk_esplora`、`bdk_electrum`および
  `bdk_bitcoind_rpc`チェーンソースは、`bdk_core`にのみ依存するように変更されました。
  これらの変更は、`bdk_chain`でのリファクタリングを高速化するために行われました。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3263,3247,1569" %}
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[news315 oblivious]: /ja/newsletters/2024/08/09/#block-withholding-attacks-and-potential-solutions
[beddict mining-dev]: https://groups.google.com/g/bitcoinminingdev/c/97fkfVmHWYU
[erhardt warp]: https://groups.google.com/g/bitcoinminingdev/c/jjkbeODskIk
[schmidt oblivious]: https://groups.google.com/g/bitcoinminingdev/c/npitVsP9KNo
[towns oblivious]: https://groups.google.com/g/bitcoindev/c/1tDke1a2e_Q
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news216 headers presync]: /ja/newsletters/2022/09/07/#bitcoin-core-25717
[news303 onion]: /ja/newsletters/2024/05/17/#ldk-2907