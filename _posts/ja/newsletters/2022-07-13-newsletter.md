---
title: 'Bitcoin Optech Newsletter #208'
permalink: /ja/newsletters/2022/07/13/
name: 2022-07-13-newsletter-ja
slug: 2022-07-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Schnorr署名のハーフアグリゲーションや、
x-only pubkeyを確実に使用できないプロトコルに対する回避策、
LN支払いの転送を意図的に遅くすることについての議論を掲載しています。
また、Bitcoin Core PR Review Clubの概要や、リリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点など、
恒例のセクションも含まれています。

## ニュース

- **BIP340署名のハーフアグリゲーション:** Jonas Nickは、
  Bitcoin-Devメーリングリストに、
  Bitcoinの[Schnorr署名][topic schnorr signatures]のハーフアグリゲーションに関する[BIPドラフト][bip-agg]と
  [ブログ記事][blog agg]を[投稿しました][nick agg]。
  プログの記事で言及されているように、この提案は、
  「複数の署名を集約して、個々の署名の合計の約半分の長さの単一の署名にすることができます。
  重要なのは、この方式が非対話型であることです。
  つまり、署名者が関与することなく、第三者によって署名のセットをハーフアグリゲーションすることができるのです。」

  [別のドキュメント][cia doc]では、
  ハーフアグリゲーションがBitcoinとLNノードのオペレーターにどんな利益をもたらすかの例や、
  コンセンサスプロトコルにハーフアグリゲーションを追加するソフトフォークの設計で考慮する必要があるいくつかの懸念事項が示されています。

- **x-onlyの回避策:** Bitcoinの公開鍵は、
  *x*座標と*y*座標の交点として参照される2次元グラフ上の点です。
  任意の*x*座標に対して、有効な*y*座標は2つしかなく、これらは*x*の値から計算できます。
  このため、[Taproot][topic taproot]の設計では、
  [BIP340][]形式のSchnorr署名で使用されるすべての公開鍵は、
  2つの*y*座標のうち特定の1つだけを使用することを要求する最適化が行われ、
  トランザクションに含まれる公開鍵は*y*座標を完全に省略できるようになり、
  オリジナルのTaprootの設計より署名毎に1 vbyteの節約が可能になりました。

  当時、（*x-only public key*と呼ばれる）この手法は、
  大きなトレードオフのない最適化と考えられていましたが、
  その後のOP_TAPLEAF_UPDATE_VERIFY（[TLUV][news166 tluv]）の設計作業により、
  x-only pubkeyでは提案に計算上の制限、
  もしくはブロックチェーンまたはUTXOセット内に余分なデータを保存する必要があることが判明しました。
  この問題は、公開鍵の他の高度な使用法にも影響を与える可能性があります。

  今週、Tim Ruffingは、Bitcoin-Devメーリングリストに、
  署名者によるわずかな追加計算を必要とする回避策の可能性を[投稿しました][ruffing xonly]。
  リソースに制約のあるハードウェア署名デバイスでも、ユーザーをあまり待たせずに実行できる可能性のあるものです。

- **意図的に遅いLN支払いの転送を許可する:**
  再帰的/ネストされた [MuSig2][topic musig]（[ニュースレター #204][news204 rmusig]参照）と、
  それを使用するノードが支払いのルーティング時に追加する遅延に関するスレッドへの返信で、
  開発者のPeter Toddは、Lightning-Devメーリングリストに、
  「プライバシーのために、よりゆっくりと行われる支払いに人々がオプトインできるようにすることは価値はありますか？」
  と[尋ねました][todd delay]。たとえば、アリスとボブがそれぞれ、
  ほぼ同時期にキャロルの転送ノードを介してダンの転送ノードにゆっくりと支払いを転送した場合、
  キャロルは両方の支払いをまとめて転送することができ、
  第三者が[残高調査][topic payment probes]やネットワーク活動の監視などを通じて発見可能な参加者のプライバシー漏洩の情報量を減らすことができます。
  開発者のMatt Coralloは、興味深いアイディアであると[同意しました][corallo delay]。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Manual block-relay-only connections with addnode][review club 24170]は、
Martin ZumsandeによるPRで、
ブロックのみをリレーする（トランザクションやピアのアドレスはリレーしない）ノードと手動で接続できるようにします。
このオプションは、特にTorなどの[プライバシーネットワーク][topic anonymity networks]上で動作するノードに対して、
[エクリプス攻撃][topic eclipse attacks]を防止するのに役立ちます。

{% include functions/details-list.md

  q0="<!--why-could-peers-that-are-only-active-on-privacy-networks-such-as-tor-be-more-susceptible-to-eclipse-attacks-compared-to-clearnet-only-peers-->
クリアネットのみのピアと比較して、Torなどのプライバシーネットワークでのみアクティブなピアは、
なぜエクリプス攻撃の影響を受けやすいのですか？"
  a0="クリアネット上のノードは、IPアドレスのネットワークグループなどの情報を使って、
「多様な」ピアを選択しようとすることができます。一方、onionアドレスのセットが、
すべて単一の攻撃者に属しているかどうかを見分けるのは難しいため、Tor上ではそれが困難です。
また、Tor上で動作するBitcoinノードの数はとても多いですが、
Bitcoinノードの数が僅かなプライバシーネットワーク上で-onlynetを使用しているノードは、ピアの選択肢があまりないため、
簡単にエクリプス攻撃にさらされます。"
  a0link="https://bitcoincore.reviews/24170#l-42"

  q1="<!--what-is-the-difference-between-the-onetry-and-add-modes-in-the-addnode-rpc-->
`addnode` RPCの`onetry`モードと`add`モードの違いは何ですか？"
  a1="その名前が示すように、`onetry`は`CConnman::OpenNetworkConnection()`を一度だけ呼ぼうとします。
失敗した場合、ピアは追加されません。一方、`add`モードでは、
成功するまで繰り返しノードへの接続を試みます。"
  a1link="https://bitcoincore.reviews/24170#l-72"

  q2="<!--the-pr-introduces-a-new-connection-type-manual-block-relay-that-combines-the-properties-of-manual-and-block-relay-peers-what-are-the-advantages-and-disadvantages-of-having-an-extra-connection-type-as-opposed-to-combining-the-logic-of-the-existing-ones-->
このPRでは、`MANUAL`ピアと`BLOCK_RELAY`ピアの特性を組み合わせた新しい接続タイプ`MANUAL_BLOCK_RELAY`を導入しています。
既存の接続タイプのロジックを組み合わせるのではなく、追加の接続タイプを持つことの利点と欠点は何ですか？"
  a2="P2P接続には多くの属性がありますが、タイプは少ないため、
参加者はフラットな列挙型で接続タイプを使用する方がよりシンプルであることに同意しました。
また、機能と権限の組み合わせで接続を定義すると、
意味をなさないものも含め、接続タイプとロジックの組み合わせが膨大になる可能性についても言及されました。"
  a2link="https://bitcoincore.reviews/24170#l-97"

  q3="<!--what-types-of-attacks-that-this-pr-tries-to-mitigate-are-fixed-by-bip324-which-ones-aren-t-->
このPRが軽減しようとする攻撃のうち、BIP324によって修正されるのはどのような攻撃ですか？
また、そうでないものは何ですか？"
  a3="[BIP324][]は、盗聴やネットワーク全体の監視を防ぐための暗号化を追加することでプライバシーを強化しますが、
エクリプス攻撃を防ぐためのものではありません。何らかの認証の仕組みがあったとしても、
ピアが正直か、他のピアと異なるものかを識別する助けにはなりません。"
  a3link="https://bitcoincore.reviews/24170#l-110"

%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BTCPay Server 1.6.1][]は、
  この人気のセルフホスト型のペイメントプロセッサソリューションの1.6ブランチのリリースで、
  複数の新しい機能とバグ修正が含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #25353][]は、以前[ニュースレター #205][news205 fullrbf]で説明した
  `mempoolfullrbf`設定オプションを導入しました。
  このオプションにより、ノードオペレーターは、ノードの[トランザクション置換動作][topic rbf]を
  デフォルトの[オプトインRBF (BIP125)][BIP125]から、
  シグナリング要件を強制することなくノードのmempoolのトランザクションの置換を許可するフルRBFに切り替えることができますが、
  オプトインRBFと同じ経済ルールに従います。

- [Bitcoin Core #25454][]では、同じピアへの複数のgetheadersメッセージの送信を回避します。
  前のgetheadersメッセージに対する応答を最大2分間待ってから新しいメッセージを発行することで、
  帯域幅の使用量を削減します。

- [Core Lightning #5239][]は、CLNのゴシップレート制限を満たす通知のみをリレーするものの、
  受信したすべての通知を使用して支払いリレーネットワークのCLNの内部マップを更新するようゴシップ処理コードを改善しました。
  これまでは、CLNはレート制限に従って受信メッセージをドロップしていました。
  この変更により、CLNがピアに送信するデータ量に影響を与えることなく、
  ピアのレート制限がゆるい（もしくはまったくない）場合に、CLNにネットワークのより良いビューを提供できます。

- [Core Lightning #5275][]は、[ゼロ承認チャネルの開設][topic zero-conf channels]と、
  それに関連するShort Channel IDentifier (SCID)エイリアス（[ニュースレター #203][news203 scid]参照）のサポートを追加しました。
  これには、`listpeers`RPC、`fundchannel`RPC、`multifundchannel`RPCの更新が含まれています。

- [LND #5955][]は、上記のマージと同様に、ゼロ承認チャネルの開設と、関連するSCIDエイリアスのサポートを追加しています。

- [LDK #1567][]は、近い将来に支払いが送信された場合に、
  どの支払いルートが成功する可能性が高いかテストするのに使用できる
  基本的な[支払い探索][topic payment probes]APIのサポートを追加しました。
  これには、送信ノードが余分な状態を保存することなく、戻ってきた際に、
  実際の支払い[HTLC][topic htlc]からHTLCを分離可能にする方法でHTLCを構築するサポートが含まれています。

- [LDK #1589][]は、LDKのメンテナーにセキュリティの脆弱性を安全に報告するために使用できる
  [セキュリティポリシー][ldk security policy]を追加しました。

- [BTCPay Server #3922][]は、*カストディアンアカウント*用の基本的なUIを追加しました。
  このアカウントは、（ローカルユーザーが自身の秘密鍵をコントロールするのではなく）Bitcoinの取引所のような
  管理者によって資金が管理されるBTCPayインスタンスに関連付けられたアカウントです。
  BTCPayインスタンスは、ローカルウォレットとカストディアンアカウントの両方を持つことができ、
  両者の資金を簡単に管理することができます。たとえば、
  マーチャントはプライベートかつ安全に彼らのウォレットに資金を受け取ったり、
  販売するために取引所に迅速に資金を転送することが可能になります。

- [BDK #634][]は、特定の高さにある最良のブロックチェーン上のブロックのヘッダーハッシュを返す
  `get_block_hash`メソッドを追加しました。

- [BDK #614][]は、100承認未満のマイナーのコインベーストランザクションのアウトプットである
  未成熟なコインベースアウトプットを使用するトランザクションの作成を回避します。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25353,25454,5239,5275,5955,1567,1589,3922,634,614" %}
[btcpay server 1.6.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.6.1
[ldk security policy]: https://github.com/TheBlueMatt/rust-lightning/blob/92919c8f375311e4f9a596d64a026a172839dd0f/SECURITY.md
[nick agg]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020662.html
[bip-agg]: https://github.com/ElementsProject/cross-input-aggregation/blob/master/half-aggregation.mediawiki
[blog agg]: https://blog.blockstream.com/half-aggregation-of-bip-340-signatures/
[news166 tluv]: /ja/newsletters/2021/09/15/#covenant-opcode-proposal-covenant-opcode
[ruffing xonly]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020663.html
[news204 rmusig]: /ja/newsletters/2022/06/15/#musig2
[todd delay]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003621.html
[corallo delay]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003641.html
[news203 scid]: /ja/newsletters/2022/06/08/#bolts-910
[cia doc]: https://github.com/ElementsProject/cross-input-aggregation
[news205 fullrbf]: /ja/newsletters/2022/06/22/#rbf
[review club 24170]: https://bitcoincore.reviews/24170
[BIP324]: https://gist.github.com/dhruv/5b1275751bc98f3b64bcafce7876b489
