---
title: 'Bitcoin Optech Newsletter #174'
permalink: /ja/newsletters/2021/11/10/
name: 2021-11-10-newsletter-ja
slug: 2021-11-10-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Discreet Log ContractをLNチャネルに統合する方法についての投稿と、
最近開催されたLN開発者カンファレンスの詳細な要約へのリンク、
Compact Block Filterの追加検証を行うためのアイディアを掲載しています。
また、Bitcoin Core PR Review Clubミーティングのまとめや、
Taprootのアクティベーションの準備についての最後のコラム、
新しいリリースとリリース候補の説明、
人気のあるインフラストラクチャソフトウェアの注目すべき変更点などの恒例のセクションも含まれています。

## ニュース

- **LNを介したDLC:** Thibaut Le Guillyは、
  DLC-Devメーリングリストで[Discreet Log Contract][topic dlc]のLNとの統合に関する[スレッド][leguilly thread]を立ち上げました。
  最初の投稿では、（共同でチャネルを運営するアリスとボブのような）
  2つの直接のLNピア間のトランザクションにDLCを含めるためのいくつかの可能な構成について説明しています。
  また、LNネットワークを介してルーティングされるDLCを作成する際のいくつかの課題についても説明しています。

- **LN summit 2021のメモ:** Olaoluwa Osuntokunは、
  最近チューリッヒで開催されたリモートおよび対面式のLN開発者会議の広範な要約を[投稿しました][osuntokun summary]。
  この要約には、[PTLC][topic ptlc]や[マルチシグ][topic multisignature]用の[MuSig2][topic musig]、
  [eltoo][topic eltoo]などLNでの[Taproot][topic taproot]の使用や、
  仕様に関する議論をIRCからビデオチャットに移行すること、
  現在のBOLT仕様モデルへの変更、オニオンメッセージと[Offer][topic offers]、
  スタックレスペイメント（[ニュースレター #53][news53 stuckless]参照）、
  [チャネルジャミング攻撃][topic channel jamming attacks]とその様々な緩和策および、
  [トランポリンルーティング][topic trampoline payments]に関するメモが含まれています。

- **Compact Block Filterの追加検証:**
  [Neutrino][]軽量版には、[Compact Block Filter][topic compact block filters]が正しいデータを含まない可能性を検出するヒューリスティックが含まれており、
  このヒューリスティックは、Taprootトランザクションを含むtestnetのブロックに対して正しく生成されたフィルターに対して誤ってエラーを報告していました。
  この問題について、Neutrinoのソースコードには既に[パッチがあてられており][neutrino #234]、
  他のCompact Block Filterの実装には影響はありませんが、
  Olaoluwa Osuntokunは問題と次のようなCompact Block Filterの将来の改善の可能性について、
  [Bitcoin-Dev][bd cbf thread]メーリングリストと[LND-Dev][ld cbf thread]メーリングリストにスレットを立ち上げました:

    - *<!--new-filters-->新しいフィルター:*
      軽量クライアントが他のタイプのデータを検索できるように、オプションのフィルター・タイプを追加で作成する。

    - *<!--new-p2p-protocol-message-->新しいP2Pプロトコルメッセージ:*
      ブロックのundoデータを取得するための新しいP2Pプロトコルメッセージを追加する。
      ブロックのundoデータには、ブロックで使用された各インプットが参照する以前のアウトプットが含まれており、
      これをブロックと組み合わせることで、そのデータからフィルターが作成されたことを完全に検証することができます。
      undoデータ自体は、ピア間で不一致が合った場合に、[検証することができます][harding undo verification]。

    - *<!--multi-block-filters-->マルチブロック・フィルター:*
      これにより軽量クライアントがダウンロードする必要のあるデータがさらに削減できます。

    - *<!--committed-block-filters-->コミットされたブロック・フィルター:*
      マイナーに自分のブロックのフィルターにコミットするよう要求することで、
      異なるピアによって提供されるフィルターの不一致を監視するためにダウンロードする必要のあるデータ量を削減できます。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Add `ChainstateManager::ProcessTransaction`][review club #23173]は、
John NewberyによるPRで、mempoolへの候補としてトランザクションを処理し、
mempoolの一貫性チェックを実行する責務を持つ新しい`ChainstateManager::ProcessTransaction()`インターフェース関数を追加するものです。
Review Clubでは、mempoolにトランザクションを追加するための現在のインターフェースについて議論しました。

{% include functions/details-list.md
  q0="<!--what-is-cs-main-why-is-it-called-cs-main-->`cs_main`とは何ですか？なぜ`cs_main`と呼ばれているのですか？"
  a0="`cs_main`は、マルチスレッドでバリデーションステートへのアクセスを同期させるためのmutexです。
  実際には、P2Pロジックで使用されるデータなど、非バリデーションデータも保護しています。
  複数のコントリビューターが`cs_main`の使用を最小限にしたいと考えています。
  この変数は、バリデーション機能がmain.cppファイルに格納されていた時に名付けられました。
  プレフィックスの`cs`はcritical sectionの略です。"
  a0link="https://bitcoincore.reviews/23173#l-45"

  q1="<!--which-components-currently-call-accepttomemorypool-which-of-the-atmp-calls-are-from-external-client-code-and-which-are-from-inside-validation-->
  現在`AcceptToMemoryPool`を呼び出しているコンポーネントは何ですか？
  ATMP呼び出しのうち、外部クライアントコードからのものと、内部バリデーションからのものはどれですか？"
  a1="テストからの呼び出しを除くと、4つの呼び出しサイトがあります:
  1. ノードが起動すると、mempool.datからトランザクションを[ロードし][atmp disk]、
     ATMPを呼び出してトランザクションを再検証し、mempoolの内容を復元します。
     これは内部のバリデーション呼び出しです。
  2. P2Pネットワーク上のピアから受信したトランザクションは、ATMPを通して[検証され、mempoolに送信されます][atmp p2p]。
     この呼び出しは、バリデーションの外部コンポーネントから発生します。
  3. 再編成の際、切断されたブロックには存在するものの、新しいチェーンの先頭には含まれていないトランザクションは、
     ATMPを使用してmempoolに[再送信][atmp reorg]されます。これは、内部のバリデーション呼び出しです。
  4. RPC (例：`sendrawtransaction`)やウォレット(例：`sendtoaddress`)などのクライアントは、
     ATMPを呼び出す[`BroadcastTransaction()`][atmp client]を使用して、ノードにトランザクションを送信します。
     `testmempoolaccept`RPCは、`test_accept`を`true`にセットしてATMPを呼び出します。
     これらはバリデーションの外部のコンポーネントからの呼び出しの例です。"
  a1link="https://bitcoincore.reviews/23173#l-80"

  q2="<!--what-does-ctxmempool-check-do-whose-responsibility-is-it-to-call-that-function-->
    `CTxMemPool::check()`は何をするものですか？また、その関数呼び出すのは誰の責務ですか？"
  a2="`CTxMemPool::check()`は、すべてのトランザクションのインプットが利用可能なUTXOに対応することをチェックし、
    mempool全体の内部的な一貫性チェックを実行します。例えば、キャッシュされた
    `ancestorsize`や`ancestorcount`、`descendantsize`、`descendantcount`の値が正確か確認するために、
    各mempoolエントリーの祖先と子孫の数を数えます。現在、ATMPの呼び出し側は、
    その後で`check()`を呼び出す責任があります。しかし、参加者の間では、
    `ChainstateManager`が責任を持って自身で内部的な一貫性チェックを行うべきだと議論されました。"
  a2link="https://bitcoincore.reviews/23173#l-122"

  q3="<!--what-does-the-bypass-limits-argument-do-in-which-circumstances-is-atmp-called-with-it-set-to-true-->
    `bypass_limits`引数は何をするものですか？これがtrueにセットされた状態でATMPが呼び出されるのはどんな状況ですか？"
  a3="`bypass_limits`がtrueの場合、mempoolの最大サイズと最小手数料率は適用されません。
  例えば、mempoolがいっぱいで、mempoolの動的な最小手数料率が3 sat/vBの場合、
  手数料率が1 sat/vBの個々のトランザクションも受け入れられるでしょう。
  ATMPは、[再編成][atmp bypass limits]中に`bypass_limits`を使って呼び出されます。
  これらのトランザクションは個々の手数料率が低くても、子孫の手数料率が高い場合があります。
  mempoolに再追加するトランザクションの合計サイズは、`MAX_DISCONNECTED_TX_POOL_SIZE`または20MBに制限されています。"
  a3link="https://bitcoincore.reviews/23173#l-132"
%}

## Taprootの準備 #21: ありがとう！

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]の最終回をお届けします。*

{% include specials/taproot/ja/21-thanks.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BTCPay Server 1.3.3][]は、<!-- along with the previous release one day earlier -->
  LNノードを共有している共有サーバー上のインスタンスに対する重要なセキュリティパッチを含むリリースです。
  また、小さな機能やその他のバグ修正も含まれています。

- [Rust-Lightning 0.0.103][]は、いくつかの経路が失敗した際に支払いをリトライする`InvoicePayer` APIを追加したリリースです。

- [C-Lightning 0.10.2][]は、[経済合理性のないアウトプットのセキュリティ問題][news170 unec bug]の修正、
  データベースサイズの縮小、`pay`コマンドの有効性の向上が[含まれた][decker tweet]リリースです。

- [LND 0.13.4-beta][]は、*ニュース*セクションで説明したNeutrinoのバグを修正したメンテナンスリリースです。
  リリースノートには「Neutrinoの本番環境で実行している場合、ノードがチェーンの中で前進することを保証するために、
  Taprootのアクティベーション前にこのバージョンにアップデートすることを強く推奨します。」と記載されています。

- [LND 0.14.0-beta.rc3][]は、[エクリプス攻撃][topic eclipse attacks]対策の追加
  （[ニュースレター #164][news164 ping]参照）、リモートデータベースのサポート（[ニュースレター #157][news157 db]参照）、
  経路探索の高速化（[ニュースレター #170][news170 path]参照）、
  Lightning Poolユーザー向けの改善（[ニュースレター #172][news172 pool]参照）、
  再利用可能な[AMP][topic amp]インボイス（[ニュースレター #173][news173 amp]参照）および、
  他の多くの機能やバグ修正が含まれたリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Rust-Lightning #1078][]では、[BOLTs #880][]で定義され[ニュースレター #165][news165 bolts-880]で取り上げられた
  `channel_type`ネゴシエーションを追加しています。この実装では、
  [BOLTs #906][]で提案されているfeature bitは現在のところ送信されません。
  BOLTs #880は[Anchor Channel][topic anchor outputs]に必要で、
  [ゼロ承認チャネル][news156 zcc]をサポートするのにも必要かもしれません。

- [Rust-Lightning #1144][]は、ルートのスコアリングロジックにペナルティの仕組みを追加しました。
  このペナルティは、支払いの再試行中に失敗したチャネルに適用され、
  経路選択アルゴリズムに潜在的に欠陥のあるチャネルを知らせます。

- [BIPs #1215][]は、[BIP119][]の[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]の提案をいくつか更新しました:

  * ソフトフォークはTaprootのアクティベーションと同様に、
    [Speedy Trial][news139 speedy trial]によるアクチベーションを使ってデプロイされることを明記しました。
  * 非タグ付きSHA256ハッシュを使用することの根拠を文書化しました。
  * OP_CHECKTEMPLATEVERIFYの提案と[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]の提案の比較を追加しました。
  * OP_CHECKTEMPLATEVERIFYと潜在的な他の将来のコンセンサスの変更との間の相互作用を説明しました。

{% include references.md %}
{% include linkers/issues.md issues="1078,1144,1215,880,906,23173" %}
[c-lightning 0.10.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.2
[decker tweet]: https://twitter.com/Snyke/status/1452260691939938312
[news170 unec bug]: /ja/newsletters/2021/10/13/#ln-spend-to-fees-cve-ln-cve
[btcpay server 1.3.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.3.3
[rust-lightning 0.0.103]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.103
[lnd 0.14.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.0-beta.rc3
[leguilly thread]: https://mailmanlists.org/pipermail/dlc-dev/2021-November/000091.html
[osuntokun summary]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003336.html
[news53 stuckless]: /en/newsletters/2019/07/03/#stuckless-payments
[neutrino]: https://github.com/lightninglabs/neutrino
[neutrino #234]: https://github.com/lightninglabs/neutrino/pull/234
[bd cbf thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-November/019589.html
[ld cbf thread]: https://groups.google.com/a/lightning.engineering/g/lnd/c/CE2EslTiqW4/m/CSV3mL5JBQAJ
[harding undo verification]: https://groups.google.com/a/lightning.engineering/g/lnd/c/CE2EslTiqW4/m/O0_kQF7mBQAJ
[news164 ping]: /ja/newsletters/2021/09/01/#lnd-5621
[news165 bolts-880]: /ja/newsletters/2021/09/08/#bolts-880
[news157 db]: /ja/newsletters/2021/07/14/#lnd-5447
[news170 path]: /ja/newsletters/2021/10/13/#lnd-5642
[news172 pool]: /ja/newsletters/2021/10/27/#lnd-5709
[news173 amp]: /ja/newsletters/2021/11/03/#lnd-5803
[news156 zcc]: /ja/newsletters/2021/07/07/#zero-conf-channel-opens
[lnd 0.13.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.4-beta
[news139 speedy trial]: /ja/newsletters/2021/03/10/#a-short-duration-attempt-at-miner-activation
[atmp disk]: https://github.com/bitcoin/bitcoin/blob/23ae7931be50376fa6bda692c641a3d2538556ee/src/validation.cpp#L4489-L4490
[atmp p2p]: https://github.com/bitcoin/bitcoin/blob/23ae7931be50376fa6bda692c641a3d2538556ee/src/net_processing.cpp#L3262
[atmp reorg]: https://github.com/bitcoin/bitcoin/blob/23ae7931be50376fa6bda692c641a3d2538556ee/src/validation.cpp#L352-L354
[atmp client]: https://github.com/bitcoin/bitcoin/blob/23ae7931be50376fa6bda692c641a3d2538556ee/src/node/transaction.cpp#L73-L83
[atmp bypass limits]: https://github.com/bitcoin/bitcoin/blob/f87e07c6fe321f0fb97703c82c0e4122f800589f/src/validation.cpp#L353
[series preparing for taproot]: /ja/preparing-for-taproot/
