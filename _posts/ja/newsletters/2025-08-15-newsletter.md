---
title: 'Bitcoin Optech Newsletter #367'
permalink: /ja/newsletters/2025/08/15/
name: 2025-08-15-newsletter-ja
slug: 2025-08-15-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、新しいリリース候補の発表や
人気のBitcoinインフラストラクチャソフトウェアの注目すべき更新など
恒例のセクションを掲載しています。

## ニュース

_今週は、どの[情報源][optech sources]からも重要なニュースは見つかりませんでした。_

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND v0.19.3-beta.rc1][]は、この人気のLNノード実装のメンテナンスバージョンのリリース候補で、
  「重要なバグ修正」が含まれています。最も注目すべきは、「オプションの移行で[…]
  ノードのディスクおよびメモリ要件が大幅に削減される」ことです。

- [Bitcoin Core 29.1rc1][]は、主要なフルノードソフトウェアのメンテナンスバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33050][]は、コンセンサスが無効なトランザクションに対する
  ピアの排除機能（[ニュースレター #309][news309 peer]参照）を削除しました。
  これは、DoSの保護が効果的でなかったためです。攻撃者は、ポリシー上無効なトランザクションをスパムすることで、
  ペナルティなしでこの保護を回避できました。このアップデートにより、
  コンセンサスの失敗と標準（ポリシー）の失敗を区別する必要がなくなったため、
  スクリプトの二重検証が不要になり、CPUコストを削減できます。

- [Bitcoin Core #32473][]は、標準トランザクションに対する二次的なハッシュ計算攻撃の影響を軽減するため、
  スクリプトインタプリタに、レガシー（例：ベアマルチシグ）、P2SH、P2WSH（そしてついでにP2WPKH）インプットに対する
  sighashの事前計算用のインプット毎のキャッシュを導入します。Coreは、
  標準的なマルチシグトランザクションや同様のパターンでのハッシュ計算の繰り返しを削減するために、
  sighashバイトを追加する直前までに計算されたほぼ完成済みのハッシュをキャッシュします。
  同じインプットの別の署名で、同じsighashモードを使用し、スクリプトの同じパーツにコミットするものは、
  計算の大部分を再利用できます。これはポリシー（mempool）とコンセンサス（ブロック）の両方の検証で有効になっています。
  [Taproot][topic taproot]のインプットは、デフォルトでこの動作を既にしているため、
  このアップデートを適用する必要はありません。

- [Bitcoin Core #33077][]は、プライベートな依存関係のすべてのオブジェクトファイルを
  単一のアーカイブにバンドルする、モノリシックな静的ライブラリ[`libbitcoinkernel.a`][libbitcoinkernel project]を作成し、
  下流のプロジェクトが、この1つのファイルのみにリンクできるようにします。
  関連する`libsecp256k1`の基盤については、[ニュースレター #360][news360 kernel]をご覧ください。

- [Core Lightning #8389][]は、最近の仕様の更新（[ニュースレター #364][news364 spec]参照）に合わせて、
  チャネルを開く際に`channel_type`フィールドを必須にします。RPCコマンド`fundchannel`および
  `fundchannel_start`は、`minimum_depth`が0の場合に、
  [ゼロ承認チャネル][topic zero-conf channels]オプションのチャネルタイプを報告するようになります。

{% include snippets/recap-ad.md when="2025-08-19 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33050,32473,33077,8389" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[lnd v0.19.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta.rc1
[news309 peer]: /ja/newsletters/2024/06/28/#bitcoin-core-29575
[news360 kernel]: /ja/newsletters/2025/06/27/#libsecp256k1-1678
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/27587
[news364 spec]: /ja/newsletters/2025/07/25/#bolts-1232
