---
title: 'Bitcoin Optech Newsletter #292'
permalink: /ja/newsletters/2024/03/06/
name: 2024-03-06-newsletter-ja
slug: 2024-03-06-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、BIP21 `bitcoin:` URIの仕様の更新に関する議論と、
最小限の状態で複数の並行MuSig2署名セッションを管理するための提案、
BIPリポジトリのエディターの追加に関するスレッドのリンク、
Bitcoin CoreのGitHubプロジェクトをセルフホスト型のGitLabプロジェクトに迅速に移植できる
一連のツールについて掲載しています。また、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャソフトウェアの最近の変更の要約など、恒例のセクションも含まれています。

## ニュース

- **BIP21 `bitcoin:` URIの更新:** Josie Bakerは、
  [BIP21][] URIがどのように使われるように定義されているか、
  現在どのように使用されているか、そして将来どのように使用できるかについての議論を
  Delving Bitcoinに[投稿しました][baker bip21]。仕様では、`bitcoin:1BoB...`のように、
  コロンの直後の本文が従来のP2PKH Bitcoinアドレスである必要があります。
  本文の後に、HTTPクエリエンコードを使用して非レガシーアドレス形式のアドレスなどのパラメーターを渡すことができます。
  たとえば、bech32mアドレスは、`bitcoin:1Bob...?bech32m=bc1pbob...`のようになります。
  しかし、これは`bitcoin:` URIの使われ方と大きく異なります。
  P2PKH以外のアドレスが本文として使用されることが多く、
  代替のペイメントプロトコルを通じて支払いを受け取りたいだけのソフトウェアでは本文が空白のままになることがあります。
  さらに、Bakerは、[サイレントペイメント][topic silent payments]や[オファー][topic offers]など、
  プライバシーを尊重した永続的な識別子を送信するために、`bitcoin:` URIが使用されることが増えていると指摘しています。

  このスレッドで議論されているように、改善策として、
  URIの作成者が、`bitcoin:?bc1q...&sp1q...`のように、
  ベアパラメーターを使用してサポートするすべての支払い方法を指定できるようにすることが考えられます。
  そして（通常、手数料を支払う責任がある）支払人は、リストの中から好みの支払い方法を選ぶことができます。
  本記事の執筆時点では、いくつかの細かい技術的な論点が議論されていましたが、
  このアプローチに対する大きな批判は投稿されていませんでした。

- **複数の並行MuSig2署名セッション用のPSBT:** Salvatore Ingalaは、
  複数の[MuSig2][topic musig]署名セッションを並行して実行するために必要な状態の量の最小化について
  Delving Bitcoinに[投稿しました][ingala musig2]。
  [BIP327][]に記載されている署名アルゴリズムを使用すると、
  共同署名者のグループは、作成するトランザクションに追加するインプット毎に比例して増加する量のデータを一時的に保存する必要があります。
  多くのハードウェア署名デバイスでは、利用可能なストレージの量が限られているため、
  （セキュリティを低下させることなく）必要な状態の量を最小限に抑えることは非常に有用です。

  Ingalaは、[PSBT][topic psbt]全体に対して1つの状態オブジェクトを生成し、
  その結果がランダムと見分けがつかないような方法で、インプット毎のステートを決定論的に導出することを提案しています。
  そうすることで、トランザクションに含まれるインプットの数に関係なく、
  署名者が保存する必要のあるデータは一定になります。

  開発者のChristopher Scottは、[返信][scott musig2]の中で、
  [BitEscrow][]が既に同様の仕組みを使用していると指摘しました。

- **BIPエディターの追加に関する議論:** Ava Chowは、
  現在のエディターを支援するために、BIPエディターを追加する提案をBitcoin-Devメーリングリストに[投稿しました][chow bips]。
  現在のエディターであるLuke Dashjrは、作業が滞っており、助けを求めていると[述べています][dashjr backlogged]。
  Chowは、2人の著名な専門家のコントリビューターにエディターになってもらうことを提案し、
  支持を得たようです。また、追加されるエディターにBIP番号を割り当てる能力を持たせるかどうかについても議論されました。
  この記事の執筆時点では、明確な解決には至っていません。

- **Bitcoin Core GitHubプロジェクトのGitLabバックアップ:** Fabian Jahrは、
  セルフホスト型のGitLabインスタンス上でBitcoin CoreプロジェクトのGithubアカウントのバックアップを維持することについて、
  Delving Bitcoinに[投稿しました][jahr gitlab]。
  プロジェクトが突然Githubから離れる必要が生じた場合でも、
  これにより、すべての既存の課題やプルリクエストに短時間でGitLabでアクセスできるようになり、
  短時間の中断だけで作業を継続できるようになります。Jahrは、GitLab上のプロジェクトのプレビューを提供し、
  必要に応じて迅速にGitLabに切り替えられるよう、今後もバックアップを維持する予定です。
  この記事の執筆時点では、彼の投稿にはコメントはありませんが、
  可能な限り簡単な移行を実現してくれた彼に感謝しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Eclair v0.10.0][]は、このLNノード実装の新しいメジャーリリースです。
  [デュアルファンディング機能][topic dual funding]の公式サポートや、
  BOLT12 [オファー][topic offers]の最新の実装、
  完全に動作する[スプライシング][topic splicing]のプロトタイプが追加され、
  さらに、さまざまなオンチェーン手数料の改善や、より多くの構成オプション、
  パフォーマンス改善およびさまざまな小さなバグ修正が含まれています。

- [Bitcoin Core 26.1rc1][]は、この主流のフルノード実装のメンテナンスリリースのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [Bitcoin Core #29412][]は、有効なブロックを取得して変更し、
  無効ではあるものの同じブロックヘッダーハッシュを持つ代替ブロックを生成する
  既知のあらゆる方法をチェックするコードを追加します。
  変異したブロックは過去に複数の脆弱性を引き起こしています。2012年、そして2017年に再び。
  Bitcoin Coreのキャッシュ済みの無効ブロックの拒否は、
  攻撃者が新しい有効なブロックを無効なブロックに変え、被害者のノードにそれを送信します。
  被害者のノードではそれを無効なものとして拒否し、
  その後（ノードが次に再起動されるまで）有効な方のブロックを受け入れないため、ベストブロックチェーンから分離され、
  攻撃者が[エクリプス攻撃][topic eclipse attacks]の一種を実行できるようになります。
  詳細は、[ニュースレター #37][news37 invalid]をご覧ください。
  最近では、Bitcoin Coreがあるピアからのブロックを要求した際、
  別のピアから変異ブロックが送信され、Bitcoin Coreが最初のピアからのブロックの待機を停止する可能性がありました。
  この問題の修正は、[ニュースレター #251][news251 block]で取り上げています。

  このPRで追加されたコードを使用すると、新しく受信したブロックに、
  そのブロックを無効にする既知の変異タイプのいずれかが含まれているかどうかを迅速にチェックできます。
  もし含まれていれば、変異ブロックを早い段階で拒否することができ、
  うまくいけばそのブロックに関するものがキャッシュされたり、
  後で受信する有効なバージョンのブロックの正しい処理を妨げるために使用されることを防ぐことができます。

- [Eclair #2829][]では、プラグインで[デュアルファンディングチャネルの開設][topic dual funding]に向けて
  資金を提供するためのポリシーを設定できるようになりました。デフォルトでは、
  Eclairはデュアルファンディングチャネルの開設に資金を提供しません。
  このPRにより、プラグインがそのポリシーをオーバーライドし、
  ノードオペレーターの資金のどれだけを新しいチャネルに提供するか決定できるようになります。

- [LND #8378][]は、LNDの[コイン選択][topic coin selection]機能にいくつかの改良を加えています。
  ユーザーがコイン選択戦略を選択できるようにしたり、
  トランザクションに含めるいくつかのインプットをユーザーが指定できるようにしますが、
  コイン選択戦略は追加で必要なインプットを見つけることができます。

- [BIPs #1421][]は、`OP_VAULT` opcodeと関連するコンセンサスの変更のための[BIP345][]を追加します。
  ソフトフォークで有効化されると、[Vault][topic vaults]のサポートが追加されます。
  現在の署名済みトランザクションを使用するVaultとは異なり、
  BIP345 Vaultは直前のトランザクション置換攻撃に対して脆弱ではありません。
  BIP345 Vaultでは[バッチ][topic payment batching]操作も可能であり、
  より一般的な[コベナンツ][topic covenants]の仕組みのみを使用する提案中のほとんどの設計よりも効率的になります。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29412,2829,8378,1421" %}
[jahr gitlab]: https://delvingbitcoin.org/t/gitlab-backups-for-bitcoin-core-repository/624
[ingala musig2]: https://delvingbitcoin.org/t/state-minimization-in-musig2-signing-sessions/626
[scott musig2]: https://delvingbitcoin.org/t/state-minimization-in-musig2-signing-sessions/626/2
[baker bip21]: https://delvingbitcoin.org/t/revisiting-bip21/630
[bitescrow]: https://github.com/BitEscrow/escrow-core
[chow bips]: https://gnusha.org/pi/bitcoindev/2092f7ff-4860-47f8-ba1a-c9d97927551e@achow101.com/
[dashjr backlogged]: https://twitter.com/LukeDashjr/status/1761127972302459000
[news37 invalid]: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure
[news251 block]: /ja/newsletters/2023/05/17/#bitcoin-core-27608
[eclair v0.10.0]: https://github.com/ACINQ/eclair/releases/tag/v0.10.0
[bitcoin core 26.1rc1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
