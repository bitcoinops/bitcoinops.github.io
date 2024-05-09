---
title: 'Bitcoin Optech Newsletter #148'
permalink: /ja/newsletters/2021/05/12/
name: 2021-05-12-newsletter-ja
slug: 2021-05-12-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、
BIP125 opt-in Replace By Feeの特定の動作によってプロトコルに影響を与えるセキュリティの開示と、
Bitcoin Core PR Review Clubミーティングの概要や、リリースおよびリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点などの通常のセクションを掲載しています。

## ニュース

- **<!--cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation-->CVE-2021-31876 BIP125とBitcoin Coreの実装の不一致:**
  opt-in Replace By Fee（[RBF][topic rbf]）の仕様[BIP125][]では、
  交換可能であることを示す未承認の親トランザクションにより、その親のアウトプットを使用する子トランザクションも、
  推論継承を通じて交換可能になるとしています。今週、Antoine RiardはBitcoin-Devメーリングリストに、
  Bitcoin Coreがこの動作を実装していないという、以前非公開で報告された発見の完全な開示を[投稿しました][riard cve-2021-31876]。
  ただ、子トランザクションが明示的に交換可能であることを示している場合は交換可能で、
  親トランザクションが交換された場合は子トランザクションがmempoolから削除されます。

  Riardは、推論継承による交換が使用できないことが、現在および提案されているさまざまなプロトコルにどう影響するかを分析しました。
  影響を受けるのはLNだけのようですが、それは[Pinning][topic transaction pinning]を使った既存の攻撃
  （[ニュースレーター #95][news95 atomicity attack]参照）がより安価になるという意味に過ぎません。
  さまざまなLNの実装が[Anchor Output][topic anchor outputs]を継続的に展開することで、
  そのPinningを実行する機能はなくなります。

  この記事の執筆時点では、メーリングリストでこの問題について実質的な議論はされていません。

- **<!--call-for-brink-grant-applications-->Brinkグラント申請の募集:**
  Bitcoin Optechでは、オープンソースのBitcoinもしくはLightningプロジェクトに貢献しているエンジニアの方に、
  5月17日の申請期限までに[Brinkグラント][brink grant application]の申請をお勧めします。
  最初のグラントは1年間で、開発者は世界のどこからでもオープンソース・プロジェクトにフルタイムで取り組むことができます。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Introduce node rebroadcast module][review club #21061]は、
Amiti UttarwarによるPR（[#21061][Bitcoin Core #21061]）で、
Review Club[#16698][review club #16698]と[#18038][review club #18038]で以前議論された
再ブロードキャストプロジェクト（ニュースレーター [#64][rebroadcast 1]、[#96][rebroadcast 2]、
[#129][rebroadcast 3]、[#142][rebroadcast 4]参照）の作業の続きで、
ウォレットトランザクションに対するノードの再ブロードキャストの動作を、
他のピアのトランザクションと区別できないようにすることが目的です。

Review Clubでは、現在のトランザクションの動作と提案された変更点に焦点が当てられました:

{% include functions/details-list.md
  q0="<!--why-might-we-want-to-rebroadcast-a-transaction-->
      なぜトランザクションを再ブロードキャストしたいのですか？"
  a0="私たちのトランザクションが伝播しなかった場合（おそらくノードがオフラインだった）や、
      もしくは、ネットワーク内の他のノードのmempoolからドロップされたようにみえるためです。"
  a0link="https://bitcoincore.reviews/21061#l-39"

  q1="<!--why-does-a-node-drop-a-transaction-from-its-mempool-->
      ノードが自身のmempoolからトランザクションをドロップするのはなぜですか？"
  a1="ブロックに格納されるのは別として、トランザクションが14日後に期限切れとなったり、
      ノードの限られたmempoolサイズ（デフォルトのサイズは300MiB）のためより手数料の高いトランザクションによって押し出されたり、
      [BIP125][] opt-in Replace-By-Fee（[RBF][topic rbf]）で交換されたり、
      競合するトランザクションがブロックに格納されている場合は削除されたり、
      その後で再編成されたブロックに含まれていたりします（この場合、
      ノードは再編成後に再び一貫性を保つため[mempoolを更新しながら][UpdateMempoolForReorg]トランザクションを再度追加しようとします）。"
  a1link="https://bitcoincore.reviews/21061#l-53"

  q2="<!--what-could-be-an-issue-with-the-current-behavior-of-each-wallet-being-responsible-for-rebroadcasting-its-own-transactions-->
      各ウォレットが自身のトランザクションの再ブロードキャストに責任を持つという現在の動作に問題がありますか？"
  a2="現在の動作は、IPアドレスとウォレットアドレスをリンクすることができるプライバシーのリークになる可能性があります。
      現在の再ブロードキャストの動作では、１つのトランザクションを2回以上ブロードキャストするノードは、
      基本的にそのトランザクションがそのウォレットのものであることを発表していることになります。"
  a2link="https://bitcoincore.reviews/21061#l-58"

  q3="<!--when-might-a-miner-exclude-a-transaction-that-is-in-our-mempool-->
      マイナーが私たちのmempoolにあるトランザクションを除外するのはどのような場合ですか？"
  a3="手数料が低く優先順位を下げた場合や、まだ確認されていない場合、
      RBFによってmempoolから削除した場合、検閲した場合、空のブロックをマイニングする場合です。"

  q4="<!--when-might-a-miner-include-a-transaction-that-is-not-in-our-mempool-->
      マイナーが私たちのmempoolにないトランザクションをブロックに含めるのはどのような場合ですか？"
  a4="トランザクションに優先順位を付けた場合（例えば有償のサービスとして）や、
      私たちのノードより前にトランザクションを受信していた場合、
      トランザクションが私たちのmempoolの別のトランザクションと競合しそれが彼らのmempoolにはない場合です。"

  q5="<!--how-would-the-proposal-under-review-decide-which-transactions-to-rebroadcast-->
      レビュー中の提案は、どのトランザクションを再ブロードキャストするかをどのように決定するのですか？"
  a5="新しいブロックごとに1回、少なくとも30分経過した推定手数料率以上のトランザクションで、
      6回以上かつ直近4時間以内に再ブロードキャストされていないものを、
      ブロックに適合するトランザクションの最大3/4まで再ブロードキャストすることを提案しています。"
  a5link="https://bitcoincore.reviews/21061#l-63"

  q6="<!--why-might-we-want-to-keep-a-transaction-in-our-rebroadcast-attempt-tracker-even-after-it-has-been-removed-from-our-mempool-->
      私たちのmempoolから削除された後でも、再ブロードキャスト試行トラッカーによりトランザクションを残しておきたい理由は何ですか？"
  a6="コンセンサスルールが変更された後、ネットワーク上のアップデートされていないノードが、
      新しいコンセンサスルールに適合しないトランザクションを再ブロードキャストすることがあります。
      再ブロードキャスト試行トラッカーにトランザクションを残すことで、
      これらのノードがそのトランザクションを何度も再ブロードキャストしてしまうのを防ぎ（90日間で最大6回）、
      トランザクションの有効期限が切れます。"
  a6link="https://bitcoincore.reviews/21061#l-178"

  q7="<!--when-would-we-remove-a-transaction-from-our-rebroadcast-attempt-tracker-->
  再ブロードキャスト試行トラッカーからトランザクションを削除するのはいつですか？"
  a7="トランザクションが承認された時や、[RBFされた][topic rbf]時、
      もしくはブロックに含まれた他のトランザクションと競合した時です。"
  a7link="https://bitcoincore.reviews/21061#l-199"

  q8="<!--how-would-the-estimated-minimum-feerate-for-rebroadcast-be-calculated-why-not-use-the-lowest-feerate-in-the-last-mined-block-->
      再ブロードキャストの最小推定手数料率はどのように計算されますか？
      なぜ最後にマイニングされたブロックの最低手数料率を使用しないのですか？"
  a8="再ブロードキャストの手数料率の下限は、次にマイニングされるブロックに含まれるようシミュレートするため、
      mempoolからブロックを組み立てることで1分間に1回推定されます。このアプローチは、
      過去に基づくのではなく変化する環境における近い将来に基づいて計算するため、
      最後にマイニングされたブロックの最低手数料率を使用するよりも優れています。"
  a8link="https://bitcoincore.reviews/21061#l-227"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Rust-Lightning 0.0.14][]は、Rust LightningがElectrumスタイルのサーバーからデータを取得する際の互換性を高め、
  設定オプションを追加し、LN仕様への適合性を向上させ、バグ修正や改良を行った新しいリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #20867][]では、multisig [descriptor][topic descriptors]に含めることができ、
  `addmultisigaddress` RPCや`createmultisig` RPCで使用できる鍵の数を16から20に増やしています。
  この制限の増加は、P2WSHアウトプットのみで使用できます。
  P2SHアウトプットは520バイトのスクリプトに制限されており、これは15個の圧縮公開鍵を保持するのに十分なサイズしかありません。

- [Bitcoin Core GUI #125][]では、
  イントロ・ダイアログで自動プルーニングのブロックスペースのサイズをデフォルトから調整できるようになりました。
  また、プルーニングされたストレージがどのように機能するかについての説明が改善され、
  ブロックチェーン全体をダウンロードして処理しなければならないが、
  その後ディスク使用量を低く抑えるため破棄されることを明確にしています。

- [C-Lightning #4489][]は、受信したチャネル開設要求に応じて
  [デュアル・ファンディング][topic dual funding]コントリビューションの動作を構成するための`funder`プラグインを追加しました。
  ユーザーは、一般的なコントリビューションポリシー（マッチ率、利用可能な資金の割合、固定コントリビューション）、
  デュアル・ファンディングのコントリビューションが発生しないウォレットのリザーブ額、
  単一チャネルの開設要求に対する最大コントリビューション額などを指定できます。

  このPRは、C-Lightningノード間の実験的なデュアル・ファンディングのサポートを有効にするための最後のステップです。
  この作業から生まれたインタラクティブなトランザクションの構築とチャネル確立のv2プロトコルは、
  公開中の[BOLTs #851][] PRで標準化中です。

- [C-Lightning #4496][]では、プラグインが通知を発行する予定のトピックを登録する機能が追加されました。
  他のプラグインは、そのトピックを購読して通知を受け取ることができます。
  C-Lightningには既にいくつかの組み込みトピックがありますが、このマージされたPRにより、
  プラグインの作者は使用したい新しいトピックカテゴリの通知を作成して使用できます。

- [Rust Bitcoin #589][]は、
  [Schnorr署名][topic schnorr signatures]を使用する[Taproot][topic taproot]のサポートを実装するプロセスを開始しました。
  既存のECDSAのサポートは新しいモジュールに移されましたが、APIの互換性を保つため既存の名前で引き続きエクスポートされます。
  新しい`util::schnorr`モジュールが[BIP340][] Schnorrキーエンコーディングのサポートを追加しています。
  課題[#588][rust bitcoin #588]が、Taproot互換の完全な実装を追跡するのに使用されています。

{% include references.md %}
{% include linkers/issues.md issues="20867,125,4489,4496,589,588,21061,16698,18038,851" %}
[riard cve-2021-31876]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/018893.html
[news95 atomicity attack]: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[rust-lightning 0.0.14]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.14
[rebroadcast 1]: /en/newsletters/2019/09/18/#bitcoin-core-rebroadcasting-logic
[rebroadcast 2]: /en/newsletters/2020/05/06/#bitcoin-core-18038
[rebroadcast 3]: /en/newsletters/2020/12/23/#transaction-origin-privacy
[rebroadcast 4]: /ja/newsletters/2021/03/31/#will-nodes-with-a-larger-than-default-mempool-retransmit-transactions-that-have-been-dropped-from-smaller-mempools-mempool-mempool
[UpdateMempoolForReorg]: https://github.com/bitcoin/bitcoin/blob/e175a20769/src/validation.cpp#L357
[brink grant application]: https://brink.homerun.co/grants
