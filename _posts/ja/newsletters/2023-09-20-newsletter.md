---
title: 'Bitcoin Optech Newsletter #269'
permalink: /ja/newsletters/2023/09/20/
name: 2023-09-20-newsletter-ja
slug: 2023-09-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、近々開催されるリサーチイベントのお知らせと、
さまざまなサービスやクライアントソフトウェアの重要なアップデートの概要、
新しいソフトウェアリリースとリリース候補の発表および、
人気のあるインフラストラクチャソフトウェアの最近の変更点など恒例のセクションを掲載しています。

## ニュース

- **Bitcoinのリサーチイベント:** Sergi Delgado SeguraとClara Shikhelmanは、
  10月27日にニューヨークで開催されるBitcoin Research Dayイベントの発表を
  Bitcoin-DevメーリングリストとLightning-Devメーリングリストに[投稿しました][ds brd]。
  これは、多くの著名なBitcoin研究者が講演する対面イベントです。
  予約が必要で、投稿時点では短い（5分間）プレゼンテーション枠がいくつか残っていました。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Bitcoinに似たScript Symbolic Tracer (B'SST)のリリース:**
  [B'SST][]は、BitcoinとElementsのスクリプト分析ツールで、「スクリプトが強制する条件、
  起こりうる失敗、データの可能な値」などのスクリプトに関するフィードバックを提供します。

- **STARKヘッダーチェーン検証のデモ:**
  [ZeroSync][news222 zerosync]プロジェクトは、Bitcoinのブロックヘッダーのチェーンを証明および検証するために
  STARKsを使用した[デモ][zerosync demo]と[リポジトリ][zerosync code]を発表しました。

- **JoinMarket v0.9.10リリース:**
  [v0.9.10][joinmarket v0.9.10]のリリースでは、
  非[Coinjoin][topic coinjoin]トランザクションに対する[RBF][topic rbf]サポートが追加され、
  手数料の推定の更新や、その他の改善が行われています。

- **BitBoxがMiniscriptを追加:**
  [最新のBitBox02ファームウェア][bitbox blog]では、セキュリティの修正と使いやすさの強化に加えて、
  [Miniscript][topic miniscript]のサポートが追加されています。

- **Machankuraが加法的バッチ機能を発表:**
  Bitcoinサービスプロバイダーの[Machankura][]は、
  FROSTによる[閾値][topic threshold signature]支払い条件を持つ[Taproot][topic taproot]ウォレットで、
  RBFを使用した加法的[バッチ][batching]機能をサポートするベータ機能を[発表しました][machankura tweet]。

- **SimLNライトニングシミュレーションツール:**
  [SimLN][]は、LN研究者やプロトコル/アプリケーション開発者向けのシミュレーションツールで、現実的なLN支払いアクティビティを生成します。
  SimLNはLNDとCLNをサポートしており、EclairとLDK-Nodeの作業も進行中です。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 23.08.1][]は、いくつかのバグ修正を含むメンテナンスリリースです。

- [LND v0.17.0-beta.rc4][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。
  このリリースで予定されている主な実験的な新機能は、テストの恩恵を受ける可能性が高そうな、
  「Simple taproot channel」のサポートです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #26152][]は、以前追加されたインターフェース（[ニュースレター #252][news252 bumpfee]参照）に基づき、
  トランザクションに含まれるように選択されたインプットの手数料不足を補います。
  手数料不足は、ウォレットが低手数料率の未承認の祖先を持つUTXOを選択しなければならない時に発生します。
  ユーザーのトランザクションが、ユーザーが選択した手数料率を支払うためには、
  そのトランザクションは低手数料率の未承認の祖先と自身の両方について十分に高い手数料を支払う必要があります。
  つまり、このPRは、手数料率を選択した（トランザクションがいつ承認されるかに影響する優先順位を設定した）ユーザーが、
  ウォレットが未承認のUTXOを使用する必要がある場合でも、実際にその優先度になることを保証します。
  私たちが知っている他のすべてのウォレットは、承認済みのUTXOのみを使用する場合にのみ、
  特定の手数料率に基づく優先度を保証できます。このPRに関するBitcoin Core
  PR Review Clubミーティングの要約については、[ニュースレター #229][news229 bumpfee]をご覧ください。

- [Bitcoin Core #28414][]は、`walletprocesspsbt` RPCを更新し、
  ウォレットの処理ステップでブロードキャスト可能なトランザクションが発生した場合に、
  （16進数の）完全にシリアライズされたトランザクションを含めるようにしました。
  これにより、ユーザーは既に確定した[PSBT][topic psbt]に対して`finalizepsbt`を呼び出す手間が省けます。

- [Bitcoin Core #28448][]は、`rpcserialversion` (RPCシリアライゼーションバージョン)設定パラメーターを廃止しました。
  このオプションは、v0 segwitへの移行中に導入されたもので、古いプログラムが引き続き（segwitフィールドを持たない）
  ストリップされた形式でブロックやトランザクションにアクセスできるようにするためのものです。
  現時点で、すべてのプログラムはsegwitトランザクションを処理できるように更新されるべきで、
  このオプションはもはや必要ないはずですが、このPRで追加されたリリースノートに記載されているように、
  非推奨APIとして一時的に再有効化することは可能です。

- [Bitcoin Core #28196][]は、[BIP324][]で定義された
  [v2トランスポートプロトコル][topic v2 p2p transport]をサポートするために必要なコードの大部分を追加し、
  コードの広範なファズテストを追加しました。これにより新しい機能が有効になるわけではありませんが、
  将来のPRでこれらの機能を有効にするために追加する必要のあるコードの量を減らすことができます。

- [Eclair #2743][]は、コミットメントトランザクションの[CPFPによる手数料の引き上げ][topic cpfp]に、
  チャネルの[アンカー・アウトプット][topic anchor outputs]を使用するように手動でノードに指示する
  `bumpforceclose` RPCを追加しました。Eclairノードは必要に応じて手数料を自動的に引き上げますが、
  これにより、オペレーターが手動で同じ機能にアクセスできるようになります。

- [LDK #2176][]は、LDKが支払いをルーティングしようとした離れたチャネルで利用可能な
  流動性の量を確率的に推測しようとする精度を向上させました。精度は、
  1.00000 BTCのチャネルで0.01500 BTCと低かったのが、新しい精度は同じサイズのチャネルで
  約0.00006 BTCまで追跡します。これにより支払いの経路を見つけるのにかかる時間が若干長くなる可能性がありますが、
  テストによりと大きな違いはありませんでした。

- [LDK #2413][]は、[ブラインドパス][topic rv routing]への支払いの送信をサポートし、
  支払人から隠蔽（ブラインド）されている単一の最終ホップがそのパスへの支払いを受け取ることを可能にします。
  [PR #2514][ldk #2514]も今週マージされ、LDKでのブラインド支払いに対するその他のサポートを提供しています。

- [LDK #2371][]では、[オファー][topic offers]を利用した支払い管理がサポートされました。
  これにより、LDKを使用するクライアントアプリケーションは、オファーを使用してインボイスに支払う意思を登録し、
  送信されたオファーがインボイスを受信しなかった場合、支払いの試行をタイムアウトし、
  LDKの既存のコードを使用してインボイスに支払うことができます（最初の試行が成功しなかった場合の再試行を含む）。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26152,28414,28448,28196,2743,2176,2413,2514,2371" %}
[LND v0.17.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc4
[ds brd]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021959.html
[news252 bumpfee]: /ja/newsletters/2023/05/24/#bitcoin-core-27021
[news229 bumpfee]: /ja/newsletters/2022/12/07/#bitcoin-core-pr-review-club
[Core Lightning 23.08.1]: https://github.com/ElementsProject/lightning/releases/tag/v23.08.1
[B'SST]: https://github.com/dgpv/bsst
[news222 zerosync]: /ja/newsletters/2022/10/19/#zerosync
[zerosync demo]: https://zerosync.org/demo/
[zerosync code]: https://github.com/ZeroSync/header_chain
[joinmarket v0.9.10]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.10
[bitbox blog]: https://bitbox.swiss/blog/bitbox-08-2023-marinelli-update/
[Machankura]: https://8333.mobi/
[machankura tweet]: https://twitter.com/machankura8333/status/1695827506794754104
[batching]: /en/payment-batching/
[SimLN]: https://github.com/bitcoin-dev-project/sim-ln
