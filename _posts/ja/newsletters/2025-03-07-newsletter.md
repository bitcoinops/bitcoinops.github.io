---
title: 'Bitcoin Optech Newsletter #344'
permalink: /ja/newsletters/2025/03/07/
name: 2025-03-07-newsletter-ja
slug: 2025-03-07-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNDの旧バージョンに影響する脆弱性の開示の発表と、
Bitcoin Coreプロジェクトの優先事項に関する議論を掲載しています。
また、コンセンサスの変更に関する議論や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **盗難を可能にする修正済みのLNDの脆弱性の開示:** Matt Morehouseは、
  LNDのバージョン0.18未満に影響する脆弱性の[責任ある開示][topic responsible disclosures]を
  Delving Bitcoinに[投稿しました][morehouse failback]。
  0.18または（理想的には）[現在のバージョン][lnd current]にアップグレードすることを推奨します。
  被害者のノードとチャネルを共有し、被害者のノードを特定の時間に再起動させることができる攻撃者は、
  LNDを騙して同じHTLCの支払いと返金の両方をさせることで、チャネルの資金を盗むことができます。

  Morehouseは、他のLN実装は2018年の早い段階を含め（[ニュースレター #17][news17 cln2000]参照）
  すべて独立してこの脆弱性を発見し修正していますが、LN仕様には正しい動作が記述されていない（
  誤った動作を要求する場合もある）と指摘しています。彼は、仕様を更新するための[PRを公開しました][bolts #1233]。

- **Bitcoin Coreの優先順位に関する議論:** Antoine Poinsotによる
  Bitcoin Coreプロジェクトの将来に関するブログ記事が、Delving Bitcoinの
  [スレッド][poinsot pri]にリンクされました。[最初の][poinsot pri1]ブログ記事では、
  長期的な目標設定のメリットとアドホックな意思決定のコストについて説明しています。
  [２つめ][poinsot pri2]の記事では「Bitcoin Coreは、Bitcoinネットワークの堅牢なバックボーンであるべきで、
  Bitcoin Coreソフトウェアのセキュリティ保護と
  Bitcoinネットワークの強化および改善のための新機能の実装との間でバランスを取る必要がある」と主張しています。
  [３つめ][poinsot pri3]の記事では、既存のプロジェクトをノード、ウォレット、
  GUIの３つのプロジェクトに分割することを推奨しています。これは、マルチプロセスサブプロジェクトの数年にわたる取り組みのおかげで、
  現在では実現可能です（2019年にこのサブプロジェクトについて初めて言及した[ニュースレター #39][news39 multiprocess]を参照）。

  Anthony Townsは、個々のコンポーネントが密結合したままであるため、
  マルチプロセスで本当に効果的な分割が可能なのか[疑問視][towns pri]しています。
  1つのプロジェクトで多くの変更を行うと、他のプロジェクトでも変更が必要になります。
  しかし、現在ノードを必要としない機能を、独立してメンテナンスできるライブラリやツールに移行するのは、
  明らかにメリットがあるでしょう。彼はまた、ユーザーがブロックチェーンのインデックス（
  基本的には[個人用のブロックエクスプローラ][topic block explorers]）を使って自分のウォレットを自分のノードに簡単に接続できるようにする
  ミドルウェアを備えたノードを現在使用している人々がいることを説明しています。
  Bitcoin Coreプロジェクトで以前、ノードに直接含めることを拒否したものです。
  最後に彼は、「（彼にとって）ウォレット機能（のほとんど）とGUI（範囲は狭いが…）を提供することは、
  ビットコインが分散化されたハッカー集団によって使用可能であるという原則に誠実であり続けるための方法で、
  クジラや大規模な投資をする気のある大企業だけが実際に使用できるというものではない」と[述べています][towns pri2]。

  David Hardingは、メインプロジェクトをコンセンサスコードとP2Pリレーだけに焦点を絞ると、
  一般ユーザーがフルノードを使って自分のウォレットトランザクションを検証すのが難しくなると[懸念][harding pri]を表明しています。
  彼は、Poinsotや他のコントリビューターに、
  一般ユーザーにとってBitcoin Coreを使いやすくすることに焦点を当てる検討をするよう求めています。
  経済活動の大部分を検証するフルノードを運用する人は、Bitcoinのコンセンサスルールを定義する能力を持っています。
  例として、ルールを適用するのが30分変わるだけでも、2100万BTCの制限など、
  Bitcoinの重要な特性が政治的に永久に破壊される可能性があることを示しています。
  彼は、一般ユーザーは、顧客に代わってノードを運用する組織よりも、Bitcoinの特性に強く投資していると考えています。
  Bitcoin Coreの開発者が現在のコンセンサスルールを重視するのであれば、
  一般ユーザーが個人的にウォレットトランザクションを検証しやすくすることは、
  深刻な脆弱性につながる可能性のあるバグを防止、排除することと同じくらいセキュリティにとって重要であると主張しています。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **Bitcoin Forking Guide:** Anthony Townsは、
  Bitcoinのコンセンサスルールの変更について、コミュニティの合意を形成する方法に関するガイドを
  Delving Bitcoinで[発表しました][towns bfg]。彼は、
  社会的合意形成を4つの段階（研究開発、パワーユーザーによる調査、業界評価、投資家のレビュー）に分けています。
  そして、Bitcoinソフトウェアの変更を有効にするための、プロセスの最後の技術的なステップについて簡単に触れています。

  彼の投稿では、「これは協力的な道へのガイドに過ぎません。そこでは、みんなの生活がより良くなるような変更を行い、
  多かれ少なかれすべての人がその変更がみんなの生活を良くすることに同意して終わります。」と述べています。
  また、「これはかなり高レベルのガイドに過ぎません」とも注意しています。

- **BIP360 P2QRH（pay-to-quantum-resistant-hash）の最新情報:** 開発者の
  Hunter Beastは、[BIP360][]の[量子耐性][topic quantum resistance]に関する彼の研究の最新情報を
  Bitcoin-Devメーリングリストに[投稿しました][beast p2qrh]。
  彼は提案している量子安全なアルゴリズムのリストに変更を加え、
  P2TRH（pay-to-taproot-hash）スキーム（[ニュースレター #141][news141 p2trh]参照）の開発を推進してくれる人を求めています。
  また、より多くのブロックスペースとCPU検証時間を必要とするより高いレベル（NIST V）ではなく、
  現在Bitcoinで提供されているのと同じセキュリティレベル（NIST II）を目標にすることを検討しています。
  彼の投稿には複数の返信が寄せられました。

- **集中型のMEVを防止するためのプライベートブロックテンプレートのマーケットプレイス:**
  Matt Coralloと開発者7d5x9は、マイナーのブロックテンプレート内の選択されたスペースに対して、
  関係者が公開マーケットで入札できるようにすることについてDelving Bitcoinに[投稿しました][c7 mev]。
  たとえば、「トランザクションYが、Zで識別されるスマートコントラクトとやりとりする他のトランザクションよりも前に来るのであれば、
  トランザクションYを含めるためにX [BTC]支払います」というように。
  これは、Bitcoinのトランザクションの作成者が、特定の[カラードコインプロトコル][topic client-side
  validation]などのさまざまプロトコルに対して既に望んでいるもので、
  新しいプロトコルが開発されるにつれて（[コベナンツ][topic covenants]など、
  特定のコンセンサスの変更を必要とする提案を含む）、将来さらに望まれるようになる可能性があります。

  ブロックテンプレート内の優先トランザクションの順序付けのサービスが、
  トラストの低い公開マーケットによって提供されない場合、
  代わりに大規模なマイナーによって提供される可能性があり、さまざままなプロトコルのユーザーと競合します。
  このため、マイナーは多額の資本と高度な技術を獲得する必要があり、
  そのような能力を持たない小規模なマイナーよりも大幅に高い利益を得る可能性があります。
  これによりマイニングが集中化され、大規模なマイナーがBitcoinのトランザクションをより簡単に検閲できるようになります。

  開発者は、マイナーがブロックを公開するのに十分なProof of Workを生成するまで、
  完全なトランザクションがマイナーに公開されない、ブラインドブロックテンプレートで作業できるようにすることで、
  トラストを削減することを提案しています。開発者は、
  コンセンサスの変更を必要とせずにこれを実現するための2つの仕組みを提案しています:

  - **<!--trusted-block-templates-->信頼できるブロックテンプレート:**
    マイナーはマーケットプレイスに接続し、ブロックに含める入札を選択し、
    マーケットプレイスにブロックテンプレートの作成を依頼します。
    マーケットプレイスは、ブロックヘッダー、コインベーストランザクション、
    部分的なマークルブランチで応答します。これにより、マイナーは正確な内容を知ることなく、
    そのテンプレートのProof of Workを生成できます。
    マイナーがネットワークの目標量のProof of Workを生成すると、
    ヘッダーとコインベーストランザクションをマーケットプレイスに送信します。
    マーケットプレイスはProof of Workを検証し、ブロックテンプレートに追加してブロックをブロードキャストします。
    マーケットプレイスは、ブロックテンプレートにマイナーに支払うトランザクションを含める場合もあれば、
    後でマイナーに別途支払う場合もあります。

  - **<!--trusted-execution-environments-->信頼できる実行環境:**
    マイナーは[TEE][]セキュアエンクレーブを備えたデバイスを入手し、
    マーケットプレイスに接続してブロックに含める入札を選択し、
    TEEのエンクレーブ鍵に暗号化された入札のトランザクションを受け取ります。
    ブロックテンプレートはTEE内で構築され、ヘッダー、コインベーストランザクション、
    部分的なマークルブランチをホストOSに提供します。目標のProof of Workがが生成されると、
    マイナーはそれをTEEに提供し、TEEはそれを検証し、マイナーがヘッダーに追加してブロードキャストするための
    完全な復号されたブロックテンプレートを返します。繰り返しますが、
    ブロックテンプレートには、マーケットプレイスのUTXOからマイナーに支払われるトランザクションが含まれている場合もあれば、
    マーケットプレイスが後でマイナーに支払う場合もあります。

  どちらのスキームでも、事実上、複数の競合するマーケットプレイスを必要とし、
  提案では、単一の信頼されるマーケットプレイスによる支配に対抗し分散化を維持するために、
  一部のコミュニティメンバーや組織が非営利ベースのマーケットプレイスを運営することが期待されると指摘されています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 25.02][]は、この人気のLNノードの次期メジャーバージョンのリリースです。
  このリリースには、他の改善やバグ修正に加えて[ピアストレージ][topic peer storage]（
  暗号化されたペナルティトランザクションを保存し、取得し復号することで、
  [ウォッチタワー][topic watchtowers]の一種として機能します）のサポートが含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Eclair #3019][]は、ピアが開始した一方的な閉鎖中に、mempoolで確認されたリモートのコミットメントトランザクションを
  ローカルのトランザクションのブロードキャストよりも優先するようノードの動作を変更します。
  これまでは、ノードはローカルのコミットメントトランザクションをブロードキャストしていたため、
  2つのトランザクション間で競合が発生する可能性がありました。
  リモートのコミットメントトランザクションを選択する方が、`OP_CHECKSEQUENCEVERIFY` (CSV)の
  [タイムロック][topic timelocks]による遅延が回避され、
  保留中の[HTLC][topic htlc]を解決するための追加トランザクションが不要になるため、
  ローカルノードにとって有益です。

- [Eclair #3016][]は、機能的な変更を加えずに、[Simple Taproot Channel][topic simple taproot channels]
  でライトニングトランザクションを作成するための低レベルのメソッドを導入します。
  これらのメソッドは、[miniscript][topic miniscript]で生成され、
  [BOLTs #995][]仕様で概説されているものとは異なります。

- [LDK #3342][]は、ユーザーが[BOLT12][topic offers]インボイス支払いの
  ルーティングパラメーターをカスタマイズできるようにする`RouteParametersConfig`構造体を追加します。
  これまでは、`max_total_routing_fee_msat`に限定されていましたが、
  新しい構造体には、[`max_total_cltv_expiry_delta`][topic cltv expiry delta]、
  `max_path_count`および`max_channel_saturation_power_of_half`が含まれています。
  この変更により、[BOLT12][]パラメーター設定が[BOLT11][]の設定と一致するようになりました。

- [Rust Bitcoin #4114][]は、Bitcoin Coreのポリシー（ニュースレター[#222][news222 minsize]および
  [#232][news232 minsize]参照）に合わせて、最小非witnessトランザクションのサイズを85バイトから
  65バイトに引き下げました。この変更により、1つのインプットと1つの`OP_RETURN`アウトプットを持つトランザクションなど、
  より最小限のトランザクションが可能になります。

- [Rust Bitcoin #4111][]は、Bitcoin Core 28.0で導入された（ニュースレター[#315][news315 p2a]参照）
  新しい[P2A][topic ephemeral anchors]標準アウトプットタイプをサポートします。

- [BIPs #1758][]は、DLEQ（Discrete Log Equality Proofs）を定義する[BIP374][]（ニュースレター[#335][news335 dleq]参照）を更新し、
  `rand`の計算にメッセージフィールドを組み込みます。この変更により、
  2つの証明が同じ`a`、`b`、`g`で構成され、メッセージが異なり、`r`がすべてゼロである場合に発生する可能性のある
  `a`（秘密鍵）の漏洩を防止できます。

- [BIPs #1750][]は、[ウォレットラベル][topic wallet labels]のエクスポート形式を定義する[BIP329][]を更新し、
  アドレス、トランザクション、アウトプットに関連付けられるオプションフィールドを追加します。
  JSONタイプの修正も含まれています。

- [BIPs #1712][]と[BIPs #1771][]は、BIPプロセスにいくつかの更新を加えることで[BIP2][]を置き換えた
  [BIP3][]を追加します。変更点には、ステータスフィールドの値を9から4に減らすこと、
  作成者が進行中の作業を確認しない場合、ドラフトBIPが1年経過しても進捗がなければ誰でもClosedにできるようにすること、
  BIPが無期限にCompleteステータスのままになることを許可する、今回のようなBIPを処理するために継続的な更新を可能にする、
  一部の編集上の決定をBIPエディターから作成者またはリポジトリの対象者に再割当てする、
  コメントシステムの廃止、番号を受け取るためにBIPがトピックに沿っている必要があること、
  BIPの形式と前文にいくつかの更新を加えることが含まれています。

{% include snippets/recap-ad.md when="2025-03-11 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3019,3016,3342,4114,4111,1758,1750,1712,1771,1233,995" %}
[Core Lightning 25.02]: https://github.com/ElementsProject/lightning/releases/tag/v25.02
[news39 multiprocess]: /en/newsletters/2019/03/26/#bitcoin-core-10973
[news141 p2trh]: /ja/newsletters/2021/03/24/#we-could-add-a-hash-style-address-after-taproot-is-activated-taproot
[poinsot pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/
[poinsot pri1]: https://antoinep.com/posts/core_project_direction/
[poinsot pri2]: https://antoinep.com/posts/stating_the_obvious/
[poinsot pri3]: https://antoinep.com/posts/bitcoin_core_scope/
[towns pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/3
[towns pri2]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/15
[harding pri]: https://delvingbitcoin.org/t/antoine-poinsot-on-bitcoin-cores-priorities/1470/10
[towns bfg]: https://delvingbitcoin.org/t/bitcoin-forking-guide/1451
[beast p2qrh]: https://mailing-list.bitcoindevs.xyz/bitcoindev/8797807d-e017-44e2-b419-803291779007n@googlegroups.com/
[c7 mev]: https://delvingbitcoin.org/t/best-worst-case-mevil-response/1465
[tee]: https://en.wikipedia.org/wiki/Trusted_execution_environment
[news17 cln2000]: /en/newsletters/2018/10/16/#c-lightning-2000
[morehouse failback]: https://delvingbitcoin.org/t/disclosure-lnd-excessive-failback-exploit/1493
[lnd current]: https://github.com/lightningnetwork/lnd/releases
[news222 minsize]: /ja/newsletters/2022/10/19/#minimum-relayable-transaction-size
[news232 minsize]: /ja/newsletters/2023/01/04/#bitcoin-core-26265
[news315 p2a]: /ja/newsletters/2024/08/09/#bitcoin-core-30352
[news335 dleq]: /ja/newsletters/2025/01/03/#bips-1689