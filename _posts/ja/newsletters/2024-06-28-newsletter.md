---
title: 'Bitcoin Optech Newsletter #309'
permalink: /ja/newsletters/2024/06/28/
name: 2024-06-28-newsletter-ja
slug: 2024-06-28-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LN支払いが実現可能である可能性を推定する調査のまとめを掲載しています。
また、Bitcoin Stack Exchangeで人気の質問とその回答や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **LN支払いが実現可能である可能性の推定:** René Pickhardtは、
  チャネルの最大容量が公開されているものの、現在の残高の分布が不明な場合に、
  LN支払いが実現可能である可能性を推定する方法についてDelving Bitcoinに[投稿しました][pickhardt feasible1]。
  たとえば、アリスはボブとのチャネルを持っていて、ボブはキャロルとのチャネルを持っています。
  アリスはボブとキャロルのチャネルの容量を知っていますが、その残高の内ボブがどれだけ管理し、
  キャロルがどれだけ管理しているかは知りません。

  Pickhardtは、ペイメントネットワークでは、不可分な資金の分配もあると指摘しています。
  たとえば、キャロルはボブとのチャネルで、そのチャネルの容量を超える金額を受け取ることはできません。
  不可能な分配をすべて除外すると、残りの資金の分配はすべて発生する可能性が同等であると考えることができます。
  これにより、支払いが実現可能である可能性の指標を作成することができます。

  たとえば、アリスがキャロルに1 BTCの支払いをしたい場合、
  その支払いが通過可能なチャネルがアリス-ボブとボブ-キャロル間だけであれば、
  アリス-ボブのチャネルとボブ-キャロルのチャネルの資金配分の何%がその支払いを成功させるかを調べることができます。
  アリス-ボブのチャネルの容量が数BTCの場合、考えられる資金配分のほとんどで支払いは成功するでしょう。
  ボブ-キャロルのチャネルの容量が1 BTCをわずかに超える程度であれば、
  考えられる資金配分のほとんどで支払いは成功しないでしょう。これにより、
  アリスからキャロルへの1 BTCの支払いの実現可能性の全体的な可能性を計算できます。

  実現可能性により、単純に可能だろうと考えた多くのLN支払いが実際には成功しないことが明確になります。
  これは比較を行うための有用な基盤も提供します。Pickhardtは、[返信][pickhardt feasible2]で、
  ウォレットやビジネスソフトウェアが可能性の指標を使用して、
  ユーザーに代わってインテリジェントな決定を自動的に行う方法について説明しています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [IBD（Initial Block Download）の進行状況はどのように計算されますか？]({{bse}}123350)
  Pieter Wuilleは、Bitcoin Coreの`GuessVerificationProgress`関数を示し、
  チェーン内の推定総トランザクション数は、
  各メジャーリリースの一部として更新されるハードコードされた統計を使用していると説明しています。

- [<!--what-is-progress-increase-per-hour-during-synchronization-->同期中の`1時間あたりの進行状況の増加`はどのくらいですか？]({{bse}}123279)
  Pieter Wuilleは、1時間あたりの進行状況の増加は、1時間あたりに同期されるブロックチェーンの割合であり、
  進行率の増加ではないことを明確にしています。さらに、進行状況が一定ではなく変化する可能性がある理由についても説明しています。

- [Y座標を偶数にするのは、すべての鍵の微調整後に適用する必要がありますか？それとも最後だけ適用すべきでしょうか？]({{bse}}119485)
  Pieter Wuilleは、[x座標のみの公開鍵][topic X-only public keys]を強制するためにいつ鍵の符号の反転を実行するかは、
  プロトコルによって長所と短所があることを指摘しつつも、大きく意見が分かれるところであることに同意しています。

- [signetのモバイルウォレット？]({{bse}}123045)
  Murch listsは、Nunchuk、Lava、EnvoyおよびXverseという4つの[signet][topic signet]互換のモバイルウォレットアプリを挙げています。

- [<!--what-block-had-the-most-transaction-fees-why-->トランザクション手数料が最も高かったブロックはどれですか？またその理由は？]({{bse}}7582)
  Murchは、ビットコイン建ての手数料が最も多いブロック409,008（お釣り用のアウトプットの欠落により291.533 BTC）と、
  米ドル建ての手数料が最も多いブロック818,087（お釣り用のアウトプットの欠落により$3,189,221.5 USD）を発見しました。

- [bitcoin-cli listtransactionsの手数料額が大幅にずれていますが、どうしてですか？]({{bse}}123391)
  Ava Chowは、この不一致は[payjoin][topic payjoin]トランザクションの質問で示されている例のように、
  Bitcoin Coreのウォレットがトランザクションのインプットの1つを認識していないが、
  他のインプットを認識している場合に発生すると指摘しています。さらに「ウォレットは手数料を正確に判断できないため、
  ここで手数料を返すべきではありません」と述べています。

- [<!--did-uncompressed-public-keys-use-the-04-prefix-before-compressed-public-keys-were-used-->非圧縮の公開鍵は、圧縮公開鍵が使用される前にプレフィックス`04`を使用していましたか？]({{bse}}123252)
  Pieter Wuilleは、歴史的に署名検証はOpenSSLライブラリによって行われ、
  それにより非圧縮公開鍵（プレフィックス`04`）、圧縮公開鍵（プレフィックス`02`および`03`）、
  ハイブリッド公開鍵（プレフィックス`06`および`07`）が許容されていると説明しています。

- [HTLCの金額がdust limitを下回るとどうなりますか？]({{bse}}123393)
  Antoine Poinsotは、LNのコミットメントトランザクションのアウトプットの金額が
  [dust limit][topic uneconomical outputs]を下回る可能性があり、
  その場合、そのアウトプットのsatoshiは手数料に使用されることになると指摘しています（[トリムされるHTLC][topic trimmed htlc]参照）。

- [subtractfeefromはどのように機能しますか？]({{bse}}123262)
  Murchは、`subtractfeefrom`オプションが使用されている場合の
  Bitcoin Coreの[コイン選択][topic coin selection]の仕組みの概要を説明しています。
  また`subtractfeefromoutput`を使用すると、お釣りのないトランザクションを見つける際に、
  いくつかのバグが発生することにも言及しています。

- [<!--what-s-the-difference-between-the-3-index-directories-->3つのインデックスディレクトリ"blocks/index/"、"bitcoin/indexes"および"chainstate"の違いは何ですか？]({{bse}}123364)
  Ava Chowは、Bitcoin Coreのデータディレクトリをいくつか挙げています:

  - `blocks/index`には、ブロックインデックス用のLevelDBのデータベースが含まれています
  - `chainstate/`には、UTXOセット用のLevelDBデータベースが含まれています
  - `indexes/`には、txindex、coinstatsindexおよびオプションのblockfilterindexが含まれています

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND v0.18.1-beta][]は、「旧バージョン（v0.24.2より前）のbtcdバックエンドが使用されている場合に、
  トランザクションをブロードキャストしようとした後のエラー処理時に発生する[問題][lnd #8862]」を修正したマイナーリリースです。

- [Bitcoin Core 26.2rc1][]は、Bitcoin Coreの旧リリースシリーズのメンテナンスバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #29575][]は、ピアの不正行為のスコアリングシステムを簡素化し、
  2つのインクリメントのみを使用するようにしました：100ポイント（即時切断と推奨されない動作）と
  0ポイント（許可された動作）のみです。ほどんどの種類の不正行為は回避可能でスコアが100に引き上げられましたが、
  誠実で正しく機能しているノードが特定の状況下で実行する可能性のある2つの動作は0に削減されました。
  このPRでは、最大8つのブロックヘッダーを含むP2Pの`headers`メッセージのみを
  新しいブロックの[BIP130][]通知の可能性として考慮するヒューリスティックも削除されました。
  Bitcoin Coreは、ノードが認識しているブロックツリーに接続していないすべての`headers`メッセージを
  潜在的な新しいブロックの通知として扱い、不足しているブロックを要求します。

- [Bitcoin Core #28984][]は、サイズが2（1つの親と1つの子）のクラスターを持つ[パッケージ][topic package relay]に対して、
  （v3トランザクションと呼ばれる）[TRUC][topic v3 transaction relay]
  （Topologically Restricted Until Confirmation）トランザクションを含む
  [RBF（replace-by-fee）][topic rbf]の限定バージョンのサポートを追加します。
  これらのクラスターは、同じサイズ以下の既存のクラスターのみを置き換えることができます。
  関連するコンテキストについては、[ニュースレター #296][news296 packagerbf]をご覧ください。

- [Core Lightning #7388][]は、2021年に行われたBOLT仕様の変更（[ニュースレター #165][news165 anchors]参照）に準拠するため、
  手数料がゼロでない[アンカー形式][topic anchor outputs]のチャネルを作成する機能を削除します。
  しかし、既存のチャネルのサポートは維持されます。Core Lightningは、これを完全に追加した唯一の実装であり、
  実験モードでのみ実行されましたが、安全でないことが判明し（[ニュースレター #115][news115 anchors]参照）、
  ゼロ手数料のアンカーチャネルに置き換えられました。その他の更新には、
  `scid`と`node`を両方含む`encrypted_recipient_data`の拒否や、
  Onion仕様に追加されたLaTeXフォーマットの解析、ニュースレター[#259][news259 bolts]と[#305][news305 bolts]で言及されている
  その他のBOLT仕様の変更が含まれています。

- [LND #8734][]は、支払いのループ中にクライアントのストリーミングコンテキストを認識させることで、
  ユーザーが`lncli estimateroutefee` RPCコマンドを中断した際の支払いのルート推定の中止プロセスを改善します。
  以前は、このコマンドを中断すると、サーバーが不要な[支払いのプローブ][topic payment probes]を続行していました。
  このコマンドの以前の参照については、ニュースレター[#293][news293 routefee]をご覧ください。

- [LDK #3127][]は、[BOLT4][]で指定されているように、支払いの信頼性を向上させるために非厳密な転送を実装し、
  [HTLC][topic htlc]をOnionメッセージの`short_channel_id`で指定されたチャネル以外のチャネルを介してピアに転送できるようにします。
  HTLCを通過できるアウトバウンドの流動性が最も少ないチャネルが選択され、
  後続のHTLCの成功確率が最大化されます。

- [Rust Bitcoin #2794][]は、`ScriptHash`と`WScriptHash`にエラーが発生する可能性のあるコンストラクタを追加することで、
  P2SHのredeem scriptの520バイトのサイズ制限とP2WSHのwitness scriptの10,000バイトのサイズ制限の強制を実装します。

- [BDK #1395][]は、明示的な使用と暗黙的な使用の両方で`rand`への依存関係を削除し、
  `rand-core`に置き換えて依存関係を簡素化し、`thread_rng`および`getrandom`の複雑さを回避し、
  ユーザーが独自の乱数生成器（RNG）を渡すことができるようにすることで柔軟性を高めます。

- [BIPs #1620][]と[BIPs #1622][]は、[サイレントペイメント][topic silent payments]の[BIP352][]仕様に変更を加えます。
  `secp256k1`ライブラリでサイレントペイメントを実装するPRの議論では、
  [BIP352][]にコーナーケースの処理を追加することが推奨されています。具体的には、
  送信とスキャンにおいて無効な秘密鍵/公開鍵の合算処理で、
  （送信者の場合）秘密鍵の合算値がゼロの場合は失敗し、（受信者の場合）公開鍵の合算値が無限遠点の場合は失敗します。
  #1622では、鍵の集約の前ではなく後で`input_hash`を計算するようにBIP352が変更され、
  これにより冗長性を減らし、送信者と受信者の双方にとって処理が明確になるようにします。

- [BOLTs #869][]は、BOLT2に新しいチャネル静止プロトコルを導入します。
  このプロトコルは、[プロトコルのアップグレード][topic channel commitment upgrades]や
  ペイメントチャネルの大きな変更を、そのプロセス中に安定したチャネル状態を確保することで、
  安全かつ効率的にすることを目的としています。このプロトコルは、
  `option_quiesce`がネゴシエートされた場合のみ送信できる新しいメッセージタイプ`stfu`（SomeThing Fundamental is
  Underway）を導入します。`stfu`が送信されると、送信者はすべての更新メッセージを停止します。
  受信者は、更新の送信を停止し、可能であれば`stfu`で応答し、チャネルが完全に静止するようにする必要があります。
  ニュースレター[#152][news152 quiescence]および[#262][news262 quiescence]をご覧ください。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29575,28984,7388,8734,3127,2794,1395,1620,1622,869,8862" %}
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[pickhardt feasible1]: https://delvingbitcoin.org/t/estimating-likelihood-for-lightning-payments-to-be-in-feasible/973
[pickhardt feasible2]: https://delvingbitcoin.org/t/estimating-likelihood-for-lightning-payments-to-be-in-feasible/973/4
[lnd v0.18.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.1-beta
[news296 packagerbf]: /ja/newsletters/2024/04/03/#bitcoin-core-29242
[news259 bolts]: /ja/newsletters/2024/05/31/#bolts-1092
[news305 bolts]:/ja/newsletters/2023/07/12/#ln
[news293 routefee]: /ja/newsletters/2024/03/13/#lnd-8136
[news152 quiescence]: /ja/newsletters/2021/06/09/#c-lightning-4532
[news262 quiescence]:/ja/newsletters/2023/08/02/#eclair-2680
[news115 anchors]: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[news165 anchors]: /ja/newsletters/2021/09/08/#bolts-824
