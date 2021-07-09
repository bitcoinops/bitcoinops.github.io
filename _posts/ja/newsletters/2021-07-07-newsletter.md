---
title: 'Bitcoin Optech Newsletter #156'
permalink: /ja/newsletters/2021/07/07/
name: 2021-07-07-newsletter-ja
slug: 2021-07-07-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Output script descriptor関連のBIPおよび、
LNプロトコルの拡張とアプリケーションのインターオペラビリティのための一連の標準ドキュメントの作成の提案、
あらかじめ信頼されているゼロ承認のチャネル開設をサポートする標準化の議論を掲載しています。
また、Taprootの準備方法や、リリースとリリース候補、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点などの恒例のセクションも含まれています。

## ニュース

- **Output script descriptorのBIP:** Andrew Chowは、
  [Output script descriptor][topic descriptors]
  を標準化するためのBIPの提案をBitcoin-Devメーリングリストに[投稿しました][chow descriptors post]。
  コアとなるBIPは、descriptorで使用される一般的なセマンティクスと主な要素を提供します。
  6つの追加のBIPは、`pkh()`、`wpkh()`および`tr()`など、引数を使ってスクリプトテンプレートを埋める拡張関数を記載しています。
  複数のBIPにより、開発者はどのdescriptorの機能を実装するか選択することができます。
  例えば、新しいウォレットでは、レガシーな`pkh()`descriptorを実装しないこともあります。

    descriptorはもともとBitcoin Core用に実装されたものですが、
    ここ1年間で他のプロジェクトでも採用が増えています。
    ウォレットが、[Taproot][topic taproot]によって可能になる柔軟性や、
    [Miniscript][topic miniscript]などのツールを介して柔軟なスクリプトへのアクセスを簡単にする機能を模索し始めると、
    descriptorの使用が大幅に増加することが予想されます。

{% comment %}<!-- Gentry uses a lowercase leading character (bLIPs).  I
asked in IRC why, but unless there's a *really* compelling reason, I'd
prefer to capitalize.  I won't die on this hill, but I'm willing to lose
a little blood to prevent terms like iPhone that are super annoying to use
at the beginning of a sentence. -harding -->{% endcomment %}

- **BLIP:** Ryan Gentryは、Lightning-Devメーリングリストに、
  インターオペラビリティの標準から恩恵を受けるLNの拡張やアプリケーションを記載したドキュメントである
  Bitcoin Lightning Improvement Proposals (BLIP)のコレクションの提案を[投稿しました][gentry blips]。
  René Pickhardtは、2018年に彼が行った[ほぼ同じ提案][pickhardt lips]をリンクしました。

    議論の中で、このアイディアは幅広い支持を得ているようにみえましたが、
    それらの標準を基本のBOLTドキュメントに組み込むための障壁、
    つまり経験豊富な開発者が多くのコミュニティ提案をレビューする十分な時間がないという障壁を実際に解決できないという
    [懸念][teinturier blips]が示されました。
    BLIPが十分なレビューを経ずにマージされると、バグが含まれていたり、
    複数のステークホルダーから幅広い支持を得られなかったりする可能性が高くなり、
    異なるプロジェクトが競合する標準を採用することで断片化が進むことになりかねません。
    しかし、非メインラインのプロトコルは既に作成されており、
    それらのプロトコルに関するドキュメントを公開できる有名なアーカイブを提供することは主に有益であると
    ほとんどの議論の参加者は考えているようです。

- **<!--zero-conf-channel-opens-->ゼロ承認のチャネル開設:** Rusty Russellは、
  Lightning-Devメーリングリスト上で、*turbo channel*という名前でも知られている、
  ゼロ承認チャネルの取り扱いを標準化するための[議論][russell zeroconf]を開始しました。
  これらは、資金提供者が初期資金の一部またはすべてを受領者に提供する新しいシングルファンド・チャネルです。
  これらの資金は、チャネルを開設するトランザクションが十分な数の承認を得るまで安全ではないため、
  受領者が標準的なLNプロトコルを使用して資金の一部を資金提供者に戻すことにリスクはありません。

    例えば、アリスはボブのカストディアルな取引所の口座に数BTC持っています。
    アリスはボブに、アリスに1.0 BTC支払う新しいチャネルを開くよう依頼します。
    ボブは自分自身が開設したばかりのチャネルを二重使用しないと信じているので、
    チャネル開設トランザクションが１つめの承認を受ける前であっても、
    アリスがボブのノードを通じて0.1 BTCを第三者のキャロルに送信できるようにすることができます。

    {:.center}
    ![Zero-conf channel illustration](/img/posts/2021-07-zeroconf-channels.png)

    一部のLNの実装は、既にこのアイディアを非標準的な方法でサポートしているものもあり、
    議論に参加した全員が標準化を支持しているようでした。
    具体的にどのような方法で使用するかは、執筆時にはまだ議論中でした。

## Taprootの準備 #3: Taproot descriptor

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/02-descriptors.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.13.1-beta.rc1][LND 0.13.1-beta]は、0.13.0-betaで導入された機能の
  マイナーな改善とバグ修正を含むメンテナンスリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #19651][]では、
  ウォレットキーマネージャーが既存の[descriptor][topic descriptors]を更新できるようになりました。
  これにより、ウォレットのユーザーは、ラベルの編集やdescriptorの範囲の拡張、
  非アクティブなdescriptorの再有効化およびその他の更新を
  `importdescriptors`ウォレットRPCを使って行うことができます。

- [C-Lightning #4610][]では、
  `--experimental-accept-extra-tlv-types`コマンドラインオプションが追加されました。
  これにより、ユーザーはプラグインが処理するために`lightningd`が通過させるべき偶数番めのTLVタイプのリストを指定できるようになります。
  これまでは、`lightningd`はすべての未知の偶数タイプのTLVメッセージを無効とみなしていました。
  この変更により、プラグインが`lightningd`に知られていない独自のカスタムTLVタイプを定義して処理できるようになりました。

- [Eclair #1854][]は、警告メッセージタイプが[最近実装された][news136 c-lightning 4364]
  C-Lightningのような相手から送られた[警告メッセージ][bolts #834]のデコードとロギングのサポートを追加しました。

- [BIPs #1137][]は、単一の鍵のP2TRアウトプットに対する鍵導出方式を提案する[BIP86][]を追加しました。
  このBIPについては、[先週のニュースレターにまとめられています][bip-taproot-bip44 desc]。

- [BIPs #1134][]は、BIP155を更新し、
  ソフトウェアプログラムが[バージョン2のaddrメッセージ][topic addr v2]を理解する場合に、
  プログラムが必ずしも`addr`メッセージの受信を望んでいない場合も含めて、
  `sendaddr2` P2Pの機能ネゴシエーションメッセージを送信する必要があることを示しています。

{% include references.md %}
{% include linkers/issues.md issues="19651,4610,1854,1137,1134,834" %}
[LND 0.13.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.1-beta.rc1
[chow descriptors post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019151.html
[news34 descriptor checksums]: /en/newsletters/2019/02/19/#bitcoin-core-15368
[gentry blips]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-June/003086.html
[pickhardt lips]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-June/003088.html
[teinturier blips]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-July/003093.html
[russell zeroconf]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-June/003074.html
[news136 c-lightning 4364]: /ja/newsletters/2021/02/17/#c-lightning-4364
[bip86]: https://github.com/bitcoin/bips/blob/master/bip-0086.mediawiki
[bip-taproot-bip44 desc]: /ja/newsletters/2021/06/30/#p2tr
[series preparing for taproot]: /ja/preparing-for-taproot/