---
title: 'Bitcoin Optech Newsletter #232'
permalink: /ja/newsletters/2023/01/04/
name: 2023-01-04-newsletter-ja
slug: 2023-01-04-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、リリースの署名鍵の侵害についてBitcoin Knotsのユーザーへの警告と、
Bitcoin Coreの2つのソフトウェアフォークのリリースの発表、
Replace-By-Feeポリシーに関する継続的な議論の要約を掲載しています。
また、新しいソフトウェアリリースとリリース候補の発表や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **Bitcoin Knotsの署名鍵の侵害:** Bitcoin Knotsフルノード実装のメンテナーは、
  Knotsのリリースに署名するために使用するPGP鍵の侵害を発表しました。
  彼らは、「これが解決されるまで、Bitcoin Knotsをダウンロードし信用しないでください。
  ここ数ヶ月の間に既にダウンロードして実行している場合は、今のところそのシステムのシャットダウンを検討してください。
  」と言っています。
  <!-- https://web.archive.org/web/20230103220745/https://twitter.com/LukeDashjr/status/1609763079423655938 -->
  他のフルノード実装は影響を受けません。

- **Bitcoin Coreのソフトウェアフォーク:** 先月、Bitcoin Coreを元にした2つのパッチセットがリリースされました：

    - *Bitcoin Inquisition:* Anthony Townsは、Bitcoin-Devメーリングリストで
      [Bitcoin Inquisition][]を[発表しました][towns bci]。
      これは、Bitcoin Coreのソフトウェアをフォークしたもので、
      提案されたソフトフォークやその他の重要なプロトコル変更を、
      デフォルト[signet][topic signet]上でテストできるように設計されています。
      このバージョンには、[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]と、
      [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]の提案のサポートが含まれています。
      Townsのメールには、signetのテストに参加する人向けの有益な追加情報も含まれています。

    - *フルRBFのピアリングノード:* Peter Toddは、
      ノードが`mempoolfullrbf`を有効に設定している場合にのみ、
      ネットワークアドレスを他のノードに配信する際に[フルRBFのサービスビット][full-RBF service bit]をセットするよう
      Bitcoin Core 24.0.1にパッチをあてたバージョンを[発表しました][todd rbf node]。
      このパッチを実行しているノードは、最大4つ、フルRBFのサポートを配信している追加ピアにも接続します。
      Peter Toddは、他のフルノード実装であるBitcoin Knotsも、
      フルRBFのサポートを配信するノードとピアリングするコードは含まれていないものの、
      サービスビットを配信していることを指摘しています。
      このパッチは、Bitcoin CoreのPR[#25600][bitcoin core #25600]に基づくものです。

- **<!--continued-rbf-discussion-->RBFの継続的な議論:** mainnetで[フルRBF][topic rbf]を実現するための継続的な議論において、
  先月はメーリングリスト上でいくつかの並行した議論が行われました:

    - *<!--full-rbf-nodes-->フルRBFノード:* Peter Toddは、Bitcoin Core 24.xを実行しており、
      IPv4アドレスでインバウンド接続を受け入れることを公表しているフルノードを調査しました。
      彼は、約17%が、[BIP125][]のシグナルを含まないトランザクションを置換する
      フルRBFの置換トランザクションをリレーしていることを[発見しました][todd probe]。
      これは、これらのノードが、オプションのデフォルト値が`false`であるにも関わらず、
      `mempoolfullrbf`設定オプションを`true`にセットして実行していることを示唆します。

    - *RBF-FSSの再検討:* Daniel Lipshitzは、Bitcoin-Devメーリングリストに、
      FSS(First Seen Safe)と呼ばれるタイプのトランザクション置換のアイディアを[投稿しました][lipshitz fss]。
      この置換は、少なくとも元のトランザクションと同じ金額を元のアウトプットに支払い、
      置換の仕組みが元のトランザクションの受信者から資金を盗むために使用できないことを保証します。
      Yuval Kogmanは、2015年にPeter Toddが投稿した[以前の][rbf-fss]同じアイディアのリンクを[返信しました][kogman fss]。
      [その後の][todd fss]返信で、Toddは、このアイディアがオプトインRBFやフルRBFよりも好ましくないいくつかの点を説明しています。

    - *<!--full-rbf-motivation-->フルRBFの動機:* Anthony Townsは、
      さまざまなグループがフルRBFを実行する動機についてスレッドに[返信しました][towns rbfm]。
      Townsは、マイナーのトランザクションの選択という文脈で、
      経済合理性が何を意味し、何を意味しないかを分析しています。
      短期的な利益を最適化するマイナーは、当然フルRBFを好むでしょう。
      しかし、Townsは、マイニング機器に長期的な資本投資を行っているマイナーは、
      複数のブロックにわたる手数料収入の最適化を好むかもしれず、
      その場合、常にフルRBFを好むとは限らないと指摘しています。
      彼は、考慮すべき3つのシナリオを提示しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Eclair 0.8.0][]は、この人気のあるLNノード実装のメジャーバージョンリリースです。
  [ゼロ承認チャネル][topic zero-conf channels]とSCID（Short Channel IDentifier）エイリアスのサポートが追加されました。
  これらの機能やその他の変更点についての詳細は、[リリースノート][eclair 0.8 rn]をご覧ください。

- [LDK 0.0.113][]は、LN対応のウォレットやアプリケーションを構築するためのライブラリの新バージョンです。

- [BDK 0.26.0-rc.2][]は、ウォレットを構築するためのこのライブラリのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #26265][]は、トランザクションリレーポリシーにおいて許容される
  トランザクションの非witnessシリアライズサイズの最小値を82バイトから65バイトに緩和しました。
  たとえば、これまでは小さすぎると拒否されていた、単一のインプットと
  4バイトのOP\_RETURNパディングの単一のアウトプットを持つトランザクションを
  ノードのmempoolに受け入れ、リレーすることができるようになりました。
  この変更の背景と動機については、[ニュースレター #222][min relay size ml]を参照ください。

- [Bitcoin Core #21576][]では、外部署名者（例：[HWI][topic hwi]）を使用するウォレットが、
  GUIや`bumpfee` RPCを使用する際に、[オプトインRBF][topic rbf]による手数料の引き上げができるようになりました。

- [Bitcoin Core #24865][]は、ウォレットが作成された後に生成されたすべてのブロックがノードに残っている場合に、
  古いブロックがプルーニングされるノード上でウォレットのバックアップの復元を可能にしました。
  これらのブロックは、Bitcoin Coreがウォレットの残高に影響を与えるトランザクションをスキャンするために必要です。
  Bitcoin Coreは、バックアップにウォレットが作成された日付が含まれているため、
  ウォレットの年齢を決定することが可能です。

- [Bitcoin Core #23319][]は、`verbose`パラメーターに`2`がセットされている場合に、
  追加情報を提供するよう`getrawtransaction`RPCを更新しました。
  追加情報には、トランザクションが支払った手数料と、
  そのトランザクションのインプットとして使用された以前のトランザクション（「prevouts」）のアウトプットに関する情報が含まれています。
  情報の取得方法については、[ニュースレター #172][news172 prevout]を参照ください。

- [Bitcoin Core #26628][]では、同じパラメーター名を複数含むRPCリクエストを拒否するようになりました。
  これまでは、daemonはパラメーターが繰り返されるリクエストについて、繰り返されるパラメーターの内、
  最後のものだけを持つかのように扱っていました。たとえば、`{"foo"="bar", "foo"="baz"}`は、
  `{"foo"="baz"}`として扱われていました。この場合、リクエストは失敗するようになりました。
  `bitcoin-cli`を名前付きパラメーターで使用する場合は、動作は変わりません。
  同じ名前の複数のパラメーターは拒否されませんが、最後ののものだけが送信されます。

- [Eclair #2464][]では、リモートピアが支払いを処理する準備ができた際に、イベントを発生させる機能を追加しました。
  これは、ローカルノードがリモートピアのために支払いを一時的に保留し、
  ピアが接続（または再接続）するのを待ってから支払いを行う[非同期支払い][topic async payments]の文脈で特に役立ちます。

- [Eclair #2482][]は、最後の数ホップが受信者によって選択される[ブラインド・ルート][topic rv routing]を使用した
  支払いの送信を許可するようにしました。受信者はオニオンによる暗号化によりホップの詳細を難読化し、
  暗号化したデータとブラインド・ルートの最初のノードのIDを送信者に提供します。
  送信者は、その最初のノードへの支払い経路を構築し、
  最後のいくつかのノードのオペレーターが復号して受信者に支払いを転送するために使用する暗号化された詳細を含めます。
  これにより、受信者は送信者にノードやチャネルのIDを開示することなく支払いを受け入れることができ、
  プライバシーを向上させることができます。

- [LND #2208][]では、支払額に対するチャネルの最大キャパシティに応じて、異なる支払い経路を選択するようになりました。
  支払額がチャネルのキャパシティに近くなると、そのチャネルが経路として選択される可能性は低くなります。
  これは、Core LightningやLDKで既に使われている経路探索コードとほぼ同じです。

- [LDK #1738][]と[#1908][ldk #1908]は、[Offer][topic offers]を処理するための追加機能を提供します。

- [Rust Bitcoin #1467][]は、トランザクションのインプットとアウトプットの[weight単位][weight units]のサイズを
  計算するメソッドを追加しました。

- [Rust Bitcoin #1330][]は、`PackedLockTime`型を削除し、
  下流のコードにほぼ同じ`absolute::LockTime`型を使用するよう要求しています。
  コードを更新する人が調査する必要がある2つの型の違いは、
  `PackedLockTime`が`Ord`を提供するのに対し、`absolute::LockTime`は提供しません（
  locktimeはそれを含むトランザクションの`Ord`で考慮されます）。

- [BTCPay Server #4411][]では、Core Lightning 22.11（[ニュースレター #229][news229 cln]）を使用するように更新されました。
  [BOLT11][]インボイスに注文の説明のハッシュを入れたい人は、
  `invoiceWithDescriptionHash`プラグインを使用することなく、
  代わりに`description`フィールドをセットして`descriptionHashOnly`オプションを有効にすることができます。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26265,21576,24865,23319,26628,2464,2482,2208,1738,1908,1467,1330,4411,25600" %}
[news172 prevout]: /ja/newsletters/2021/10/27/#bitcoin-core-22918
[weight units]: https://en.bitcoin.it/wiki/Weight_units
[towns bci]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021275.html
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin
[todd probe]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021296.html
[lipshitz fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021272.html
[kogman fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021274.html
[todd fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021286.html
[rbf-fss]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-May/008248.html
[towns rbfm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021276.html
[todd rbf node]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021270.html
[news229 cln]: /ja/newsletters/2022/12/07/#core-lightning-22-11
[min relay size ml]: /ja/newsletters/2022/10/19/#minimum-relayable-transaction-size
[full-rbf service bit]: https://github.com/petertodd/bitcoin/commit/c15b8d70778238abfa751e4216a97140be6369af
[eclair 0.8.0]: https://github.com/ACINQ/eclair/releases/tag/v0.8.0
[eclair 0.8 rn]: https://github.com/ACINQ/eclair/blob/master/docs/release-notes/eclair-v0.8.0.md
[ldk 0.0.113]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.113
[bdk 0.26.0-rc.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.26.0-rc.2
