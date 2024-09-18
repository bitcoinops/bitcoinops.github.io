---
title: 'Bitcoin Optech Newsletter #320'
permalink: /ja/newsletters/2024/09/13/
name: 2024-09-13-newsletter-ja
slug: 2024-09-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreの新しいテストツールの発表と、
DLCベースのローンコントラクトの簡単な説明を掲載しています。また、
Bitcoin Core PR Review Clubの概要や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **Bitcoin Coreのミューテーションテスト:** Bruno Garciaは、
  PRやコミットで変更されたコードを自動的に変更（変異）し、
  その変異によって既存のテストが失敗するかどうかを判定する[ツール][mutation-core]の発表を
  Delving Bitcoinに[投稿しました][garcia announce]。
  コードのランダムな変更によって失敗が発生しない場合、テストのカバレッジが不完全である可能性があります。
  Garciaの自動ミューテーションツールは、コードのコメントや変更が生じないと思われるコード行を無視します。

- **DLCベースのローンコントラクトの実行:** Shehzan Marediaは、
  ビットコイン担保ローンの価格発見に[DLC][topic dlc]オラクルを使用するローンコントラクト
  [Lava Loans][]の発表をDelving Bitcoinに[投稿しました][maredia post]。
  たとえば、アリスはボブに、ボブがデポジットアドレスに少なくとも$100,000の2倍相当のBTCを保持している場合に、
  $100,000を提供します。アリスとボブの両者が信頼するオラクルは、現在のBTC/USD価格にコミットする署名を定期的に公開します。
  ボブのBTC担保が合意価格を下回った場合、アリスはオラクルが署名した最高額の$100,000相当のBTCを差し押さえることができます。
  または、ボブはローンを返済したという証拠を（アリスが公開したハッシュのプリイメージの形式で）オンチェーンで提供し、
  担保を取り戻すことができます。両者が協力しない場合や、一方が応答しなくなった場合は、
  コントラクトの別の解決方法を使用できます。他のDLCと同様に、
  価格オラクルはコントラクトの詳細を知ることも、価格情報がコントラクトで使用されているこを知ることもできません。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Testing Bitcoin Core 28.0 Release Candidates][review club
v28-rc-testing]は、特定のPRをレビューするのではなく、グループテスト作業を行うReview Clubのミーティングでした。

[Bitcoin Coreの各メジャーリリース][major Bitcoin Core release]の前には、
コミュニティによる広範なテストが不可欠であると考えられています。このため、
ボランティアが[リリース候補][release candidate]のテストガイドを作成し、
リリースで何が新しくなり何が変更されたかを個別に確認したり、
これらの機能や変更をテストするためにさまざまなセットアップ手順を再発明することなく、
できるだけ多くの人が生産的にテストできるようにします。

テストが難しいのは、予期しない動作に遭遇した際、それが実際のバグによるものなのか、
それともテスターのミスによるものなのか、はっきりしないことが多いためです。
実際にはバグではないものを開発者に報告するのは、開発者の時間を無駄にします。
このような問題を軽減し、テストへの取り組みを促進するために、
Review Clubのミーティングが特定のリリース候補（ここでは28.0rc1）について開催されます。

[28.0リリース候補のテストガイド][28.0 testing]は、Review Clubミーティングの主催者でもあるrkruxによって書かれました。

参加者はまた、[28.0のリリースノート][28.0 release notes]を読むことで、
テストのアイディアを得ることが奨励されました。

このReview Clubでは、[testnet4][topic testnet]の導入（[Bitcoin Core #29775][]）、
[TRUC (v3) トランザクション][topic v3 transaction relay]（[Bitcoin Core #28948][]）、
[パッケージRBF][topic rbf]（[Bitcoin Core #28984][]）、
競合するmempoolトランザクション（[Bitcoin Core #27307][]）が取り上げられました。
ガイドに記載されているもののミーティングでは取り上げられなかった他のトピックには、
`mempoolfullrbf`のデフォルト化（[Bitcoin Core #30493][]）、
[`PayToAnchor`][topic ephemeral anchors]支払い（[Bitcoin Core #30352][]）、
新しい`dumptxoutset`フォーマット（[Bitcoin Core #29612][]）が含まれます。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND v0.18.3-beta][]は、この人気のLNノード実装の軽微なバグ修正リリースです。

- [BDK 1.0.0-beta.2][]は、ウォレットやその他のBitcoin対応アプリケーションを構築するためのこのライブラリのリリース候補です。
  元の`bdk` Rustクレートの名前が`bdk_wallet`変更され、 低レイヤーのモジュールは、
  `bdk_chain`、`bdk_electrum`、`bdk_esplora`、`bdk_bitcoind_rpc`などの独自のクレートに抽出されました。
  `bdk_wallet`クレートは、「安定した 1.0.0 API を提供する最初のバージョンです」。

- [Bitcoin Core 28.0rc1][]は、主要なフルノード実装の次期メジャーバージョンのリリース候補です。
  [テストガイド][bcc testing]が利用可能です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

_注: 以下に掲載するBitcoin Coreへのコミットは、master開発ブランチに適用されるため、
これらの変更がリリースされるのは、次期バージョン28のリリースから約6ヶ月後になると思われます。_

- [Bitcoin Core #30509][]は、他のプロセスがUnixソケット経由でノードに接続し制御できるように、
  `bitcoin-node`に`-ipcbind`オプションを追加します。今後のPR [Bitcoin Core #30510][]と組み合わせることで、
  外部の[Stratum v2][topic pooled mining]マイニングサービスが、
  ブロックテンプレートを作成、管理、送信できるようになります。
  これは、Bitcoin Coreの[マルチプロセスプロジェクト][multiprocess project]の一部です。
  ニュースレター[#99][news99 multi]と[#147][news147 multi]をご覧ください。

- [Bitcoin Core #29605][]は、ピア検出を変更し、シードノードからのフェッチよりも
  ローカルアドレスマネージャーからのピアを優先し、前者がピア選択に与える影響を減らし、
  不要な情報共有を減らします。デフォルトでは、
  シードノードはすべてのDNSシードが到達不能な場合（mainnetでは非常に稀）のバックアップになりますが、
  テストネットワークやカスタマイズされたノードのユーザーは、シードノードを手動で追加して、同じように構成されたノードを見つけることができます。
  このPR以前は、シードノードを追加すると、ノードが起動するたびにほぼ毎回新しいアドレスが照会され、
  ピアの選択に影響を与え、データを共有するピアだけを推奨する可能性がありました。
  このPRにより、アドレスマネージャーが空の場合、または一定期間アドレスの試行に失敗した後にのみ、
  シードノードがランダムな順序でアドレスのフェッチキューに追加されます。シードノードの詳細については、
  ニュースレター[#301][news301 seednode]をご覧ください。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30509,29605,30510,29775,28948,28984,27307,30493,30352,29612" %}
[LND v0.18.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[garcia announce]: https://delvingbitcoin.org/t/mutation-core-a-mutation-testing-tool-for-bitcoin-core/1119
[mutation-core]: https://github.com/brunoerg/mutation-core
[maredia post]: https://delvingbitcoin.org/t/lava-loans-trust-minimized-bitcoin-secured-loans/1112
[lava loans]: https://github.com/lava-xyz/loans-paper/blob/960b91af83513f6a17d87904457e7a9e786b21e0/loans_v2.pdf
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news99 multi]: /en/newsletters/2020/05/27/#bitcoin-core-18677
[news147 multi]: /ja/newsletters/2021/05/05/#bitcoin-core-19160
[multiprocess project]: https://github.com/ryanofsky/bitcoin/blob/pr/ipc/doc/design/multiprocess.md
[news301 seednode]: /ja/newsletters/2024/05/08/#bitcoin-core-28016
[review club v28-rc-testing]: https://bitcoincore.reviews/v28-rc-testing
[major bitcoin core release]: https://bitcoincore.org/ja/lifecycle/#major-releases
[28.0 release notes]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Notes-Draft
[release candidate]: https://bitcoincore.org/ja/lifecycle/#versioning
[28.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
