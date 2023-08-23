---
title: 'Bitcoin Optech Newsletter #265'
permalink: /ja/newsletters/2023/08/23/
name: 2023-08-23-newsletter-ja
slug: 2023-08-23-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、古いバックアップ状態に対するFraud Proofについて掲載しています。
また、サービスやクライアントソフトウェアの最近の変更や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **古いバックアップ状態のFraud Proof:** Thomas Voegtlinは、
  最新バージョン以外の状態のバックアップをユーザーに提供した場合にペナルティを受けるサービスのアイディアを
  Lightning-Devメーリングリストに[投稿しました][voegtlin backups]。
  基本的な仕組みはシンプルで:

    - アリスはバックアップしたいデータを持っています。データにはバージョン番号が含まれており、
      データに対する署名を作成し、ボブにデータと署名を渡します。

    - ボブは、アリスのデータを受け取った直後に、データのバージョン番号と現在時刻の両方にコミットする署名をアリスに送信します。

    - その後、アリスはデータを更新し、バージョン番号をインクリメントし、
      ボブに更新したデータとそのデータに対する署名を提供します。ボブは、
      新しい（より高い）バージョン番号と新しい（より高い）現在時刻にコミットした署名を返します。
      両者はこのステップを何度も繰り返します。

    - 最終的に、アリスはボブをテストするために自分のデータを要求します。
      ボブは、データのバージョンとそのデータに対する彼女の署名を送り、
      それが実際に彼女のデータであることを証明することができます。
      ボブはまた、データのバージョン番号と現在時刻にコミットした署名も送ります。

    - もしボブが不正をして、古いバージョン番号の古いデータをアリスに送った場合、
      アリスは、_Fraud Proof_ を生成することができます。つまり、
      ボブが以前、ボブが提供した署名コミットメントよりも前の時間により高いバージョン番号に署名したことを示すことができます。

  ここまでの説明で、最新状態のFraud Proofを生成するこの仕組みには、Bitcoin特有のものはありません。
  しかし、Voegtlinは、ソフトフォークで[OP_CHECKSIGFROMSTACK (CSFS)とOP_CAT][topic op_checksigfromstack] opcodeが
  Bitcoinに追加された場合、このFraud Proofをオンチェーンで使用することが可能になると指摘しています。

  たとえば、アリスとボブは、アリスがこの種のFraud Proofを提供できれば、
  アリスがチャネルの資金をすべて使用できるという追加の[taproot][topic taproot]の条件を含むLNチャネルを共有します。
  チャネルの通常の動作に追加のステップが加わります。つまり、チャネルを更新するたびに、
  アリスはボブに現在の状態（状態番号を含む）に対する署名を渡します。
  その後、アリスはボブと自然に再接続するたびに、最新のバックアップを要求し、
  上記の仕組みを使用してその整合性を検証します。ボブが古いバックアップを提供した場合、
  アリスはFraud ProofとCSFSの使用条件を使ってチャネルの全残高を使用することができます。

  この仕組みは、アリスが実際にデータを失った場合に、
  ボブから提供された状態を最新のチャネルの状態として使用することが安全になるようにします。
  現在のLNのチャネル設計（LN-Penalty）では、ボブがアリスを騙してアリスに古い状態を使用させると、
  ボブはチャネル内の彼女の全残高を盗むことができます。
  [LN-Symmetry][topic eltoo]のような提案されているアップグレードを使用しても、
  アリスが古い状態を使用すると、ボブは彼女から資金を盗むことができる可能性があります。
  最新の状態を偽ったボブに対して金銭的なペナルティを科すことが可能になれば、
  ボブがアリスに嘘をつく可能性は低くなるでしょう。

  この提案には多くの議論がありました:

  <!-- I've previously confirmed that "ghost43" (all lowercase) is how
  they'd like to be attributed -->

  - *<!--noted-->* Peter Toddは、基本的な仕組みは一般的なものであると[指摘しました][todd backups1]。
    これはLN特有のものではなく、さまざまなプロトコルで有用である可能性があります。
    彼はまた、アリスがボブと自然に再接続するたびに、Fraud Proofを必要とせず
    ボブから最新の状態をダウンロードするだけのより単純な仕組みも[指摘しました][todd backups2]。
    もし、ボブが古い状態を提供した場合、アリスはボブとのチャネルを閉じ、彼が将来の支払いから得る転送手数料を拒否します。
    これは、[BOLTs #881][]で定義された[ピア・ストレージ][topic peer storage]や、
    今年初旬にCore Lightningで実験的に実装されたバージョン（[ニュースレター #238][news238 peer storage]参照）、
    （Bastien Teinturierの[メッセージ][teinturier backups]によると）
    LN用のPhoenixウォレットで実装された方式のバージョンと非常によく似ています。

  - *<!--reply-->* ghost43による[返信][ghost43 backups]では、金銭的なペナルティにつながるFraud Proofは、
    匿名のピアとデータを保存するクライアントにとって強力なツールであると説明されました。
    大手の人気サービスであれば、クライアントに嘘をつくのを避けるために評判を気にするかもしれませんが、
    匿名のピアには失う評判はありません。また、ghost43によって提案されたのはプロトコルを対称的に修正することで、
    アリスがボブとの間で彼女の状態を保存する（そしてボブが嘘をついた場合にペナルティを受ける）のに加えて、
    ボブはアリスとの間で彼の状態を保存してもらい、アリスが嘘をついた場合にペナルティを受けさせることができるというものです。

      Voegtlinは、このアイディアを広げ、ウォレットソフトウェアのプロバイダーには良い評判が非常に重要で、
      ソフトウェアが可能な限り最高に機能していたとしても、ユーザーが資金を失った場合には評判が失われると[警告しました][voegtlin backups2]。
      したがって、ウォレットソフトウェアの開発者として、ピア・バックアップのような仕組みを使っているElectrumユーザーから
      匿名のピアによって盗まれるリスクを最小限に抑えることは彼にとって重要なことです。

  議論に対する明確な解決策はありませんでした。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Scaling Lightningのフィードバックの募集:**
  [Scaling Lightning][]は、regtestおよびsignet上のライトニングネットワークのテストツールキットです。
  このプロジェクトは、さまざまな構成とシナリオで異なるLN実装をテストするためのツールを提供することを目的としています。
  このプロジェクトは、コミュニティに向けに最近の[アップデート動画][sl twitter update]を提供しました。
  LN開発者や研究者およびインフラ運用者は、[フィードバックを提供する][sl tg]ことが推奨されます。

- **Torq v1.0リリース:**
  エンタープライズユーザーを対象としたLNノード管理ソフトウェア[Torq][torq github]は、
  LSP（Lightning Service Provider）機能や、自動化ワークフロー、大規模ノード運用者向けの高度な機能を含む
  v1.0のリリースを[発表しました][torq blog]。

- **Blixt Wallet v0.6.8リリース:**
  [v0.6.8のリリース][blixt v0.6.8]には、[HOLDインボイス][topic hold invoices]や
  [ゼロ承認チャネル][topic zero-conf channels]のサポート、その他の改善が含まれています。

- **Sparrow 1.7.8リリース:**
  Sparrow [1.7.8][sparrow 1.7.8]は、P2TRアドレスを含む[BIP322][]の[メッセージ署名][topic generic signmessage]のサポートが追加され、
  [RBF][topic rbf]および[CPFP][topic cpfp]による手数料引き上げ機能にさまざまな改善が加えられています。

- **オープンソースのASICマイナーbitaxeUltraのプロトタイプ:**
  [bitaxeUltra][github bitaxeUltra]は、既存の商用マイニングハードウェアをベースにした
  ASIC（Application-Specific Integrated Circuit）を使用するオープンソースマイナーです。

- **FROSTソフトウェアFrostsnapの発表:**
  チームは、実験的なFROST実装である[secp256kfun][secp256kfun github]を使用して、
  FROST[閾値署名][topic threshold signature]方式を[構築する][frostsnap github]というビジョンを[発表しました][frostsnap blog]。

- **Libflorestaライブラリの発表:**
  [Utreexo][topic utreexo]を搭載した[Floresta][news247 floresta]ノードに関する以前の研究を基に構築された
  [Libfloresta][libfloresta blog]は、UtreexoベースのBitcoinノード機能をアプリケーションに追加するためのRustライブラリです。

- **Wasabi Wallet 2.0.4リリース:**
  Wasabi [2.0.4][wasabi 2.0.4]は、[RBF][topic rbf]または[CPFP][topic cpfp]による手数料引き上げ機能の追加、
  [Coinjoin][topic coinjoin]の改善、ウォレットロード処理の高速化、RPCの機能強化、その他の改善とバグ修正が含まれています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 23.08rc3][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。

- [HWI 2.3.1][]は、ハードウェア署名デバイスを扱うためのこのツールキットのマイナーリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #27981][]は、２つのノードが互いにデータを受信できなくなる可能性があったバグを修正しました。
  アリスのノードがボブのノードに送信するためにキューに入れられた多くのデータを持っている場合、
  アリスのノードはボブから新しいデータを受け入れる前にそのデータを送信しようとします。
  もし、ボブのノードもアリスのノードに送信するためにキューに入れられた多くのデータを持っている場合、
  ボブのノードもアリスから新しいデータを受け入れることはないでしょう。
  このため、どちらも相手からデータをいつまでも受け取ろうとしない可能性があります。
  この問題は、もともと[Elements Project][]で発見されました。

- [BOLTs #919][]では、LNの仕様が更新され、ある金額を超えるトリムされるHTLCを受け付けなくなりました。
  トリムされるHTLCは、チャネルのコミットメントトランザクションにアウトプットとして追加されない転送可能な支払いです。
  代わりに、トリムされるHTLCの金額と同額の金額がトランザクション手数料に割り当てられます。
  これにより、オンチェーンで[経済的でない][topic uneconomical outputs]支払いをLNを使用して転送することが可能になります。
  しかし、トリムされるHTLCが保留中のままチャネルを閉じる必要がある場合、
  ノードはその資金を回収する方法がないため、その種の損失に対するノードのエクスポージャーを制限するのは理にかなっています。
  この制限を追加するさまざまな実装については、
  LDKは[ニュースレター #162][news162 trim]を、Eclairは[ニュースレター #171][news171 trim]を、
  Core Lightningは[ニュースレター #173][news173 trim]を、
  また関連するセキュリティ上の懸念については[ニュースレター #170][news170 trim]をご覧ください。

- [Rust Bitcoin #1990][]は、オプションで`bitcoin_hashes`をSHA256、
  SHA512および約半分のサイズのRIPEMD160のより遅い実装でコンパイルできるようにしました。
  これは頻繁にハッシュ計算を行う必要のない組み込みデバイス上のアプリケーションに適しています。

- [Rust Bitcoin #1962][]は、互換性のあるx86アーキテクチャ上でハードウェアに最適化されたSHA256演算を使用する機能を追加しました。

- [BIPs #1485][]では、[Drivechain][topic sidechains]の[BIP300][]の仕様が更新されました。
  主な変更は、特定の文脈における`OP_NOP5`を`OP_DRIVECHAIN`に再定義したことです。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27460,27981,919,1990,1962,1485,881" %}
[core lightning 23.08rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.08rc3
[news238 peer storage]: /ja/newsletters/2023/02/15/#core-lightning-5361
[news162 trim]: /ja/newsletters/2021/08/18/#rust-lightning-1009
[news171 trim]: /ja/newsletters/2021/10/20/#eclair-1985
[news173 trim]: /ja/newsletters/2021/11/03/#c-lightning-4837
[news170 trim]: /ja/newsletters/2021/10/13/#ln-spend-to-fees-cve-ln-cve
[elements project]: https://elementsproject.org/
[voegtlin backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004043.html
[todd backups1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004046.html
[todd backups2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004044.html
[teinturier backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004045.html
[ghost43 backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004052.html
[voegtlin backups2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004055.html
[hwi 2.3.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.3.1
[Scaling Lightning]: https://github.com/scaling-lightning/scaling-lightning
[sl twitter update]: https://twitter.com/max_blue__/status/1681781001373065216
[sl tg]: https://t.me/+AytRsS0QKH5mMzM8
[torq github]: https://github.com/lncapital/torq
[torq blog]: https://ln.capital/articles/announcing-torq-V1.0
[blixt v0.6.8]: https://github.com/hsjoberg/blixt-wallet/releases
[sparrow 1.7.8]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.8
[github bitaxeUltra]: https://github.com/skot/bitaxe/tree/ultra
[frostsnap blog]: https://frostsnap.com/introducing-frostsnap.html
[frostsnap github]: https://github.com/frostsnap/frostsnap
[secp256kfun github]: https://github.com/LLFourn/secp256kfun
[news247 floresta]: /ja/newsletters/2023/04/19/#utreexo-electrum-server
[libfloresta blog]: https://blog.dlsouza.lol/2023/07/07/libfloresta.html
[wasabi 2.0.4]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v2.0.4
