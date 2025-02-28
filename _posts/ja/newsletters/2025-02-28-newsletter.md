---
title: 'Bitcoin Optech Newsletter #343'
permalink: /ja/newsletters/2025/02/28/
name: 2025-02-28-newsletter-ja
slug: 2025-02-28-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、フルノードが最初に要求することなくリレーされたトランザクションを
無視することに関する投稿を掲載しています。また、Bitcoin Stack Exchangeで人気の質問とその回答や、
新しいリリースとリリース候補の発表、人気のBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **<!--ignoring-unsolicited-transactions-->要求していないトランザクションを無視する:**
  Antoine Riardは、_非要求トランザクション_ と呼ばれる、`inv`メッセージを使用して要求していない
  `tx`メッセージを受け入れないことをノードが通知できるようにする2つのBIPドラフトを
  Bitcoin-Devメーリングリストに[投稿しました][riard unsol]。Riardは、
  2021年にこの一般的なアイディアを提案しました（[ニュースレター #136][news136 unsol]参照）。
  最初に提案されたBIPは、ノードがトランザクションリレー機能と設定を通知できるようにする仕組みを追加します。
  2つめのBIP提案は、その通知の仕組みを使って、ノードが非要求トランザクションを無視することを示しています。

  [Bitcoin Coreのプルリクエスト][bitcoin core #30572]で説明されているように、
  この提案にはいくつかの小さなメリットがありますが、いくつかの古い軽量クライアントの設計と競合し、
  そのソフトウェアのユーザーがトランザクションをブロードキャストできない可能性があるため、
  慎重な展開が求められます。Riardは、前述のプルリクエストを公開しましたが、
  libbitcoinkernelベースの独自のフルノード実装に取り組む予定であることを示し、その後プルリクエストを閉じました。
  彼はまた、この提案は最近開示されたいくつかの攻撃（[ニュースレター #332][news332 txcen]参照）に対処するのに役立つ可能性があることも示しました。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [loadtxsoutset RPCの設定の根拠は何ですか？]({{bse}}125627)
  Pieter Wuilleは、UTXOセットを表すための[assumeUTXO][topic assumeUTXO]の値が特定のブロック高でハードコードされている理由、
  将来的にassumeUTXOスナップショットを配布する方法、Bitcoin Coreの内部データストアをコピーするだけの場合と比較した
  assumeUTXOの利点について説明しています。

- [RBFルール#3によって不可能になるPinning攻撃の種類はありますか？]({{bse}}125461)
  Murchは、[RBF][topic rbf]ルール#3は、[Pinning][topic transaction pinning]攻撃を防ぐことを目的としておらず、
  Bitcoin Coreの[置換ポリシー][bitcoin core replacements]について触れています。

- [<!--unexpected-locktime-values-->予期しないロックタイムの値]({{bse}}125562)
  ユーザーpolespinasaは、Bitcoin Coreが特定の[nLockTime][topic timelocks]を設定する異なる理由をリストアップしています。
  [手数料スナイピング][topic fee sniping]を回避するために`block_height`を設定、
  プライバシーのためにブロック高より小さいランダムな値を設定、
  ブロックチェーンが最新ではない場合は0を設定など。

- [script-pathでの支払いで1 bitを明かして、それがQのY座標のパリティと一致するかチェックする必要がある理由は？]({{bse}}125502)
  Pieter Wuilleは、将来的にバッチ検証機能が追加される可能性を考慮して、
  [Taproot][topic taproot]のscript-pathでの支払いでY座標のパリティチェックを維持する
  [BIP341の根拠][bip341 rationale]について詳しく説明しています。

- [Bitcoin Coreがassumevalidブロックではなくチェックポイントを使用する理由は？]({{bse}}125626)
  Pieter Wuilleは、Bitcoin Coreのチェックポイントの歴史とその目的について詳しく説明し、
  [チェックポイントの削除][Bitcoin Core #31649]に関するPRと議論を紹介しています。

- [Bitcoin Coreは長い再編成をどのように処理しますか？]({{bse}}105525)
  Pieter Wuilleは、Bitcoin Coreがブロックチェーンの再編成をどのように処理するかを概説し、
  より大きな再編成での違いの1つとして、「トランザクションをmempoolに再度戻すことはしない」ことだと述べています。

- [<!--what-is-the-definition-of-discard-feerate-->破棄手数料率の定義は何ですか？]({{bse}}125623)
  Murchは、お釣りを破棄するための最大手数料率と定義し、
  破棄手数料率を計算するコードを「1000ブロックのターゲット手数料率が、3–10 ṩ/vBの範囲外の場合に、その範囲に収める」と要約しています。

- [ポリシーからminiscriptへのコンパイラ]({{bse}}125406)
  Brunoergは、Lianaウォレットがポリシー言語を使用していることに言及し、
  ポリシーコンパイラの例として[sipa/miniscript][miniscript github]と
  [rust-miniscript][rust-miniscript github]ライブラリの両方を挙げています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 25.02rc3][]は、この人気のLNノードの次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Core Lightning #8116][]は、中断されたチャネルの閉鎖交渉の処理を変更し、
  必要でなくてもプロセスを再試行するようにしました。これにより、
  ピアからの`CLOSING_SIGNED`メッセージを逃したノードが再接続時にエラーを受け取り、
  一方的な閉鎖トランザクションををブロードキャストする問題が修正されます。
  一方、すでに`CLOSINGD_COMPLETE`状態にあるピアは、協調閉鎖のトランザクションをすでにブロードキャストしており、
  2つのトランザクション間で競合が発生する可能性があります。この修正により、
  協調閉鎖トランザクションが承認されるまで、再交渉を継続できるようになります。

- [Core Lightning #8095][]は、`setconfig`コマンド（ニュースレター[#257][news257 setconfig]参照）に
  `transient`フラグを追加し、設定ファイルを変更することなく一時的に適用する動的な設定変数を導入します。
  これによる変更は再起動時に元に戻ります。

- [Core Lightning #7772][]は、新しい失効シークレットを受信するたびに、
  `emergency.recover`ファイル（ニュースレター[#324][news324 emergency]参照）を更新する
  `chanbackup`プラグインに`commitment_revocation`フックを追加います。これにより、
  ピアが古い失効状態を公開した場合に、`emergency.recover`を使用して資金を回収する際に、
  ペナルティトランザクションをブロードキャストできるようになります。
  このPRは、[Static Channel Backup][topic static channel backups]のSCBフォーマットを拡張し、
  `chanbackup`プラグインを更新して新旧両方のフォーマットをシリアライズします。

- [Core Lightning #8094][]は、`xpay`プラグイン（ニュースレター[#330][news330 xpay]参照）に
  実行時に設定可能な`xpay-slow-mode`変数を導入し、
  [MPP（マルチパスペイメント）][topic multipath payments]のすべてのパーツが解決されるまで、
  成功または失敗の返信を遅らせます。この設定がなければ、一部の[HTLC][topic htlc]がまだ保留中であっても
  失敗のステータスが返される可能性があります。ユーザーが再試行し、別のノードでインボイスの支払いに成功した場合、
  保留中のHTLCも決済されると、過払いが発生する可能性があります。

- [Eclair #2993][]は、支払いパスの[ブラインド][topic rv routing]部分に関連する手数料を受信者が支払い、
  送信者が非ブラインド部分の手数料をカバーできるようにします。これまでは、送信者がすべての手数料を支払っていましたが、
  これにより、送信者がパスを推測し、潜在的にブラインドを解除できる可能性がありました。

- [LND #9491][]は、`lncli closechannel`コマンドを使用して、
  アクティブな[HTLC][topic htlc]がある場合の協調閉鎖のサポートを追加します。
  開始されると、LNDはチャネルを停止し、新しいHTLCを作成できないようにし、
  既存のすべてのHTLCが解決されるのを待ってから交渉プロセスを開始します。
  ユーザーはこの動作を有効にするために`no_wait`パラメーターを設定する必要があります。
  設定しない場合、エラーメッセージが表示され、それを指定するよう求められます。
  このPRにより、協調チャネル閉鎖が開始された際に、`max_fee_rate`設定が両参加者に適用されることも保証されます。
  これまでは、この設定はリモートの参加者にのみ適用されていました。

{% include snippets/recap-ad.md when="2025-03-04 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30572,8116,8095,7772,8094,2993,9491,31649" %}
[riard unsol]: https://mailing-list.bitcoindevs.xyz/bitcoindev/e98ec3a3-b88b-4616-8f46-58353703d206n@googlegroups.com/
[news136 unsol]: /ja/newsletters/2021/02/17/#proposal-to-stop-processing-unsolicited-transactions
[news332 txcen]: /ja/newsletters/2024/12/06/#transaction-censorship-vulnerability
[Core Lightning 25.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v25.02rc3
[news257 setconfig]: /ja/newsletters/2023/06/28/#core-lightning-6303
[news324 emergency]: /ja/newsletters/2024/10/11/#core-lightning-7539
[news330 xpay]: /ja/newsletters/2024/11/22/#core-lightning-7799
[bitcoin core replacements]: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/mempool-replacements.md#current-replace-by-fee-policy
[bip341 rationale]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-10
[miniscript github]: https://github.com/sipa/miniscript
[rust-miniscript github]: https://github.com/rust-bitcoin/rust-miniscript
