---
title: 'Bitcoin Optech Newsletter #351'
permalink: /ja/newsletters/2025/04/25/
name: 2025-04-25-newsletter-ja
slug: 2025-04-25-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、secp256k1と互換性のある新しい集約署名プロトコルの発表と、
ウォレットディスクリプター用のバックアップスキームの標準化について掲載しています。
また、Bitcoin Stack Exchangeでの最近の質問とその回答や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **secp256k1互換の対話型集約署名:** Jonas Nick、Tim RuffingおよびYannick Seurinは、
  Bitcoinで既に使われている暗号プリミティブと互換性のある64 byteの集約署名の作成に関する
  [論文][dahlias paper]をBitcoin-Devメーリングリストで[発表しました][nrs dahlias]。
  集約署名は、インプットをまたいだ署名の集約[CISA（cross-input signature aggregation）][topic cisa]の暗号要件です。
  インプットが複数あるトランザクションのサイズを縮小し、
  [Coinjoin][topic coinjoin]や[Payjoin][topic payjoin]によるプライバシーが強化された支払いを含む、
  さまざまな支払いのコストを削減できる可能性があります。

  著者らが提案したDahLIASのような集約署名スキームに加えて、
  BitcoinにCISAのサポートを追加するためにはコンセンサスの変更が必要で、
  署名の集約と他の提案中のコンセンサスの変更との間の相互作用については、
  さらに研究が必要かもしれません。

- **<!--standardized-backup-for-wallet-descriptors-->ウォレットディスクリプター用のバックアップの標準化:**
  Salvatore Ingalaは、ウォレット[ディスクリプター][topic descriptors]のバックアップに関連するさまざまなトレードオフと、
  複雑なスクリプトを使っているものを含む多くの異なるタイプのウォレットに有用なスキームの提案を
  Delving Bitcoinに[投稿しました][ingala backdes]。彼のスキームでは、
  決定論的に生成された32 byteのシークレットを使ってディスクリプターを暗号化します。
  ディスクリプター内の各公開鍵（または拡張公開鍵）に対して、
  シークレットのコピーと公開鍵をXOR演算し、_n_ 個の公開鍵に対して、
  _n_ 個の32 byteの暗号シークレットが作成されます。
  ディスクリプターで使われている公開鍵の1つを知っている人は、
  その公開鍵と暗号シークレットをXOR演算することで、ディスクリプターを復号できる32 byteのシークレットを取得できます。
  このシンプルで効率的なスキームにより、誰でも複数のメディアやネットワーク上の場所にディスクリプターの暗号化コピーを多数保存し、
  [BIP32ウォレットシード][topic bip32]を使ってxpubを生成することで、
  ウォレットデータを紛失した場合でも、ディスクリプターを復号できます。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [半集約型Schnorr署名の実用性は？]({{bse}}125982)
  Fjahrは、[CISA（cross-input signature aggregation）][topic cisa]において半集約型署名を検証するために、
  独立した非集約署名がなぜ必要ないのか、そして非集約署名が実際に問題となり得る理由について議論しています。

- [これまでに作成されたOP_RETURNペイロードの最大サイズは？]({{bse}}126131)
  Vojtěch Strnadは、79,870 byteが最大の`OP_RETURN`であるRunesの[メタプロトコル][topic
  client-side validation]トランザクションの[リンク][op_return tx]を提供しています。

- [LN以外でのpay-to-anchorの説明は？]({{bse}}126098)
  Murchは、[P2A（pay-to-anchor）][topic ephemeral anchors]アンカーアウトプットスクリプトの
  論拠と構造について詳細に説明しています。

- [<!--up-to-date-statistics-about-chain-reorganizations-->チェーンの再編成に関する最新の統計は？]({{bse}}126019)
  0xb10cとMurchは、[stale-blocks][stale-blocks github]リポジトリ、
  [forkmonitor.info][]ウェブサイトおよび[fork.observer][]ウェブサイトを含む再編成のデータソースを示しています。

- [ライトニングチャネルは常にP2WSHですか？]({{bse}}125967)
  Polespinasaは、進行中のP2TR [Simple Taproot Channel][topic simple taproot channels]の開発について言及し、
  ライトニング実装間での現在のサポート状況をまとめています。

- [二重支払いに対する防御策としてのChild-pays-for-parent？]({{bse}}126056)
  Murchは、既に承認済みの二重支払いアウトプットに対する防御策として、
  高額な手数料の[CPFP][topic cpfp]子トランザクションを使ってブロックチェーンの再編成を促すことの複雑さをリストアップしています。

- [CHECKTEMPLATEVERIFYはどの値をハッシュしますか？]({{bse}}126133)
  Average-grayは、[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]がコミットするフィールドを概説しています。
  nVersion、nLockTime、インプットの数、シーケンスのハッシュ、アウトプットの数、
  全アウトプットのハッシュ、インプットのインデックス、場合によってはscriptSigのハッシュ。

- [<!--why-can-t-lightning-nodes-opt-to-reveal-channel-balances-for-better-routing-efficiency-->ライトニングノードが、ルーティング効率を向上させるためにチャネル残高を開示できないのはどうしてですか？]({{bse}}125985)
  Rene Pickhardtは、データの古さと信頼性、プライバシーへの影響に関する懸念について説明し、
  2020年の[同様の提案][BOLTs #780]を指摘しています。

- [<!--does-post-quantum-require-hard-fork-or-soft-fork-->耐量子暗号にはハードフォークとソフトフォークどちらが必要ですか？]({{bse}}126122)
  Vojtěch Strnadは、[耐量子暗号][topic quantum resistance]（PQC）署名方式を
  [ソフトフォークで有効化][topic soft fork activation]する方法、
  そしてハードフォークまたはソフトフォークで量子コンピューターに対して脆弱なコインをロックする方法について概説しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND 0.19.0-beta.rc3][]は、この人気のLNノードのリリース候補です。
  おそらくテストが必要な主な改善の1つは、協調クローズにおける新しいRBFベースの手数料引き上げです。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31247][]は、[BIP373][]で定義されている
  [MuSig2][topic musig]の[PSBT][topic psbt]フィールドのシリアライズとパース処理をサポートし、
  ウォレットが[MuSig2][topic musig]インプットに署名して使用できるようにします。
  入力側には、参加者の公開鍵をリストするフィールドに加えて、各署名ごとに別々の公開ナンスフィールドと
  部分署名フィールドが含まれます。出力側は、新しいUTXOの参加者の公開鍵をリストする単一のフィールドです。

- [LDK #3601][]は、標準の[BOLT4][]エラーコードを表す新しい`LocalHTLCFailureReason`列挙型と、
  以前はプライバシー上の理由から削除されていたユーザーへの追加情報を表示するいくつかのバリエーションを追加しています。

{% include snippets/recap-ad.md when="2025-04-29 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31247,3601,780" %}
[lnd 0.19.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc3
[nrs dahlias]: https://mailing-list.bitcoindevs.xyz/bitcoindev/be3813bf-467d-4880-9383-2a0b0223e7e5@gmail.com/
[dahlias paper]: https://eprint.iacr.org/2025/692.pdf
[ingala backdes]: https://delvingbitcoin.org/t/a-simple-backup-scheme-for-wallet-accounts/1607
[op_return tx]: https://mempool.space/tx/fd3c5762e882489a62da3ba75a04ed283543bfc15737e3d6576042810ab553bc
[stale-blocks github]: https://github.com/bitcoin-data/stale-blocks
[forkmonitor.info]: https://forkmonitor.info/nodes/btc
[fork.observer]: https://fork.observer/
