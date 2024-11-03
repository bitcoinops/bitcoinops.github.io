---
title: 'Bitcoin Optech Newsletter #247'
permalink: /ja/newsletters/2023/04/19/
name: 2023-04-19-newsletter-ja
slug: 2023-04-19-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、RGBプロトコルの開発状況のアップデートを掲載しています。
また、クライアントやサービスの最近の更新や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点など恒例のセクションも掲載しています。

## ニュース

- **RGBのアップデート:** Maxim Orlovskyは、Bitcoin-Devメーリングリストに
  RGBの開発状況のアップデートを[投稿][orlovsky rgb]しました。
  RGBは、オフチェーンのコントラクトで状態の更新を行うのに、Bitcoinのトランザクションを使用するプロトコルです。
  簡単な例として、トークンの作成と転送が挙げられますが、RGBはトークンの転送だけでなく、
  より多くの目的に使用するために設計されています。

  - オフチェーンで、アリスは、自分が管理するUTXOに初期状態で1,000トークンを割り当てるコントラクトを作成します。

  - ボブが、その内の400トークンを欲しがっているとします。アリスはボブに、
    元のコントラクトのコピーと、彼女のUTXOを使用して新しいアウトプットを生成するトランザクションを渡します。
    そのアウトプットにはコントラクトの新しい状態への非公開のコミットメントが含まれています。
    コントラクトの新しい状態は、量の新しい配分（400トークンをボブに、600トークンをアリスに戻す）と、
    それらの量を制御する2つのアウトプットの識別子を指定します。
    アリスはトランザクションをブロードキャストします。
    このトークン転送の二重支払いに対するセキュリティは、アリスのBitcoinトランザクションと同等になります。
    たとえば、アリスのトランザクションに6回の承認がある場合、トークンの転送は、
    最大6ブロックのフォークに対して安全です。

    量を管理するアウトプットは、必ずしもコミットメントを含むトランザクションのアウトプットである必要はありません
    （ただ、そうしても問題ありません）。これにより、RGBベースの転送を
    オンチェーンのトランザクションを解析して追跡することができなくなります。
    トークンは、既存のUTXOに、あるいは受信者が将来存在すると確信しているUTXO（
    たとえば、何年もオンチェーンには現れないかもしれない、コールドウォレットで事前署名された支払い）に転送することができます。
    これらのアウトプットのビットコインの量や、その他の特性は、RGBプロトコルにとっては関係ありませんが、
    アリスとボブは、それらが簡単に使えることを保証したいと思うでしょう。

  - その後、キャロルは1つのオンチェーントランザクションで、ボブから100トークンをアトミック・スワップで購入したいとします。
    キャロルは、自分のインプットから資金を出し、ボブにビットコインを支払うアウトプットと
    お釣りのビットコインを自分に返す2つめのアウトプットを含む未署名のPSBTを生成します。
    このアウトプットの1つは、キャロルがトークンを受け取り、ボブがお釣りのトークンを受け取る量とUTXO識別子にもコミットします。

    ボブはキャロルに、元のコントラクトと、ボブが400トークンを管理していることを証明するアリスが以前作成したコミットメントを提供します。
    ボブは、アリスが残りの600トークンを何に使ったかを知る必要はなく、
    アリスもボブとキャロルの間の取引に関与する必要はありません。
    ボブは、トークンを管理するUTXOの署名済みインプットでPSBTを更新します。

    キャロルは、元のコントラクトと以前の状態更新の履歴を検証します。
    また、PSBTの他のすべてが正しいことも確認します。そして署名を提供し、トランザクションをブロードキャストします。

  上記のトークン転送の例はオンチェーンで行われましたが、オフチェーンで動作するようにプロトコルを変更することも簡単です。
  キャロルはダンにコントラクトのコピーと、彼女が100トークンを受け取るまでの状態更新の履歴を渡します。
  そしてキャロルとダンは、100トークンを受け取るアウトプットを作成します。このアウトプットを使用するには、両者の署名を必要とします。
  オフチェーンで、このマルチシグアウトプットを使用する多くの異なるバージョンのトランザクションを生成することで、
  トークンを相互に転送します。オフチェーンの各支払いは、トークンの配分と、
  それらのトークンを受け取るアウトプットの識別子をコミットします。最後に、
  そのうちの1つをブロードキャストし、状態をオンチェーン化します。

  トークンが割り当てられたアウトプットは、誰が最終的にトークンを管理するかを決定するBitcoinスクリプトによって制御されます。
  たとえば、キャロルがプリイメージと署名を提供できる場合はいつでもトークンを使用でき、
  タイムロックの期限が過ぎたらダンが単に署名のみでトークンを使用できるようにするといった
  [HTLC][topic htlc]スクリプトに支払うこともできます。これによりトークンを、
  LNで使用されているような、転送されるオフチェーン支払いに使用できます。

  スレッドへの[返信][tenga rgb]で、Federico Tengaは[LDK][ldk repo]のフォークをベースにした
  RGBベースの[LNノード][rgb-lightning-sample]と、そのプロジェクトの[LDK sample][ldk-sample]ノードのリンクを提供しました。
  そのプロジェクトのリンクをたどると、LNの互換性に関して役立つ[追加情報][rgb.info ln]が見つかります。
  RGBプロトコルに関するより詳細な情報は、LNP/BPアソシエーションがホストする[ウェブサイト][rgb.tech]で見つけることができます。

  今週の投稿で、OrlovskyはRGB v0.10の[リリース][rgb blog]を発表しました。
  最も重要なのは、新バージョンは以前のバージョンで作成されたコントラクトと互換性がないことです
  （ただし、mainnet上には商用のRGBコントラクトは存在しません）。
  この新しい設計は、将来のプロトコルの変更に対応するために、
  すべての新しいコントラクトをアップグレードできるようにすることを目的としています。
  その他にも多くの改良が実装され、追加機能のロードマップが提示されています。

  この記事を書いている時点で、この発表はメーリングリスト上でささやかな議論を得ています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Descriptor walletライブラリがブロックエクスプローラーを追加:**
  [Descriptor walletライブラリ][Descriptor wallet library]は、Rustのディスクリプターベースのウォレットライブラリで、
  rust-bitcoinをベースにしており、[miniscript][topic miniscript]、[ディスクリプター][topic descriptors]、
  [PSBT][topic psbt]をサポートしています。また、最近の[リリース][Descriptor Wallet v0.9.2]では、
  トランザクションインプットのwitnessからTaprootの[制御ブロック][se107154]の拡張された詳細や、
  トランザクションのスクリプトに合致するディスクリプターとminiscriptを解析し表示する
  テキストベースの[ブロックエクスプローラー][topic block explorers]をサポートしています。

- **Stratum v2の参照実装のアップデートを発表:**
  プロジェクトは、プール内のマイナーが候補ブロックのトランザクションを選択する機能を含むアップデートの詳細を[公開][stratum blog]しました。
  マイナー、プールおよびマイニングファームウェアの開発者は、テストしフィードバックを提供することが推奨されています。

- **Liana 0.4リリース:**
  Lianaの[0.4リリース][liana 0.4]では、複数のリカバリーパスをサポートし、
  追加のディスクリプターを追加し、より大きな定足数を可能にします。

- **Coldcardファームウェアが追加のsighashフラグをサポート:**
  Coldcardの[バージョン 5.1.2 ファームウェア][coldcard firmware]は、
  `SIGHASH_ALL`だけでなく、すべての[署名ハッシュ][wiki sighash]（sighash）タイプをサポートし、
  高度なトランザクションの可能性を実現します。

- **Zeusが手数料の引き上げ機能を追加:**
  [Zeus v0.7.4][]は、LNのチャネル開設やチャネルクローズのトランザクションを含むオンチェーントランザクションに対して、
  [RBF][topic rbf]および[CPFP][topic cpfp]を利用した手数料の引き上げをサポートします。
  手数料の引き上げは、最初はLNDバックエンドでのみサポートされています。

- **UtreexoベースのElectrum Serverの発表:**
  [Floresta][floresta blog]は、[Utreexo][topic utreexo]を使用してサーバーのリソース要件を軽減する
  Electrumプロトコル互換のサーバーです。現在このソフトウェアは[signet][topic signet]のテストネットをサポートしています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BDK 0.28.0][]は、Bitcoin対応アプリケーションを構築するためのこのライブラリのメンテナンスリリースです。

- [Core Lightning 23.02.2][]は、いくつかのバグ修正を含む、この人気のあるLNノードソフトウェアのメンテナンスリリースです。

- [Core Lightning 23.05rc1][]は、このLNノードの次期バージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #27358][]は、Bitcoin Coreのリリースファイルを検証するプロセスを自動化するための
  `verify.py`スクリプトを更新しました。ユーザーは自分が信頼する署名者のPGP鍵をインポートします。
  スクリプトは、リリースのチェックサムファイルのリストと、それらのチェックサムにコミットした人の署名をダウンロードします。
  スクリプトは、これらのチェックサムにコミットした信頼できる署名者のうち、少なくとも *k* 人を検証します。
  ここで、 *k* はユーザーが必要とする信頼できる署名者の数です。信頼できる署名者による有効な署名が十分に見つかった場合、
  スクリプトはファイルをダウンロードし、ユーザーがそのバージョンのBitcoin Coreをインストールできるようにします。
  その他の詳細については、[ドキュメント][verify docs]を参照してください。
  このスクリプトはBitcoin Coreを使用するために必要なものではなく、
  インターネットからダウンロードしたセキュリティ上重要なファイルを使用する前に、
  ユーザーが自分で行うことを推奨しているプロセスを自動化するだけのものです。

- [Core Lightning #6120][]では、自動的にRBFでトランザクションの手数料を引き上げるタイミングのルールを実装するなど、
  [トランザクションの置換][topic rbf]ロジックを改善しました。また、
  未承認のトランザクションを定期的に再ブロードキャストし、
  確実にリレーされるようにしています（[ニュースレター #243][news243 rebroadcast]参照）。

- [Eclair #2584][]では、既存のチャネルに資金を追加するスプライス・インと、
  チャネルの資金をオンチェーンの宛先に送金するスプライス・アウトの両方に対応する
  [スプライシング][topic splicing]のサポートを追加しました。
  PRでは、現在の[ドラフト仕様][bolts #863]とは実装にいくつかの違いがあることを注意しています。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27358,6120,2584,863" %}
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[orlovsky rgb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021554.html
[tenga rgb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021558.html
[rgb-lightning-sample]: https://github.com/RGB-Tools/rgb-lightning-sample
[ldk-sample]: https://github.com/lightningdevkit/ldk-sample
[rgb.tech]: https://rgb.tech/
[rgb.info ln]: https://docs.rgb.info/lightning-network-compatibility
[verify docs]: https://github.com/theuni/bitcoin/blob/754fb6bb8125317575edec7c20b5617ad27a9bdd/contrib/verifybinaries/README.md
[news243 rebroadcast]: /ja/newsletters/2023/03/22/#lnd-7448
[Descriptor wallet library]: https://github.com/BP-WG/descriptor-wallet
[Descriptor Wallet v0.9.2]: https://github.com/BP-WG/descriptor-wallet/releases/tag/v0.9.2
[stratum blog]: https://stratumprotocol.org/blog/stratumv2-jn-announcement/
[liana 0.4]: https://wizardsardine.com/blog/liana-0.4-release/
[coldcard firmware]: https://coldcard.com/docs/upgrade
[wiki sighash]: https://en.bitcoin.it/wiki/Contract#SIGHASH_flags
[zeus v0.7.4]: https://github.com/ZeusLN/zeus/releases/tag/v0.7.4
[floresta blog]: https://medium.com/vinteum-org/introducing-floresta-an-utreexo-powered-electrum-server-implementation-60feba8e179d
[se107154]: https://bitcoin.stackexchange.com/questions/107154/what-is-the-control-block-in-taproot
[rgb blog]: https://rgb.tech/blog/release-v0-10/
[bdk 0.28.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.28.0
[Core Lightning 23.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02.2
[Core Lightning 23.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc1
