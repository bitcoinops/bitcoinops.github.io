---
title: 'Bitcoin Optech Newsletter #322'
permalink: /ja/newsletters/2024/09/27/
name: 2024-09-27-newsletter-ja
slug: 2024-09-27-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreの旧バージョンに影響する脆弱性の修正の発表と、
ハイブリッドチャネルジャミング緩和に関する最新情報、より効率的でプライベートなClient-side Validationに関する論文の要約、
BIPプロセスの更新の提案を掲載しています。また、Bitcoin Stack Exchangeで人気の質問とその回答や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **Bitcoin Core 24.0.1より前のバージョンに影響する脆弱性の開示:**
  Antoine Poinsotは、2023年12月以降のサポートが終了したバージョンのBitcoin Coreに影響する脆弱性の発表のリンクを
  Bitcoin-Devメーリングリストに[投稿しました][poinsot headers]。
  これは、以前の脆弱性の開示に続くものです（ニュースレター[#310][news310 bcc]および[#314][news314 bcc]参照）。

  新しい開示では、Bitcoin Coreのフルノードをクラッシュさせる以前から知られている方法について説明しています。
  メモリに保存される長いブロックヘッダーチェーンを送信するという方法です。
  各ブロックヘッダーは80 byteで、何も保護がなければ、プロトコルの最小難易度で作成できるため、
  最新のASICマイニングを持つ攻撃者であれば、秒間数百万のブロックを生成できます。
  ただ、Bitcoin Coreは、初期バージョンで追加されたチェックポイントの副作用により、長年にわたって保護されています。
  これにより、攻撃者はヘッダーチェーンの最初のブロックを最小難易度で作成できなくなり、
  有効なブロックを作成した場合に報酬を得られる重要なProof of Workを実行せざるを得なくなります。

  しかし、最後のチェックポイントが追加されたのは10年以上前で、
  Bitcoin Core開発者は新たなチェックポイントを追加することに消極的でした。
  チェックポイントの追加により、トランザクションのファイナリティは
  最終的に開発者がチェックポイントを作成することに依存しているという誤った印象を与えるからです。
  マイニング機器が改良され、ネットワークのハッシュレートが増加するにつれて、
  偽のヘッダーチェーンを作成するコストは低下しました。コストが下がるにつれて、
  研究者のDavid JaensonとBraydon Fullerは、それぞれ個別に
  Bitcoin Core開発者に攻撃を[責任を持って開示しました][topic responsible disclosures]。
  開発者は、この問題が既知であるこを回答し、2019年にFullerにこの問題に関する彼の[論文][fuller paper]を
  公開するよう促しました。

  2022年、攻撃のコストがさらに低下したため、開発者のグループがチェックポイントを使用しないソリューションに取り組み始めました。
  Bitcoin Core PR #25717（[ニュースレター #216][news216 checkpoints]）は、その作業の結果です。
  その後、Niklas Göggeが#25717のロジックにバグを発見し、
  それを修正するために[PR #26355][bitcoin core #26355]を作成しました。
  両方のPRがマージされ、修正を加えたBitcoin Core 24.0.1がリリースされました。

- **<!--hybrid-jamming-mitigation-testing-and-changes-->ハイブリッドジャミング緩和のテストと変更:**
  Carla Kirk-Cohenは、元々Clara ShikhelmanとSergei Tikhomirovによって提案された
  [チャネルジャミング攻撃][topic channel jamming attacks]に対する緩和策の実装を破ろうするさまざまな試みに関する詳細を
  Delving Bitcoinに[投稿しました][kc jam]。
  ハイブリッドジャミング緩和には、[HTLCエンドースメント][topic htlc endorsement]と
  支払いが成功しても失敗しても無条件に支払われる少額の _前払い手数料_ の組み合わせが含まれます。

  何名かの開発者が、[1時間のチャネルジャミング][kc attackathon]の挑戦に招待され、
  Kirk-CohenとShikhelmanが有望と思われる攻撃について詳しく説明しました。
  ほとんどの攻撃は失敗しました。攻撃者がこの攻撃に費やす費用が他の既知の攻撃よりも多かったか、
  ターゲットノードが攻撃中に獲得した収入が
  シミュレートされたネットワーク上の通常の転送トラフィックで得られる収入よりも多かったかのいずれかです。

  1つの攻撃は成功しました。それは、「ネットワーク内でより短く/より安価なパスを作成し、
  そのチャネルを介して転送される支払いを妨害し、経路内でそのノードより前にあるすべてのノードの評価を低下させることで、
  ターゲットノードのピアの評価を低下させることを目的とする」[シンク攻撃][sink attack]です。
  この攻撃に対処するために、Kirk-CohenとShikhelmanは、HTLCエンドースメントの考慮方法に
  [双方向レピュテーション][bidirectional reputation]を導入しました。
  ボブがアリスからキャロルに転送される支払いを受け取ると（例：`A -> B -> C`）、
  ボブはアリスがすぐに決済されるHTLCを転送する傾向があるかどうかと（これまでのHTLCエンドースメントと同様に）、
  キャロルがすぐに決済されるHTLCを受け入れる傾向があるかどうか（これが新しい機能）の両方を考慮します。
  ボブがアリスからエンドースされたHTLCを受け取ると：

  - ボブがアリスとキャロルの両者とも信頼できると考える場合、アリスからキャロルへのHTLCを転送しエンドースします。

  - ボブが信頼できるのはアリスだけと考える場合、アリスからエンドースされたHTLCを転送しません。
    ボブはすぐにそれを拒否し、失敗が元の支払人に伝わるようにします。元の支払人は別の経路を使用してすぐに再送信できます。

  - ボブが信頼できるのはキャロルだけと考える場合、ボブはキャパシティに余裕がある場合はアリスからのエンドースされたHTLCを受け入れますが、
    それをキャロルに転送する際にはエンドースしません。

  提案の変更を受けて、Kirk-CohenとShikhelmanは、期待通りに機能することを確認するために追加の実験を計画しています。
  彼らはまた、2018年5月のJim Posenの[メーリングリストへの投稿][posen bidir]のリンクも追加しています。
  この投稿では、ジャミング攻撃（当時は _ループ攻撃_ と呼ばれていました）を防ぐための双方向のレピュテーションシステムについて説明しており、
  この問題を解決するための以前の並行思考の例です。

- **シールドClient-side Validation（CSV）:** Jonas Nick、Liam Eagen、Robin Linusは、
  新しい[Client-side Validation][topic client-side validation]プロトコルに関する[論文][nel paper]を
  Bitcoin-Devメーリングリストに[投稿しました][nel post]。
  Client-side Validationにより、トークンの転送は、トークンやその転送に関する情報を公開することなく、
  BitcoinのProof of Workによって保護されます。Client-side Validationは、
  [RGB][topic client-side validation]や[Taproot Assets][topic client-side validation]などのプロトコルの
  重要なコンポーネントです。

  既存のプロトコルの1つの欠点は、トークンを受け取る際にクライアントが検証する必要があるデータ量が、
  最悪の場合、そのトークンと関連するトークンのすべての転送履歴と同程度になることです。
  言い換えると、ビットコインのように頻繁に交換されるトークンのセットでは、
  クライアントはBitcoinのブロックチェーン全体とほぼ同じ大きさの履歴を検証する必要があります。
  そのデータを転送するための帯域幅コストとそれを検証するためのCPUコストに加えて、
  完全な履歴を転送することは、トークンの以前の受信者のプライバシーを弱めることになります。
  それに比べ、シールドCSVは、ゼロ知識証明を使用することで、
  これまでの転送について開示することなく一定量のリソースでの検証を可能にします。

  既存プロトコルのもう1つの欠点は、トークンを転送するたびにBitcoinトランザクションにデータを含める必要があることです。
  シールドCSVでは、複数の転送を同じ64 byteの更新にまとめることができます。
  これにより、新しいBitcoinのブロックが発見されるたびに、
  64 byteのデータプッシュを追加した単一のBitcoinトランザクションのみを確認することで、
  トークンの何千もの転送を確認できるようになります。

  この論文では詳細に説明されています。特に興味深いのは、
  [BitVM][topic acc]を使用してコンセンサスの変更なしにビットコインをメインブロックチェーンから
  シールドCSVに（およびその逆に）トラストレスにブリッジするというアイディアと、
  アカウントの使用（セクション2）、ブロックチェーンの再編成がアカウントと転送に与える影響に関する議論（同じくセクション2）、
  未承認トランザクションへの依存に関する関連議論（セクション5.2）および、
  可能な拡張機能のリスト（Appendix A）です。

- **BIPプロセスの更新のドラフト:** Mark "Murch" Erhardtは、
  BIPリポジトリの更新プロセスを記述したBIPドラフトの[プルリクエスト][erhardt pr]が公開されたことの発表を
  Bitcoin-Devメーリングリストに[投稿しました][erhardt post]。
  興味ある方は、ドラフトを確認し、コメントを残してください。
  コミュニティがドラフトの最終バージョンが受け入れられると判断した場合、
  それがBIPエディターが使用するプロセスになります。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [新しいBitcoin TXに対して具体的にどのような検証がどのような順序で行われるのでしょうか？]({{bse}}124221)
  Murchは、`CheckTransaction`、`PreChecks`、`AcceptSingleTransaction`および関連する関数で行われるチェックを含め、
  新しいトランザクションがmempoolに送信された際にBitcoin Coreによって行われる有効性のチェックを列挙しています。

- [私のbitcoinディレクトリがプルーニングのデータ制限の設定よりも大きいのはなぜですか？]({{bse}}124197)
  Pieter Wuilleは、`prune`オプションによってBitcoin Coreのブロックチェーンデータのサイズが制限される一方で、
  chainstate、インデックス、mempoolのバックアップ、ウォレットファイルおよびその他のファイルは`prune`制限の対象ではなく、
  独立してサイズが大きくなる可能性があると述べています。

- [`getblocktemplate`を機能させるには何を設定する必要がありますか？]({{bse}}124142)
  ユーザー CoinZwischenzugも、ブロックのマークルルートとコインベーストランザクションを計算する方法について[関連する質問]({{bse}}124160)をしています。
  両方の質問に対する回答は同様に、Bitcoin Coreの`getblocktemplate`は、
  トランザクションの候補ブロックとブロックヘッダー情報を構築できるものの、
  テスト用のネットワーク以外でマイニングする場合、コインベーストランザクションはマイニングソフトウェアまたは、
  [マイニングプール][topic pooled mining]のソフトウェアで作成されることを示しています。

- [<!--can-a-silent-payment-address-body-be-brute-forced-->サイレントペイメントアドレス本体は総当たり攻撃ができますか？]({{bse}}124207)
  Josieは、[BIP352][]を参照し、[サイレントペイメント][topic silent payments]アドレスを導出する手順を概説し、
  総当り攻撃手法を使用してサイレントペイメントのプライベシーの利点を損なうことは不可能であると結論づけています。

- [トランザクションが`testmempoolaccept`でBIP125による置換に失敗するのに、`submitpackage`では受け入れられるのはなぜですか？]({{bse}}124269)
  Ava Chowは、`testmempoolaccept`はトランザクションを個別に評価するのみで、
  その結果、Bitcoin Core 28.0の[テストガイド][bcc testing rbf]の[RBF][topic rbf]の例は拒否されると指摘しています。
  しかし、[`submitpackage`][news272 submitpackage]は、
  親と子の両方の例のトランザクションを[パッケージ][topic package relay]として一緒に評価するため、
  親と子の両方が受け入れられます。

- [BANスコアアルゴリズムは、ピアのBANスコアをどのように計算していますか？]({{bse}}117227)
  Brunoergは、特定の行動に対するピアの不正行為のスコアを調整した[Bitcoin Core #29575][new309 ban score]を参照し、
  それをリストアップしました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BDK 1.0.0-beta.4][]は、ウォレットやその他のBitcoin対応アプリケーションを構築するためのこのライブラリのリリース候補です。
  元の`bdk` Rustクレートの名前が`bdk_wallet`変更され、 低レイヤーのモジュールは、
  `bdk_chain`、`bdk_electrum`、`bdk_esplora`、`bdk_bitcoind_rpc`などの独自のクレートに抽出されました。
  `bdk_wallet`クレートは、「安定した 1.0.0 API を提供する最初のバージョンです」。

- [Bitcoin Core 28.0rc2][]は、主要なフルノード実装の次期メジャーバージョンのリリース候補です。
  [テストガイド][bcc testing]が利用可能です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Eclair #2909][]は、`createinvoice` RPCコマンドに`privateChannelIds`パラメーターを追加し、
  BOLT11インボイスに[プライベートチャネル][topic unannounced channels]の経路探索ヒントを追加します。
  これにより、プライベートチャネルのみを持つノードが支払いを受け取れないバグが修正されます。
  チャネルのOutPointの漏洩を避けるため、`scid_alias`を使用する必要があります。

- [LND #9095][]および[LND #9072][]は、インボイスの[HTLC][topic htlc]修飾子、
  補助チャネルのファンディングとクロージングに変更を加え、
  カスタムチャネル構想の一環としてカスタムデータをRPC/CLIに統合し、
  LNDの[Taproot Assets][topic client-side validation]のサポートを強化します。
  このPRでは、カスタムアセット固有のデータをRPCコマンドに含めることができるようにし、
  コマンドラインインターフェースによる補助チャネルの管理をサポートします。

- [LND #8044][]は、ノードが[Taprootチャネル][topic simple taproot channels]を
  [アナウンス][topic channel announcements]および検証できるようにする新しい
  v1.75ゴシッププロトコル（[ニュースレター #261][news261 v1.75]参照）用に
  新しいメッセージタイプ`announcement_signatures_2`、`channel_announcement_2`、
  `channel_update_2`を追加します。さらに、Taprootチャネルのゴシップの効率とセキュリティを向上させるために、
  `channel_ready`や`gossip_timestamp_range`などの既存のメッセージにいくつかの変更が加えられています。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26355,2909,9095,9072,8044" %}
[BDK 1.0.0-beta.4]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.4
[bitcoin core 28.0rc2]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news216 checkpoints]: /ja/newsletters/2022/09/07/#bitcoin-core-25717
[poinsot headers]: https://mailing-list.bitcoindevs.xyz/bitcoindev/WhFGS_EOQtdGWTKD1oqSujp1GW-v_ZUJemlNePPGaGBgzpmu6ThpqLwJpUVei85OiMu_xxjEzt_SeOWY7547C72BVISLENOd_qrdCwPajgk=@protonmail.com/
[fuller dos]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017354.html
[fuller paper]: https://bcoin.io/papers/bitcoin-chain-expansion.pdf
[posen bidir]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-May/001232.html
[erhardt post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/82a37738-a17b-4a8c-9651-9e241118a363@murch.one/
[erhardt pr]: https://github.com/murchandamus/bips/pull/2
[news310 bcc]: /ja/newsletters/2024/07/05/#bitcoin-core-0-21-0
[news314 bcc]: /ja/newsletters/2024/08/02/#bitcoin-core-22-0
[kc jam]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147/
[kc attackathon]: https://github.com/carlaKC/attackathon
[sink attack]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
[bidirectional reputation]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-bidirectional-reputation-10
[nel post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b0afc5f2-4dcc-469d-b952-03eeac6e7d1b@gmail.com/
[nel paper]: https://github.com/ShieldedCSV/ShieldedCSV/releases/latest/download/shieldedcsv.pdf
[news261 v1.75]: /ja/newsletters/2023/07/26/#updated-channel-announcements
[bcc testing rbf]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide#3-package-rbf
[news272 submitpackage]: /ja/newsletters/2023/10/11/#bitcoin-core-27609
[new309 ban score]: /ja/newsletters/2024/06/28/#bitcoin-core-29575
