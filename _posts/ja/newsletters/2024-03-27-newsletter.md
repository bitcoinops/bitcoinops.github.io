---
title: 'Bitcoin Optech Newsletter #295'
permalink: /ja/newsletters/2024/03/27/
name: 2024-03-27-newsletter-ja
slug: 2024-03-27-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreと関連ノードに影響を与える帯域幅を浪費する攻撃の開示の発表と、
トランザクション手数料スポンサーシップのアイディアに対するいくつかの改善、
Bitcoin Coreの手数料推定を改善するためのmempoolのライブデータの使用に関する議論を掲載しています。
また、Bitcoin Stack Exchangeから選ばれた質問とその回答や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **<!--disclosure-of-free-relay-attack-->フリーリレー攻撃の開示:**
  帯域幅を浪費する攻撃についてBitcoin-Devメーリングリストで[説明されました][todd free relay]。
  手短に言うと、マロリーがあるバージョンのトランザクションをアリスにブロードキャストし、
  別のバージョンのトランザクションをボブにブロードキャストします。
  これらのトランザクションは、ボブはアリスのバージョンを[RBFで置換][topic rbf]できないように、
  またアリスもボブのバージョンを受け入れないよう設計されています。マロリーは次に、
  アリスは受け入れるがボブは受け入れない置換トランザクションをアリスに送信します。
  アリスはそのトランザクションをボブにリレーし、相互に帯域幅を消費しますが、
  ボブはそれを拒否し、結果としてリレー帯域幅が浪費されます（[フリーリレー][topic free relay]と呼ばれます）。
  マロリーはトランザクションが最終的に承認されるまでこれを複数回繰り返すことができ、
  各サイクルでアリスが置換を受け入れ、帯域幅を使用してそれをボブに送信し、ボブはそれを拒否します。
  攻撃の効果は、アリスが置換を拒否するボブのようなピアを複数持ち、そのすべてが置換を拒否し、
  マロリーがこの種の特別に構築されたトランザクションを並行して送信することで倍増する可能性があります。

  この攻撃は、トランザクションのいずれかのバージョンが最終的に承認された際にマロリーが支払う手数料によって制限されますが、
  攻撃の説明には、マロリーにいずれにせよトランザクションを送信する予定があった場合、これは実質的にゼロになり得ると記載されています。
  消費できる帯域幅の最大量は、Bitcoin Coreの既存のトランザクションリレー制限により制限されますが、
  この攻撃を並行して何度も実行すると、正規の未承認トランザクションの伝播が遅れる可能性があります。

  この説明では、別のよく知られているノード帯域幅の浪費についても言及しています。
  これは、ユーザーが大きなトランザクションのセットをブロードキャストし、
  マイナーと協力してリレーされたすべてのトランザクションと競合する比較的小さなトランザクションを含むブロックを作成するというものです。
  たとえば、29,000-vbyteのトランザクションは、リレーするすべてのフルノードのmempoolから
  約200MBのトランザクションを削除する可能性があります。説明では、帯域幅を浪費する攻撃の存在は、
  Replace by feerateのような提案（[ニュースレター #288][news288 rbfr]参照）を有効にするなど、
  ある程度のフリーリレーを意図的に許容することが合理的であるべきだと主張されています。

- **<!--transaction-fee-sponsorship-improvements-->トランザクション手数料スポンサーシップの改善:**
  Martin Habovštiakは、1つのトランザクションで無関係なトランザクションの優先順位を高めるアイディアを
  Bitcoin-Devメーリングリストに[投稿しました][habovstiak boost]。
  Fabian Jahrは、基本的な考え方はJeremy Rubinが2020年に提案した
  [トランザクション手数料スポンサーシップ][topic fee sponsorship]（[ニュースレター #116][news116 sponsor]参照）に
  非常に似ているようだと[指摘しました][jahr boost]。
  Rubinの元の提案では、_スポンサートランザクション_ はゼロ値のアウトプットスクリプトを使用して
  _ブーストトランザクション_ にコミットします。単一のスポンサーシップで42 vbyte、
  追加のスポンサーシップ毎に32 vbyte使用します。Habovštiakのバージョンでは、
  スポンサートランザクションはTaprootの[annex][topic annex]を使用してブーストトランザクションにコミットします。
  これは単一のスポンサーシップで約8 vbyte、追加のスポンサーシップ毎に8 vbyte使用します。

  Habovštiakのアイディアを聞いた後、David Hardingは、1月に彼とRubinが以前開発した効率改善案を
  Delving Bitcoinに[投稿しました][harding sponsor]。スポンサートランザクションは、
  署名コミットメントメッセージを使用してブーストトランザクションにコミットしますが、
  このメッセージはオンチェーンで公開されることはありません。そのため、
  単一のコミットメントのために使用されるブロックスペースはゼロです。
  これを可能にするためには、スポンサートランザクションが
  ブーストトランザクションのすぐ直後のブロックと[パッケージリレー][topic package relay]に現れる必要があり、
  フルノードの検証者は、スポンサートランザクションを検証する際にブーストトランザクションのtxidを推測できるようにする必要があります。

  ブロックに複数のスポンサートランザクションが含まれており、
  それぞれが同じブーストトランザクションの一部にそれぞれコミットする可能性がある場合、
  単純に一連のブーストトランザクションをスポンサーの直前に登場させることは不可能であるため、
  完全に推論可能なコミットメントという選択肢はありません。Hardingは、
  ブーストトランザクション毎に0.5 vbyteしか使用しないシンプルな代替案について説明しています。
  Anthony Townsは、これを[改良し][towns sponsor]、ブースト毎に0.5 vbyte以上使用することはなく、
  ほとんどのケースで使用するスペースが少なくてすむバージョンを提案しています。

  HabovštiakとHardingはどちらもアウトソーシングの可能性について言及しています。
  いずれにせよトランザクションをブロードキャストする予定のある人（
  もしくは未承認トランザクションがあり[RBF][topic rbf]で更新したいと思っている人）は、
  ブーストあたり0.5 vbyte以下というわずかなコストで手数料率を引き上げ、別のトランザクションをブーストすることができます。
  比較のため、0.5 vbyteは1つのインプットと2つのアウトプットを持つP2TRトランザクションの約0.3%に相当します。
  残念ながら、両者ともブーストのために第三者にトラストレスに支払いをする便利な方法はないと警告しています。
  しかし、Habovštiakは、LNで支払いをする人は誰でも[Proof of Payment][topic proof of payment]を受け取ることになるため、
  詐欺を証明できる可能性があると指摘しています。

  Townsはさらに、スポンサーが[クラスターmempool][topic cluster mempool]の提案中の設計と互換性があるようであること、
  スポンサーシップの最も効率的なバージョンではトランザクションの有効性のキャッシュに若干の課題があることを指摘し、
  現在および提案中のさまざまな手数料の引き上げ手法によって消費される相対的なブロックスペースを示す表で締めくくっています。
  ブーストあたり0.5 vbyte以下では、最も効率的な手数料スポンサーシップの形態は、
  RBFとマイナーに[帯域外][topic out-of-band fees]で支払う最良のケースで使用される0.0 vbyteのみです。
  手数料スポンサーシップは動的な手数料の引き上げを可能にし、帯域外でマイナーに支払うのとほぼ同じ効率であるため、
  [外部的な手数料][topic fee sourcing]に依存するプロトコルに関する大きな懸念を解決できる可能性があります。

  このニュースレターが発行される直前の[継続的な議論][daftuar sponsor]の中で、
  Suhas Daftuarは、スポンサーがクラスターmempoolでは簡単に対処できない問題を持ち込む可能性があり、
  スポンサーを必要としないユーザーに問題を引き起こす可能性があるという懸念を提起し、
  （Bitcoinに追加される場合は）スポンサーシップはそれを許可することをオプトインしたトランザクションのみが
  利用できるようにすべきであることを示しました。

- **mempoolベースの手数料率の推定:** Abubakar Sadiq Ismailは、
  ノードのローカルmempoolのデータを使用するBitcoin Coreの[手数料推定][topic fee estimation]の改善について
  Delving Bitcoinに[投稿しました][ismail fees]。現在Bitcoin Coreは、
  各未承認トランザクションを受信した時のブロック高、それが承認された時のブロック高とその手数料率を記録することで推定値を生成します。
  その情報がすべて分かれば、受信した際の高さと承認された際の高さの差を利用して、
  手数料率の範囲を表すバケットの指数加重移動平均を更新します。
  たとえば、1.1 sat/vbyteの手数料率で承認するのに100ブロックかかるトランザクションは、
  1 sat/vbyteのバケットの平均に組み込まれます。

  このアプローチの利点は、操作されにくいことです。
  すべてのトランザクションはリレーされ（すべてのマイナーが利用できることを意味します）
  承認される（コンセンサスルールに違反できないことを意味します）必要があります。
  欠点は、ブロック毎に１回しか更新されず、リアルタイムのmempoolの情報を使用する他の推定よりも大幅なラグが発生する可能性があることです。

  Ismailは、mempoolのデータを手数料率の推定に組み込むことについての[以前の議論][bitcoin core #27995]を参考にし、
  いくつかの試験的なコードを書き、現在のアルゴリズムと新しいアルゴリズムの比較を示す分析を行いました（一部の安全性チェックは含まれません）。
  スレッドへの[返信][harding fees]は、Kalle Almによるこのトピックに関する[以前の研究][alm fees]にもリンクしており、
  mempoolの情報を手数料率の推定の引き上げと引き下げの両方に使用すべきなのか、
  それとも推定の引き下げにのみ使用すべきかについての議論につながりました。
  両方に使用する場合の利点は、全体として推定がより有用になることです。
  mempoolのデータを使用して推定値を下げるだけの利点は（既存の承認ベースの推定を使用すると推定値を上げるのみ）、
  操作や正のフィードバックループに対してより耐性があることです。

  この記事の執筆時点では議論は進行中です。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [SegWit以前のノード（0.12.1）を実行するリスクは何ですか？]({{bse}}122211)
  Michael FolksonとVojtěch Strnad、Murchは、個々のユーザーがBitcoin Core 0.12.1を実行することの欠点として、
  無効なトランザクションまたはブロックを受け入れるリスクの高さ、二重支払い攻撃に対する脆弱性の増大、
  更新されたコンセンサス検証を行うために他者への依存度が高くなること、ブロックの検証が遅くなること、
  多くのパフォーマンスの改善の恩恵を受けられないこと、
  [コンパクトブロックリレー][topic compact block relay]を使用できないこと、
  現在の未承認トランザクションの約95%をリレーしないこと、[手数料の推定][topic fee estimation]が正確でなくなること、
  以前のバージョンで修正されたセキュリティ問題に対する脆弱性などを挙げています。
  0.12.1のウォレットユーザーは、[miniscript][topic miniscript]や[ディスクリプター][topic descriptors]ウォレット、
  [Segwit][topic segwit]、[Taproot][topic taproot]、
  [Schnorr署名][topic schnorr signatures]によって可能になった手数料の節約や追加のスクリプト機能に関する開発も見逃すことになります。
  Bitcoin Core 0.12.1がより広く採用された場合のBitcoinネットワークへの影響としては、
  無効なブロックがネットワークに受け入れられる可能性が高くなり、それに伴う再編成のリスク、
  古いブロックのリスクの増加によるマイナー集中化の圧力、そのバージョンを使用しているマイナーのマイニング報酬の減少などが考えられます。

- [OP_RETURNがOP_FALSEやOP_IFよりも安価なのはどのような場合ですか？]({{bse}}122321)
  Vojtěch Strnadは、`OP_RETURN`ベースのデータの埋め込みと、
  `OP_FALSE` `OP_IF`ベースの埋め込みに関連するオーバーヘッドを詳細に説明し、
  「143バイトより小さいデータでは`OP_RETURN`の方が安価」と結論づけています。

- [なぜBIP-340はsecp256k1を使用するのか？]({{bse}}122268)
  Pieter Wuilleは、[BIP340][] Schnorr署名にEd25519ではなくsecp256k1を選択した根拠を説明し、
  その理由として「既存の鍵導出インフラの再利用性」と「セキュリティ仮定を変えないこと」を挙げています。

- [Bitcoin Coreはどのような基準でブロックテンプレートを作成しているのか？]({{bse}}122216)
  Murchは、Bitcoin Coreの現在のブロック候補のトランザクション選択のための祖先のセットの手数料率ベースのアルゴリズムを説明し、
  さまざまな改善を提供する[クラスター mempool][topic cluster mempool]に関する進行中の作業について言及しています。

- [getblockchaininfo RPCのinitialblockdownloadフィールドはどのように機能しますか？]({{bse}}122169)
  Pieter Wuilleは、ノード起動後に`initialblockdownload`がfalseになるために必要な２つの条件を指摘しています:

  1. 「現在のアクティブなチェーンがソフトウェアにハードコードされた定数と少なくとも同じだけの累積PoWを持っていること」
  2. 「現在アクティブなTIP（先頭）のタイムスタンプが過去24時間以内であること」

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 26.1rc2][]は、ネットワークの主要なフルノード実装のメンテナンスリリースのリリース候補です。

- [Bitcoin Core 27.0rc1][]は、ネットワークの主要なフルノード実装の次期メジャーバージョンのリリース候補です。
  [提案されたテストトピック][bcc testing]の簡単な概要と、
  本日（３月２７日）15:00 UTCにテスト専用の[Bitcoin Core PR Review Club][]のミーティングが予定されています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

*注：以下に掲載するBitcoin Coreへのコミットは、master開発ブランチに適用されるため、
これらの変更は次期バージョンの27のリリースから約6ヶ月後までリリースされないでしょう。*

- [Bitcoin Core #28950][]は、`maxfeerate`引数と`maxburnamount`引数を`submitpackage` RPCに追加し、
  提供されたパッケージの集約手数料率が指定された最大値を超える場合、
  または指定された金額を超える金額が使用不可能なアウトプットの既知のテンプレートに送信された場合に呼び出しが失敗し終了するようになります。

- [LND #8418][]は、接続されているBitcoinプロトコルクライアントに、
  フルノードピアの[BIP133][] `feefilter`の値のポーリングを開始します。
  `feefilter`メッセージにより、ノードは接続されたピアにトランザクションのリレーを受け入れる最低手数料率を通知できます。
  LNDはこの情報を使用して、低すぎる手数料率のトランザクションの送信を回避します。
  アウトバウンドピアの`feefilter`値のみが使用されます。これらのピアはユーザーのノードが接続するために選択したピアであり、
  接続を要求されたインバウンドピアよりも攻撃者によって制御されている可能性が低いためです。

- [LDK #2756][]は、メッセージに[トランポリンルーティング][topic trampoline payments]パケットを含めるサポートを追加します。
  これはトランポリンルーティングの使用またはトランポリンルーティングサービスの提供を完全にサポートするわけではありませんが、
  他のコードがLDKを使用してこれを簡単に実行できるようになります。

- [LDK #2935][]は、[ブラインドパス][topic rv routing]への
  [keysend 支払い][topic spontaneous payments]の送信のサポートを開始します。
  keysend支払いは、インボイスなしで送信される無条件の支払いです。
  ブラインドパスは支払いのパスの最終ホップを支払人から隠します。
  ブラインドパスは通常インボイスにエンコードされているため、keysend支払いと組み合わせることはありませんが、
  LSP（Lightning service provider）またはその他のノードが、
  受信者のノードIDを明らかにせずに特定の受信者に一般的なインボイスを提供したい場合には意味があります。

- [LDK #2419][]は、[インタラクティブなトランザクションの構築][topic dual funding]、
  デュアルファンディングチャネルと[スプライシング][topic splicing]の依存関係を処理するための
  ステートマシンを追加します。

- [Rust Bitcoin #2549][]は、相対的な[ロックタイム][topic timelocks]を処理するために
  APIにさまざまな変更を加えています。

- [BTCPay Server #5852][]は、[PSBT][topic psbt]用のBBQrアニメーションQRコード（[ニュースレター #281][news281 bbqr]参照）のサポートを追加します。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28950,8418,2756,2935,2419,2549,5852,27995" %}
[bitcoin core 26.1rc2]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[news281 bbqr]: /ja/newsletters/2023/12/13/#bbqr
[todd free relay]: https://gnusha.org/pi/bitcoindev/Zfg%2F6IZyA%2FiInyMx@petertodd.org/
[news288 rbfr]: /ja/newsletters/2024/02/07/#pinning
[habovstiak boost]: https://gnusha.org/pi/bitcoindev/CALkkCJZWBTmWX_K0+ERTs2_r0w8nVK1uN44u-sz5Hbb-SbjVYw@mail.gmail.com/
[jahr boost]: https://gnusha.org/pi/bitcoindev/45ghFIBR0JCc4INUWdZcZV6ibkcoofy4MoQP_rQnjcA4YYaznwtzSIP98QvIOjtcnIdRQRt3jCTB419zFa7ZNnorT8Xz--CH4ccFCDv9tv4=@protonmail.com/
[harding sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696
[news116 sponsor]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[towns sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696/5
[ismail fees]: https://delvingbitcoin.org/t/mempool-based-fee-estimation-on-bitcoin-core/703
[harding fees]: https://delvingbitcoin.org/t/mempool-based-fee-estimation-on-bitcoin-core/703/2
[alm fees]: https://scalingbitcoin.org/stanford2017/Day2/Scaling-2017-Optimizing-fee-estimation-via-the-mempool-state.pdf
[daftuar sponsor]: https://delvingbitcoin.org/t/improving-transaction-sponsor-blockspace-efficiency/696/6
