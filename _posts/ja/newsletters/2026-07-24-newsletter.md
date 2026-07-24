---
title: 'Bitcoin Optech Newsletter #415'
permalink: /ja/newsletters/2026/07/24/
name: 2026-07-24-newsletter-ja
slug: 2026-07-24-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、BIP340署名の完全な集約に関するBIPドラフトについて掲載しています。
また、サービスやクライアントソフトウェアの最近の更新や、新しいリリースおよびリリース候補の発表、
人気のあるBitcoin基盤ソフトウェアの注目すべき更新など恒例のセクションも含まれています。

## ニュース

- **BIP340署名の完全な集約に関するBIPドラフト**: Fabian Jahrは、
  [BIP340][]署名の完全な集約に関する新しいBIPドラフトについて、Bitcoin-Devメーリングリストに
  [投稿しました][aggr ml]。これはDahLIAS集約署名スキームの標準（[ニュースレター #351][news351 dahlias] 参照）で、
  複数の署名を1つの集約署名にまとめるプロセスを記述しています。集約後の署名のサイズは、
  署名者の数にかかわらず64 byteです。ただし、このプロトコルは対話型であり、
  すべての署名者の協力が必要で、通信の複雑さを軽減するために信頼不要なコーディネーターの存在を伴います。
  コーディネーターの役割は、プロセスに参加する署名者のうち誰でも担うことができます。

  このプロセスは2つのラウンドに分かれています:

  1. 各署名者は、シークレットnonce（`secnonce`）と公開nonce（`pubnonce`）を計算して署名セッションを開始します。
  `pubnonce`はコーディネーターに送信され、コーディネーターはそれらを集約し（`aggnonce`）、
  その結果を他の情報とともに署名者に送り返します。

  2. 各署名者は、秘密鍵、`secnonce`、署名対象のメッセージ、および提供された情報を使用して部分署名を計算します。
  その後、部分署名はコーディネーターに送信され、コーディネーターはそれらを1つの64 byteの署名に集約します。

  Jahrによると、この提案の応用先として考えられるものの1つが[クロスインプット署名集約（CISA）][topic cisa]です。
  これはBitcoinのコンセンサスの変更であり、複数のインプットを持つトランザクションのサイズ、
  ひいてはオンチェーン手数料を削減するものです。ただし、このコンセンサス変更は現在のBIPの範囲外であると著者は明記しています。

  このBIPドラフトは現在BIP459と呼ばれており、[BIPs #2210][]で議論が進められ、コミュニティからのフィードバックを募っている段階です。

## サービスとクライアントソフトウェアの更新

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Wasabi Wallet 2.8.0のリリース:**
  Wasabi Wallet [2.8.0][wasabi 2.8.0]は、[コンパクトブロックフィルター][topic compact block filters]を
  P2Pネットワークから直接ダウンロードするようになり、これまで必要だった中央集権的なバックエンドサーバーを排除しました。
  このリリースではほかにも、[coinjoin][topic coinjoin]実行中に受取人に直接支払う機能、
  [1 sat/vbyte未満の手数料率][topic default minimum transaction relay feerates]のサポート、
  [支払いバッチ処理][topic payment batching]などの機能が追加されています。

- **Coinswap v0.2.2のリリース:**
  Coinswap [v0.2.2][coinswap v0.2.2]は、[coinswap][topic coinswap]プロトコル実装（ニュースレター [#338][news338 coinswap] 参照）に、
  マルチトランザクションスワップ、否認可能性の証明、マーケットプレイスの改善を追加しました。
  このリリースには、SpiralのオープンソースかつAIを活用したセキュリティスキャナーである
  Loupeを用いて実施されたセキュリティ監査で指摘された問題の修正も含まれています。

- **Go言語向けsecp256k1ライブラリの発表:**
  Alloczは、C言語との相互運用が有効な場合は[libsecp256k1][libsecp256k1 repo]のバインディングを使用し、
  そうでない場合は純粋なGo実装にフォールバックすることで、
  Goのクロスコンパイル機能を維持する[Goライブラリ][secp256k1 go]を[発表しました][secp256k1 go delving]。
  著者の報告によると、ECDSAおよび[Schnorr署名][topic schnorr signatures]の検証時間は、
  純粋なGo実装と比較して70%短縮されるとのことです。

- **ASMapダッシュボードの発表:**
  Joris Strakeljahnは、[ASMapデータ][github asmap-data]のリリース履歴（ニュースレター [#394][news394 asmap] 参照）を追跡する
  [ASMapダッシュボード][asmap dashboard]を[発表しました][asmap delving]。
  このダッシュボードでは、リリースごとにどれだけのアドレス空間が事業者間で移動したか、
  また、データが古くなるにつれて各リリースが実際に観測されたBitcoinノードをどの程度カバーしているかなどを確認できます。

- **Wavelengthアルファ版のリリース:**
  Lightning Labsは、Wavelengthのアルファ版を[発表しました][wavelength blog]。
  これは、BOLT11 LNインボイスの支払いと受け取り、[Ark][topic ark]に似た決済レイヤーを使用したオフチェーン送金のバッチ処理、
  Lightning Labsのインフラを通じた流動性の確保を行うためのツールキットです。
  アルファ版は[signet][topic signet]とtestnetで利用可能です。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning v26.06.6][]は、このLNノード実装のメンテナンスリリースです。
  本リリースでは、バンドルされている`pyln-proto`ライブラリの`coincurve`依存関係を更新して
  Pythonビルド環境の問題を修正し、既存チャネルのファンディングアウトポイントを再利用するチャネルを拒否するチェックを追加しています。

- [Bitcoin Inquisition 29.4][]は、提案中のソフトフォークやその他の主要なプロトコル変更を実験するために設計された
  [signet][topic signet]用のフルノードのリリースです。Bitcoin Core 29.4をベースにしており、
  実験的に有効化されたソフトフォーク提案のセットに、[BIP446][]（`OP_TEMPLATEHASH`）のアクティベーションを追加しています。
  これは、支払いトランザクションのハッシュをスタックにプッシュする提案中の[Tapscript][topic tapscript] opcodeです
  （[ニュースレター #365][news365 templatehash] 参照）。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #35215][]は、インメモリUTXOキャッシュ（`CCoinsMap`）のルックアップを高速化します。
  `COutPoint`キーのハッシュに使用されていた関数`SipHash-2-4`を、
  より高速で専用に設計された[SipHash][]の変種である`SipHasher13UJ`に置き換えることで実現しています。
  各コインは、そのtxidとアウトプット番号を組み合わせたキーで検索され、
  すべてのルックアップでそのキーがハッシュ関数を通過します。`SipHash-2-4`は、
  コインの32 byteのtxidを4つの64 bitの断片に分けて処理するため、
  1つのアウトポイントのハッシュに14回の内部ラウンドを要します。一方`SipHasher13UJ`は、
  txid全体を1回の256 bitステップで取り込み、より少ないラウンドで処理するため、ラウンド数は5回に削減されます。
  著者の報告によると、独立したベンチマークではハッシュのスループットが約2倍になり、
  chainstateの再インデックス処理では約5%の時間短縮が見られたとのことです。

- [Bitcoin Core #35766][]は、DNSシードおよびコンパイル時に組み込まれた固定シードから取得したアドレスに最初に接続する際に、
  [BIP324][] [v2 P2Pトランスポート][topic v2 p2p transport]をデフォルトで有効にします。
  BIP324の実験的サポートはBitcoin Core 26.0で導入され、27.0でデフォルトで有効化されました。
  これらのシードメカニズムはサービスフラグなしでアドレスを提供するため、
  Bitcoin Coreは従来、そのピアをv1のみとして扱い、ノードの最初の自動接続では暗号化トランスポートが試行されませんでした。
  新しい`SeedsAssumedServiceFlags()`関数は、これらのアドレスに対して`NODE_P2P_V2`を想定するようになりました。
  この想定が特定のピアに対して誤っていた場合、ノードは単純にv1を使用して再接続します。
  `-seednode`オプションによる接続とアドレス取得は、すでにデフォルトでv2が試行されるようになっています。

- [BIPs #2075][]は、[BIP174][]における[PSBT][topic psbt]の結合方法の記述を明確化します。
  この仕様は、独立して更新されたPSBTの結合は無条件に順序に依存しない（順序を入れ替えても結果が変わらない）と主張していましたが、
  これは参加者がそれぞれ異なるフィールドを追加する場合にのみ当てはまることでした。
  2つのPSBTが同じキーに異なる値を持つ場合、結合処理を行う側（combiner）はどちらかの値を選択するか、
  結合を拒否する可能性があるため、仕様には、この場合の結果は可換ではないことが明記されるようになりました。

- [BIPs #2204][]は、ドラフト段階の[BIP440][]および[BIP441][]「Great Script
  Restoration」の仕様（[ニュースレター #400][news400 gsr] 参照）を更新しています。
  スタック要素のbyte長を次の8 byte境界に切り上げる`wordspan`記法を導入し、
  多数のオペレーションコスト計算式が見直されました。具体的には、
  データを64 bitワード単位で処理する操作のコストは`wordspan`に基づいて計算される一方、
  正確なbyte単位で動作する操作は引き続きbyte長に基づいて計算されるようになります。
  この更新では、`OP_RIGHT`の定義の修正や、他のいくつかのopcodeのコストと範囲チェックの仕様も明確化されています。

- [Core Lightning #8935][]は、置換トランザクションがすでに承認された後でも、
  ノードがトランザクションを繰り返し[RBF][topic rbf]してしまう可能性のあるバグを修正しています。
  CLNは保留中のトランザクションを、元のtxidをキーとする`outgoing_tx_map`に格納しますが、
  より高い手数料のバージョンが作られるたびに、キーを変更せずにトランザクションオブジェクトだけを置き換えます。
  ブロックごとに実行される`rebroadcast_txs()`ループは、マイニングされることのない古い元のtxidを使用して承認を確認していたため、
  最新のトランザクションが承認済みであっても、再ブロードキャストと置換のロジックを呼び出し続けていました。
  txidはハッシュテーブルのキーとして機能しており、その場で更新できないため、
  修正後のループでは反復処理のたびに現在のトランザクションのtxidを計算し、
  それを承認チェックに使用するようになりました。

- [Core Lightning #9324][]は、v26.04以降に存在していた
  `Renepay`のリグレッション（[ニュースレター #263][news263 renepay] 参照）を修正しています。
  このリグレッションにより、CLTVの有効期限が本来あるべき高さよりも約1ブロック分先にずれた[HTLC][topic htlc]が構築されていました。
  Renepayのルートデータは、すでに各ホップのCLTV値に現在のブロック高を組み込んでいましたが、
  `route_sendpay_request()`がルートを`sendpay`に渡す際にブロック高をもう一度加算していたため、
  有効期限が実質的に2倍になっていました。その結果、転送ノードが`expiry_too_far`でオニオンを拒否する可能性がありました。

- [libsecp256k1 #1765][]は、[BIP352][] [サイレントペイメント][topic silent payments]で定義された
  楕円曲線演算を実装するオプションの`silentpayments`モジュールを追加します。
  スキャン機能はフルノードに限定されています。送信者向けには、送信者のインプットの秘密鍵、
  トランザクションの最小のアウトポイント、受信者が公開しているスキャン用公開鍵と支払い用公開鍵を組み合わせて、
  トランザクションが支払うべきアウトプットの鍵を導出する関数が1つ用意されています。
  受信者向けには、フルノードによるスキャンで、トランザクションのアウトプットのうちどれが受信者のものであるかを検出し、
  それらを支払いに使用するために必要な調整値（tweak）を返します。
  この処理は受信者のスキャン用の秘密鍵と支払い用公開鍵のみから行われるため、
  支払い用の秘密鍵はオフラインのままにしておくことができます。ラベルを管理する関数も別途用意されています。
  ラベルは[BIP352][]のオプション機能で、受信者がアドレスの識別可能なバリエーションを導出して、
  着金を区別したり、自身のお釣りをマークしたりすることを可能にします。
  軽量クライアント向けのスキャンのサポートは後続のPRに持ち越されました。

- [Rust Bitcoin #6317][]は、[コンパクトブロックリレー][topic compact block relay]のデコード処理を更新し、
  [BIP152][]で要求されているとおり、ブールのアナウンスフィールドが厳密に
  `0`または`1`でない`sendcmpct`メッセージを拒否するようにします。これまでは、
  Rust Bitcoinはこのフィールドを非ゼロ判定でデコードしており、
  任意の非ゼロ値をtrue（高帯域モード）として受け入れていました。このPRは、Bitcoin Coreにおける同等の堅牢化
  （[ニュースレター #412][news412 sendcmpct] 参照）を反映したものです。

- [BTCPay Server #7457][]は、[BIP329][] JSON Lines形式で[ウォレットラベル][topic wallet labels]をインポートする機能を追加し、
  既存のエクスポート機能を補完します。これまでは、別のサーバーに移行する際にラベルは事実上失われており、
  SparrowやEnvoyのようなBIP329対応ウォレットが生成したラベルファイルはまったく読み込めませんでした。
  このインポーターは、その形式の`tx`、`addr`、`output`レコードを読み込み、
  BTCPayのトランザクション、アドレス、UTXOオブジェクトにマッピングし、適用できないレコードはスキップします。

- [BLIPs #71][]は、[BLIP32][]に`dnssec_error`レスポンスを追加します。
  BLIP32は、DNSSECのクエリと証明をライトニングのオニオンメッセージで伝送することで、
  [BIP353][]の人間が読み取り可能な支払い名（human-readable payment names）を解決するプロトコルです（
  [ニュースレター #306][news306 blip32] 参照）。これまでは、このプロトコルには`dnssec_query`と
  `dnssec_proof`しか定義されておらず、応答できないリゾルバーがそのことをリクエスト元に伝える標準化された方法がなかったため、
  リクエスト元は待ち続けることになっていました。新しく追加された最終ホップTLV（タイプ `65550`）には、
  クエリされた`domain_name`が含まれるほか、`definitely_unresolvable`というブール値が含まれています。
  リゾルバーは、NXDOMAINや署名されていない名前などの恒久的な失敗の場合はこのブール値をセットし、
  一時的な障害の可能性があるその他の失敗の場合はセットしません。

{% include snippets/recap-ad.md when="2026-07-28 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2210,35215,35766,8935,9324,1765,6317,7457,2075,2204,71" %}

[aggr ml]: https://groups.google.com/g/bitcoindev/c/TF5mPfy58RQ/m/vAk1Mfg2AwAJ
[news351 dahlias]: /ja/newsletters/2025/04/25/#secp256k1
[wavelength blog]: https://lightning.engineering/posts/2026-07-21-wavelength-launch/
[wasabi 2.8.0]: https://github.com/WalletWasabi/WalletWasabi/releases/tag/v2.8.0
[coinswap v0.2.2]: https://github.com/citadel-tech/coinswap/releases/tag/v0.2.2
[news338 coinswap]: /ja/newsletters/2025/01/24/#coinswap-v0-1-0
[secp256k1 go delving]: https://delvingbitcoin.org/t/a-faster-go-golang-secp256k1-library/2658
[secp256k1 go]: https://github.com/allocz/secp256k1
[asmap delving]: https://delvingbitcoin.org/t/asmap-dashboard-tracking-the-asmap-data-history-against-the-observed-network/2652
[asmap dashboard]: https://jorisstrakeljahn.github.io/asmap-dashboard/
[github asmap-data]: https://github.com/bitcoin/bitcoin/blob/master/doc/asmap-data.md
[news394 asmap]: /ja/newsletters/2026/02/27/#bitcoin-core-28792
[news263 renepay]: /ja/newsletters/2023/08/09/#core-lightning-6376
[news412 sendcmpct]: /ja/newsletters/2026/07/03/#bitcoin-core-35550
[news400 gsr]: /ja/newsletters/2026/04/10/#bips-2118
[news306 blip32]: /ja/newsletters/2024/06/07/#blips-32
[news365 templatehash]: /ja/newsletters/2025/08/01/#taproot-op-templatehash
[SipHash]: https://en.wikipedia.org/wiki/SipHash
[Core Lightning v26.06.6]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.6
[Bitcoin Inquisition 29.4]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.4-inq
