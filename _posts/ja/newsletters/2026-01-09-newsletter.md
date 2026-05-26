---
title: 'Bitcoin Optech Newsletter #387'
permalink: /ja/newsletters/2026/01/09/
name: 2026-01-09-newsletter-ja
slug: 2026-01-09-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreのウォレット移行バグに関する警告と、
ArkプロトコルをLNチャネルファクトリーとして使用する方法に関する投稿の要約、
サイレントペイメントディスクリプターのBIPドラフトのリンクを掲載しています。
また、リリース候補や人気のBitcoin基盤ソフトウェアの注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **Bitcoin Coreのウォレット移行バグ**: Bitcoin Coreは、
  バージョン30.0および30.1のレガシーウォレットの移行機能にバグがあることを[発表しました][bitcoin core notice]。
  Bitcoin Coreで名前のないウォレットを使用しているレガシーウォレットのユーザーが、
  これまでディスクリプターウォレットに移行しておらず、これらのバージョンで移行を試みると、
  移行が失敗した場合にウォレットディレクトリが削除され、資金が失われる可能性があります。
  ウォレットユーザーは、バージョン30.2がリリースされるまで（以下の[Bitcoin Core 30.2rc1](#bitcoin-core-30-2rc1)参照）、
  GUIまたはRPCを使ってウォレットの移行を試みないでください。レガシーウォレットの移行以外の機能を使用するユーザーは、
  これらのBitcoin Coreバージョンを通常通り引き続き利用できます。

- **チャネルファクトリーとしてのArkの利用**:
  René Pickhardtは、[Ark][topic ark]の最適なユースケースは、エンドユーザー向けの支払いソリューションではなく、
  柔軟な[チャネルファクトリー][topic channel factories]ではないかという彼のアイディアについて
  Delving Bitcoinに[投稿しました][rp delving ark cf]。Pickhardtのこれまでの研究は、
  [ルーティング][news333 rp routing]や[チャネルバランスの調整][news359 rp balance]を通じて
  ライトニングネットワークの支払いの成功率を最適化する手法に焦点を当ててきました。
  ライトニングチャネルを含んだArk的な構造については、以前から議論されています（[1][optech superscalar]、
  [2][news169 jl tt]、[3][news270 jl cov]）。

  Pickhardtのアイディアは、多くのチャネルオーナーがチャネルの流動性の変更（チャネルの開設や、
  閉鎖、スプライシング）をArkのvTXO構造を使ってバッチ処理することで、
  ライトニングネットワークの運用に必要なオンチェーンコストを大幅に削減できる可能性について焦点を当てています。
  ただし、チャネルが失効してからそのArkバッチが完全に期限切れになるまでの間、追加の流動性オーバーヘッドが発生します。
  Arkバッチを効率的なチャネルファクトリーとして使用することで、
  LSPはより多くのエンドユーザーに効率的に流動性を提供できるようになり、
  バッチに組み込まれた期限により、コストのかかる専用のオンチェーン強制閉鎖シーケンスなしで、
  アイドル状態のチャネルから流動性を回収する能力が保証されます。ルーティングノードも、
  個別のスプライシング操作ではなく、定期的なバッチを使ってチャネル間で流動性を移動させることで、
  より効率的なチャネル管理操作の恩恵を受けることができます。

  Greg Sandersは、同様の可能性を調査しており、特に[hArk][sr delving hark]を使って
  ライトニングチャネルの状態をあるバッチから別のバッチへ（ほぼ）オンラインで転送することを検討していると[返信しました][delving ark hark]。
  hArkには、[CTV][topic op_checktemplateverify]、`OP_TEMPLATEHASH`、または同様のopcodeが必要です。

  Vincenzo Palazzoは、Arkチャネルファクトリーを実装した概念実証コードを[返信の中][delving ark poc]で紹介しました。

- **サイレントペイメントディスクリプター用のBIPドラフト**: Craig Rawは、
  [サイレントペイメント][topic silent payments]用の新しいトップレベルディスクリプタースクリプト式
  `sp()`を定義する[BIP][BIPs #2047]ドラフトの提案をBitcoin-Devメーリングリストに[投稿しました][sp ml]。
  Rawによると、このディスクリプターは、アウトプットディスクリプターのフレームワーク内で
  サイレントペイメントのアウトプットを表現する標準化された方法を提供し、
  既存のディスクリプターベースのインフラを使用したウォレットの相互運用性とリカバリーを可能にします。

  `sp()`式は、同じ提案で定義されている2つの新しい鍵式のいずれかを引数とします:

  - `spscan1q..`: スキャン用の秘密鍵と使用公開鍵の[bech32m][topic bech32]エンコーディング。
    文字`q`はサイレントペイメントのバージョン`0`を表します。

  - `spspend1q..`: スキャン用の秘密鍵と使用秘密鍵のbech32mエンコーディング。
    文字`q`はサイレントペイメントのバージョン`0`を表します。

  オプションで、`sp()`式は`BIRTHDAY`を入力引数として取ることができます。
  これはスキャンを開始すべきブロック高を表す正数として定義します（
  [BIP352][]がマージされたブロック高である842579より大きくなければなりません）。
  またウォレットで使用される0以上の整数である`LABEL`を引数として取ることができます。

  `sp()`によって生成されるアウトプットスクリプトは、BIP352で指定されている[BIP341][] Taprootアウトプットです。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 30.2rc1][]は、名前のないレガシーウォレットを移行する際に
  `wallets`ディレクトリ全体が誤って削除される可能性があるバグ（[上記](#bitcoin-core)参照）を修正した
  マイナーバージョンのリリース候補です（[Bitcoin Core #34156](#bitcoin-core-34156)）参照。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #34156][]および[Bitcoin Core #34215][]は、
  バージョン30.0および30.1で`wallets`ディレクトリ全体が誤って削除される可能性があったバグを修正します。
  名前のないレガシーウォレットの移行が失敗した場合、クリーンアップロジックは、
  新しく作成された[ディスクリプター][topic descriptors]ウォレットのディレクトリのみを削除するよう意図されていましたが、
  名前のないウォレットはトップレベルのwalletsディレクトリに直接存在するため、ディレクトリ全体が削除されていました。
  2つめのPRは、ウォレット名が空文字でダンプファイルにチェックサムエラーが含まれている場合の
  `wallettool`の`createfromdump`コマンド（ニュースレター[#45][news45 wallettool]および
  [#130][news130 createfrom]参照）における同様の問題に対処しています。両方の修正により、
  新しく作成されたウォレットファイルのみが削除されることが保証されます。

- [Bitcoin Core #34085][]は、別個の`FixLinearization()`関数を廃止し、
  その機能を`Linearize()`に統合しました。`TxGraph`は、
  クラスターの修正を最初の再リニアライゼーションまで延期するようになりました。
  スパニング・フォレストリニアライゼーション（SFL）アルゴリズム（[ニュースレター #386][news386 sfl]参照）は、
  既存のリニアライゼーションを読み込む際に同様の作業を効果的に実行するため、
  `PostLinearize`の呼び出し回数が削減されます。これは[クラスターmempool][topic cluster mempool]プロジェクトの一部です。

- [Bitcoin Core #34197][]は、`getpeerinfo` RPCのレスポンスから`startingheight`フィールドを削除し、
  事実上非推奨としました。設定オプション`deprecatedrpc=startingheight`を使用すると、
  レスポンスにこのフィールドが保持されます。
  `startingheight`は、接続開始時にピアが自己報告したチェーンの先頭の高さを示します。
  この非推奨化は、ピアの`VERSION`メッセージで報告されるスタート高が
  信頼性に欠けるという考えに基づいています。次のメジャーバージョンで完全に削除される予定です。

- [Bitcoin Core #33135][]は、[BIP68][]（相対タイムロック）および[BIP112][]
  (OP_CSV)においてコンセンサス上の意味を持たない`older()`値（[タイムロック][topic timelocks]を指定）を含む
  [miniscript][topic miniscript][ディスクリプター][topic descriptors]を使って
  `importdescriptors`が呼び出された場合に警告を追加します。
  ライトニングなどの一部のプロトコルは、追加データをエンコードするために意図的に非標準の値を使用しますが、
  この慣行は、実際には最小限の遅延しかないものの、強力にタイムロックされているように見える可能性があるため、
  リスクがあります。

- [LDK #4213][]は、[ブラインドパス][topic rv routing]をデフォルトにしました。
  [オファー][topic offers]コンテキストではないブラインドパスを構築する場合、
  非コンパクトなブラインドパスを使用し、4ホップ（受信者を含む）にパディングすることでプライバシーを最大化することを目指しています。
  ブラインドパスがオファー用の場合、パディングを減らしコンパクトなブラインドパスの構築を試みることで、バイトサイズを最小化します。

- [Eclair #3217][]は、実験的な[HTLCエンドースメント][topic htlc endorsement]シグナルに代わって、
  [HTLC][topic htlc]用のアカウンタビリティシグナルを追加します。これは、
  [チャネルジャミング][topic channel jamming attacks]の軽減策に関する[BOLTs #1280][]の仕様の更新に合わせたものです。
  新しい提案では、このシグナルを希少なリソースに対するアカウンタビリティフラグとして扱い、
  保護されたHTLCキャパシティが使用されたこと、および下流のピアがタイムリーな解決に対して責任を負えることを示します。

- [LND #10367][]は、提案中の[BOLTs #1280][]に基づいて、
  [BLIPs #67][]の最新提案に合わせて[BLIP4][]の実験的な`endorsement`シグナルを
  `accountable`に名称変更しました。

- [Rust Bitcoin #5450][]は、コンセンサスルールで規定されているように、
  `null` prevoutを含む非コインベーストランザクションを拒否するバリデーションをトランザクションデコーダーに追加しました。

- [Rust Bitcoin #5434][]は、`scriptSig`の長さが2〜100 byteの範囲外のコインベーストランザクションを拒否する
  バリデーションをトランザクションデコーダーに追加しました。

{% include snippets/recap-ad.md when="2026-01-13 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2047,34156,34215,34085,34197,33135,4213,3217,1280,10367,67,5450,5434" %}
[rp delving ark cf]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179
[news333 rp routing]: /ja/newsletters/2024/12/13/#insights-into-channel-depletion
[news359 rp balance]: /ja/newsletters/2025/06/20/#channel-rebalancing-research
[optech superscalar]: /en/podcast/2024/10/31/
[news169 jl tt]: /ja/newsletters/2021/10/06/#proposal-for-transaction-heritage-identifiers
[news270 jl cov]: /ja/newsletters/2023/09/27/#covenant-ln
[delving ark hark]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179/2
[delving ark poc]: https://delvingbitcoin.org/t/ark-as-a-channel-factory-compressed-liquidity-management-for-improved-payment-feasibility/2179/4
[sr delving hark]: https://delvingbitcoin.org/t/evolving-the-ark-protocol-using-ctv-and-csfs/1602
[bitcoin core notice]: https://bitcoincore.org/ja/2026/01/05/wallet-migration-bug/
[Bitcoin Core 30.2rc1]: https://bitcoincore.org/bin/bitcoin-core-30.2/test.rc1/
[news45 wallettool]: /en/newsletters/2019/05/07/#new-wallet-tool
[news130 createfrom]: /en/newsletters/2021/01/06/#bitcoin-core-19137
[news386 sfl]: /ja/newsletters/2026/01/02/#bitcoin-core-32545
[sp ml]: https://groups.google.com/g/bitcoindev/c/bP6ktUyCOJI