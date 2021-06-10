---
title: 'Bitcoin Optech Newsletter #152'
permalink: /ja/newsletters/2021/06/09/
name: 2021-06-09-newsletter-ja
slug: 2021-06-09-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNノードが常に秘密鍵をオンラインにしておかなくても支払いを受け取れるようにする提案を掲載しています。
また、Bitcoin Core PR Review Clubミーティングの概要や、
新しいソフトウェアのリリースおよびリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点などの恒例のセクションも含まれています。

## ニュース

- **<!--receiving-ln-payments-with-a-mostly-offline-private-key-->秘密鍵をほぼオフラインのままLN支払いを受け取る:**
  2019年、開発者のZmnSCPxjは、支払いを受け入れるためのネットワークの帯域幅とレイテンシーを削減する、
  保留中のLN支払い（[HTLC][topic htlc]）をカプセル化する別の方法を[提案しました][zmn ff]。
  最近、Lloyd Fournierがこのアイディアを利用して、秘密鍵をオンラインにしておかなくても、
  ノードが複数のLN支払いを受け入れることができるようにすることができると提案しました。
  しかし、このアイディアにはいくつかの欠点があります。

  - ノードは必要に応じてペナルティトランザクションを送信するために秘密鍵を必要とします。

  - ノードが秘密鍵を使用せずに受け取った支払いが多いほど、
    チャネルが一方的に閉じられた際に、より多くのオンチェーン手数料を支払う必要があります。

  - 受信ノードはプライバシーを失うことになります。つまり、
    そのノードが単なるルーティング・ホップではなく、支払いの最終的な受信者であることを
    近隣のピアが判断できるようになります。
    しかし、支払いをルーティングしない一部のエンドユーザーノードにとっては、
    これはすでに明らかな場合があります。

  これらの制限の中で、アイディは実行可能と思われ、今週メーリングリストでは、
  ZmnSCPxjが分かりやすい[プレゼンテーション][zmn preso]を行い、そのバリエーションが[議論][zmn revive]されました。
  Fournier laterは、アイディアの改善を[提案しました][fournier asym]。

  アイディアを実装するには、いくつか重要なLNプロトコルの変更が必要になるため、
  ユーザーが短期または中期的に利用できるようになることはなさそうです。
  ただし、LNの受信ノードがオンラインで鍵を保持する必要性を最小限に抑えたいと考えている人は、
  このアイディアを調査することをお勧めします。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Prune g_chainman usage in auxiliary modules][review club #21767]は、
Carl DongによるリファクタリングPR（[#21767][Bitcoin Core #21767]）で、
コンセンサスエンジンのモジュール化の第一歩として、
`g_chainman`を非グローバル化するプロジェクトの一部です。
これにより、コンポーネントが分離され、より焦点を絞ったテストが可能になります。
長期的な目標は、コンセンサスエンジンを非コンセンサスコードから完全に分離することです。

Review Clubの議論は、コードの変更について深く掘り下げる前に、以下のような一般的な質問から始まりました:

{% include functions/details-list.md
  q0="<!--this-pr-is-a-refactoring-and-should-not-change-any-functional-behaviour-what-are-some-ways-we-can-verify-that-->
      このPRはリファクタリングであり、機能的な動作を変更してはいけません。
      それを検証するには、どのような方法がありますか？"
  a0="コードを注意深くレビューすること、テストを実行すること、テストのカバレッジを追加すること、
      assertやカスタムログを挿入すること、`--enable-debug`でビルドすること、
      変更を加えたbitcoindを実行すること、GDBやLLDBなどのデバッガでコードをステップ実行することなどです。"
  a0link="https://bitcoincore.reviews/21767#l-53"

  q1="<!--this-pr-is-part-of-a-larger-project-to-modularize-and-separate-the-bitcoin-core-consensus-engine-what-are-some-benefits-of-doing-that-->
      このPRは、Bitcoin Coreのコンセンサスエンジンをモジュール化して分離するというより大きなプロジェクトの一部です。
      これにはどんなメリットがありますか？"
  a1="そうすることで、コードの推論、保守、構成およびテストが容易になります。
      セキュリティとメンテナンス性のために最小限のAPIを公開し、非グローバルデータを渡すための設定オプションを提供できます。
      さまざまな設定でそれらのオブジェクトをより細かく制御できるように、
      可変パラメータを使用してコンポーネントを構築できます。"
  a1link="https://bitcoincore.reviews/21767#l-63"

  q2="<!--what-is-the-chainstatemanager-responsible-for-->`ChainstateManager`の責務は何ですか？"
  a2="[`ChainstateManager`][ChainstateManager]クラスは、1つまたは2つのchainstate（
      Initial Block Download (IBD)とオプションのスナップショット）を作成し操作するためのインターフェースを提供します。"
  a2link="https://bitcoincore.reviews/21767#l-117"

  q3="<!--what-does-cchainstate-do-->`CChainState`は何をするのですか？"
  a3="[`CChainState`][CChainState]クラスは、現在の最長チェーンを保存し、
      その状態に関するローカルの情報を更新するためのAPIを提供します。"
  a3link="https://bitcoincore.reviews/21767#l-174"

  q4="<!--what-is-the-cchain-class-->`CChain`クラスとは何ですか？"
  a4="[`CChain`][CChain]クラスは、メモリ内のインデックスされたブロックのチェーンです。
      [ブロックインデックスポインターのvector][cchain vectors]が含まれています。"
  a4link="https://bitcoincore.reviews/21767#l-120"

  q5="<!--what-is-the-blockmanager-responsible-for-->`BlockManager`の責務は何ですか？"
  a5="[`BlockManager`][BlockManager]クラスは、`m_block_index`に保存されたブロックのツリーを維持し、
      これを参照して最も作業の多いチェーンの先頭を探します。"
  a5link="https://bitcoincore.reviews/21767#l-121"

  q6="<!--what-is-cs-main-->`cs_main`とは何ですか？"
  a6="`cs_main`は、バリデーション固有のデータ（および今のところ、他の多くのもの）を保護するためのmutexです。
      名前は、[*critical section main*][csmain1]を意味し、`main.cpp`のデータを保護するものです。
      現在、`validation.cpp`および`net_processing.cpp`にあるコードは、
      [以前は`main.cpp`という1つのファイルにありました][csmain2]。"
  a6link="https://bitcoincore.reviews/21767#l-202"

  q7="<!--conceptually-when-we-refer-to-the-validation-part-of-the-codebase-what-does-that-include-->
      概念的に、コードベースの\"Validation\"部分には何が含まれるのでしょうか？"
  a7="Validationは、ブロックチェーンと関連するUTXOセットの最長のビューを格納、維持します。
      また未承認トランザクションをmempoolに登録するインターフェースも含まれます。"
  a7link="https://bitcoincore.reviews/21767#l-228"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.13.0-beta.rc5][LND 0.13.0-beta]は、プルーニングされたBitcoinフルノードの使用をサポートし、
  Atomic MultiPath ([AMP][topic multipath payments])を使用した支払いの送受信を可能にし、
  [PSBT][topic psbt]機能の向上、その他の改善およびバグ修正を行ったリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #22051][]では、
  [Taproot][topic taproot]アウトプットの[descriptor][topic descriptors]
  をBitcoin Coreウォレットにインポートするためのサポートを追加しています。
  このPRは、ウォレットユーザーがTaprootアウトプットで資金を受け取れるようにし、
  ユーザーがTaprootをアウトプットを受け取り使用できるようにする完全なサポートを実装する
  [公開中のPR][Bitcoin Core #21365]の前提条件になります。

- [Bitcoin Core #22050][]は、バージョン2のTor onion service（Hidden service）のサポートを止めました。
  バージョン2のサービスは既に非推奨で、Torプロジェクトは9月にアクセスできなくなることを発表しています。
  Bitcoin Coreは既にバージョン3のonion serviceをサポートしています（[ニュースレター #132][news132 v3onion] 参照）。

- [Bitcoin Core #22095][]では、Bitcoin Coreが[BIP32][]秘密鍵を導出する方法をチェックするテストが追加されています。
  Bitcoin Coreでは常にこれらの鍵を正しく導出していましたが、
  最近他のウォレットが32バイト未満の拡張秘密鍵（xpriv）のパディングに失敗したことで、
  128個の鍵のうち１つ以上を誤って導出していることが[判明しました][btcd issue]。
  これは資金の損失やセキュリティの低下に直接つながるものではありませんが、
  あるウォレットでHDウォレットのシードを作成し、それを別のウォレットにインポートする、もしくは
  マルチシグウォレットを作成するユーザーにとっては問題になります。
  このPRで実装されたTest Vectorは、
  将来のウォレット作成者がこの問題を回避できるようBIP32にも[追加されています][bips #1030]。

- [C-Lightning #4532][]では、[チャネルのアップグレード][bolts #868]の実験的なサポートを追加しています。
  最新のコミットメントトランザクションを再構築することで、
  例えば[Taproot][topic taproot]を使用するように変換するといった、
  新機能や構造的な変更を組み込めるようになります。
  プロトコルは[休止][bolts #869]要求で始まり、
  どちらの参加者も休止期間が終わるまで状態の更新を送信しないという合意をします。
  この期間、ノードは自分たちがしたい変更をネゴシエートし、それを実行します。
  最後に、チャネルは完全な動作状態に戻ります。
  C-Lightningでは現在、チャネルが既に強制的な非アクティブ期間にある場合の接続の再確立中にこれを実装しています。
  チャネルのアップグレードについては、さまざまな提案が[ニュースレター #108][news108 channel upgrades]で議論され、
  このPRの作者は[ニュースレター #109][news109 simplified htlc]に掲載された
  "simplified HTLC negotiation"に取り組むのもあって、この機能を望んでいます。
  このPRにより、C-Lightningが2019年に初めてサポートした
  `option_static_remotekey`（[ニュースレター #64][news64 static remotekey]参照）
  を利用できるよう古いチャネルをアップグレードすることができます。

- [LND #5336][]では、新しいPayment Secretを指定することで、
  ユーザーが[AMP][topic multipath payments]インボイスを非対話的に再利用できる機能を追加しています。
  また、前述の再利用の仕組みを促進するために、
  LNDで作成されたAMPインボイスのデフォルトのインボイス有効期限も30日に引き上げられています。

- [BTCPay Server #2474][]では、すべての通常のフィールド（ダミーデータ）を含む偽のイベントを送信することで
  Webhookをテストする機能が追加されています。
  これは、StripeやCoinbase Commerceのような中央でホストされているBitcoinのペイメントプロセッサで利用できるテスト機能を反映してます。

{% include references.md %}
{% include linkers/issues.md issues="22051,22050,22095,4532,869,5336,2474,1030,868,21767,21365" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc5
[news64 static remotekey]: /en/newsletters/2019/09/18/#c-lightning-3010
[news108 channel upgrades]: /en/newsletters/2020/07/29/#upgrading-channel-commitment-formats
[news109 simplified htlc]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[zmn ff]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-April/001986.html
[zmn revive]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-May/003038.html
[zmn preso]: https://zmnscpxj.github.io/offchain/2021-06-fast-forwards.odp
[fournier asym]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-June/003045.html
[btcd issue]: https://github.com/btcsuite/btcutil/issues/172
[news132 v3onion]: /ja/newsletters/2021/01/20/#bitcoin-core-0-21-0
[cchain vectors]: https://bitcoincore.reviews/21767#l-196
[csmain1]: https://bitcoincore.reviews/21767#l-216
[csmain2]: https://bitcoincore.reviews/21767#l-213
[ChainstateManager]: https://github.com/bitcoin/bitcoin/blob/7a799c9/src/validation.h#L759
[CChainState]: https://github.com/bitcoin/bitcoin/blob/7a799c9/src/validation.h#L502
[CChain]: https://github.com/bitcoin/bitcoin/blob/7a799c9/src/chain.h#L391
[BlockManager]: https://github.com/bitcoin/bitcoin/blob/7a799c9/src/validation.h#L343
