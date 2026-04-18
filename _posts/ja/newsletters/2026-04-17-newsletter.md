---
title: 'Bitcoin Optech Newsletter #401'
permalink: /ja/newsletters/2026/04/17/
name: 2026-04-17-newsletter-ja
slug: 2026-04-17-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ネスト型MuSig2ライトニングノードのアイディアと、
secp256k1のモジュロスカラー乗算の形式検証を行うプロジェクトを掲載しています。
また、サービスとクライアントソフトウェアの最近のアップデートや、
新しいリリースとリリース候補の発表、人気のビットコイン基盤ソフトウェアの注目すべき更新など、
恒例のセクションも含まれています。

## ニュース

- **ライトニングネットワークでネスト型MuSig2を使用することに関する議論**: ZmnSCPxjは、
  最近の[論文][nmusig2 paper]で議論されているネスト型MuSig2の提案を活用して
  k-of-nのマルチシグライトニングノードを作るアイディアについてDelving Bitcoinに[投稿しました][kofn post del]。
  具体的には、まずこのような機能を持つことの重要性を説明し、次にライトニングプロトコルの現在の技術的制約について説明した上で、
  最後にBOLT仕様を修正する提案を示しています。

  ZmnSCPxjによると、ライトニングにおいてk-of-nの署名スキームが必要とされる理由は、
  大口の保有者が手数料と引き換えに自身の流動性をネットワークに提供したいというニーズに由来します。
  こうした大口保有者は資金の安全性に関する強力な保証を必要とする可能性があり、
  単一の鍵ではそれを提供できないかもしれません。一方、k-of-nのスキームであれば、
  k個未満の鍵が侵害されても、必要なセキュリティを提供できます。

  現状では、BOLTの仕様はk-of-nマルチシグスキームを安全に実装する方法を規定していません。
  その主な障害となっているのが失効鍵です。BOLTによると、失効鍵はshachainと呼ばれる仕組みを使って生成されますが、
  その特性上、k-of-nのマルチシグスキームでの利用には適していません。

  ZmnSCPxjは、`globalfeatures`および`localfeatures`の両方で、
  `no_more_shachains`という新しい機能ビットのペアをシグナリングすることで、
  ノードがチャネル相手からの失効鍵に対するshachain検証を行うかどうかをオプションにできるよう、
  BOLT仕様を修正することを提案しています。奇数ビットは、レガシーノードとの互換性を保つために自分自身は
  shachainとして有効な失効鍵を提供しつつ、相手側のshachain検証は行わないことを示します。
  一方、偶数ビットは、shachainとして有効な失効鍵の検証も提供も行わないことを示します。
  前者は、ZmnSCPxjがゲートウェイノードと定義する、
  ネットワークの残りの部分と（偶数ビットを持つ）k-of-nノードとを接続するノードによって使用されます。

  最後にZmnSCPxjは、この提案には大きなトレードオフ、すなわち失効鍵のストレージ要件があることを強調しています。
  実際、ノードはコンパクトなshachain表現の代わりに、個々の失効鍵を保存する必要があり、
  必要となるディスク量は実質3倍になります。

- **secp256k1のモジュロスカラー乗算の形式検証**:
  Remix7531は、secp256k1のモジュロスカラー乗算の形式検証を作成したことを
  Bitcoin-Devメーリングリストに[投稿しました][topic secp formalization]。
  このプロジェクトは、bitcoin-core/secp256k1サブセットに対する形式検証が実用的であることを示すものです。

  [secp256k1-scalar-fv-testコードベース][secp verification codebase]において、
  Remix7531は同ライブラリの実際のCのコードを取り上げ、RocqおよびVST（Verified
  Software Toolchain）を用いて形式的な数学的仕様に対する正しさを証明しています。
  Rocqによる形式化では、メモリエラーの有無、仕様に対する正しさ、そして停止性を証明できます。

  彼は既存のスカラー乗算の証明をRefinedCに移植する予定です。
  スカラー乗算の証明を移植することで、同じ検証済みコード上で両フレームワークを直接比較できるようになります。
  また、検証面における次のターゲットは、署名のバッチ検証に使われるマルチスカラー乗算用のPippengerアルゴリズムです。

## サービスとクライアントソフトウェアの更新

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Coldcard 6.5.0でMuSig2とminiscriptを追加:**
  Coldcard [6.5.0][coldcard 6.5.0]では、[MuSig2][topic musig]署名のサポート、
  [BIP322][]のProof of Reserve機能、そして最大8リーフまでの[Tapscript][topic
  tapscript]サポートを含む[miniscript][topic miniscript]と[Taproot][topic taproot]機能が追加されました。

- **Frigate 1.4.0 リリース:**
  [サイレントペイメント][topic silent payments]のスキャン用の実験的なElectrumサーバーである
  Frigate [v1.4.0][frigate blog]（[ニュースレター #389][news389 frigate]参照）は、
  最新のGPUコンピューティングとUltrafastSecp256k1を組み合わせることで、
  数カ月分のブロックのスキャン時間を１時間から0.5秒に短縮しました。

- **Bitcoin Backboneの更新:**
  Bitcoin Backboneは、[BIP152][]の[コンパクトブロック][topic compact block relay]のサポート、
  トランザクションおよびアドレス管理の改善、マルチプロセスインターフェースの基盤構築など
  複数の[更新][backbone ml 2]を[リリースしました][backbone ml 1]（[ニュースレター #368][news368 backbone]参照）。
  発表では、スタンドアロンのヘッダー検証とトランザクション検証のためのBitcoin Kernel APIの拡張も提案されています。

- **Utreexod 0.5 リリース:**
  Utreexod [v0.5][utreexod blog]では、[SwiftSync][news349 swiftsync]を使用したIBDを導入しました。
  これは、暗号学的集約によりIBD中にアキュムレーターの包含証明をダウンロードして検証する必要性をなくし、
  IBD中にCompact Stateノードによってダウンロードされるデータを1.4TBから約200GBに削減します。
  証明のキャッシュによりさらに削減することも可能です。

- **Floresta 0.9.0 リリース:**
  Floresta [v0.9.0][floresta v0.9.0]は、UTXOプルーフの交換用に
  P2Pネットワークを[BIP183][news366 utreexo bips]に合わせ、
  libbitcoinconsensusをBitcoin Kernelに置き換えることで、スクリプト検証を約15倍高速化するなど、
  さまざまな変更を加えています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 31.0rc4][]は、主流のフルノード実装の次期メジャーバージョンのリリース候補です。
  [テストガイド][bcc31 testing]が利用可能です。

- [Core Lightning 26.04rc3][]は、この人気のLNノードの次期メジャーバージョンのリリース候補で、
  以前のリリース候補からスプライシング関連の更新やバグ修正が続いています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [Bitcoin Core #34401][]は、`libbitcoinkernel` C API（ニュースレター
  [#380][news380 kernel]および[#390][news390 header]参照）に追加された
  `btck_BlockHeader`サポートを拡張し、ブロックヘッダーを標準のバイトエンコーディングにシリアライズするメソッドを追加しました。
  これにより、C APIを使用する外部プログラムが、別途シリアライズコードを持つことなく、
  シリアライズされたヘッダーを保存、送信または比較できるようになります。

- [Bitcoin Core #35032][]は、`sendrawtransaction` RPCで`privatebroadcast`オプション（
  [ニュースレター #388][news388 private]参照）を使用した際に学習されたネットワークアドレスを、
  Bitcoin Coreのピアアドレスマネージャーである`addrman`に保存しないようにしました。
  `privatebroadcast`オプションは、ユーザーが短命の[Tor][topic anonymity networks]またはI2P接続、
  あるいはTorプロキシを介してIPv4/IPv6ピアにトランザクションをブロードキャストできるようにします。

- [Core Lightning #9021][]は、スプライシングがBOLTの仕様にマージされたことを受け（[ニュースレター #398][news398 splicing]参照）、
  [スプライシング][topic splicing]を実験的ステータスから外し、デフォルトで有効にします。

- [Core Lightning #9046][]は、[keysend支払い][topic spontaneous payments]における想定
  `final_cltv_expiry`（最終ホップの[CLTV expiry delta][topic cltv expiry delta]）を
  22ブロックから42ブロックに引き上げ、LDKの値と一致させて相互運用性を復元します。

- [LDK #4515][]は、[ゼロ手数料コミットメント][topic v3 commitments]（0FC）チャネル（[ニュースレター #371][news371 0fc]参照）を
  実験的な機能ビットからプロダクション用の機能ビットに切り替えます。
  0FCチャネルは、2つの[アンカーアウトプット][topic anchor outputs]を
  240satsの1つの共有[Pay-to-Anchor (P2A)][topic ephemeral anchors]アウトプットに置き換えます。

- [LDK #4558][]は、不完全な[マルチパス支払い][topic multipath payments]に対する既存の受信側のタイムアウトを
  [keysend支払い][topic spontaneous payments]にも適用します。これまでは、不完全なkeysend MPPは、
  通常のタイムアウト期間後にフォールバックされる代わりにCLTVの期限まで保留状態のまま残り、
  [HTLC][topic htlc]スロットを占有し続ける可能性がありました。

- [LND #9985][]は、独自のコミットメントタイプ（`SIMPLE_TAPROOT_FINAL`）と
  プロダクション用のフィーチャービット80/81を備えたプロダクション用の[Simple Taproot
  Channel][topic simple taproot channels]に対するエンドツーエンドのサポートを追加します。
  プロダクションでは、`OP_CHECKSIG`+`OP_DROP`よりも`OP_CHECKSIGVERIFY`を優先する最適化された
  [Tapscripts][topic tapscript]を使用し、また将来の[スプライシング][topic splicing]に向けた基盤として、
  ファンディングtxidをキーとしたマップベースのナンスのハンドリングを`revoke_and_ack`に追加しています。

- [BTCPay Server #7250][]は、[LNURL-pay][topic lnurl]経由で作成された
  [BOLT11][]インボイスが決済済みかどうかを外部サービスが検証できるようにする、
  `verify`という名前のオプションの非認証エンドポイントを導入することで、[LUD-21][]のサポートを追加します。

- [BIPs #2089][]は、[BIP376][]を公開しました。このBIPは、
  [サイレントペイメント][topic silent payments]アウトプットの署名と使用に必要な[BIP352][]のtweakデータを格納するための
  新しいインプット単位の[PSBTv2][topic psbt]フィールドと、[BIP352][]の33
  byteのspend keyと互換性のあるオプションのspend-key [BIP32][topic bip32]導出フィールドを定義します。
  これは、PSBTを用いてサイレントペイメントアウトプットを作成する方法を規定する
  [BIP375][]（[ニュースレター #337][news337 bip375]参照）を補完するものです。

{% include snippets/recap-ad.md when="2026-04-21 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34401,35032,9021,9046,4515,4558,9985,7250,2089" %}

[coldcard 6.5.0]: https://coldcard.com/docs/upgrade/#edge-version-650xqx-musig2-miniscript-and-taproot-support
[frigate blog]: https://damus.io/nevent1qqsrg3xsjwpt4d9g05rqy4vkzx5ysdffm40qtxntfr47y3annnfwpzgpp4mhxue69uhkummn9ekx7mqpz3mhxue69uhkummnw3ezummcw3ezuer9wcq3samnwvaz7tmjv4kxz7fwwdhx7un59eek7cmfv9kqz9rhwden5te0wfjkccte9ejxzmt4wvhxjmczyzl85553k5ew3wgc7twfs9yffz3n60sd5pmc346pdaemf363fuywvqcyqqqqqqgmgu9ev
[news389 frigate]: /ja/newsletters/2026/01/23/#electrum
[news368 backbone]: /ja/newsletters/2025/08/22/#bitcoin-core-kernel
[backbone ml 1]: https://groups.google.com/g/bitcoindev/c/D6nhUXx7Gnw/m/q1Bx4vAeAgAJ
[backbone ml 2]: https://groups.google.com/g/bitcoindev/c/ViIOYc76CjU/m/cFOAYKHJAgAJ
[news349 swiftsync]: /ja/newsletters/2025/04/11/#swiftsync
[utreexod blog]: https://delvingbitcoin.org/t/new-utreexo-releases/2371
[floresta v0.9.0]: https://www.getfloresta.org/blog/release-v0.9.0
[news366 utreexo bips]: /ja/newsletters/2025/08/08/#utreexo-bip
[kofn post del]: https://delvingbitcoin.org/t/towards-a-k-of-n-lightning-network-node/2395
[nmusig2 paper]: https://eprint.iacr.org/2026/223
[bitcoin core 31.0rc4]: https://bitcoincore.org/bin/bitcoin-core-31.0/test.rc4/
[bcc31 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[Core Lightning 26.04rc3]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc3
[news380 kernel]: /ja/newsletters/2025/11/14/#bitcoin-core-30595
[news390 header]: /ja/newsletters/2026/01/30/#bitcoin-core-33822
[news388 private]: /ja/newsletters/2026/01/16/#bitcoin-core-29415
[news398 splicing]: /ja/newsletters/2026/03/27/#bolts-1160
[news371 0fc]: /ja/newsletters/2025/09/12/#ldk-4053
[news337 bip375]: /ja/newsletters/2025/01/17/#bips-1687
[BIP376]: https://github.com/bitcoin/bips/blob/master/bip-0376.mediawiki
[LUD-21]: https://github.com/lnurl/luds/blob/luds/21.md
[topic secp formalization]: https://groups.google.com/g/bitcoindev/c/l7AdGAKd1Oo
[secp verification codebase]: https://github.com/remix7531/secp256k1-scalar-fv-test
