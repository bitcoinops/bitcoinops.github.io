---
title: 'Bitcoin Optech Newsletter #134'
permalink: /ja/newsletters/2021/02/03/
name: 2021-02-03-newsletter-ja
slug: 2021-02-03-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、Taproot有効化後のScript言語に小さな変更をすることでコントラクトの柔軟性を高める方法に関するブログ投稿のリンクと、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき変更点を含む通常のセクションを掲載しています。

## ニュース

- **BIP340と`OP_CAT`による`OP_CHECKSIGFROMSTACK`の模倣:**
  Andrew Poelstraは、[ElementsProject.org][]の[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (`OP_CSFS`) opcode
  の機能を、現在提案されている[BIP340][]の[Schnorr署名][topic schnorr signatures]の仕様と2010年半ばまでBitcoinの一部であった
  （そして再導入について言及されることの多い）[OP_CAT][csfs cat] opcodeを使ってBitcoinに実装することについて[ブログ記事][poelstra 340cat]を執筆しました。
  BitcoinでCSFSのような動作を有効にすることで、トランザクションに事前に署名することなく[Covenants][topic covenants]やその他の高度なコントラクトを作成することが可能になり、
  複雑さや保存する必要のあるデータ量を削減することができる可能性があります。この記事の最後には、シリーズの後半の記事へのお誘いがあります(リンクは私達が追加):

  > "次の記事では、補助インプットを使って[SIGHASH_NOINPUT][topic sighash_anyprevout]をシミュレートし、
  > Lightning Channelの一定サイズのバックアップを可能にする方法と、"value-switching"を使って
  > [Vault][topic vaults]を構築する方法についてお話します。最後の記事では、[Miniscript][topic miniscript]
  > のアドホックな拡張と、そのためのソフトウェアをメンテナンス可能な方法で開発する方法についてお話します。"

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、
[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #20226][]では、ウォレットのための新しいRPCメソッドとして`listdescriptors`が追加されました。
  最近の[0.21.0 ソフトウェアリリース][news132 bitcoin core v0.21]に含まれる[PR #16528][news96 descriptor wallets]では、
  [Descriptor][topic descriptors]ウォレットのサポートが追加されました。この新しいRPCメソッドは、
  DescriptorウォレットにインポートされたすべてのDescriptorをリストアップします。

- [Bitcoin Core GUI #163][]は、GUIピア詳細領域の*Direction*フィールドをDirectionとピア接続のタイプの両方を表示する*Connection Type*に置き換えます。
  詳細については、Connection Typeフィールド名の上にカーソルを置くと以下のようなツールチップが表示されます。

    {:.center}
    ![Illustration of GUI peer detail connection type](/img/posts/2021-02-gui-peer-connection-type.png)

- [HWI #430][]では、`displayaddress`コマンドでTrezor Oneのマルチシグアドレス用の[BIP32][] 拡張公開鍵（xpub）を表示できるようになりました。

- [HWI #415][]は、`getkeypool`と`displayaddress`コマンドを更新し、`--sh_wpkh`と`--wpkh`オプションを`--addr-type`オプションに置き換え、
  `--addr-type sh_wpkh`のようにアドレスの種類をパラメータとして取るようになりました。

{% include references.md %}
{% include linkers/issues.md issues="16528,20226,163,430,415" %}
[btcpay server 1.0.6.8]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.6.8
[poelstra 340cat]: https://medium.com/blockstream/cat-and-schnorr-tricks-i-faf1b59bd298
[csfs cat]: /en/topics/op_checksigfromstack/#relationship-to-op_cat
[news96 descriptor wallets]: /en/newsletters/2020/05/06/#bitcoin-core-16528
[news132 bitcoin core v0.21]: /ja/newsletters/2021/01/20/#bitcoin-core-0-21-0
