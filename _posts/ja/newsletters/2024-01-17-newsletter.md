---
title: 'Bitcoin Optech Newsletter #285'
permalink: /ja/newsletters/2024/01/17/
name: 2024-01-17-newsletter-ja
slug: 2024-01-17-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Core Lightningに影響を与えた過去の脆弱性の開示と、
2つの新しいソフトフォークの提案の発表、クラスターmempool提案の概要、
更新されたトランザクション圧縮の仕様と実装に関する情報、
非ゼロのエフェメラルアンカーにおけるMEV（Miner Extractable Value）に関する議論を掲載しています。
また、新しいリリースの発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **Core Lightningの過去の脆弱性の開示:** Matt Morehouseは、
  Delving Bitcoinで、彼が以前[責任を持って開示した][topic responsible disclosures]
  Core Lightningのバージョン23.02から23.05.2に影響する脆弱性を[発表しました][morehouse delving]。
  23.08以降の最新バージョンは影響を受けません。

  この新しい脆弱性は、Morehouseが以前責任を持って開示した（[ニュースレター #266][news266 lnbugs]参照）
  フェイクファンディングに関する研究のフォローアップで発見されました。
  フェイクファンディングの修正を実装したノードを再テストしたところ、
  [競合状態][race condition]が発生し、約30秒の作業でCLNがクラッシュしました。
  LNノードがオフラインになると、悪意ある取引相手や障害のある取引相手からユーザーを保護することができず、
  ユーザーの資金が危険にさらされます。分析によると、CLNは当初フェイクファンディングの脆弱性を修正していましたが、
  脆弱性が公表される前にそのテストを安全に含めることができず、その結果、
  悪用可能な競合状態を導入するプラグインがその後マージされたことが分かりました。
  Morehouseの開示後、競合状態によるノードのクラッシュを防ぐために、CLNに迅速にパッチがマージされました。

  詳細については、 Morehouseの素晴らしい[完全な開示][morehouse full]のブログ記事を読むことをお勧めします。

- **新しいソフトフォークの組み合わせLNHANCEの提案:** Brandon Blackは、
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)と
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS)の以前の提案と、
  スタックに[Taprootの内部鍵][taproot internal key]を配置する`OP_INTERNALKEY`の新しい提案を組み合わせた
  ソフトフォークの詳細をDelving Bitcoinに[投稿しました][black lnhance]。
  スクリプトの作者は、アウトプットに支払う前に内部鍵を知っている必要があるため、
  スクリプトに直接内部鍵を含めることができます。ただし、`OP_INTERNALKEY`は、
  CTVのオリジナルの作成者であるJeremy Rubinによる[以前の提案][rubin templating]の簡易版であり、
  鍵の値をスクリプトインタプリタで取得できるようにすることで、数vbyte節約し、
  スクリプトをより再利用しやすくする可能性があります。

  このスレッドの中で、Blackらは、このコンセンサス変更の組み合わせによって可能になるプロトコルのいくつかを説明しています。
  [LN-Symmetry][topic eltoo] (eltoo)、[Ark][topic ark]スタイルの[Joinpool][topic joinpools]、
  署名を削減した[DLC][topic dlc]、事前署名したトランザクションを必要としない[Vault][topic vaults]および、
  CTVスタイルの輻輳制御やCSFSスタイルの署名の移譲など、基本的な提案のメリットも説明されています。

  この記事の執筆時点では、技術的な議論は、組み合わせの提案によってどのようなプロトコルが可能になるかについての要求に限られています。

- **<!--proposal-for-64-bit-arithmetic-soft-fork-->64-bit演算のソフトフォークの提案:** Chris Stewartは、
  将来のソフトフォークでBitcoinで64-bitの算術演算を可能にするための[BIPのドラフト][bip 64]を
  Delving Bitcoinに[投稿しました][stewart 64]。Bitcoinは[現在][script wiki]、
  32-bitの演算しかできません（符号付き整数を使用しているため、31 bitを超える数値は使用できません）。
  64-bit値のサポートは、アウトプットで支払われるsatoshisの数を操作する必要があるような構成で特に役立ちます（
  アウトプットの値は64-bitの整数で指定されているため）。たとえば、
  [Joinpool][topic joinpools]の終了プロトコルは、量のイントロスペクションの恩恵を受けるでしょう（
  ニュースレター[#166][news166 tluv]および[#283][news283 exits]参照）。

  この記事の執筆時点では、整数値をどのようにエンコードするか、
  どの[Taproot][topic taproot]のアップグレード機能を使用するか、
  既存の演算opcodeをアップグレードするよりも、新しい演算opcodeのセットを作成する方が好ましいかどうかなど、
  提案の詳細に議論が集中していました。

- **クラスターmempool提案の概要:** Suhas Daftuarは、
  [クラスターmempool][topic cluster mempool]提案の概要をDelving Bitcoinに[投稿しました][daftuar cluster]。
  Optechは、クラスターmempoolの議論の現状の要約を[ニュースレター #280][news280 cluster]で試みましたが、
  提案の設計者の一人であるDaftuarによる概要を読むことを強くお勧めします。
  私たちがこれまで取り上げてこなかった詳細が１つ目に留まりました。

  - *CPFP carve outは削除する必要がある:* [2019][news56 carveout]年にBitcoin Coreに追加された
    [CPFP carve out][topic cpfp carve out]のmempoolポリシーは、
    取引相手の攻撃者がBitcoin Coreの関連トランザクション数とサイズの制限を利用して
    正直なピアの子トランザクションの検討を遅らせるCPFP版の[トランザクションPinning][topic transaction pinning]に対処します。
    carve outにより、1つのトランザクションのみ制限を超えることが許可されます。
    クラスターmempoolでは、関連トランザクションがクラスター内に配置され、
    制限はトランザクション毎ではなくクラスター毎に適用されます。このポリシーの下では、
    ネットワーク上でリレーされるトランザクション間に許容される関係を現在の制限を遥かに超えて制限しない限り、
    クラスターが最大1つのcarve outしか含まないことを保証する既知の方法はありません。
    複数のcarve outを持つクラスターは、その制限を大幅に超える可能性があり、
    その場合、プロトコルはより高い制限に対応できるように設計される必要があります。
    その場合、carve outのユーザーには対応できますが、
    通常のトランザクションのブロードキャスターが実行できることを制限することになります。
    これは望ましくない提案です。

    carve outとクラスターmempool間の非互換性に対する解決策として提案されているのは、
    [v3トランザクションリレー][topic v3 transaction relay]です。
    これにより、v1およびv2トランザクションの通常のユーザーは、
    これまでの一般的なすべての方法でそれらを使用し続けることができるだけでなく、
    LNのようなコントラクトプロトコルの利用者には、トランザクション間の関係（_トポロジー_）を強制する
    v3トランザクションを選択することも可能にします。制限されたトポロジーは、
    トランザクションPinning攻撃を緩和し、[エフェメラルアンカー][topic ephemeral anchors]などの
    carve outトランザクションの代替と組み合わせることができます。

  Bitcoin Coreのmempool管理アルゴリズムの大きな変更では、
  現在または近い将来に人々がBitcoinを使用する可能性のあるすべての方法を考慮することが重要です。
  そのため、マイニングやウォレットまたはコントラクトプロトコルのソフトウェアの開発に取り組んでいる開発者には、
  Daftuarの説明を読み、不明な点や、Bitcoinソフトウェアがクラスターmempoolと連携する方法について
  悪影響を与える可能性のある点について質問してください。

- **Bitcoinトランザクションの圧縮の仕様と実装の更新:**
  Tom Briarは、圧縮されたBitcoinトランザクションの更新された[ドラフト仕様][compress spec]と
  [実装案][bitcoin core #28134]をBitcoin-Devメーリングリストに[投稿しました][briar compress]。
  より小さなトランザクションは、衛星やステガノグラフィ（たとえば、ビットマップ画像にトランザクションをエンコードするなど）など、
  帯域幅に制約のある媒体を通じてリレーするのに実用的です。
  元の提案については、[ニュースレター #267][news267 compress]をご覧ください。
  Briarは、注目すべき変更について次のように述べています。
  「すべての圧縮インプットで使用される相対的なブロック高を優先しnLocktimeを削除し、
  二種類の可変長整数を使用」

- **非ゼロ値のエフェメラルアンカーのMEV（Miner Extractable Value）の議論:**
  Gregory Sandersは、0より多い値を持つ[エフェメラルアンカー][topic ephemeral anchors]アウトプットに関する懸念について
  Delving Bitcoinに[投稿しました][sanders mev]。エフェメラルアンカーは、
  誰もが使用可能な標準アウトプットスクリプトに対する支払いです。

  エフェメラルアンカーを使用する1つの方法は、アウトプットの金額を0にすることです。
  エフェメラルアンカーに関するポリシールールが、
  アンカーアウトプットを使用する子トランザクションを伴う必要があることを考慮すると、これは合理的です。
  しかし、現在のLNプロトコルでは、参加者が[経済合理性のない][topic uneconomical outputs]HTLCを作成したい場合、
  その支払金額は代わりにコミットメントトランザクションのオンチェーン手数料の過払いに使用されます。
  これは _トリムされたHTLC_ と呼ばれます。
  もしエフェメラルアンカーを使用するコミットメントトランザクションでHTLCのトリミングが行われると、
  マイナーにとってエフェメラルアンカーアウトプットを使用する子トランザクションなしでコミットメントトランザクションを承認する方が
  利益になる可能性があります。コミットメントトランザクションが承認されると、
  金額ゼロのエフェメラルアンカーを使用するインセンティブはありません。つまり、
  フルノードのUTXOセットのスペースを永遠に消費することになり、望ましくない結果になります。

  提案されている代替案は、トリムしたHTLCの金額をエフェメラルアンカーの金額に入れるというものです。
  そうすることで、コミットメントトランザクションとエフェメラルアンカーの使用の両方を承認するインセンティブを与えることができます。
  投稿の中でSandersはこの可能性を分析し、これがいくつかのセキュリティ問題を引き起こす可能性があることを発見しました。
  これらはマイナーがトランザクションを分析し、エフェメラルアンカーアウトプットを自ら使用した方が利益になるタイミングを判断し、
  必要なトランザクションを作成することで解決できます。
  これは、MEV（[Miner Extractable Value][news201 mev]）の一種です。
  いくつかの代替ソリューションも提案されました。

  - *<!--only-relaying-transactions-that-are-fully-miner-incentive-compatible-->マイナーのインセンティブと完全に互換性のあるトランザクションのみをリレーする:*
    誰かがマイナーの収益を最大化しない方法でエフェメラルアンカーを使用しようとした場合、
    そのトランザクションはBitcoin Coreでリレーされません。

  - *<!--burn-trimmed-value-->トリムされた値を焼却する:*
    トリムされたHTLCの金額を手数料に変える代わりに、その金額を`OP_RETURN`アウトプットに支払い、
    それらのsatoshiを永遠に使用不可能にして破壊します。これは、トリムされたHTLCがオンチェーンに展開された場合にのみ発生します。
    通常、トリムされたHTLCは、オフチェーンで解決され、その金額は一方の参加者から他方の参加者に正常に転送されます。

  - *MEVトランザクションが容易に伝播するようにする:* マイナーが価値を最大化する特別なコードを実行する代わりに、
    価値を最大化するトランザクションがネットワークを介して容易に伝播するようにします。
    そうすれば誰でもMEVコードを実行し、すべてのマイナーとリレーノードが同じトランザクションのセットを確実に入手できる方法で、
    結果をマイナーにリレーできます。

  記事の執筆時点では、明確な結論は出てないようです。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LDK 0.0.119][]は、LN対応アプリケーションを構築するためのこのライブラリの新しいリリースです。
  マルチホップの[ブラインドパス][topic rv routing]への支払いの受け取りなど、複数の新機能が追加され、
  複数のバグ修正やその他の改善も行われています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #29058][]は、[バージョン2 P2Pトランスポート(BIP324)][topic v2 p2p transport]を
  デフォルトで有効にするための準備ステップです。このパッチは、`-v2transport`が有効な場合に、
  `-connect`、`-addnode`、`-seednode`の設定引数にv2トランスポートのサポートを追加します。
  ピアがv2をサポートしていない場合はv1で再接続します。さらにこの更新により、
  `netinfo`ピア接続の`bitcoin-cli`ダッシュボードにトランスポートプロトコルのバージョンを表示する列が追加されます。

- [Bitcoin Core #29200][]により、[I2Pネットワークのサポート][topic anonymity networks]は、
  「ECIES-X25519とElGamal（それぞれタイプ4と0）を使用して暗号化された接続を使用できるようになります。
  これにより、どちらのタイプでもI2Pピアに接続できるようになります。より新しく高速なECIES-X25519が優先されます。」

- [Bitcoin Core #28890][]は、以前非推奨とした（[ニュースレター #269][news269 rpc]参照）
  `-rpcserialversion`設定パラメーターを削除しました。このオプションは、
  v0 segwitへの移行時に導入されたもので、古いプログラムが引き続きsegwitフィールドのない形式の
  ブロックやトランザクションにアクセスできるようにするためのものです。現時点では、
  すべてのプログラムがsegwitトランザクションを扱えるよう更新されており、このオプションはもはや必要ないはずです。

- [Eclair #2808][]は、`open`コマンドを更新し、`--fundingFeeBudgetSatoshis`パラメーターを追加しました。
  このパラメーターは、チャネルを開くためにノードが支払うオンチェーン手数料の上限額を定義するもので、
  デフォルトではチャネルに支払われる金額の0.1%が設定されます。Eclairは、
  可能な限り手数料を低くしようとしますが、必要であれば予算額まで支払います。`rbfopen`コマンドも更新され、
  [RBFによる手数料の引き上げ][topic rbf]に使用する上限額を定義する同じパラメーターを受け付けるようになりました。

- [LND #8188][]は、デバッグ情報を迅速に取得し、公開鍵でそれを暗号化し、
  秘密鍵でそれを復号するいくつかの新しいRPCが追加されました。
  PRの説明にあるように、「GitHubのIssueテンプレートで公開鍵を公開し、
  ユーザーに`lncli encryptdebugpackage`コマンドを実行して暗号化された出力ファイルをGithubのIssueにアップロードしてもらい、
  ユーザーの問題をデバッグするために必要な情報を提供してもらうためのアイディアです。」

- [LND #8096][]は、「手数料スパイクバッファ」を追加しました。
  現在のLNプロトコルでは、チャネルに資金を提供した当事者が、
  コミットメントトランザクションおよび事前署名済みのHTLC-Success、
  HTLC-Timeoutトランザクション（HTLC-Xトランザクション）に直接含まれるオンチェーン手数料を支払う責任があります。
  資金提供した当事者がチャネルにあまり資金を持っておらず、手数料率が上昇した場合、
  資金提供者は手数料を支払うのに十分な資金がないため、新しい支払いを受け入れることができない可能性があります。
  これは、新しい支払いによりその支払いが決済された場合に資金提供者の残高が増加するという事実にもかかわらずです。
  この種のチャネルのスタック問題を回避するため、[BOLT2][]の推奨事項（[BOLTs #740][]で数年前に追加）では、
  手数料率が上昇した場合でも追加の支払いを確実に受け取れるように、資金提供者が自発的に追加の資金を確保しておくことを提案しています。
  LNDは現在このソリューションを実装し、これはCore LightningやEclairでも実装されています（
  ニュースレター[#85][news85 stuck]および[#89][news89 stuck]参照）。

- [LND #8095][]と[#8142][lnd #8142]は、[ブラインドパス][topic rv routing]を処理するための追加のロジックを
  LNDのコードベースの一部に追加しました。これはLNDにブラインドパスの完全なサポートを追加するための進行中の作業の一部です。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28134,29058,29200,28890,2808,8188,8096,8095,8142,740" %}
[morehouse delving]: https://delvingbitcoin.org/t/dos-disclosure-channel-open-race-in-cln/385
[morehouse blog]: https://morehouse.github.io/lightning/cln-channel-open-race/
[script wiki]: https://en.bitcoin.it/wiki/Script#Arithmetic
[news166 tluv]: /ja/newsletters/2021/09/15/#amount-introspection
[news283 exits]: /ja/newsletters/2024/01/03/#fraud-proof-pool
[daftuar cluster]: https://delvingbitcoin.org/t/an-overview-of-the-cluster-mempool-proposal/393/
[news280 cluster]: /ja/newsletters/2023/12/06/#mempool
[news267 compress]: /ja/newsletters/2023/09/06/#bitcoin
[briar compress]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022274.html
[compress spec]: https://github.com/bitcoin/bitcoin/blob/7e8511c1a8229736d58bd904595815636f410aa8/doc/compressed_transactions.md
[news201 mev]: /ja/newsletters/2022/05/25/#miner-extractable-value
[news266 lnbugs]: /ja/newsletters/2023/08/30/#ln
[race condition]: https://ja.wikipedia.org/wiki/競合状態
[morehouse full]: https://morehouse.github.io/lightning/cln-channel-open-race/
[black lnhance]: https://delvingbitcoin.org/t/lnhance-bips-and-implementation/376/
[stewart 64]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/
[daftuar cluster]: https://delvingbitcoin.org/t/an-overview-of-the-cluster-mempool-proposal/393/
[sanders mev]: https://delvingbitcoin.org/t/ephemeral-anchors-and-mev/383/
[bip 64]: https://github.com/bitcoin/bips/pull/1538
[taproot internal key]: /en/newsletters/2019/05/14/#complex-spending-with-taproot
[news56 carveout]: /en/newsletters/2019/07/24/#bitcoin-core-15681
[news269 rpc]: /ja/newsletters/2023/09/20/#bitcoin-core-28448
[news85 stuck]: /ja/newsletters/2020/02/19/#c-lightning-3500
[news89 stuck]: /ja/newsletters/2020/03/18/#eclair-1319
[ldk 0.0.119]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.119
[rubin templating]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-05-24#24661606;
