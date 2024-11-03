---
title: 'Bitcoin Optech Newsletter #276'
permalink: /ja/newsletters/2023/11/08/
name: 2023-11-08-newsletter-ja
slug: 2023-11-08-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin-Devメーリングリストの今後の変更のお知らせと、
複数のHTLCを一緒に集約できるようにする提案の簡単な要約を掲載しています。
また、Bitcoin Core PR Review Clubの概要や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **<!--mailing-list-hosting-->メーリングリストのホスティング:**
  Bitcoin-Devメーリングリストの管理者は、メーリングリストをホスティングしている組織が、
  年内をもってメーリングリストのホスティングを終了する予定であることを[発表しました][bishop lists]。
  過去のメールのアーカイブは、当面の間は現在のURLでホストされると予想されます。
  メールのリレーの終了は、同じ組織がホストしているLightning-Devメーリングリストにも影響すると考えられます。

  管理者は、メーリングリストをGoogleグループに移行するなどの選択肢について、
  コミュニティにフィードバックを求めました。そのような移行が行われた場合、
  Optechはそれを[ニュースソース][sources]の1つとして使用し始めるでしょう。

  また、この発表の数ヶ月前に、一部の著名な開発者が[DelvingBitcoin][]
  Webフォーラムで議論の実験を始めていたことも承知しています。
  Optechは、そのフォーラムで興味深い議論や重要な議論がないか、モニタリングを始めます。

- **コベナンツを使用したHTLCの集約:** Johan Torås Halsethは、
  [コベナンツ][topic covenants]を使用して複数の[HTLC][topic htlc]を1つのアウトプットに集約し、
  当事者がすべてのプリイメージを知っている場合に一度に使用できるようにする提案を
  Lightning-Devメーリングリストに[投稿しました][halseth agg]。
  当事者がプリイメージの一部しか知らない場合は、それらだけを請求し、残りの残高は相手方に返金することができます。
  Halsethは、これによりオンチェーンの効率が向上し、
  ある種の[チャネルジャミング攻撃][topic channel jamming attacks]がより困難になると指摘しています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Fee Estimator updates from Validation Interface/CScheduler thread][review club 28368]は、
Abubakar Sadiq Ismail (ismaelsadeeq)によるPRで、
トランザクションの手数料推定データの更新方法を変更します。
（手数料の推定は、ノードの所有者がトランザクションを作成する際に使用されます。）
手数料推定の更新が、mempoolの更新（トランザクションの追加または削除）中に同期的に発生するのではなく、
非同期で行われるようになります。これにより、全体的な処理の複雑さは増加しますが、
クリティカル・パスのパフォーマンス（これについては以下の議論で明らかになります）が向上します。

新しいブロックが見つかると、mempool内にあるそのブロックのトランザクションは、
そのトランザクションと競合するトランザクションと一緒に削除されます。
ブロックの処理とリレーは、パフォーマンスが重要であるため、手数料推定の更新など、
新しいブロックの処理中に必要な作業量を削減するのは有益です。

{% include functions/details-list.md
  q0="`CTxMempool`の`CBlockPolicyEstimator`への依存関係を削除するのがなぜ有益なのですか？"
  a0="現在、新しいブロックを受信すると、手数料の推定が更新される間、その処理はブロックされます。
      これにより、新しいブロックの処理の完了が遅れ、ピアへのブロックのリレーも遅れます。
      `CTxMempool`の`CBlockPolicyEstimator`への依存関係を削除すると、
      手数料の推定を非同期（別のスレッド）で更新できるようになり、検証とリレーをより迅速に完了できます。
      また、`CTxMempool`のテストも容易になる可能性があります。
      最後に、ブロックの検証やリレーのパフォーマンスに影響を与えることなく、
      より複雑な手数料推定アルゴリズムを将来的に使用できるようになります。"
  a0link="https://bitcoincore.reviews/28368#l-30"

  q1="現在、手数料の推定は、新しいブロックが到着しなくても、トランザクションがmempoolに追加されたり削除されると
      同期的に更新されませんか？"
  a1="はい。ただし、その場合はブロックの検証やリレーほどパフォーマンスは重要ではありません。"
  a1link="https://bitcoincore.reviews/28368#l-41"

  q2="`CBlockPolicyEstimator`が`CTxMempool`のメンバーで、それを同期的に更新すること（現在の更新）にメリットはありますか？
      それを削除することによるデメリットはありますか？"
  a2="同期コードはよりシンプルで、推論しやすくなります。また、手数料推定では、mempool全体をより見やすくなります。
      デメリットは、手数料の推定に必要なすべての情報を新しい`NewMempoolTransactionInfo`構造体にカプセル化する必要があることです。
      ただし、手数料の推定に必要な情報はそれほど多くありません。"
  a2link="https://bitcoincore.reviews/28368#l-43"

  q3="`CValidationInterface`を分割する[PR 11775][]で採用されたアプローチと比較して、
      このPRで採用されたアプローチの長所と短所は何だと思いますか？"
  a3="分割するのは良いことだと思いますが、（イベントの順序を適切に保つために）バックエンドを共有しているので、
      実際には相互にあまり独立していませんでした。分割することには実際的なメリットはあまりないように思えます。
      現在のPRは、より限定的で、手数料の推定を非同期で更新するという最小限の範囲にとどまっています。"
  a3link="https://bitcoincore.reviews/28368#l-71"

  q4="サブクラスにおいて、なぜ`CValidationInterface`メソッドを実行することがイベントを購読することと等価なのですか？"
  a4="`CValidationInterface`のサブクラスはすべてクライアントです。サブクラスは、
      `CValidationInterface`のメソッド（コールバック）の一部またはすべてを実装することができます。
      たとえば、ブロックの接続や切断、トランザクションのmempoolへの[追加][tx add]や[削除][tx remove]などです。
      （`RegisterSharedValidationInterface()`を呼び出すことで）登録された後、
      実装された`CValidationInterface`メソッドは、`CMainSignals`を使用してメソッドコールバックが発生する度に実行されます。
      コールバックは、対応するイベントが発生する度に起動されます。"
  a4link="https://bitcoincore.reviews/28368#l-90"

  q5="[`BlockConnected`][BlockConnected]と[`NewPoWValidBlock`][NewPoWValidBlock]は異なるコールバックです。
      どちらが非同期でどちらが同期なのでしょうか？またどうやって見分けるのですか？"
  a5="`BlockConnected`は非同期で、`NewPoWValidBlock`は同期です。
      非同期のコールバックは、`CScheduler`スレッド内で後で実行される「イベント」をキューに入れます。"
  a5link="https://bitcoincore.reviews/28368#l-105"

  q6="[コミット4986edb][commit 4986edb]で、なぜ`BlockConnected`（これはトランザクションがmempoolから削除されたことも示す）を使用するのではなく、
      新しいコールバック`MempoolTransactionsRemovedForConnectedBlock`を追加しているのですか？"
  a6="手数料の推定は、ブロックが接続された時だけでなく、何らかの理由でトランザクションがmempoolから削除された時も知る必要があります。
      また手数料の推定には、トランザクションの基本手数料が必要ですが、
      これは（`CBlock`を提供する）`BlockConnected`経由では提供されません。
      `block.vtx`（トランザクションリスト）のエントリーに基本手数料を追加することもできますが、
      手数料の推定をサポートするためだけに、このような重要で偏在するデータ構造を変更するのは望ましくありません。"
  a6link="https://bitcoincore.reviews/28368#l-130"

  q7="`MempoolTransactionsRemovedForBlock`コールバックのパラメーターとして
      `std::vector<CTxMempoolEntry>`を使用しないのはなぜですか？
      これを使用すれば、手数料の推定に必要なトランザクションごとの情報を保持するための新しい構造体型は不要です。"
  a7="手数料の推定には、`CTxMempoolEntry`のすべてのフィールドが必要なわけではありません。"
  a7link="https://bitcoincore.reviews/28368#l-159"

  q8="`CTransactionRef`の基本手数料はどのように計算されるのですか？"
  a8="これはインプットの値の合計からアウトプットの値の合計を引いたものです。
      ただし、インプットの値は（コールバックはアクセスできない）前のトランザクションアウトプットに保存されているため、
      コールバックはインプットの値にアクセスできません。これが基本手数料が`TransactionInfo`構造体に含まれている理由です。"
  a8link="https://bitcoincore.reviews/28368#l-166"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 26.0rc2][]は、主流のフルノード実装の次期メジャーバージョンのリリース候補です。
  [推奨されるテストトピック][26.0 testing]の簡単な概要があり、
  テスト専用の[Bitcoin Core PR Review Club][]ミーティングが2023年11月15日に予定されています。

- [Core Lightning 23.11rc1][]は、このLNノード実装の次期メジャーバージョンのリリース候補です。

- [LND 0.17.1-beta.rc1][]は、このLNノード実装のメンテナンスリリースのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Core Lightning #6824][]は、[対話型のファンディングプロトコル][topic dual funding]の実装を更新し、
  「`commitment_signed`を送信するときにステートを保存し、
  `next_funding_txid`フィールドを`channel_reestablish`に追加して、
  受信していない署名を再送信するようピアに要求します。」
  これは、提案中の[デュアル・ファンディングのPR][bolts #851]の[更新][36c04c8ac]に基づいたものです。

- [Core Lightning #6783][]では、`large-channels`設定オプションが廃止され、
  [ラージ・チャネル][topic large channels]と高額な支払いが常に有効になります。

- [Core Lightning #6780][]は、[アンカー・アウトプット][topic anchor outputs]に関連する
  オンチェーントランザクションの手数料の引き上げのサポートを改善しました。

- [Core Lightning #6773][]により、`decode` RPCは、バックアップファイルの内容が有効であり、
  完全なリカバリーの実行に必要な最新情報が含まれていることを検証できるようになりました。

- [Core Lightning #6734][]は、`listfunds` RPCを更新し、
  ユーザーがチャネルの協調クローズトランザクションについて[CPFP][topic cpfp]で手数料の引き上げを行いたい場合に必要な情報を提供します。

- [Eclair #2761][]は、チャネルリザーブの要件を下回っている場合でも、
  限られた数の[HTLC][topic htlc]を転送できるようにしました。
  これは、[スプライシング][topic splicing]や[デュアル・ファンディング][topic dual funding]後に発生する可能性のある
  _資金のスタック問題_ を解決するのに役立ちます。資金のスタック問題に対するEclairの別の緩和策については、
  [ニュースレター #253][news253 stuck]をご覧ください。

{% include references.md %}
{% include linkers/issues.md v=2 issues="6824,6783,6780,6773,6734,2761,851" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[core lightning 23.11rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc1
[lnd 0.17.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.1-beta.rc1
[sources]: /en/internal/sources/
[bishop lists]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022134.html
[delvingbitcoin]: https://delvingbitcoin.org/
[halseth agg]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-October/004181.html
[36c04c8ac]: https://github.com/lightning/bolts/pull/851/commits/36c04c8aca48e04d1fba64d968054eba221e63a1
[news253 stuck]: /ja/newsletters/2023/05/31/#eclair-2666
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Testing-Guide-Topics
[review club 28368]: https://bitcoincore.reviews/28368
[pr 11775]: https://github.com/bitcoin/bitcoin/pull/11775
[tx add]: https://github.com/bitcoin/bitcoin/blob/eca2e430acf50f11da2220f56d13e20073a57c9b/src/validation.cpp#L1217
[tx remove]: https://github.com/bitcoin/bitcoin/blob/eca2e430acf50f11da2220f56d13e20073a57c9b/src/txmempool.cpp#L504
[BlockConnected]: https://github.com/bitcoin/bitcoin/blob/d53400e75e2a4573229dba7f1a0da88eb936811c/src/validationinterface.cpp#L227
[NewPoWValidBlock]: https://github.com/bitcoin/bitcoin/blob/d53400e75e2a4573229dba7f1a0da88eb936811c/src/validationinterface.cpp#L260
[commit 4986edb]: https://github.com/bitcoin-core-review-club/bitcoin/commit/4986edb99f8aa73f72e87f3bdc09387c3e516197
