---
title: 'Bitcoin Optech Newsletter #170'
permalink: /ja/newsletters/2021/10/13/
name: 2021-10-13-newsletter-ja
slug: 2021-10-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、いくつかのLN実装で最近修正された脆弱性と、
Taprootの機能を利用するためにLNプロトコルをアップグレードすることで複数のメリットを提供する提案の要約を掲載しています。
また、最近のBitcoin Core PR Review Clubミーティングの概要や、
Taprootの準備に関する情報、新しいソフトウェアリリースとリリース候補のリスト、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点などの恒例のセクションも含まれています。

## ニュース

- **<!--ln-spend-to-fees-cve-->LNの支払いが手数料に使われるCVE:** 先週、Antoine Riardは、
  複数のプログラムに対するCVEの発表をLightning-Devメーリングリストに[投稿しました][riard cve]。
  Bitcoinのユーザーは、使用する際に価値の大部分がコストとなるような
  [経済合理性のないアウトプット][topic uneconomical outputs]を作成することを常に控えてきました。
  しかし、LNではユーザーが、オンチェーンでは経済合理性のない少額の送金を行うことができます。
  そのような場合、支払いノードやルーティングノードは、コミットメントトランザクションのマイナー手数料を少額だけ過剰に支払い、
  コミットメントトランザクションが公開された場合（ほとんどの場合、発生しませんが）事実上、
  そのお金はマイナーに寄付することになります。

  Riardが報告したように、LNの実装では、経済合理性の制限をチャネルの資金の20%以上に設定できるため、
  5回以下の支払いで、チャネルの資金のすべてをマイナーへの寄付に使用することができます。
  マイナーに資金を奪われることは、LNで採用されている少額決済の仕組みの基本的なリスクですが、
  わずか5回の支払いでチャネルの資金すべてを失うリスクは明らかに過剰であると考えられました。

  Riardのメールでは、一定額以上の資金をマイナーの手数料へ寄付するリスクのある支払いのルーティングを単純に拒否するなど、
  いくつかの緩和策が記載されています。これを実装することで、実際に問題が発生するかどうかは不明ですが、
  オンチェーン上で経済合理性のない少額の支払いを同時に複数回ルーティングするノードの能力が低下する可能性があります。
  Optechが追跡している影響を受けたLNの実装はすべて、緩和策の少なくとも１つを実装したバージョンをリリースしているか、
  近日中にリリースする予定です。

- **<!--multiple-proposed-ln-improvements-->複数のLNの改善案:** Anthony Townsは、
  支払いのレイテンシーを短縮し、バックアップの復元性を向上させ、
  署名鍵がオフラインでもLN支払いを受け入れられるようにする方法を説明した
  サンプルコードを含む詳細な提案をLightning-Devメーリングリストに[投稿しました][towns proposal]。
  この提案は、[eltoo][topic eltoo]と同様の利点を提供しますが、
  ブロック高{{site.trb}}で有効になるTaprootのソフトフォーク以外の、
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]や他のコンセンサスの変更を必要としません。
  そのため、LN開発者によって実装、テストされたら、すぐにデプロイできます。
  主な機能をみてみましょう:

  - **<!--reduced-payment-latency-->支払いのレイテンシーの短縮:**
    支払いのプロセスには必要なものの、支払いの詳細には固有ではない一部の詳細情報をチャネルパートナーが事前に交換しておくことで、
    ノードは支払いと支払いに対する署名をチャネルパートナーに送信するだけで、
    支払いを開始またはルーティングすることができます。
    クリティカルパス上でのラウンドトリップの通信は不要であり、
    LNノード間の基盤となるリンク速度に近い速度で支払いをネットワーク全体に伝播できます。
    支払いが失敗した場合の払い戻しには時間がかかりますが、この変更前よりも遅くなることはありません。
    この機能は、開発者のZmnSCPxjによって以前提案されたアイディア（[ニュースレター #152][news152 ff]参照）を拡張したもので、
    同氏は今週、Townsとの議論のいくつかに基づいて関連する投稿を[書きました][zmnscpxj name drop]。

  - **<!--improved-backup-resiliency-->バックアップの復元性の向上:**
    現在LNは、資金が盗まれる場合に備えて、チャネルの両参加者と[Watchtower][topic watchtowers]は、
    チャネルの過去のステートに関する情報を保存する必要があります。
    Townsの提案では、チャネルのステートに関するほとんどの情報を決定論的に導出し、
    各トランザクションにステート番号をエンコードすることで、必要な情報を復元できるようにしています
    （場合によって、多少のブルートフォースによる処理が必要になります）。
    これにより、ノードはチャネル作成時にすべての鍵関連の情報をバックアップすることができます。
    その他に必要な情報は、（盗難の場合は）ブロックチェーンから、
    または（ノードが自身のデータを失った場合は）チャネルパートナーから入手できる必要があります。

  - **<!--receiving-payments-with-an-offline-key-->鍵がオフラインのまま支払いを受信:**
    LNで支払いを送信またはルーティングするためには、基本的にオンライン（ホット）鍵が必要ですが、
    現在のプロトコルでは、支払いを受信するのにもオンラインの鍵を必要とします。
    Lloyd FournierによるZmnSCPxjの以前のアイディアに基づいて（[ニュースレター #152][news152 ff]でも取り上げています）、
    受信ノードは、チャネルを開いたり、閉じたり、リバランスしたりするために鍵をオンラインにするだけで済みます。
    これにより、マーチャントノードのセキュリティが向上します。

  この提案は、Taprootや[PTLC][topic ptlc]を使用するようLNをアップグレードすることで、
  [よく知られている][zmnscpxj taproot ln]プライバシーと効率の利点も提供します。
  このアイディアは、メーリングリストでよく議論され、この記事を書いている時点でも議論は続いています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Extract RBF logic into policy/rbf][review club #22675]は、
Gloria ZhaoによるPRで、Bitcoin Coreの[Replace By Fee][topic rbf]ロジックを個別のユーティリティ関数に抽出するものです。

{% include functions/details-list.md

  q0="<!--what-is-the-high-level-design-goal-for-the-mempool-->mempoolの高レベルの設計目標は何ですか？"
  a0="mempoolは、非マイニングノードであっても、
マイニングのための最もインセンティブのあるトランザクション候補を維持することを目的としています。
しかし、DoS対策（例えば、P2Pネットワークを使って承認されないトランザクションのブロードキャストを許可しないなど）と、
マイナーのインセンティブ（mempoolの上位1ブロック分の手数料を最大化すること）との間には根本的な競合があります。
設計の目標は、競合がどこで発生するかを特定し、それを最小化しようとすることです。"
  a0link="https://bitcoincore.reviews/22675#l-86"

  q1="<!--what-are-the-benefits-of-extracting-the-rbf-logic-into-separate-helper-functions-->RBFのロジックを個別のヘルパー関数に抽出することの利点は何ですか？"
  a1="ロジックを小さな関数に分離することで、単体テストが改善され、
mempoolのパッケージ受け入れや[パッケージリレー][topic package relay]の実装でロジックを再利用することができます。"
  a1link="https://bitcoincore.reviews/22675#l-24"

  q2="<!--in-bip125-rule-2-why-is-it-important-for-the-replacement-transaction-to-not-introduce-any-new-unconfirmed-inputs-->
[BIP125][]のルール#2で、置換トランザクションが新しい未承認のインプットを導入しないことが重要な理由は何ですか？"
  a2="置換トランザクションで新しい _未承認_ のインプットの追加を許可すると、
手数料率が増加しても、そのトランザクションの祖先の手数料率を減少させることができます。
マイナーは祖先の手数料率に基づいてブロックに含めるトランザクションを選択するため、
新しいインプットの追加を許可した場合、置換トランザクションは置換されたものよりもマイニングの魅力が低下する可能性があります。"
  a2link="https://bitcoincore.reviews/22675#l-52"

  q3="<!--in-bip125-rule-4-what-does-it-mean-for-a-transaction-to-pay-for-its-own-bandwidth-why-don-t-we-just-allow-any-replacement-as-long-as-it-has-a-higher-feerate-->
BIP125のルール#4の、トランザクションが「自分の帯域幅を支払う」とはどういう意味ですか？
より高い手数料率を持つのであれば、どのような置換トランザクションでも許可していいのでは？"
  a3="「自分の帯域幅を支払う」とは、置換トランザクションが最小リレー手数料をカバーする追加金額を含む手数料を支払うことを意味します。
このルールがないと、悪意あるアクターはトランザクション手数料を1 satoshiずつ繰り返し引き上げ、
不釣り合いな量のmempoolのコンピューティングリソースと、ネットワーク帯域幅を使用することができます。"
  a3link="https://bitcoincore.reviews/22675#l-117"

  q4="<!--replace-by-fee-logic-is-concerned-with-mempool-policy-why-does-this-logic-transaction-spends-its-outputs-return-that-the-replacement-transaction-failed-due-to-consensus-rules-not-policy-rules-->
Replace-by-feeのロジックは、mempoolポリシーに関係しています。なぜ[このロジック][transaction spends its outputs]は、
ポリシールールではなく、コンセンサスルールにより置換トランザクションが失敗したと返すのですか？"
  a4="このロジックは、置換トランザクションが置換したトランザクションを支払いに使用しているケースをキャッチします。
元のトランザクションと置換トランザクションの両方を承認することは不可能であるため、
この置換トランザクションはブロックチェーンに現れることはなく、コンセンサスは無効です。"
  a4link="https://bitcoincore.reviews/22675#l-40"

%}

## Taprootの準備 #17: 協力は常にオプション？

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/17-keypath-universality.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Eclair 0.6.2][]は、上記の*ニュース*に掲載されている脆弱性の修正および、
  [リリースノート][eclair rn]に記載されている新しい機能やその他のバグ修正を含む新しいリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #20487][]では、実験的なシステムコール（syscall）のサンドボックスを有効にするための
  `-sandbox`設定オプションが追加されました。sandboxが有効な場合、
  プロセス毎のホワイトリストに記載されている以外のシステムコールを実行すると、
  カーネルがBitcoin Coreを終了させます。このモードは現在x86_64でのみ利用可能で、
  主に特定のスレッドで使われているシステムコールをテストするためのものです。

- [Bitcoin Core #17211][]では、ウォレットの`fundrawtransaction`と`walletcreatefundedpsbt`、
  `send`RPCメソッドを更新し、トランザクションで使用されるアウトプットのすべてがウォレットで所有されていないトランザクションも許可します。

  これまでは、ウォレットが所有していないアウトプットの使用する際に必要な手数料を見積もることができませんでした。
  これはインプットでそのアウトプットを使用するために必要なサイズが分からなかったためです。
  このPRでは、これらのRPCメソッドを更新し、`solving_data`引数を受け付けるようにしました。
  トランザクションで使用されるアウトプットの公開鍵、シリアライズされたscriptPubKey、
  もしくは[descriptor][topic descriptors]を提供することで、
  ウォレットはそれらのアウトプットを使用するのに必要なインプットのサイズ（したがって、
  アウトプットを使用するのに必要な手数料）を見積もることができます。

- [Bitcoin Core #22340][] ブロックがマイニングされると、P2Pネットワークへブロードキャストされ、
  最終的にネットワークのすべてのノードにリレーされます。従来、ブロックをリレーする方法には、
  レガシーリレーと[BIP152][]スタイルの[Compact Block Relay][topic compact block relay]の2種類がありました。

  ブロックオンリーのノードは、帯域幅の使用量を減らすためトランザクションリレーには参加しないので、
  mempoolを持っていません。したがって、このようなノードでは常に完全なブロックをダウンロードする必要があるため、
  Compact Blockはメリットがありません。しかし、高帯域幅モードでも低帯域幅モードでも、
  `cmpctblock`メッセージはリレーされます。`cmpctblock`メッセージは、
  `headers`や`inv`の通知に比べて平均的なケースで数倍の大きさになるため、
  ブロックオンリーノードにとっては帯域幅のオーバーヘッドになります。

  [ニュースレター #165][PR review club 22340]に掲載したように、
  このPRは、高帯域幅のブロックリレー接続を開始するのを防ぎ、`sendcmpct(1)`の送信を無効にすることで、
  ブロックオンリーノードがレガシーリレーを使って新しいブロックをダウンロードするようにします。
  さらに、ブロックオンリーノードは、`getdata(CMPCT)`を使ってCompact Blockを要求しなくなりました。

- [Bitcoin Core #23123][]では、`-rescan`起動オプションを削除しました。
  ユーザーは代わりに`rescan`RPCを使用できます。

- [Eclair #1980][]は、[Anchor Output][topic anchor outputs]が使用されている場合、
  ローカルのフルノードの動的な最小リレー手数料以上の手数料率で作成されたコミットメントトランザクションを受け入れます。

- [LND #5363][]では、LND内で[PSBT][topic psbt]のファイナライズのステップをスキップすることができ、
  他のソフトウェアを使ってPSBTをファイナライズしブロードキャストできるようになりました。
  これによりトランザクションのtxidが誤って変更された場合に資金が失われる可能性がありますが、
  代替のワークフローが可能になります。

- [LND #5642][]では、経路探索操作を高速化するため、チャネルグラフのインメモリキャッシュを保持するようになりました。
  これまでは、経路探索に高価なデータベースへの問い合わせが必要で、
  PRの作者による計測では10倍以上遅かったようです。

  低メモリのシステム上でLNDを実行しているユーザーは、
  `routing.strictgraphpruning=true`フラグを使ってゾンビチャネルを積極的に削除することで、
  この新しいキャッシュのメモリフットプリントを削減できます。

- [LND #5770][]では、上記の*ニュース*セクションに掲載されているLNのCVEの緩和策を実装できるようにするため、
  経済合理性のないアウトプットに関する詳細情報をLNDのサブシステムに提供するようになりました。

{% include references.md %}
{% include linkers/issues.md issues="20487,17211,22340,23123,1980,5363,5642,5770,22675" %}
[riard cve]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003257.html
[zmnscpxj name drop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003265.html
[news152 ff]: /ja/newsletters/2021/06/09/#receiving-ln-payments-with-a-mostly-offline-private-key-ln
[towns proposal]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003278.html
[zmnscpxj taproot ln]: /ja/preparing-for-taproot/#lnとtaproot
[eclair 0.6.2]: https://github.com/ACINQ/eclair/releases/tag/v0.6.2
[eclair rn]: https://github.com/ACINQ/eclair/blob/master/docs/release-notes/eclair-v0.6.2.md
[transaction spends its outputs]: https://github.com/bitcoin/bitcoin/blob/0ed5ad102/src/validation.cpp#L774
[PR review club 22340]: /ja/newsletters/2021/09/08/#bitcoin-core-pr-review-club
[series preparing for taproot]: /ja/preparing-for-taproot/
