---
title: 'Bitcoin Optech Newsletter #258'
permalink: /ja/newsletters/2023/07/05/
name: 2023-07-05-newsletter-ja
slug: 2023-07-05-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、mempoolポリシーに関する限定週刊シリーズの新しい記事に加えて、
新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションを掲載しています。

## ニュース

_今週は、Bitcoin-DevメーリングリストやLightning-Devメーリングリストでは目立ったニュースはありませんでした。_

## 承認を待つ #8: インターフェースとしてのポリシー

_トランザクションリレーや、mempoolへの受け入れ、マイニングトランザクションの選択に関する限定週刊[シリーズ][policy series]です。
Bitcoin Coreがコンセンサスで認められているよりも制限的なポリシーを持っている理由や、
ウォレットがそのポリシーを最も効果的に使用する方法などが含まれます。_

{% include specials/policy/ja/08-interface.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 23.05.2][]は、このLNノードソフトウェアのメンテナンスリリースで、
  プロダクションで使用しているユーザーに影響する可能性のあるいくつかのバグ修正が含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #24914][]は、依存関係を検出するためにデータベース全体を２回反復する代わりに、
  ウォレットデータベースのレコードをタイプ毎に順番に読み込むようになりました。
  レコードが破損している一部のウォレットは、この変更後に読み込めなくなる可能性がありますが、
  前のバージョンのBitcoin Coreで読み込み、新しいウォレットに移植することができます。

- [Bitcoin Core #27896][]は、実験的なシステムコール（syscall）の
  サンドボックス機能（[ニュースレター #170][news170 syscall]参照）を削除しました。
  [関連する課題][Bitcoin Core #24771]とその後のコメントでは、
  （syscallのホワイトリストとOSサポートの両方の）保守性や、
  より適切にサポートされている代替手段、syscallのサンドボックス化がBitcoin Coreの責任であるかどうかに関する考慮事項など、
  この機能の欠点が指摘されています。

- [Core Lightning #6334][]は、
  [アンカーアウトプット][topic anchor outputs]に対するCLNの実験的なサポートを更新および拡張しています（
  CLNの初期実装については、[ニュースレター #111][news111 cln anchor]参照）。
  このPRの更新内容には、手数料ゼロの[HTLC][topic htlc]アンカーの実験的なサポートの有効化や、
  ノードがアンカーチャネルの運用に必要な最低限の緊急資金を持っていることを確認するための設定可能なチェックを追加することなどが含まれています。

- [BIPs #1452][]は、[ウォレットラベル][topic wallet labels]のエクスポートフォーマットに関する[BIP329][]仕様を更新し、
  関連するアウトプットがウォレットで使用可能であるかどうかを示す新しいオプションの`spendable`タグを追加しました。
  多くのウォレットは、_コイン制御_ 機能を実装しており、ユーザーがプライバシーを損なう可能性のあるアウトプットなど、
  特定のアウトプットを使用しないように[コイン選択][topic coin selection]アルゴリズムに指示することができます。

- [BIPs #1354][]は、[ニュースレター #211][news211 desc]に掲載した
  複数の導出パスの[ディスクリプター][topic descriptors]に関する[BIP389][]を追加しました。
  これは、1つのディスクリプターで、HD鍵生成のための2つの関連するBIP32パス（最初のパスは支払いの受け取り用、
  2つめのパスは内部ウォレットの支払い用（お釣りなど））を指定できるようにするものです。

{% include references.md %}
{% include linkers/issues.md v=2 issues="24914,27896,6334,1452,1354,24771" %}
[policy series]: /ja/blog/waiting-for-confirmation/
[news111 cln anchor]: /en/newsletters/2020/08/19/#c-lightning-3830
[news211 desc]: /ja/newsletters/2022/08/03/#multiple-derivation-path-descriptors
[core lightning 23.05.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05.2
[news170 syscall]: /ja/newsletters/2021/10/13/#bitcoin-core-20487
