---
title: 'Bitcoin Optech Newsletter #161'
permalink: /ja/newsletters/2021/08/11/
name: 2021-08-11-newsletter-ja
slug: 2021-08-11-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、JoinMarketのFidelity bondに関する以前の記事の続きと、
Bitcoin Core PR Review Clubミーティングの概要、
Taprootの準備の提案、リリースおよびリリース候補の発表、
人気のあるインフラストラクチャプロジェクトの注目すべき変更などの恒例のセクションを掲載しています。

## ニュース

- **<!--implementation-of-fidelity-bonds-->Fidelity bondの実装:** [JoinMarket 0.9.0][]の[coinjoin][topic coinjoin]の実装には
  [Fidelity bond][fidelity bonds doc]の[サポート][jm notes]が含まれています。
  以前[ニュースレター #57][news57 fidelity bonds]に掲載したように、
  この保証は、JoinMarketシステムのシビル耐性を向上させ、
  coinjoin開始者（テイカー）が独自の流動性（メーカー）を選択する能力を高めます。
  リリースから数日のうちに、
  [50 BTCを超える額][waxwing toot]（現在の価値にして200万USD以上）がタイムロックされたFidelity bondに預け入れられました。

  具体的な実装はJoinMarket独自のものですが、全体的な設計は、
  Bitcoin上に構築された他の分散プロトコルにも役立つ可能性があります。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Prefer to use txindex if available for GetTransaction][review club #22383]は、
Jameson LoppによるPRで、可能な限りトランザクションインデックス（txindex）を利用することで、
`GetTransaction`（ひいては、ユーザー向けの`getrawtransaction` RPC）のパフォーマンスを向上させるものです。
この変更により、txindexを利用可能なノードでトランザクションが含まれるブロックのハッシュを指定して
`getrawtransaction`を呼び出すと著しく遅くなるという予期せぬ性能低下が修正されました。
Review Clubでは、txindexを使用する場合としない場合のトランザクションの取得手順を比較することで、
このパフォーマンス問題の原因を評価しました。

{% include functions/details-list.md

  q0="<!--what-are-the-different-ways-gettransaction-can-retrieve-a-transaction-from-disk-->
  `GetTransaction`がディスクからトランザクションを取得する方法にはどのような方法がありますか？"
  a0="トランザクションを取得する方法には、（未承認の場合）mempoolから取得する方法、
  ディスクからブロック全体を取得してトランザクションを検索する方法、
  txindexを使用してトランザクションをディスクから単独でフェッチする方法があります。"
  a0link="https://bitcoincore.reviews/22383#l-33"

  q1="<!--why-do-you-think-that-performance-is-worse-when-the-block-hash-is-provided-when-txindex-is-enabled-->
  （txindexが有効で）ブロックハッシュが提供されている場合にパフォーマンスが低下するのはなぜだと思いますか？"
  a1="参加者は、ブロックのデシリアライゼーションがボトルネックになっているのではないかと推測しました。
  ブロック全体をフェッチする場合の固有の処理として、時間はかかりませんが、
  トランザクションのリスト全体をリニアに検索する処理があります。"
  a1link="https://bitcoincore.reviews/22383#l-42"

  q2="<!--if-we-are-looking-up-the-transaction-by-block-hash-what-are-the-steps-how-much-data-is-deserialized-->
  ブロックハッシュでトランザクションを検索する場合、どんな手順になりますか？どのくらいのデータがデシリアライズされますか？"
  a2="まず、ブロックインデックスを使用して、ブロックへアクセスする際に必要なファイルとバイトオフセットを見つけます。
  その後、ブロック全体をフェッチ、デシリアライズし、一致するものが見つかるまでトランザクションリストをスキャンします。
  これには約1〜2MBのデータのデシリアライズが必要です。"
  a2link="https://bitcoincore.reviews/22383#l-56"

  q3="<!--if-we-are-looking-up-the-transaction-using-the-txindex-what-are-the-steps-how-much-data-is-deserialized-->
  txindexを使ってトランザクションを検索する場合、どんな手順になりますか？どのくらいのデータがデシリアライズされますか？"
  a3="txindexは、トランザクションIDからファイルと（ブロックインデックスと同様）ブロックの位置、
  blk\*.datファイル内のトランザクションの開始オフセットまでをマッピングします。
  ブロックヘッダーとトランザクションをフェッチ、デシリアライズします。
  ヘッダーは80Bで、ブロックハッシュをユーザーに返すことができます（これはtxindexに保存されていない情報です）。
  トランザクションはどんなサイズでもいいですが、通常はブロックの数千分の1になります。"
  a3link="https://bitcoincore.reviews/22383#l-88"

  q4="<!--the-first-version-of-this-pr-included-a-behavior-change-when-an-incorrect-block-index-is-provided-to-gettransaction-find-and-return-the-tx-anyway-using-the-txindex-do-you-think-this-change-is-an-improvement-and-should-it-be-included-in-this-pr-->
  このPRの最初のバージョンでは、`GetTransaction`に誤った`block_index`が与えられた場合、
  txindexを使ってとにかくtxを見つけて返すという動作の変更が含まれていました。
  この変更は改善だと思いますか？またこのPRに含めるべきだと思いますか？"
  a4="参加者は、便利だが誤解を招くおそれがあり、誤ったブロックハッシュを入力したことをユーザーに通知する方が良いという点で合意しました。
  また、パフォーマンスの改善と動作の変更は、別のPRに分けるのが最適であることも指摘されました。"
  a4link="https://bitcoincore.reviews/22383#l-128"
%}

## Taprootの準備 #8: マルチシグのnonce

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/07-nonces.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [C-Lightning 0.10.1][]は、いくつかの新機能やバグ修正、
  （[デュアル・ファンディング][topic dual funding]や[Offer][topic offers]を含む）
  開発中のプロトコルのいくつかの更新を含むリリースです。

- [Bitcoin Core 22.0rc2][bitcoin core 22.0]は、
  このフルノード実装と関連するウォレットおよび他のソフトウェアの次のメジャーバージョンのリリース候補です。
  この新バージョンの主な変更点は、[I2P][topic anonymity networks]接続のサポートと、
  [Torのバージョン2][topic anonymity networks]接続のサポートの削除および、
  ハードウェアウォレットのサポートの強化などです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #21528][]は、フルノードのリスニングアドレスのP2P伝播の改善を目的としています。
  多様なアドレスセットを公開することは、
  [エクリプス攻撃][topic eclipse attacks]のようなネットワーク分断からノードを保護するのに重要です。
  Bitcoin Coreノードは、10個以下のアドレスを含むアドレスメッセージを受信すると、
  それを自身の1〜2つのピアに転送します。これは自身でアドレスを配信するために使用される主な手法であるため、
  これらのアドレスを中継しないピアに送信すると、ネットワークを介した伝播が効果的に停止またはブラックホールになります。
  悪意あるケースでは、伝播の失敗を防ぐことはできませんが、このパッチは、
  block-relay-only接続や軽量クライアントなどの正直なケースのアドレスの伝播を改善します。

  この更新により、`addr`や`addrv2`、`getaddr`などのアドレス関連のメッセージが、
  接続を介して送信されたかどうかに基づいて、インバウンド接続がアドレス転送候補かどうかを識別します。
  この動作の変更は、アドレスメッセージの受信に依存しているものの、
  アドレス関連のメッセージを決して開始しないソフトウェアがネットワーク上に存在する場合、
  問題となる可能性があります。そのため、作者は、この変更案がマージされる前に、
  [メーリングリスト][addrRelay improvements]に投稿したり、
  [他のオープンソースクライアント][addr client research]を調査して互換性を確認するなど、注意を払いました。

- [LND #5484][]では、すべてのデータを単一の外部Etcdデータベースに保存できるようになりました。
  これにより、クラスターのリーダーシップの変更が瞬時に行われるようになり、
  高可用性のあるデプロイが改善されます。対応するLNDクラスタリングのドキュメントは、
  以前の[ニュースレター #157][news157 lnd ha]でカバーされています。

- [Rust-Lightning #1004][]では、支払いの転送が成功した際の追跡を可能にする`PaymentForwarded`の新しいイベントを追加しています。
  転送が成功するとノードが手数料を得られる可能性があるため、
  これによりユーザーの会計記録のためにその収入を追跡することができます。

- [BTCPay Server #2730][]では、インボイス生成時に金額を省略できるようになりました。
  これにより、アカウントに補充する際など、オペレーターが金額の選択をユーザーに委譲する際の支払いフローが簡素化されます。

{% include references.md %}
{% include linkers/issues.md issues="21528,5484,1004,2730,22383" %}
[C-Lightning 0.10.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.1
[joinmarket 0.9.0]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.0
[jm notes]: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/release-notes/release-notes-0.9.0.md#fidelity-bond-for-improving-sybil-attack-resistance
[fidelity bonds doc]: https://gist.github.com/chris-belcher/18ea0e6acdb885a2bfbdee43dcd6b5af/
[waxwing toot]: https://x0f.org/@waxwing/106696673020308743
[news57 fidelity bonds]: /en/newsletters/2019/07/31/#fidelity-bonds-for-improved-sybil-resistance
[addrRelay improvements]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018784.html
[addr client research]: https://github.com/bitcoin/bitcoin/pull/21528#issuecomment-809906430
[news157 lnd ha]: /ja/newsletters/2021/07/14/#lnd-5447
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[series preparing for taproot]: /ja/preparing-for-taproot/
