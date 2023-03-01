---
title: 'Bitcoin Optech Newsletter #240'
permalink: /ja/newsletters/2023/03/01/
name: 2023-03-01-newsletter-ja
slug: 2023-03-01-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、BIP32マスターシードのバックアップが破損していないことを
デジタル機器を使用せずに検証する最速の方法についての議論を掲載しています。
また、新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **<!--faster-seed-backup-checksums-->より高速なシードバックアップのチェックサム:**
  Peter Toddは、[BIP32][topic bip32]シードのリカバリーコードの作成、検証、使用を可能にする方式である
  Codex32のBIPドラフト（[先週のニュースレター][news239 codex32]参照）に関する議論に[返信しました][todd codex32]。
  既存の方式に対するCodex32の特別な利点は、ペンと紙、ドキュメントを使ってわずかな時間でバックアップの完全性を検証できることです。

    Codex32は、バックアップのエラーを検出する能力について、設計どおり強力な保証を提供します。
    Peter Toddは、より簡単な方法として、リカバリーコードを生成し、
    そのパーツを加算してチェックサムを生成する方法を提案しました。
    チェックサムを既知の定数で割って余りが出ないようにすれば、
    チェックサムアルゴリズムのパラメーター内でバックアップの完全性を検証することができます。
    Peter Toddは、タイプミスに対しておよそ99.9%の保護を提供するアルゴリズムの使用を提案しました。
    これは十分に強力で、利用者が使いやすく、覚えやすく追加のCodex32資料を必要としないと考えています。

    Russell O'Connorは、利用者がより低い保護率の受け入れを望むのであれば、
    Codex32の完全なリカバリーコードは、完全な検証よりもはるかに速くチェックできると[答えました][o'connor codex32]。
    一度に2文字ずつチェックすれば、リカバリーコードの1文字の間違いも確実に検出でき、
    その他の置換ミスに対しても99.9%の保護が可能です。
    このプロセスは、Peter Toddが説明したチェックサムの生成と多少似ていますが、
    一般の利用者が覚えにくいルックアップテーブルを使用する必要があります。
    検証者がコードをチェックする度に、異なるルックアップテーブルの使用を厭わなければ、
    検証を重ねる毎にエラーを検出する確率が上がり、7回めの検証まででCodex32の完全な検証と同じ保証を得ることができます。
    Codex32を使用するために必要なテーブルやワークシートを提供するために、
    Codex32のドキュメントを更新する必要がありますが、
    強化されたクイックチェックの特性を得るためにCodex32に変更を加える必要はありません。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [HWI 2.2.1][]は、ソフトウェアウォレットとハードウェア署名デバイスのインターフェースとなる
  このアプリケーションのメンテナンスリリースです。

- [Core Lightning 23.02rc3][]は、この人気のLN実装の新しいメンテナンスバージョンのリリース候補です。

- [lnd v0.16.0-beta.rc1][]は、この人気のLN実装の新しいメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。

- [Bitcoin Core #25943][]は、`sendrawtransaction` RPCにパラメーターを追加し、
  アウトプット毎に焼却される資金の量を制限します。
  トランザクションが、ヒューリスティックに使用不可能と判断されるスクリプト（
  `OP_RETURN`や、無効なopcode、最大スクリプトサイズを超えるものなど）のアウトプットを含み、
  その金額が`maxburnamount`より大きい場合、そのトランザクションはmempoolに送信されません。
  デフォルトでは、この金額はゼロに設定されており、ユーザーを意図しない資金の焼却から保護します。

- [Bitcoin Core #26595][]は、暗号化されたレガシーウォレットと
  現在[ディスクリプター][topic descriptors]ウォレットにロードされていないウォレットの移行をサポートするために、
  [`migratewallet`][news217 migratewallet] RPCに、`wallet_name`パラメーターと`passphrase`パラメーターを追加しました。

- [Bitcoin Core #27068][]は、Bitcoin Coreがパスフレーズ入力を処理する方法を更新しました。
  これまでは、ASCII ヌル文字（0x00）を含むパスフレーズを受け入れ、
  最初のヌル文字までの文字列の一部がウォレットの暗号化処理で使用されていました。
  このため、ユーザーが期待するよりも安全性の低いパスフレーズを持つウォレットになってしまう可能性があります。
  このPRでは、ヌル文字を含むパスフレーズ全体を暗号化と復号に使用します。
  もしユーザーがヌル文字を含むパスフレーズを入力し、既存のウォレットの復号に失敗した場合、
  古い動作の下でパスフレーズを設定した可能性を示し、回避策が指示されます。

- [LDK #1988][]は、ピア接続と資金提供のないチャネルの制限を追加し、
  サービス拒否攻撃によるリソース枯渇を防止します。新しい制限は次のとおりです:

    - ローカルノードと資金提供されたチャネルを持たないデータ共有ピアの最大数は250

    - ローカルノードと現在チャネルを開こうとしているピアの最大数は50

    - 1つのピアからまだ資金提供を受けていないチャネルは最大4つ

- [LDK #1977][]は、[BOLT12ドラフト][bolts #798]で定義された[Offer][topic offers]を
  シリアライズおよびパースするための構造をpublicにしました。
  LDKはまだ[ブラインド・パス][topic rv routing]をサポートしていないため、
  現在Offerを直接送受信することはできませんが、このPRにより開発者が実験を開始することができます。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25943,26595,27068,1988,1977,798" %}
[core lightning 23.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc3
[lnd v0.16.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc1
[hwi 2.2.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.1
[news239 codex32]: /ja/newsletters/2023/02/22/#codex32-bip
[todd codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021498.html
[o'connor codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021504.html
[news217 migratewallet]: /ja/newsletters/2022/09/14/#bitcoin-core-19602
