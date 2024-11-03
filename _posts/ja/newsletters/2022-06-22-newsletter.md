---
title: 'Bitcoin Optech Newsletter #205'
permalink: /ja/newsletters/2022/06/22/
name: 2022-06-22-newsletter-ja
slug: 2022-06-22-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、BIP125にオプトインしないトランザクションに対しても
トランザクションの置換を容易に可能にするBitcoin Coreのオプション案や、
Hertzbleedサイドチャネル脆弱性についての情報のリンク、
タイムスタンプのシステム設計に関する議論の結論の要約、
BitcoinのUTXOを使用した新しいシビル対策プロトコルについて掲載しています。
また、Bitcoinのクライアントやサービスにおける興味深い新機能の説明や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点など、
恒例のセクションも含まれています。

## ニュース

- **フルRBF:** デフォルトではオフのオプションとして、
  フルReplace By Fee（[RBF][topic rbf]）のサポートをBitcoin Coreに追加するための[2つ][bitcoin core #25353]の
  [プルリクエスト][bitcoin core #25373]が公開されました。
  これを有効にすると、ノードのmempool内の未承認トランザクションは、（他のルールと共に）
  より高い手数料を支払うそのトランザクションの代替バージョンで置き換えられる可能性があります。

  現在、Bitcoin Coreは、[BIP125][]で定義されているように、
  置換元のトランザクションのバージョンがシグナル用のbitを有効にしている場合のみ、RBFを許可します。
  これは、LNや[DLC][topic dlc]のようなマルチパーティプロトコルにとって、
  他の参加者がトランザクションの置換を防ぐために、
  ある参加者がトランザクションからBIP125のシグナルを削除することが可能な場合があるという課題を生むことになります。
  これは遅延の原因となり、最悪の場合、タイムリーな承認に依存するプロトコル（[HTLC][topic htlc]など）において、
  資金の喪失に繋がる可能性があります。

  [PRの1つは][bitcoin core #25353]、開発者から大きな支持を得ました。
  これは、フルRBFを有効にする機能を追加するだけで、デフォルトでは有効にしないため、
  Bitcoin Coreの現在のデフォルトの動作を変更するものではありません。
  長期的には、一部の開発者はデフォルトでフルRBFの有効化を提唱すると思われるため、
  今週、サービスやアプリケーションおよび他のフルノードソフトウェアの開発者に、
  フルRBFを提供し、おそらく最終的にそれがデフォルトになる方向であることに対して反論の機会を与えるため、
  Bitcoin-Devメーリングリストにスレッドが[立ち上げられました][rbf discussion]。

- **Hertzbleed:** 最近[公開された][hertzbleed]セキュリティの脆弱性は、
  多くの（おそらくすべての）ラップトップ、デスクトップおよびサーバーのCPUプロセッサに影響を与え、
  そららの環境で秘密鍵がBitcoinのトランザクションの署名の作成（または他の同様の操作）に使用されている場合、
  攻撃者が秘密鍵を発見できる可能性があることを示しています。
  この攻撃で注目すべき点は、攻撃者への情報漏洩を防ぐため、
  常に同じタイプと数のCPU操作を使用するよう特別に書かれた署名生成コードに影響を与える可能性があることです。

  この脆弱性を悪用するには、攻撃者がCPUチップの消費電力を測定するか、
  署名動作の一部の時間を測定する必要があります。
  攻撃者にとっては、ユーザーが同じ秘密鍵を使って多くの署名を作成する間に測定できるのが理想的です。
  そのため、この脆弱性は、ホスティングサービスやLNのルーティングノードで使用されるような頻繁に使用されるホットウォレットや、
  [アドレス再利用][topic output linking]のケースに影響する可能性が高いものになります。
  安全な環境で使用されるオフラインのウォレットであれば、より攻撃されにくいでしょう。

  この記事を書いている時点で、この脆弱性がBitcoinユーザーにとってどの程度重要であるかは完全には明らかになっていません。
  いくつかの人気のハードウェア署名デバイスを含む現在のウォレットの多くは、
  電力やタイミング解析に対して脆弱な署名生成コードを使用していることが既に知られているため、
  おそらくそれらのユーザーとっては何も変わらないでしょう。
  より安全なコードを使用するユーザーにとっては、開発者が追加の保護を実装する可能性があります。
  使用しているソフトウェアについて質問や懸念がある場合は、
  適切なサポートチャネル（多くのフリーおよびオープンソースソフトウェアのBitcoinプロジェクトにとっての
  [Bitcoin Stack Exchange][]などの）を通じてその開発者に連絡してください。

- **<!--timestamping-design-->タイムスタンプの設計:**
  Bitcoinベースの[Open Timestamps][]（OTS）システムの設計について、
  Bitcoin-Devメーリングリストで長く続いた議論が今週[終わりを迎えた][poelstra timestamping]ようです。
  議論の元は、タイムスタンプシステムにおける2つの異なる設計の存在にあったようです:

  - *Time Stamped Proofs of Existence (TSPoE):*
    Bitcoinのトランザクションは、ドキュメントにコミットするハッシュダイジェストにコミットします。
    トランザクションがブロックで承認されると、コミットメントの作成者は、
    ブロックが作成された段階でドキュメントが存在していたことを第三者に証明することができます。
    特に、各タイムスタンプトランザクションは、他のタイムスタンプトランザクションから完全に独立しており、
    同じドキュメントに何度もタイムスタンプを押すことが可能で、そのタイムスタンプ間の関連性はありません。

  - *Event Ordering (EO):*
    システムのすべてのユーザーがすべてのコミットメントを確認できるよう、
    指定された方法ですべて相互に関連する一連のトランザクションがドキュメントにコミットします。
    このシステムで2回以上タイムスタンプが付けられたドキュメントは、
    最初のタイムスタンプが付けられたのはいつかを判別することができます。

  OTSで実装されているTSPoEシステムは、基本的に完全に効率的です。
  同じ量のグローバルストレージのスペースを使用して、無制限の数のドキュメントにタイムスタンプを押すことができ、
  タイムスタンプを要求する各ユーザーがタイムスタンプの証明の保存に責任を持つことができます。
  このシステムは、コンセプトも実装もシンプルであるというメリットもあります。

  EOシステムでは、すべての参加者がすべてのドキュメントに対するコミットメントを保存する必要があります。
  これはとても効率的ではなく、複雑さが増す可能性があります。
  その代わり、参加者はドキュメントがいつシステムに最初に公開されたかを検証することができます。

  この議論は、Open Timestampsやトランザクションスポーンサーシップ
  （もともとの議論のトピックは[ニュースレター #116][news116 sponsorship]参照）
  などのシステムの提案の変更に繋がるものではありませんでした。
  議論の参加者の中には、「タイムスタンプ」が意味するものについて、
  それぞれ異なる概念を持っていることに驚いたようです。

- **新しいシビル対策RIDDLE:** Adam "Waxwing" Gibsonは、
  BitcoinのUTXOセットを使用し、適度に良いプライバシーを提供できる[シビル対策][sybil]の仕組みの
  [提案][gibson riddle gist]をBitcoin-Devメーリングリストに[投稿しました][gibson riddle post]。
  ユーザーは、UTXOの1つが自分に属し、その他は他のユーザーに属するUTXOのリストを生成することができます。
  続いて、ユーザーはそれがUTXOのリストのいずれかの所有者によるものであるが、
  どの所有者がそれを作成したかは分からない署名を作成します。

  悪意あるユーザーは、このような証明を多数作成することができますが、
  オプションのプールを使い切る前にその数は有限であり、
  希少なネットワークリソースを過剰に消費する能力を制限することができます。
  また、悪意あるユーザーは、UTXOをできるだけ長く使用し、またそれを使って新しいUTXOを入手することもできますが、
  これにはトランザクション手数料が発生します。このようなコストがかかることも不正利用の抑止につながります。
  サービス側では、ユーザーが選択できるUTXOを制限することで、さらにシビル制限が可能です。
  たとえば、あるサービスでは、1 BTCの値を持つUTXOで、1年間未使用のものしか署名を受け付けないようにすることができます。

  Gibsonは、メンバーシップの証明に、グローバルな証明とローカルな証明の2種類を提案しています。
  グローバルな証明は、検証者間で共有され、理想的な条件下では、
  ユーザーはグローバルコンテキストにおいてUTXO毎に1つの証明しか作成できないようにします。
  たとえば、ユーザーは、1年前の1 BTCのUTXOにつきアカウントを1つだけ登録することができます。

  ローカルコンテキストは、単一の検証者（もしくは分散型取引所のような関連する検証者グループ）に固有のものです。
  たとえば、ユーザーはUTXOを使ってサービスAのAPIにアクセスし、同じUTXOをサービスBで再利用できます。

  また、値の多いUTXOは値が少ない複数のUTXOとして扱えるため、
  10 BTCのUTXOは、グローバルコンテキストでそれぞれ1 BTCの資本を必要とする異なる10種類のサービスのアカウントに登録することができます。

  RIDDLEプロトコルは、他のシビル対策の仕組みよりもプライバシー面で優れていますが、
  Gibsonは、システムの利用により得られる情報が他の利用可能な情報と組み合わされて、
  ユーザーのプライバシーを損なう可能性があることを警告しています。
  彼は、「この種のシステムが鉄壁なプライバシーの保証を提供できる可能性はありません。
  実際の署名UTXOの場所を保護するのが死活問題である場合は、このようなシステムは絶対に使用しないでください。」と書いています。

  Lightning-Devメーリングリストでは、開発者のZmnSCPxjが、
  LNのシビル対策の仕組みをUTXOベースのチャネル識別子から切り離すオプションとしてRIDDLEを[提案しました][zmnscpxj riddle]。
  このチャネル識別子は、[Taproot][topic taproot]や[集約署名][topic musig]の時代において、
  どのオンチェーントランザクションがLNチャネルの開設および協調クローズであるかを不必要に公開しています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **ZeusがTaprootをサポート:**
  [Zeus v0.6.5-rc1][]は、LND v0.15+のバックエンド用の[Taproot][topic taproot]の送受信のサポートを追加しました。

- **Wasabi Wallet 2.0リリース:**
  この[Coinjoin][topic coinjoin]ソフトウェアは、[WabiSabiプロトコル][news194 wabisabi]の実装とその他の改良を[リリースしました][wasabi 2.0]。

- **SparrowがTaprootのハードウェア署名を追加:**
  [HWI 2.1.0][]にアップグレードすることで、
  Sparrow [1.6.4][sparrow 1.6.4]は、特定のハードウェア署名デバイスに対するTaprootの署名サポートを追加しました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.15.0-beta.rc6][]は、この人気のあるLNノードの次のメジャーバージョンのリリース候補です。

- [LDK 0.0.108][]および0.0.107は、
  [ラージチャネル][topic large channels]と[ゼロ承認チャネル][topic zero-conf channels]をサポートし、
  モバイルクライアントがサーバーからルーティング情報（*ゴシップ*）同期できるコードを提供し、
  その他の機能およびバグ修正を追加したリリースです。

- [BDK 0.19.0][]は、[ディスクリプター][topic descriptors]、[PSBT][topic psbt]および他のサブシステムを介した
  [Taproot][topic taproot]の実験的なサポートを追加しました。
  また、新しい[コイン選択アルゴリズム][topic coin selection]も追加されています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core GUI #602][]では、GUIで変更された設定を、
  ヘッドレスデーモン（`bitcoind`）によってもロードされるファイルに書き込むようになったため、
  ユーザーがBitcoin Coreをどのように起動しても変更した設定が使用されます。

- [Eclair #2224][]は、Short Channel Identifier (scid)エイリアスと[ゼロ承認チャネル][topic zero-conf channels]タイプをサポートしました。
  scidエイリアスは、プライバシーを向上させ、ノードが十分に承認される前のチャネルを簡単に参照できるようにしました。
  ゼロ承認チャネルは、2つのノードが、チャネルが十分に承認される前に、
  特定の制限の下で安全にルーティング支払いにチャネルを使用することを合意できるようにします。

- [HWI #611][]は、BitBox02ハードウェア署名デバイスで、[bech32mアドレス][topic bech32]の単一の署名をサポートしました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="602,2224,611,25353,25373" %}
[lnd 0.15.0-beta.rc6]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc6
[ldk 0.0.108]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.108
[bdk 0.19.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.19.0
[rbf discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020557.html
[hertzbleed]: https://www.hertzbleed.com/
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[poelstra timestamping]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020569.html
[gibson riddle post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020555.html
[gibson riddle gist]: https://gist.github.com/AdamISZ/51349418be08be22aa2b4b469e3be92f
[bitcoin stack exchange]: https://bitcoin.stackexchange.com/
[open timestamps]: https://opentimestamps.org/
[sybil]: https://en.wikipedia.org/wiki/Sybil_attack
[zmnscpxj riddle]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003607.html
[Zeus v0.6.5-rc1]: https://github.com/ZeusLN/zeus/releases/tag/v0.6.5-rc1
[wasabi 2.0]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v2.0.0.0
[news194 wabisabi]: /ja/newsletters/2022/04/06/#payjoin-wabisabi
[HWI 2.1.0]: /ja/newsletters/2022/03/23/#hwi-2-1-0-rc-1
[sparrow 1.6.4]: https://github.com/sparrowwallet/sparrow/releases/tag/1.6.4
