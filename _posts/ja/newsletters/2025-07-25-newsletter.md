---
title: 'Bitcoin Optech Newsletter #364'
permalink: /ja/newsletters/2025/07/25/
name: 2025-07-25-newsletter-ja
slug: 2025-07-25-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、旧バージョンのLNDに影響する脆弱性の概要と、
共同署名サービス利用時のプライバシーの向上策、量子耐性署名アルゴリズムへの移行が
HDウォレットやスクリプトレスマルチシグ、サイレントペイメントに与える影響について掲載しています。
また、Bitcoin Stack Exchangeで人気の質問とその回答や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき更新に関する恒例のセクションも含まれています。

## ニュース

- **LNDのゴシップフィルターのDoS脆弱性:** Matt Morehouseは、
  以前[責任を持って開示した][topic responsible disclosures]LNDの旧バージョンに影響する脆弱性について、
  Delving Bitcoinに[投稿しました][morehouse gosvuln]。攻撃者は、
  LNDノードがメモリ不足に陥って終了するまで、過去のゴシップメッセージを繰り返し要求することができました。
  この脆弱性は、2024年9月にリリースされたLND 0.18.3で修正されました。

- **<!--chain-code-withholding-for-multisig-scripts-->マルチシグスクリプトのためのチェーンコードの秘匿:**
  Jurvis Tanは、Jesse Posnerと共同で行ったマルチシグ共同カストディのプライバシーとセキュリティ向上に関する研究について
  Delving Bitcoinに[投稿しました][tan ccw]。一般的な共同カストディサービスでは、
  以下の３つの鍵を用いた2-of-3のマルチシグが使用されます:

  - ユーザーの _ホットキー_：ネットワーク接続されたデバイスに保存され、
    ユーザーのためにトランザクションに署名します（手動またはソフトウェアにより自動で）

  - プロバイダーのホットキー：プロバイダーが排他的に管理する別のネットワーク接続デバイスに保存されています。
    この鍵は１日に _x_ BTCまでの支払いのみを許可するなど、ユーザが事前に定義したポリシーに従ってトランザクションに署名します。

  - ユーザーの _コールドキー_：オフラインで保存され、ユーザーのホットキーが失われた場合、
    またはプロバイダーが承認されたトランザクションへの署名を停止した場合にのみ使用されます。

  上記の構成は、セキュリティを大幅に強化できますが、ほとんどの場合、
  ユーザーがプロバイダーとユーザーのホットウォレットとコールドウォレットの
  [BIP32拡張公開鍵][topic bip32]を共有するという設定方法が採用されています。
  これにより、プロバイダーはユーザーのウォレットに入金されたすべての資金を検出し、
  ユーザーがプロバイダーの支援なしに支払いをした場合でも、それらの資金のすべての支払いを追跡できます。
  このプライバシーの損失を軽減する方法は、これまでにいくつか提案されていますが、
  それらは通常の用途には適さない（例：個別のtapleafを使用する）か、
  複雑（例：[MPC][]を必要とする）です。TanとPosnerは、シンプルな代替案を説明しています:

  - プロバイダーはBIP32HD拡張鍵の半分（鍵部分）のみを生成し、公開鍵をユーザーに渡します。

  - ユーザーは残りの半分（チェーンコード）を生成し、これは秘密にしておきます。

  資金を受け取る際は、ユーザーは２つのパーツを組み合わせて拡張公開鍵（xpub）を作成し、
  通常どおりマルチシグアドレスを導出します。プロバイダーはチェーンコードを知らないため、
  xpubを導出したりアドレスを発見することはできません。

  資金を使用する際は、ユーザーはチェーンコードから必要な _調整値_ を導出します。
  プロバイダーは、この調整値を秘密鍵と組み合わせて有効な署名を作成します。
  ユーザーは単にこの調整値をプロバイダーと共有するだけです。プロバイダーは、
  調整値が資金を受け取った特定のscriptPubKeyからの支払いに有効であるということ以外、
  調整値から何も知ることはできません。

  一部のプロバイダーは、支払いトランザクションのお釣り用のアウトプットで、
  資金を同じスクリプトテンプレートに送り返すよう要求する場合があります。
  Tanの投稿では、これを簡単に実現する方法が説明されています。

- **研究によりBitcoinの一般的なプリミティブが量子耐性署名アルゴリズムと互換性があることが示される:**
  Jesse Posnerは、[量子耐性][topic quantum resistance]署名アルゴリズムが、
  現在Bitcoinで使用されている[BIP32 HDウォレット][topic bip32]、[サイレントペイメントアドレス][topic silent payments]、
  [スクリプトレスマルチシグアドレス][topic multisignature]、
  [スクリプトレス閾値署名][topic threshold signature]と同等のプリミティブを提供することを示す研究論文のいくつかのリンクを
  Delving Bitcoinに[投稿しました][posner qc]。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Bitcoin Coreは、10ブロックを超える再編成をどのように処理しますか？]({{bse}}127512)
  TheCharlatanは、最大10ブロック分のトランザクションのみをmempoolに再追加することでチェーンの再編成を処理する
  Bitcoin Coreのコードのリンクを提供しています。

- [<!--advantages-of-a-signing-device-over-an-encrypted-drive-->暗号化ドライブと比較した署名デバイスの利点は何ですか？]({{bse}}127596)
  RedGrittyBrickは、暗号化ドライブ上のデータは暗号化されていない状態でも抽出可能であるのに対し、
  ハードウェア署名デバイスはこのようなデータ抽出攻撃を防ぐように設計されていると指摘しています。

- [Taprootアウトプットはkeypathとscriptpathを介して使用できる？]({{bse}}127601)
  Antoine Poinsotは、マークルツリー、鍵の調整、リーフスクリプトを使用して
  どのようにTaprootのkeypath支払いとscriptpath支払いが実現されているかを詳しく説明しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Libsecp256k1 v0.7.0][]は、Bitcoinと互換性のある暗号プリミティブを含むこのライブラリのリリースです。
  これまでのリリースとのAPI/ABI互換性を損なういくつかのの小さな変更が含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32521][]は、2500を超える署名操作（sigops）を含むレガシートランザクションを非標準とします。
  これは、[コンセンサスクリーンアップソフトフォーク][topic consensus cleanup]のアップグレードによって
  コンセンサスレベルで制限が適用される可能性があるためです。この変更なしにソフトフォークが行われた場合、
  アップグレードを行っていないマイナーは軽微なDoS攻撃の標的になる可能性があります。
  レガシーインプットのsigops制限の詳細については、ニュースレター[#340][news340 sigops]をご覧ください。

- [Bitcoin Core #31829][]は、オーファントランザクションハンドラーである`TxOrphanage`（ニュースレター
  [#304][news304 orphan]参照）にリソース制限を追加し、DoSスパム攻撃に対しても
  1P1C（one-parent-one-child）[パッケージリレー][topic package relay]を維持します。
  適用される制限は４つあります。（CPUと遅延コストを最小化するための）3,000オーファンアナウンスのグローバル上限、
  ピアごとのオーファンアナウンスの比例上限、ピアごとの 24 × 400 kWUの予約ウェイト、
  可変のグローバルメモリ上限です。いずれかの制限を超えると、ノードは、
  許容量と比較して最も多くのCPUまはたメモリを使用した（ピアDoSスコアが最も高い）ピアから、
  最も古いオーファンアナウンスを削除します。またこのPRでは、
  ランダムにアナウンスを削除するポリシーが、オーファンセット全体を置き換えることで[1P1Cリレー][1p1c relay]を無効にすることを可能にしていた
  `‑maxorphantxs`オプション（デフォルト 100）を削除します。[ニュースレター #362][news362
  orphan]もご覧ください。

- [LDK #3801][]は、ノードが[HTLC][topic htlc]を保持している時間を記録し、
  その保持期間値を[失敗の帰属][topic attributable failures]のペイロードの上流に伝播するすることで、
  支払い成功パスに失敗の帰属を拡張します。これまでは、
  LDKは失敗した支払いの保持期間のみを追跡していました（ニュースレター[#349][news349 attributable]参照）。

- [LDK #3842][]は、[インタラクティブなトランザクション構築][topic dual funding]ステートマシン（ニュースレター
  [#295][news295 dual]参照）を拡張し、[スプライシング][topic splicing]トランザクションにおける
  共有インプットの署名の調整を処理します。`TxAddInput`メッセージの`prevtx`フィールドは、
  メモリ使用量を削減し、検証を簡単にするためにオプションになりました。

- [BIPs #1890][]は、一部のHTML 2.0 URIライブラリが`+`を空白スペースとして扱うため、
  [BIP77][]のセパレーターパラメーターを`+`から`-`に変更します。さらに、
  非同期[Payjoin][topic payjoin]プロトコルを簡単にするために、
  フラグメントパラメーターは辞書の逆順ではなく、辞書順に並べる必要があります。

- [BOLTs #1232][]は、すべての実装で強制されているため、
  チャネルを開く際に`channel_type`フィールド（ニュースレター[#165][news165 type]参照）を必須にします。
  このPRはまた、[BOLT9][]を更新し、`channel_type`フィールドに含めることができる
  機能用の新しいコンテキストタイプ`T`を追加しています。

{% include snippets/recap-ad.md when="2025-07-29 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32521,31829,3801,3842,1890,1232" %}
[morehouse gosvuln]: https://delvingbitcoin.org/t/disclosure-lnd-gossip-timestamp-filter-dos/1859
[tan ccw]: https://delvingbitcoin.org/t/chain-code-delegation-private-access-control-for-bitcoin-keys/1837
[mpc]: https://ja.wikipedia.org/wiki/秘匿マルチパーティ計算
[posner qc]: https://delvingbitcoin.org/t/post-quantum-hd-wallets-silent-payments-key-aggregation-and-threshold-signatures/1854
[Libsecp256k1 v0.7.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.7.0
[news340 sigops]: /ja/newsletters/2025/02/07/#sigops
[news304 orphan]: /ja/newsletters/2024/05/24/#bitcoin-core-30000
[1p1c relay]: /ja/bitcoin-core-28-wallet-integration-guide/#1p1cone-parent-one-childリレー
[news349 attributable]: /ja/newsletters/2025/04/11/#ldk-2256
[news295 dual]: /ja/newsletters/2024/03/27/#ldk-2419
[news165 type]: /ja/newsletters/2021/09/08/#bolts-880
[news362 orphan]: /ja/newsletters/2025/07/11/#bitcoin-core-pr-review-club