---
title: 'Bitcoin Optech Newsletter #257'
permalink: /ja/newsletters/2023/06/28/
name: 2023-06-28-newsletter-ja
slug: 2023-06-28-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Coinjoinトランザクションのピン留めを防止するためのアイディアと、
期待されるコンセンサスの変更を投機的に使用するための提案を掲載しています。
また、mempoolポリシーに関する限定週刊シリーズの新しい記事に加えて、
Bitcoin Stack Exchangeの人気の質問とその回答や、新しいリリースとリリース候補、
人気のBitcoinインフラストラクチャソフトウェアの変更など恒例のセクションも掲載しています。

## ニュース

- **v3トランザクションリレーを使用してCoinjoinのピン留めを防止する:**
  Greg Sandersは、提案されている[v3トランザクションリレールール][topic v3 transaction relay]によって、
  [トランザクションのピン留め][topic transaction pinning]に対して脆弱でない
  [Coinjoin][topic coinjoin]スタイルのマルチパーティトランザクションの作成がどう可能になるかについての説明を
  Bitcoin-Devメーリングリストに[投稿しました][sanders v3cj]。
  ピン留めに関する具体的な懸念は、Coinjoinの参加者の1人が、
  自身のインプットを使用してCoinjoinトランザクションの承認を妨げる競合トランザクションを作成する可能性があることです。

    Sandersは、Coinjoinスタイルのトランザクションでは、
    各参加者が最初に自身のビットコインを、Coinjoinの全参加者の署名か、
    タイムロックが切れた後に参加者自身の署名でのみ使用可能なスクリプト宛に送金することで、
    この問題を回避できると提案しています。または、協調型のCoinjoinの場合は、
    コーディネーターと参加者が必ず共同で署名する必要があります（タイムロックの有効期限が切れた後は参加者のみ）。

    タイムロックが期限切れになるまでは、参加者は、競合するトランザクションを作成する場合、
    他の参加者またはコーディネーターのいずれかに競合するトランザクションに共同で署名してもらう必要がありますが、
    その署名がすべての参加者にとって最善の利益にならない限り（たとえば[手数料の引き上げなど][topic rbf]）、
    彼らが共同署名する可能性は低いでしょう。

- **<!--speculatively-using-hoped-for-consensus-changes-->期待されるコンセンサスの変更を投機的に利用する:**
  Robin Linusは、長期間（たとえば20年）実行できないスクリプトの断片に資金を投じるアイディアを
  Bitcoin-Devメーリングリストに[投稿しました][linus spec]。
  そのスクリプトの断片が現在のコンセンサスルールにしたがって解釈される場合、
  20年後のマイナーがその断片に支払われた資金をすべて請求できるようになります。
  しかし、この断片は、コンセンサスのアップグレードによって異なる意味を持つように設計されています。
  Linusは、`OP_ZKP_VERIFY` opcodeを例に挙げており、このopcodeがBitcoinに追加されれば、
  特定のハッシュを持つプログラムに対するZKP（ゼロ知識証明）を提供する人が資金を請求できるようになります。

    これによって、人々は今日BTCをこれらのスクリプトの１つに支払うことができ、
    その証明を使って[サイドチェーン][topic sidechains]や別のチェーン上で同額のBTCを受け取ることができるようになります（_one-way peg_）。
    別のチェーン上のBTCは、タイムロックの期間が切れるまで、20年間繰り返し使用できます。
    その後、別のチェーン上のBTCの現在の所有者は、そのBTCを所有していることを証明するZKPを生成し、
    その証明を使ってBitcoinのmainnet上でロックされたデポジットを引き出すことができ、
    _two-way peg_ が作成されます。検証プログラムをうまく設計すれば、引き出しは簡単で柔軟なものになり、
    ファンジブルな引き出しが可能になります。

    著者らは、この構成がメリットになる人（たとえば、別のチェーンでBTCを受け取る人）は基本的に、
    Bitcoinのコンセンサスルールが変更されること（たとえば、`OP_ZKP_VERIFY`が追加される）ことに賭けることになると指摘しています。
    これにより、変更を求めるインセンティブが得られますが、
    一部のユーザーにシステム変更を強く奨励すると、他のユーザーは強制されているように感じる可能性があります。
    このアイディアは、この記事の執筆時点では、メーリングリストで議論されていません。

## 承認を待つ #7: ネットワークリソース

_トランザクションリレーや、mempoolへの受け入れ、マイニングトランザクションの選択に関する限定週刊[シリーズ][policy series]です。
Bitcoin Coreがコンセンサスで認められているよりも制限的なポリシーを持っている理由や、
ウォレットがそのポリシーを最も効果的に使用する方法などが含まれます。_

{% include specials/policy/ja/07-network-resources.md %}

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [なぜBitcoinノードは、除外されたトランザクションを多く含むブロックを受け入れるのですか？]({{bse}}118707)
  ユーザー commstark は、ノードの[ブロックテンプレート][reference getblocktemplate]に従って、
  そのブロックに対して予想されていたトランザクションを除外するマイナーのブロックを、なぜノードが受け入れるのか尋ねています。
  予想されるブロックと実際のブロックを比較[表示する][mempool space]さまざまな[ツール][miningpool observer]があります。
  Pieter Wuilleは、トランザクションの伝播に関連するノードの[mempool][waiting for confirmation 1]には固有のばらつきがあるため、
  ブロックの内容を強制するコンセンサスルールは不可能であると指摘しています。

- [<!--why-does-everyone-say-that-soft-forks-restrict-the-existing-ruleset-->なぜ皆ソフトフォークは既存のルールを制限すると言うのですか？]({{bse}}118642)
  Pieter Wuilleは、コンセンサスルールを強化する例として、
  [Taproot][topic taproot]と[Segwit][topic segwit]のソフトフォーク時に追加されたルールを挙げています:

  - Taprootは、`OP_1 <32 bytes>` (taproot)アウトプットへの支払いが、
    Taprootのコンセンサスルールに従うという要件を追加しました。
  - Segwitは、`OP_{0..16} <2..40 bytes>` (segwit)アウトプットへの支払いが、
    Segwitのコンセンサスルールに従うという要件を追加し、Segwit以前のアウトプットには空のwitnessを求めるようにしました。

- [デフォルトのLNチャネルの制限が16777215 satに設定されているのは何故ですか？]({{bse}}118709)
  Vojtěch Strnadは、2^24 satoshiの制限の歴史とラージ（wumbo）チャネルの動機について説明し、
  詳細についてはOptechの[ラージチャネルのトピック][topic large channels]を参照するようにリンクしています。

- [なぜBitcoin Coreは、トランザクションを選択するのに祖先の手数料率ではなく祖先のスコアを使うのですか？]({{bse}}118611)
  Sdaftuarは、マイニングブロックテンプレートのトランザクション選択アルゴリズムが、
  祖先の手数料率と祖先のスコアの両方を使用する理由は、パフォーマンスの最適化であると説明しています。
  ([承認を待つ #2: インセンティブ][waiting for confirmation 2]を参照してください)。

- [ライトニングのMPP（マルチパートペイメント）プロトコルは、各パーツの金額をどのように定義してるのですか？]({{bse}}117405)
  Rene Pickhardtは、[マルチパス・ペイメント][topic multipath payments]には、
  プロトコルで定義されたパーツのサイズや、パーツのサイズを選択するアルゴリズムがないことを指摘し、
  支払いの分割に関する研究をいくつか指摘しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BTCPay Server 1.10.3][]は、このセルフホスト型のペイメントプロセッサソフトウェアの最新リリースです。
  1.10ブランチの主要機能については、[ブログ記事][btcpay 1.10]をご覧ください。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Core Lightning #6303][]は、新しい`setconfig` RPCを追加し、
  デーモンを再起動することなくいくつかの設定オプションを変更できるようになりました。

- [Eclair #2701][]では、オファーされた[HTLC][topic htlc]をいつ受信し、いつ決済したかを記録するようになりました。
  これにより、ノードの視点からHTLCがどれくらいの時間保留されていたかを追跡できるようになりました。
  多くのHTLCや、少数の高額なHTLCが長時間保留されている場合、
  これは、[チャネルジャミング攻撃][topic channel jamming attacks]が進行中であることを示すかもしれません。
  HTLCの期間を追跡することは、そのような攻撃を検出し、緩和するのに役立つ可能性があります。

- [Eclair #2696][]では、ユーザーが使用する手数料率を設定する方法が変更されました。
  これまでは、_ブロックターゲット_ で使用する手数料率を指定できました。たとえば「6」を設定すると、
  Eclairは6ブロック以内にトランザクションが承認されるようにします。
  現在、Eclairは、「slow」、「medium」、「fast」を受け付けるようになり、
  それを定数またはブロックターゲットを使用して、特定の手数料率に変換します。

- [LND #7710][]では、プラグイン（またはデーモン自体）が、HTLCで以前受信したデータを取得する機能が追加されました。
  これは、[ルート・ブラインディング][topic rv routing]に必要で、
  将来の機能のアイディアの中でも特に、さまざまな[チャネルジャミング][topic channel jamming attacks]対策に使用される可能性があります。

- [LDK #2368][]は、[アンカー・アウトプット][topic anchor outputs]を使用するピアによって作成された
  新しいチャネルを受け入れられるようになりましたが、制御プログラムは新しい各チャネルを受け入れることを意図的に選択する必要があります。
  これは、アンカー・チャネルを適切に設定するには、ユーザーが十分な額を持つ1つ以上のUTXOにアクセスできる必要があるためです。
  LDKは、ユーザーのウォレットがどのような非LNのUTXOを管理しているのか知らないライブラリとして、
  制御プログラムに必要なUTXOを持っているかどうかを確認する機会を与えるために、このプロンプトを使用します。

- [LDK #2367][]では、[アンカー・チャネル][topic anchor outputs]がAPIの通常利用者にもアクセス可能になりました。

- [LDK #2319][]により、ピアは、元の送信者が支払わなければならないと言った金額よりも少ない金額を支払うことにコミットするHTLCを作成できるようになり、
  ピアはその差額を追加の手数料として自分用に保持できるようになりました。
  これは、ピアがまだチャネルを持っていない受信者のHTLCを受信する[JITチャネル][topic jit channels]の作成に役立ちます。
  ピアは、チャネルに資金を提供するオンチェーントランザクションを作成し、
  そのチャネル内のHTLCにコミットします。しかし、オンチェーントランザクションの作成により、
  追加のトランザクション手数料が発生します。追加手数料を取ることで、
  受信者が新しいチャネルを受け入れ、HTLCを時間内に決済した場合に、そのコストが補償されます。

- [LDK #2120][]は、[ブラインド・パス][topic rv routing]を使用している受信者へのルートを検索するためのサポートを追加しました。

- [LDK #2089][]は、ウォレットがオンチェーンで決済する必要のある[HTLC][topic htlc]に
  簡単に手数料を追加できるようにするイベントハンドラーを追加しました。

- [LDK #2077][]は、後で[デュアル・ファンディングチャネル][topic dual funding]のサポートを簡単に追加できるように、
  大量のコードをリファクタリングしました。

- [Libsecp256k1 #1129][]は、[ElligatorSwift][ElligatorSwift paper]手法を実装し、
  計算上ランダムデータと区別できない64バイトの公開鍵エンコーディングを導入します。
  `ellswift`モジュールは、新しい形式で公開鍵をエンコードおよびデコードするための関数に加えて、
  一様にランダムな新しい鍵を生成し、ellswiftでエンコードされた鍵で
  ECDH（楕円曲線ディフィー・ヘルマン鍵交換）を実行するための便利な関数を提供します。
  ellswiftベースのECDHは、[バージョン2 P2P暗号化トランスポート][topic v2 p2p transport]プロトコル（[BIP324][]）の接続を
  確立する際に使用されます。

{% include references.md %}
{% include linkers/issues.md v=2 issues="6303,2701,2696,7710,2368,2367,2319,2120,2089,2077,1129" %}
[policy series]: /ja/blog/waiting-for-confirmation/
[sanders v3cj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021780.html
[linus spec]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021781.html
[miningpool observer]: https://miningpool.observer/template-and-block
[mempool space]: https://mempool.space/graphs/mining/block-health
[waiting for confirmation 1]: /ja/blog/waiting-for-confirmation/#なぜmempoolがあるのか
[reference getblocktemplate]: https://developer.bitcoin.org/reference/rpc/getblocktemplate.html
[waiting for confirmation 2]: /ja/blog/waiting-for-confirmation/#インセンティブ
[ElligatorSwift paper]: https://eprint.iacr.org/2022/759
[BTCPay Server 1.10.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.10.3
[btcpay 1.10]: https://blog.btcpayserver.org/btcpay-server-1-10-0/
