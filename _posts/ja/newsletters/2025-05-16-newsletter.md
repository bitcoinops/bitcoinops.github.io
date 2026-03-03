---
title: 'Bitcoin Optech Newsletter #354'
permalink: /ja/newsletters/2025/05/16/
name: 2025-05-16-newsletter-ja
slug: 2025-05-16-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreの旧バージョンに影響する修正済みの脆弱性について掲載しています。
また、Bitcoinのコンセンサスルールの変更に関する最近の議論や、
新しいリリースおよびリリース候補の発表、人気のBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **Bitcoin Coreの旧バージョンに影響する脆弱性の開示:**
  Antoine Poinsotは、Bitcoin Coreのバージョン29.0未満に影響をおよぼす脆弱性の発表を
  Bitcoin-Devメーリングリストに[投稿しました][poinsot addrvuln]。
  この脆弱性は[ニュースレター #314][news314 excess addr]に掲載されたもともとEugene Siegelによる
  別の関連脆弱性とともに、[責任を持って開示されました][topic responsible disclosures]。
  攻撃者は、過剰な数のノードアドレスの通知を送信することで、32-bitの識別子をオーバーフローさせ、
  ノードのクラッシュを引き起こす可能性がありました。この問題は、
  ピア毎に10秒に1回の更新に制限することで部分的に軽減されました。この制限により、
  デフォルトの制限である約125個のピアにおいては、ノードが10年以上継続的に攻撃されない限り
  オーバーフローは発生しません。この脆弱性は、先月リリースされたBitcoin Core 29.0以降、
  64-bit識別子を使用することで完全に修正されました。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **<!--proposed-bip-for-64-bit-arithmetic-in-script-->スクリプトで64-bit演算をサポートするためのBIPの提案:**
  Chris Stewartは、Bitcoinの既存のopcodeを64-bitの数値で動作するようにアップグレードすることを提案する[BIPのドラフト][64bit bip]を
  Bitcoin-Devメーリングリストに[投稿しました][stewart bippost]。これは、
  彼の以前の研究（ニュースレター[#285][news285 64bit]、[#290][news290 64bit]および[#306][news306 64bit]参照）
  に基づくものです。以前の議論の一部とは異なり、新しい提案では、
  現在Bitcoinで使われているものと同じcompactSizeデータ形式の数値を使用します。
  Delving Bitcoinの2つの[スレッド][stewart overflow]でも関連する[議論が][stewart inout]行われています。

- **Quineを介して再帰的なコベナンツを可能にするopcodeの提案:** Bram Cohenは、
  自己複製スクリプト（[Quine][quines]）を介して再帰的な[コベナンツ][topic covenants]の作成を可能にする
  シンプルなopcodeセットの提案をDelving Bitcoinに[投稿しました][cohen quine]。Cohenは、
  これらのopcodeを使ってシンプルな[Vault][topic vaults]を作成する方法を説明し、
  現在開発中のより高度なシステムについても言及しています。

- **`OP_CTV`と`OP_CSFS`によるBitVMへのメリットの説明:**
  Robin Linusは、提案中の[OP_CTV][topic op_checktemplateverify] opcodeと
  [OP_CSFS][topic op_checksigfromstack] opcodeがソフトフォークで
  Bitcoinに追加された場合に可能になる[BitVM][topic acc]のいくつかの改善点について
  Delving Bitcoinに[投稿しました][linus bitvm-sf]。彼が説明したメリットには、
  デメリットなしにオペレーターの数を増やすこと、
  「トランザクションサイズを約10分の1に削減」（これによりワーストケースのコストが削減される）、
  特定のコントラクトで非対話型のペグインを可能にすることなどが含まれます。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND 0.19.0-beta.rc4][]は、この人気のLNノードのリリース候補です。
  おそらくテストが必要な主な改善の1つは、協調クローズにおける新しいRBFベースの手数料引き上げです。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32155][]は、内部マイナーを更新し、
  `nLockTime`フィールドに現在のブロック高から1を引いた値を設定し、
  （タイムロックを適用するために）`nSequence`フィールドに非ファイナル値を設定することで、
  コインベーストランザクションを[タイムロック][topic timelocks]します。
  この組み込みマイナーは、通常mainnetでは使用されませんが、この更新により、
  マイニングプールは[BIP54][]で提案されている[コンセンサスクリーンアップ][topic consensus cleanup]ソフトフォークに備えて、
  これらの変更を彼らのソフトウェアに早期に導入することが促進されます。
  コインベーストランザクションのタイムロックは、
  [重複トランザクション][topic duplicate transactions]の脆弱性を解決し、
  コストのかかる[BIP30][]チェックを不要にします。

- [Bitcoin Core #28710][]は、残っていたレガシーウォレットのコード、ドキュメントおよび関連テストを削除します。
  これには、`importmulti`、`sethdseed`、`addmultisigaddress`、`importaddress`、
  `importpubkey`、`dumpwallet`、`importwallet`、`newkeypool`といったレガシー専用のRPCが含まれます。
  レガシーウォレット削除の最終ステップとして、BerkeleyDBへの依存関係と関連関数も削除されます。
  ただし、ウォレットを[ディスクリプター][topic descriptors]ウォレットに移行するために、
  最小限のレガシーコードと独立したBDBパーサー（ニュースレター[#305][news305 bdb]参照）は残されます。

- [Core Lightning #8272][]は、オフラインのDNSシードによって引き起こされるコールブロック問題を解決するため、
  接続デーモン（`connectd`）からのDNSシードのルックアップによるピア検出のフォールバックを無効にします。

- [LND #8330][]は、数値的な不安定性に対処するために、経路探索の二峰性確率モデルに小さな定数（1/c）を追加します。
  丸め誤差により計算が失敗し、確率がゼロになるようなエッジケースでは、
  この正規化によりモデルが一様分布に戻ることでフォールバックを提供します。
  これにより、非常に大規模なチャネルや二峰性分布に適合しないチャネルを含むシナリオで発生する正規化バグが解決します。
  さらに、モデルは不要な確率計算をスキップし、チャネル流動性の古い観測値や矛盾する履歴情報を自動的に修正するようになりました。

- [Rust Bitcoin #4458][]は、`MtpAndHeight`構造体を新しく追加された`BlockMtp`と既存の
  `BlockHeight`の明示的なペアに置き換えました。これにより、
  相対[タイムロック][topic timelocks]におけるブロック高とMTP（Median Time Past）値のより適切なモデリングが可能になります。
  5億以上（おおよそ1985年以降）の値に制限される`locktime::absolute::MedianTimePast`とは異なり、
  `BlockMtp`は任意の32-bitタイムスタンプを表現できます。
  これは通常とは異なるタイムスタンプを持つチェーンなど、理論上のエッジケースに適しています。
  このアップデートでは、`BlockMtpInterval`も導入され、
  `BlockInterval`が`BlockHeightInterval`に名称変更されました。

- [BIPs #1848][]は、[BIP345][]のステータスを`Withdrawn`に更新しました。
  これは、提案者が提案していた `OP_VAULT` opcodeが、より汎用的な[Vault][topic vaults]の設計と
  新しいタイプの[コベナンツ][topic covenants]である
  [`OP_CHECKCONTRACTVERIFY`][topic matt]（OP_CCV）に取って代わられたと[考えている][obeirne vaultwithdraw]ためです。

- [BIPs #1841][]は、Bitcoinの不可分な基本単位を「satoshi」と正式に定義することを提案する
  [BIP172][]をマージしました。これは現在広く使われている用語を反映し、
  アプリケーションやドキュメント全体での用語の標準化に役立ちます。

- [BIPs #1821][]は、「bitcoin」の定義を1億単位ではなく、
  最小の不可分単位（一般的に1 satoshi）を表すものに再定義することを提案する[BIP177][]をマージしました。
  この提案は、用語を実際の基本単位に合わせることで、恣意的な小数点表記による混乱を軽減できると主張しています。

{% include snippets/recap-ad.md when="2025-05-20 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32155,28710,8272,8330,4458,1848,1841,1821" %}
[lnd 0.19.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc4
[news314 excess addr]: /ja/newsletters/2024/08/02/#addr
[stewart bippost]: https://groups.google.com/g/bitcoindev/c/j1zEky-3QEE
[64bit bip]: https://github.com/Christewart/bips/blob/2025-03-17-64bit-pt2/bip-XXXX.mediawiki
[news285 64bit]: /ja/newsletters/2024/01/17/#proposal-for-64-bit-arithmetic-soft-fork-64-bit
[news290 64bit]: /ja/newsletters/2024/02/21/#continued-discussion-about-64-bit-arithmetic-and-op-inout-amount-opcode-64-bit-op-inout-amount-opcode
[news306 64bit]: /ja/newsletters/2024/06/07/#updates-to-proposed-soft-fork-for-64-bit-arithmetic-64-bit
[stewart inout]: https://delvingbitcoin.org/t/op-inout-amount/549/4
[stewart overflow]: https://delvingbitcoin.org/t/overflow-handling-in-script/1549
[poinsot addrvuln]: https://mailing-list.bitcoindevs.xyz/bitcoindev/EYvwAFPNEfsQ8cVwiK-8v6ovJU43Vy-ylARiDQ_1XBXAgg_ZqWIpB6m51fAIRtI-rfTmMGvGLrOe5Utl5y9uaHySELpya2ojC7yGsXnP90s=@protonmail.com/
[cohen quine]: https://delvingbitcoin.org/t/a-simple-approach-to-allowing-recursive-covenants-by-enabling-quines/1655/
[linus bitvm-sf]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/
[quines]: https://ja.wikipedia.org/wiki/クワイン_(プログラミング)
[news305 bdb]: /ja/newsletters/2024/05/31/#bitcoin-core-26606
[obeirne vaultwithdraw]: https://delvingbitcoin.org/t/withdrawing-op-vault-bip-345/1670/
