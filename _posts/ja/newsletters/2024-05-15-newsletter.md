---
title: 'Bitcoin Optech Newsletter #302'
permalink: /ja/newsletters/2024/05/15/
name: 2024-05-15-newsletter-ja
slug: 2024-05-15-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、utreexoをサポートするフルノードのベータリリースの発表と、
BIP119 `OP_CHECKTEMPLATEVERIFY`への2つの拡張案を掲載しています。
また、新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **utreexodのベータリリース:** Calvin Kimは、[utreexo][topic utreexo]をサポートするフルノード
  utreexodのベータリリースの発表をBitcoin-Devメーリングリストに[投稿しました][kim utreexo]。
  utreexoを使用すると、ノードはUTXOセット全体を保存するのではなく、
  UTXOセットの状態への小さなコミットメントを保存できるようになります。
  たとえば、最小のコミットメントは32バイトで、現在のフルセットは約12GBであるため、
  コミットメントは約10億分の1になります。帯域幅を削減するため、utreexoは追加のコミットメントを保存し、
  ディスク領域の使用量を増やす可能性がありますが、それでもchainstateは従来のフルノードの約100万分の1のオーダーで小さく保たれます。
  古いブロックのプルーニングも行うutreexoノードは、小さな一定量のディスク領域で実行することができます。
  一方プルーニングされた通常のフルノードでさえ、chainstateがデバイスのストレージ容量を超えて拡大する可能性があります。

  Kimが投稿したリリースノートでは、このノードが[BDK][bdk repo]ベースのウォレットに加えて、
  [Electrumパーソナルサーバー][Electrum personal server]のサポートを通じて他の多くのウォレットと互換性があることが示されています。
  このノードは、utreexoプルーフのリレーを可能にするP2Pネットワークの拡張機能を備えたトランザクションリレーをサポートします。
  通常のutreexoノードとブリッジノードの両方がサポートされています。
  通常のutreexoノードは、ディスク領域を節約するためにutreexoコミットメントを使用します。
  ブリッジノードは、完全なUTXOステートといくつかの追加データを保存し、
  まだutreexoをサポートしていないノードやウォレットで作成されたブロックやトランザクションにutreexoプルーフを添付できます。

  utreexoは、コンセンサスの変更を必要とせず、utreexoノードは非utreexoノードに干渉することはなく
  通常のutreexoノードは、他の通常のutreexoノードやブリッジutreexoノードとのみピアになります。

  Kimの発表の中にはいくつかの警告が含まれています。「コードとプロトコルはピアレビューされていません[...]
  互換性のない変更が入る可能性があります[...]utreexodは[btcd][]をベースにしており、そこにコンセンサスの非互換性が存在する可能性はあります。」

- **より小さなハッシュと任意のデータコミットメントのためのBIP119の拡張:**
  Jeremy Rubinは、提案中の[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (`OP_CTV`)を
  2つの追加機能で拡張する[BIPの提案][bip119e]をBitcoin-Devメーリングリストに[投稿しました][rubin bip119e]:

  - *HASH160ハッシュのサポート:* P2PKH、P2SH、P2WPKHアドレスに使用されるハッシュダイジェストです。
    基本の[BIP119][]の提案で使用される32バイトのハッシュダイジェストと比較すると、これは20バイトです。
    単純なマルチパーティプロトコルでは、20バイトのハッシュに対する[衝突攻撃][collision attack]は、
    約2<sup>80</sup>の総当り演算で実行でき、これは非常にやる気のある攻撃者の手の届く範囲です。
    このため、最新のBitcoinのopcodeは、通常32バイトのハッシュダイジェストを使用しています。
    しかし、20バイトのハッシュを使用するシングルパーティプロトコルや
    適切に設計されたマルチパーティプロトコルのセキュリティは、
    約2<sup>160</sup>未満の総当り演算で侵害される可能性が低くなるよう強化でき、
    それらのプロトコルではダイジェスト毎に12バイト節約できます。
    これが役に立つ可能性があるケースの1つは、
    [eltoo][topic eltoo]プロトコル（[ニュースレター #284][news284 eltoo]参照）です。

  - *<!--support-for-additional-commitments-->追加コミットメントのサポート:*
    `OP_CTV`は、提供されたハッシュダイジェストと同じ値にハッシュされる
    インプットとアウトプットを含むトランザクション内で実行される場合にのみ成功します。
    これらのアウトプットの1つは、LNのチャネルステートをバックアップからリカバリーするために必要なデータなど、
    スクリプトの作成者がブロックチェーンに公開したいデータにコミットする`OP_RETURN`アウトプットである可能性があります。
    しかし、witnessフィールドにデータを置く方がコストは大幅に安くなります。
    `OP_CTV`の提案された更新形式を使用すると、スクリプトの作成者は、
    インプットとアウトプットがハッシュされる際に、witnessスタックから追加のデータを含めるよう要求できるようになります。
    そのデータはスクリプトの作成者によって提供されたハッシュダイジェストに対してチェックされます。
    これにより、ブロックweightを最小限に抑えてデータがブロックチェーンに公開されることが保証されます。

  この提案は、この記事の執筆時点ではメーリングリストでまだ議論されていません。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LDK v0.0.123][]は、LN対応アプリケーションを構築するためのこの人気のライブラリのリリースです。
  [トリムされるHTLC][topic trimmed htlc]の設定の更新や、[オファー][topic offers]のサポートの改善、
  その他の多くの改善が含まれています。

- [LND v0.18.0-beta.rc2][]は、この人気のLNノードの次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [Bitcoin Core #29845][]は、複数の`get*info` RPCを更新し、
  `warnings`フィールドを文字列から文字列の配列に変更し、1つだけではなく、複数の警告を返せるようにします。

- [Core Lightning #7111][]では、libpluginユーティリティを通じてプラグインで
  `check` RPCコマンドを利用できるようになりました。また、設定オプションが受け入れられるか検証する
  `check setconfig`を有効にすることで使用法も拡張され、既存の`check keysend`は、
  hsmdがトランザクションを承認するかどうかを検証するようになりました。
  初期化前メッセージに事前設定されたHSM開発フラグが追加されました。
  `check`コマンドの詳細については、ニュースレター[#25][news25 cln check]および[#47][news47 cln check]もご覧ください。

- [Libsecp256k1 #1518][]は、公開鍵のセットを辞書順にソートする`secp256k1_pubkey_sort`関数を追加しました。
  これは、[MuSig2][topic musig]や[サイレントペイメント][topic silent payments]、
  複数の鍵を必要とする他の多くのプロトコルで役立ちます。

- [Rust Bitcoin #2707][]は、[Taproot][topic taproot]の一部として導入されたタグ付きハッシュ用のAPIを更新し、
  デフォルトで内部バイト順でダイジェストを維持するようになりました。
  これまでは、APIはハッシュの表示バイト順を維持していましたが、
  これは`#[hash_newtype(backward)]`のようなコードで取得できるようになります。
  [歴史的な理由][mb3e byte order]から、txidとブロックの識別子のハッシュダイジェストは、
  トランザクションやブロックの内で、あるバイト順（内部バイト順）で表示されますが、
  ユーザーインターフェースでは逆順（表示バイト順）で表示および呼び出されます。
  このPRは、さまざまな状況で異なるバイト順を持つハッシュがさらに増えることを防ごうとするものです。

- [BIPs #1389][]は、「ディスクリプターウォレットのウォレットポリシー」を定義する[BIP388][]を追加しました。
  これは、多くのウォレットがコードとユーザーインターフェースの両方でサポートしやすい
  [アウトプットスクリプトディスクリプター][topic descriptors]のテンプレート化されたセットです。
  特に、リソースや画面のスペースが制限されたハードウェアウォレット上でディスクリプターを実装するのは困難な場合があります。
  BIP388のウォレットポリシーにより、これにオプトインしたソフトウェアやハードウェアは、
  ディスクリプターの使用方法についての仮定を簡素化することができます。
  これによりディスクリプターの範囲が最小限に抑えられ、必要なコードの量とユーザーが検証する必要のある詳細の数を削減します。
  ディスクリプターの全機能を必要とするソフトウェアは、BIP388とは独立してディスクリプターを引き続き使用できます。
  詳細については、[ニュースレター #200][news200 policies]をご覧ください。

- [BIPs #1567][]は、[Tapscript][topic tapscript]内でスクリプト化されたマルチシグ機能を提供する
  新しいディスクリプター`multi_a()`と`sortedmultia_a()`を追加する[BIP387][]を追加しました。
  BIPの例より、`multi_a(k,KEY_1,KEY_2,...,KEY_n)`というディスクリプターの断片は、
  `KEY_1 OP_CHECKSIG KEY_2 OP_CHECKSIGADD ... KEY_n OP_CHECKSIGADD OP_k
  OP_NUMEQUAL`というスクリプトを生成します。ニュースレター[#191][news191 multi_a]および、
  [#227][news227 multi_a]、[#273][news273 multi_a]もご覧ください。

- [BIPs #1525][]は、ソフトフォークで[有効化された][topic soft fork activation]場合に
  [Tapscript][topic tapscript]で使用できる[OP_CAT][topic op_cat] opcodeを提案する[BIP347][]を追加しました。
  ニュースレター[#274][news274 op_cat]および[#275][news275 op_cat]、[#293][news293 op_cat]もご覧ください。

## ニュースレター発行日の変更

今後数週間のうちに、Optechは試験的に発行日を変更します。
ニュースレターの受け取りが数日早くなったり遅れたりしても驚かないでください。
短期間の実験期間中、メールのニュースレターには、ニュースレターを読んだ人の数を確認するためのトラッカーが含まれます。
ニュースレターを読む前に、外部リソースの読み込みを無効にすることで、このトラッキングを防ぐことができます。
さらにプライバシーを守りたい場合は、一時的なTor接続を介して[RSS feed][]を購読することをお勧めします。
ご不便をかけて申し訳ありません。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1525,1567,1389,2707,1518,7111,29845" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[mb3e byte order]: https://github.com/bitcoinbook/bitcoinbook/blob/6d1c26e1640ae32b28389d5ae4caf1214c2be7db/ch06_transactions.adoc#internal_and_display_order
[news200 policies]: /ja/newsletters/2022/05/18/#miniscript
[news191 multi_a]: /ja/newsletters/2022/03/16/#bitcoin-core-24043
[news227 multi_a]: /ja/newsletters/2022/11/23/#how-do-i-create-a-taproot-multisig-address-taproot
[news273 multi_a]: /ja/newsletters/2023/10/18/#bitcoin-core-27255
[news274 op_cat]: /ja/newsletters/2023/10/25/#op-cat-bip
[news275 op_cat]: /ja/newsletters/2023/11/01/#op-cat
[news293 op_cat]: /ja/newsletters/2024/03/13/#bitcoin-core-pr-review-club
[kim utreexo]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d5f47120-3397-4f56-93ca-dd310d845f3cn@googlegroups.com/T/#u
[electrum personal server]: https://github.com/chris-belcher/electrum-personal-server
[btcd]: https://github.com/btcsuite/btcd
[rubin bip119e]: https://mailing-list.bitcoindevs.xyz/bitcoindev/35cba1cd-eb67-48d1-9615-e36f2e78d051n@googlegroups.com/T/#u
[bip119e]: https://github.com/bitcoin/bips/pull/1587
[news284 eltoo]: /ja/newsletters/2024/01/10/#ctv
[collision attack]: https://en.wikipedia.org/wiki/Collision_attack
[rss feed]: /feed.xml
[ldk v0.0.123]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.123
[news25 cln check]: /en/newsletters/2018/12/11/#c-lightning-2123
[news47 cln check]: /en/newsletters/2019/05/21/#c-lightning-2631
