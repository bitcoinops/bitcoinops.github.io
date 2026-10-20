---
title: 'Bitcoin Optech Newsletter #380'
permalink: /ja/newsletters/2025/11/14/
name: 2025-11-14-newsletter-ja
slug: 2025-11-14-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、新しいリリースとリリース候補の発表や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき更新など
恒例のセクションを掲載しています。

## ニュース

_今週は、どの[情報源][optech sources]からも重要なニュースは見つかりませんでした。_

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND 0.20.0-beta.rc4][]は、この人気のLNノード実装の新バージョンのリリース候補で、
  複数のバグ修正や、新しいNoopAdd [HTLC][topic htlc]タイプ、
  BOLT11インボイスにおける[P2TR][topic taproot]フォールバックアドレスのサポート、
  多くのRPCおよび`lncli`機能の追加と改善が含まれています。詳しくは[リリースノート][release notes]をご覧ください。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #30595][]では、`libbitcoinkernel`用（ニュースレター
  [#191][news191 lib]、[#198][news198 lib]、[#367][news367 lib]参照）のAPIとして機能する
  Cのヘッダーが導入されました。こにより外部プロジェクトは再利用可能なCのライブライを介して
  Bitcoin Coreのブロック検証およびchainstateロジックに接続できるようになります。
  現在、これはブロック操作に限定されており、現在は廃止された`libbitcoin-consensus`（
  [ニュースレター #288][news288 lib]参照）と機能的に同等です。`libbitcoinkernel`のユースケースには、
  代替ノード実装や、Electrumサーバーのインデックスビルダー、[サイレントペイメント][topic silent payments]のスキャナー、
  ブロック分析ツール、スクリプト検証のアクセラレーターなどが挙げられます。

- [Bitcoin Core #33443][]は、reindexを中断して再起動した後にブロックをリプレイする際の過剰なログ出力を削減します。
  これにより、処理中のブロック全体について1つのメッセージが生成され、
  ブロック毎に1つのログではなく、10,000ブロック毎に追加の進行状況ログが生成されるようになりました。

- [Core Lightning #8656][]は、アドレスタイプを指定せずに`newaddr`エンドポイントを使用した際、
  P2WPSHに代わって[P2TR][topic taproot]をデフォルトアドレスとして作成します。

- [Core Lightning #8671][]は、`htlc_accepted`フックに`invoice_msat`フィールドを追加し、
  プラグインが支払いのチェック時に有効な請求額を上書きできるようにします。具体的には、
  [HTLC][topic htlc]の金額がインボイスの金額と異なる場合に、HTLCの金額を使用します。
  これは、LSPがHTLCの転送に手数料を課す場合に役立ちます。

- [LDK #4204][]では、署名の交換前であれば、ピアはチャネルを強制閉鎖するとことなく
  [スプライシング][topic splicing]を中止できるようになりました。これまでは、
  スプライシングのネゴシエーション中に`tx_abort`が発生すると、
  不必要に強制閉鎖がトリガーされていましたが、現在は署名が交換された後にのみ強制閉鎖が発生します。

- [BIPs #2022][]は、[BIP3][]（[ニュースレター #344][news344 bip3]参照）を更新し、
  BIP番号の割り当て方法を明確にしました。「番号は、BIPエディターによってプルリクエストで公開された場合にのみ、
  割り当てられたものとみなされます。」ソーシャルメディアでの発表や、内部のエディターメモへの暫定的なエントリーは、
  割り当てにはなりません。

{% include snippets/recap-ad.md when="2025-11-18 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30595,33443,8656,8671,4204,2022" %}
[LND 0.20.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc4
[release notes]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.20.0.md
[news191 lib]: /ja/newsletters/2022/03/16/#bitcoin-core-24304
[news198 lib]: /ja/newsletters/2022/05/04/#bitcoin-core-24322
[news367 lib]: /ja/newsletters/2025/08/15/#bitcoin-core-33077
[news288 lib]: /ja/newsletters/2024/02/07/#bitcoin-core-29189
[news344 bip3]: /ja/newsletters/2025/03/07/#bips-1712
[optech sources]: /ja/internal/sources