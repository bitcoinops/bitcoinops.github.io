---
title: 'Bitcoin Optech Newsletter #151'
permalink: /ja/newsletters/2021/06/02/
name: 2021-06-02-newsletter-ja
slug: 2021-06-02-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、マイナー収益をわずかながら高め、かつ手数料の引き上げを行うユーザーの集団レバレッジを高めるために
Bitcoin Coreのマイナー向けブロックテンプレートのトランザクション選択アルゴリズムの変更の提案を掲載しています。
また、ソフトウェアのリリースとリリース候補に加えて、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更などの恒例のセクションも含まれています。

## ニュース

- **Candidate Set Based (CSB) ブロックテンプレートの構築:** Mark Erhardtは、
  Clara Shikhelmanと共同で行ったマイナー向けのトランザクション選択アルゴリズムの代替アルゴリズムの[分析][es analysis]について、
  Bitcoin-Devメーリングリストに[投稿しました][erhardt post]。Bitcoinのコンセンサスルールでは、
  未確認の祖先がすべて同じブロックの前方に含まれていない限り、トランザクションをブロックに含めることはできません。
  Bitcoin Coreでは、未確認の祖先を持つトランザクションを、その祖先の手数料とサイズ両方を含んでいるように扱うことで、
  この制約に対処しています。例えば、トランザクションBが未確認のトランザクションAに依存している場合、
  Bitcoin Coreは両方のトランザクションで支払われている手数料を合算し、両トランザクションの合計サイズで割ります。
  これによりBitcoin Coreは、mempool内のすべてのトランザクションを、
  トランザクションに祖先があるかどうかに関係なく、その実効的な手数料率に基づいて公平に比較することができます。

    しかし、ErhardtとShikhelmanは、もう少しCPUを必要とするかもしれないが、より洗練されたアルゴリズムによって、
    Bitcoin Coreの既存の単純なアルゴリズムよりもマイニングの利益率が高い関連トランザクションのセットを見つけることができると述べています。
    著者らは、過去のmempoolのデータで彼らのアルゴリズムをテストしたところ、
    最近のほぼすべてのブロックで、Bitcoin Coreの既存アルゴリズムよりもわずかに多くの手数料を収集していることがわかりました。

    改良されたアルゴリズムが実装されマイナーに使用されると、
    大規模な[CoinJoin][topic coinjoin]や[バッチ支払い][topic payment batching]からアウトプットを受け取った各ユーザーが、
    そのCoinJoinやバッチ支払いの[CPFPによる手数料の引き上げ][topic cpfp]に必要な総手数料のごく一部をそれぞれ支払うことができるようになります。
    これは、各ユーザーのCPFPによる手数料の引き上げが個別に考慮され、祖先トランザクションがマイニングされるどうかによって
    関連する複数の手数料の引き上げが集約的な影響を与えない現在のケースよりも改善されるでしょう。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [HWI 2.0.2][]は、BitBox02を使用したメッセージ署名のサポートの追加や、
  [BIP32][]の強化導出パスを示すのに`'`の代わりに`h`を常に使用すること、
  いくつかのバグ修正が含まれているマイナーリリースです。

- [LND 0.13.0-beta.rc3][LND 0.13.0-beta]は、プルーニングされたBitcoinフルノードの使用をサポートし、
  Atomic MultiPath ([AMP][topic multipath payments])を使用した支払いの送受信を可能にし、
  [PSBT][topic psbt]機能の向上、その他の改善およびバグ修正を行ったリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #20833][]は、
  Bitcoin Coreに[mempool package acceptance][package mempool accept blog]を実装するための取り組みにおける最初のPRです。
  この変更により、`testmempoolaccept`RPCが、
  後続のトランザクションが前のトランザクションから派生する可能性があるような複数のトランザクションを受け入れることができます。
  今後のPRでは、L2トランザクションチェーンのテスト、
  RPCを介したトランザクションパッケージのmempoolへの直接送信、
  P2Pネットワークを経由したパッケージの通信を可能にする可能性があります。

- [Bitcoin Core #22017][]は、Windowsリリースで使用されるコード署名の証明書を更新しました。
  以前の証明書は明示的な理由が提供されることなく発行者によって取り消されていました。
  Bitcoin Coreの最近のリリースのいくつかは、
  Windowsバイナリがこの証明書を使用できるように、
  バージョン番号を少し変えて再リリースされるかもしれません。

- [Bitcoin Core #18418][]では、`avoid_reuse`ウォレットフラグが設定されている場合に、
  同じアドレスで受信したUTXOを同時に使用する最大数を増やしています。
  一緒に使用されるアウトプットが多いほど、
  デフォルトのフラグを持つウォレットと比較して手数料が高くなる可能性がありますが、
  同時に、第三者がユーザーの今後のトランザクションを特定できる可能性は低くなります。

- [C-Lightning #4501][]では、C-Lightningの現在のコマンドの約半分の出力に[JSONスキーマ][JSON schemas]を追加しました
  （残りの半分のスキーマは今後追加される予定です）。
  C-Lightningのテストスイート実行中に生成された出力は、一貫性を確保するためにスキーマに対して検証されます。
  また、スキーマは、各コマンドがどのような出力をするかについてC-Lightningのドキュメントを自動生成するのにも使用されます。

- [LND #5025][]では、[signet][topic signet]を使用するための基本的なサポートが追加されています。
  Optechが追跡している他のLN実装のうち、C-Lightningもsignetをサポートしています（[ニュースレター #117][news117 cl4068]参照）。

- [LND #5155][]では、どのウォレットUTXOをトランザクションで使用するかをランダムに選択する設定オプションが追加されています。
  これによりウォレット内のUTXOのフラグメンテーションが時間とともに減少します。
  対照的に、LNDのデフォルトのコイン選択アルゴリズムは、値の高いUTXOを値の小さいUTXOよりも先に使用します。
  これにより短期的に手数料を最小限に抑えることができますが、
  トランザクションのサイズに近いかそれ以上のすべてのインプットが既に使用されている場合は、
  将来的にはより高い手数料を支払う必要が生じる可能性があります。

- [BOLTs #672][]は、
  ノードが`option_shutdown_anysegwit`オプションをネゴシエートできるように[BOLT2][]を更新しました。
  このオプションが設定されていると、LNのクロージング・トランザクションが[Taproot][topic taproot]アドレスのような
  ネットワーク上でまだコンセンサスの意味を持たないスクリプトタイプを含む、
  任意のsegwit script versionに支払いができるようになります。

- [BOLTs #872][]は、コミットメントトランザクションのインプットとアウトプットのソート順をより具体的に指定するため、
  [BOLT3][]の[BIP69][]の使用法を更新しました。
  あるコメンテーターは、BIP69の使用法により、これまでに3つの別々の問題が発生し、
  誤ってチャネルを閉じたり、不必要なオンチェーン手数料により少額の資金の損失につながった可能性があると指摘しています。
  コメンテーターは、これが明示的なBIP69の使用から移行すべき理由の１つである
  （他の理由は[ニュースレター #19][news19 bip69]参照）と指摘しています。

{% include references.md %}
{% include linkers/issues.md issues="20833,22017,18418,4501,5025,5155,672,872" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc3
[HWI 2.0.2]: https://github.com/bitcoin-core/HWI/releases/tag/2.0.2
[erhardt post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/019020.html
[es analysis]: https://gist.github.com/Xekyo/5cb413fe9f26dbce57abfd344ebbfaf2#file-candidate-set-based-block-building-md
[news117 cl4068]: /en/newsletters/2020/09/30/#c-lightning-4068
[news19 bip69]: /en/newsletters/2018/10/30/#bip69-discussion
[json schemas]: http://json-schema.org/
[package mempool accept blog]: https://brink.dev/blog/2021/01/21/fellowship-project-package-accept/
