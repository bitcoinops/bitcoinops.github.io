---
title: 'Bitcoin Optech Newsletter #178'
permalink: /ja/newsletters/2021/12/08/
name: 2021-12-08-newsletter-ja
slug: 2021-12-08-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、手数料の引き上げ方法の研究に関する投稿と、
Bitcoin Core PR Review Clubミーティングのまとめや、
Bitcoinソフトウェアの最新のリリースおよびリリース候補、
人気のあるインフラストラクチャプロジェクトの注目すべき変更点などの恒例のセクションを掲載しています。

## ニュース

- **<!--fee-bumping-research-->手数料の引き上げ方法の研究:**
  Antoine Poinsotは、[Vault][topic vaults]やLNのようなコントラクトプロトコルで使用されている
  事前署名されたトランザクションの手数料の引き上げ方法を選択する際に、
  開発者が考慮しなければならないいくつかの懸念事項についての詳細な説明をBitcoin-Devメーリングリストに[投稿しました][darosior bump]。
  特に、Poinsotは、参加者が2人より多いマルチパーティプロトコルのスキームについて検討しています。
  このようなスキームでは現在の[CPFP carve out][topic cpfp carve out]を利用したトランザクションリレーポリシーが機能せず、
  [トランザクションのPinning][topic transaction pinning]に対して脆弱な可能性がある
  [トランザクションの置換][topic rbf]の仕組みを使用する必要があります。
  また、彼の投稿には、先行研究されたアイディアのいくつかを[調査した][revault research]結果も含まれています。

  手数料の引き上げが確実に機能することは、ほとんどのコントラクトプロトコルの安全性を確保するための要件であり、
  まだ包括的な解決策がない問題です。この問題の研究が続けられているのは心強いことです。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Treat taproot as always active][review club #23512]は、Marco FalkeによるPRで、
[Taproot][topic taproot]のデプロイ状況に関わらず、Taprootを使用するトランザクションアウトプットを標準とするものです。

{% include functions/details-list.md
  q0="<!--which-areas-in-the-codebase-use-the-status-of-taproot-deployment-which-of-them-are-policy-related-->
  コードベースのどの部分が、Taprootのデプロイ状態を使用していますか？
  ポリシーに関連するものはどれですか？"
  a0="このPRの前から、4つの関連箇所があります:
  [GetBlockScriptFlags()][GetBlockScriptFlags tap] (コンセンサス)、
  [AreInputsStandard()][AreInputsStandard tap] (ポリシー)、
  [getblockchaininfo()][getblockchaininfo tap] (RPC)、
  [isTaprootActive()][isTaprootActive tap] (ウォレット)。"
  a0link="https://bitcoincore.reviews/23512#l-21"

  q1="<!--what-mempool-validation-function-checks-if-a-transaction-spends-a-taproot-input-how-does-this-pr-change-the-function-->
  トランザクションがTaprootのインプットを使用する際に、チェックするmempoolのバリデーション関数はどれですか？
  このPRではその関数をどう変更していますか？"
  a1="関数は[`AreInputsStandard()`][AreInputsStandard def]です。
  このPRでは、関数の最後の引数`bool taproot_active`を削除し、
  Taprootのアクティベーション状態に関係なくv1 segwit (taproot)の支払いに対して`true`を返します。
  これまでは、Taprootのアウトプットが見つかっても、`taproot_active`がfalseであれば、この関数はfalseを返していました。
  例えばノードがまだ初期ブロックダウンロード中でTaprootをアクティベーションする前のブロックを同期中の場合など。"
  a1link="https://bitcoincore.reviews/23512#l-40"

  q2="<!--are-there-any-theoretical-issues-with-the-change-for-wallet-users-is-it-possible-to-lose-money-->
  この変更による理論的な問題はありますか？ウォレットのユーザーが、資金を失う可能性がありますか？"
  a2="この変更により、ウォレットはいつでも、つまりTaprootが有効でなくv1 segwitのアウトプットを誰もが勝手に使用できる場合でも、
  Taprootの[descriptor][topic descriptors]をインポートすることができます。
  これは、Taprootがまだ有効でなくてもTaprootのアウトプットでビットコインを受け取ることができることを意味します。
  もし、チェーンが709,632より前のブロックに再編成された場合、
  マイナー（もしくは非標準トランザクションを承認させることができる人）はそれらのUTXOを盗むことができます。"
  a2link="https://bitcoincore.reviews/23512#l-82"

  q3="<!--theoretically-is-it-possible-for-a-mainnet-chain-that-has-taproot-never-active-or-active-at-a-different-block-height-to-exist-->
  理論的には、Taprootを決して有効にしない、もしくは異なるブロック高で有効にするmainnetのチェーンが存在する可能性はありますか？"
  a3="どちらも可能です。もし、（Taprootのロックイン前にフォークするような）とても大きな再編成が発生した場合、
  デプロイプロセスが繰り返されます。この新しいチェーンでは、
  Taprootのシグナルを送るブロックの数が閾値に達しなければ、（まだ有効な）チェーンではTaprootは有効になりません。
  最小のアクティベーションブロック高の後、かつタイムアウトの前に閾値に達した場合は、
  Taprootはそれ以降のブロック高で有効にできます。"
  a3link="https://bitcoincore.reviews/23512#l-130"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BDK 0.14.0][]は、ウォレット開発者向けのこのライブラリの最新リリースです。
  トランザクションへの`OP_RETURN`アウトプットの追加が簡単になり、
  [Taproot][topic taproot]用の[bech32m][topic bech32]アドレスへの支払いの送信の改善が含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23155][]は、`dumptxoutset` RPCを拡張し、
  chainstateスナップショット（UTXOセット）のハッシュと、その時点までのチェーン全体のトランザクション数を追加しました。
  この情報をchainstateと一緒に公開することで、他の人が`gettxoutsetinfo`RPCを使って検証することができ、
  提案されている[assumeUTXO][topic assumeutxo]を使ったノードのブートストラップで利用できます。

- [Bitcoin Core #22513][]では、`walletprocesspsbt`が[PSBT][topic psbt]をファイナライズせずに署名できるようになりました。
  これは複雑なScriptの場合に、例えば、署名者にアリスのみを必要とするフォールバックScriptと、
  アリスを含む複数の署名者を必要とする通常のScriptの２つのパスを持つ[Tapscript][topic tapscript]では、この機能が便利です。
  アリスが署名する場合、フォールバックScriptのパスでPSBTのファイナライズを遅らせ、
  代わりにアリスの署名を含むPSBTを構成し、PSBTを他の署名者に渡して彼らが署名するのを待つのが最善です。
  このシナリオでは、すべての署名が作成された後で最終的なパスが決定されます。

- [C-Lightning #4921][]では、[onionメッセージ][topic onion messages]の実装を、
  [ルート・ブラインディング][bolts #765]と[onionメッセージ][bolts #759]の仕様の最新の更新に合わせて更新しています。

- [C-Lightning #4829][]では、[BOLTs #911][]で提案されているLNプロトコルの変更に対する
  実験的なサポートを追加しています。これにより、
  ノードはIPアドレスやTorのオニオンサービスアドレスに代わってDNSアドレスを配信できます。

- [Eclair #2061][]では、[onionメッセージ][bolts #759]の初期サポートを追加しています。
  ユーザーは、onionメッセージをリレーするために`option_onion_messages`機能を有効にすることができ、
  `sendonionmessage` RPCを使ってonionメッセージを送信できます。
  受信したonionメッセージの処理と[ルート・ブラインディング][bolts #765]はまだ実装されていません。

- [Eclair #2073][]では、[BOLTs #906][]のドラフトで定義されているオプションのチャネルタイプを調整する
  feature bitのサポートを追加しています。
  これは[先週の][news177 lnd6026]LNDによる同じドラフト機能の実装に対応しています。

- [Rust-Lightning #1163][]では、リモートパーティがdust limit以下のチャネル・リザーブを設定できるようになりました。
  ゼロにすることも可能です。最悪の場合、これによりローカルノードは、
  完全にキャパシティを使用済みのチャネルからコストをかけずに資金を盗もうと試みることが可能になります。
  ただし、リモートパーティがチャネルを監視している場合、そのような試行は失敗します。
  デフォルトでは、ほとんどのリモートノードは適切なチャネル・リザーブを設定することで、
  このような試みを阻止しますが、一部のLightningサービスプロバイダー（LSP）は、
  ユーザーにより良い体験を提供するために（チャネル内の資金を100%使用できるように）、
  チャネルリザーブを低くしたりゼロにするのに使用します。
  リモートノードのみがリスクを取るため、ローカルノードがそのようなチャネルを受け入れることに問題はありません。

{% include references.md %}
{% include linkers/issues.md issues="23155,22513,4921,4829,2061,2073,906,1163,765,759,911,23512" %}
[bdk 0.14.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.14.0
[news177 lnd6026]: /ja/newsletters/2021/12/01/#lnd-6026
[darosior bump]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-November/019614.html
[revault research]: https://github.com/revault/research
[GetBlockScriptFlags tap]: https://github.com/bitcoin/bitcoin/blob/dca9ab48b80ff3a7dbe0ae26964a58e70d570618/src/validation.cpp#L1616
[AreInputsStandard tap]: https://github.com/bitcoin-core-review-club/bitcoin/blob/15d109802ab93b0af9647858c9d8adcd8a2db84a/src/validation.cpp#L726-L729
[getblockchaininfo tap]: https://github.com/bitcoin/bitcoin/blob/dca9ab48b80ff3a7dbe0ae26964a58e70d570618/src/rpc/blockchain.cpp#L1537
[isTaprootActive tap]: https://github.com/bitcoin-core-review-club/bitcoin/blob/15d109802ab93b0af9647858c9d8adcd8a2db84a/src/interfaces/chain.h#L292
[AreInputsStandard def]: https://github.com/bitcoin/bitcoin/blob/dca9ab48b80ff3a7dbe0ae26964a58e70d570618/src/policy/policy.h#L110
