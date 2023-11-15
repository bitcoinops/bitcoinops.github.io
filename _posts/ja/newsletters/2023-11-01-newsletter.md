---
title: 'Bitcoin Optech Newsletter #275'
permalink: /ja/newsletters/2023/11/01/
name: 2023-11-01-newsletter-ja
slug: 2023-11-01-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinのスクリプト言語に対する変更案に関する最近のいくつかの議論を
フォローアップしています。また、新しいリリースの発表や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **<!--continued-discussion-about-scripting-changes-->スクリプトの変更に関する継続的な議論:**
  以前取り上げた議論に対して、Bitcoin-Devメーリングリストでいくつかの返信がありました。

    - *<!--covenants-research-->コベナンツの研究:* Anthony Townsは、
      [先週][news274 cov]言及したRusty Russellの[投稿][russell cov]に[返信しました][towns cov]。
      Townsは、Russellのアプローチを、特に他の[コベナンツ][topic covenants]ベースの[Vault][topic vaults]に関する他のアプローチと比較し、
      魅力的ではないと判断しました。Russellはさらに[返信][russell cov2]の中で、
      Vaultにはさまざまな設計があり、Vaultは他のトランザクションタイプに比べて基本的に最適ではないことを指摘し、
      Vaultユーザーにとって最適化が重要ではないことを示唆しています。
      彼は、[BIP345][]のVaultアプローチは、opcodeのセットよりもアドレス形式に適していると主張しました。
      これは、BIP345がopcodeのセットとしてよりも、
      1つの機能のために設計されたテンプレート（P2WPKHのような）とする方が理にかなっていることを意味しますが、
      スクリプトの残りの部分と予期しない方法で相互作用する可能性があります。

      Townsはまた、一般的に実験を可能にする目的でRussellのアプローチを使用することを検討し、
      「より興味深い[...]が、それでもかなり不自由である」と感じています。
      彼は、LispスタイルのBitcoin Scriptの代替を提供するという以前の提案（[ニュースレター #191][news191 lisp]参照）を読者に思い出させ、
      それがwitnessの評価中にトランザクションのイントロスペクションを実行するための柔軟性と能力の向上をどうもたらすかを示しています。
      彼は、テストコードへのリンクを提供し、彼が書いたいくつかのおもちゃの例について言及しました。
      Russellは、「置き換えまでにはまだ改善の余地がたくさんあると思う。ほとんどの興味深いケースは不可能なので、
      今あるスクリプトと代替案を比較するのは難しい。」と応えています。

      TownsとRussellは、[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]、
      特にオラクルからの認証済みデータを評価スタックに直接配置できるようにする機能についても簡単に触れています。

    - *OP_CATの提案:* 先週[言及][news274 cat]した、
      [OP_CAT][]のBIP提案を発表したEthan Heilmanの[投稿][heilman cat]に数名から返信がありました。

      `OP_CAT`がスタック要素のサイズの520バイトの制限によって過度に制限されるのではないかという懸念について
      いくつかの返信で言及された後、Peter Toddは、追加の`OP_SUCCESSx`を使用せずに、
      将来のソフトフォークで制限を引き上げる方法について[説明しました][todd 520]。
      欠点は、制限を引き上げる前に`OP_CAT`を使用するには、既に有効な少数の追加のopcodeをスクリプトに含める必要があることです。

      Russellのコベナンツの研究に対するAnthony Townsの同様の回答の前に行われた[投稿で][o'beirne vault]、
      James O'Beirneは、`OP_CAT`を使用してVaultを実装する場合の重大な制限について指摘しています。
      彼は、BIP345スタイルのVaultと比較して`OP_CAT`バージョンにかけているいくつかの機能を特に指摘しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LDK 0.0.118][]は、LN対応アプリケーションを構築するためのこのライブラリの最新リリースです。
  他の新機能やバグ修正に加えて[Offer][topic offers]プロトコルの部分的な実験的サポートが含まれています。

- [Rust Bitcoin 0.31.1][]は、Bitcoinデータを扱うためのこのライブラリの最新リリースです。
  新しい機能とバグ修正のリストについては、[リリースノート][rb rn]をご覧ください。

_注:_ 前回のニュースレターで紹介したBitcoin Core 26.0rc1にはタグが付けられていますが、
macOS用の再現可能なバイナリの作成を妨げるAppleによる変更のため、バイナリはアップロードされていません。
Bitcoin Coreの開発者は、2つめのリリース候補の緩和策に取り組んでいます。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #28685][]は、[以前のニュースレター][news274 hash bug]で言及した、
  UTXOセットのハッシュの計算のバグを修正しています。これには、
  以前の`hash_serialized_2`の値が、修正されたハッシュを含む`hash_serialized_3`に置き換えられる
  `gettxoutsetinfo` RPCの破壊的な変更を含みます。

- [Bitcoin Core #28651][]により、[Miniscript][topic miniscript]は、
  [Taproot][topic taproot]アウトプットを使用するためにwitnessの構造に含める必要がある最大バイト数を
  より正確に推定できるようになりました。この精度の向上は、Bitcoin Coreのウォレットの手数料の過払いを防止するのに役立ちます。

- [Bitcoin Core #28565][]は、[#27511][Bitcoin Core #27511]をベースに構築され、
  ネットワーク（IPv4、IPv6、Tor、I2P、CJDNS）ごとにセグメントされた「新規」または「試行済み」の
  ピアのアドレスの数を公開する`getaddrmaninfo` RPCを追加しました。
  このセグメンテーションの動機については、[ニュースレター #237][news237 pr review]および
  [ポッドキャスト #237][pod237 pr review]を参照ください。

- [LND #7828][]は、ピアが妥当な時間内にLNプロトコルの`ping`メッセージに応答することを要求するようになりました。
  応答しないと接続が切断されます。これは接続がアクティブな状態を維持するのに役立ちます（
  切断された接続によって支払いが滞り、望ましくないチャネルの強制閉鎖が発生する可能性が低減されます）。
  LNのpingとpongには他にも多くの利点があります。ネットワークトラフィックの偽装に役立ち、
  ネットワークの観察者が支払いを追跡するのが難しくなります（支払いやping、pongはすべて暗号化されているため）。
  [BOLT1][]で定義されているように、暗号鍵のローテーションをより頻繁にトリガーします。
  特にLNDでは、[エクリプス攻撃][topic eclipse attacks]の防止に
  `pong`メッセージを使用しています（[ニュースレター #164][news164 pong]参照）。

- [LDK #2660][]により、呼び出し元がオンチェーントランザクションに対して選択できる手数料率について
  より柔軟に選択できるようになりました。
  これには、最低額の支払い、承認に1日以上かかる可能性がある低手数料率、通常の優先順位、
  高優先順位の設定が含まれます。

- [BOLTs #1086][]は、転送された[HTLC][topic htlc]を作成するための指示が、
  ローカルノードが払い戻しを請求できるようになるまで2,016ブロックを超えて待機するような要求であった場合に、
  ノードはHTLCを拒否（払い戻し）し、`expiry_too_far`エラーを返すよう定義しました。
  この設定を下げると、特定の[チャネルジャミング攻撃][topic channel jamming attacks]や、
  長期の[保留インボイス][topic hold invoices]によるノードの最悪の場合の収入損失を減らすことができます。
  この設定を引き上げると、同じ最大HTLC deltaの設定でより多くのチャネルに支払いを転送することができます（
  または、より高い最大HTLC delta設定の場合は同じホップ数で、
  [先週のニュースレター][news274 cycling]で説明した置換サイクル攻撃などの特定の攻撃に対する耐性を向上させることができます）。

{% include references.md %}
{% include linkers/issues.md v=2 issues="28685,28651,28565,7828,2660,1086,27511" %}
[news164 pong]: /ja/newsletters/2021/09/01/#lnd-5621
[towns cov]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022099.html
[russell cov]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022031.html
[news274 cov]: /ja/newsletters/2023/10/25/#research-into-generic-covenants-with-minimal-script-language-changes
[russell cov2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022103.html
[news191 lisp]: /ja/newsletters/2022/03/16/#chia-lisp
[heilman cat]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022049.html
[news274 cat]: /ja/newsletters/2023/10/25/#op-cat-bip
[todd 520]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022094.html
[o'beirne vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022092.html
[Bitcoin Core 26.0rc1]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[bitcoin core developer wiki]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[news274 cycling]: /ja/newsletters/2023/10/25/#htlc
[ldk 0.0.118]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.118
[rust bitcoin 0.31.1]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.31.0
[rb rn]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/bitcoin/CHANGELOG.md#0311---2023-10-18
[news274 hash bug]: /ja/newsletters/2023/10/25/#bitcoin-utxo
[news237 pr review]: /ja/newsletters/2023/02/08/#bitcoin-core-pr-review-club
[pod237 pr review]: /en/podcast/2023/02/09/#bitcoin-core-pr-review-club-transcript
