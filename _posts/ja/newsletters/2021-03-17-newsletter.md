---
title: 'Bitcoin Optech Newsletter #140'
permalink: /ja/newsletters/2021/03/17/
name: 2021-03-17-newsletter-ja
slug: 2021-03-17-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、失われたLNファンディング・トランザクションの救済に関する議論と、
リリースとリリース候補の発表および人気のBitcoinインフラストラクチャソフトウェアの注目すべき変更点の通常のセクションを掲載しています。

## ニュース

- **<!--rescuing-lost-ln-funding-transactions-->失われたLNファンディング・トランザクションの救済:**
  LNのファンディング・トランザクションは、トランザクションのマリアビリティがある場合には安全ではありません。
  Segwitはほとんどのトランザクションで懸念される第三者によるマリアビリティを排除しましたが、
  [Replace-by-Fee][topic rbf] (RBF)を使用してファンディング・トランザクションの手数料を引き上げるといった、
  トランザクションの作成者自信がそのtxidを変異させるケースには対応していません。
  txidが変異すると、事前に署名された払い戻しトランザクションが無効になるため、ユーザーは自身の資金を取り戻すことができません。
  さらにリモートノードは自動的にファンディング・トランザクションを確認できないため、
  資金提供者が資金を取り戻す支援をできない可能性があります。

  今週、Rusty Russellは、この問題を抱えるユーザーが資金を取り戻せるよう、
  C-Lightningに素早く実装した実験的な機能についてLightning-Devメーリングリストに[投稿しました][russell funding rescue]。
  また、関連する問題の代替ソリューションや、
  [提案されている][bolts #851]チャネルのデュアル・ファンディングプロトコルがこの問題に与える影響についても説明しました。
  Christian Deckerもまた、ファンディングの回収を容易にするためのLN仕様の[変更案][bolts #854]を[投稿しました][decker funding rescue]。
  LNソフトウェアが外部ウォレットからのファンディングチャネルをサポートするようになると
  （例えば、[ニュースレター #51][news51 cl2672]に掲載したC-Lightningや、
  [ニュースレター #92][news92 lnd4079]に掲載したLNDなど）、
  開発者はこの種の障害シナリオにもっと注意を払うようになるかもしれません。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [HWI 2.0.0][hwi 2.0.0]は、HWIの次のメジャーバージョンのリリースです。
  とりわけ、BitBox02でのマルチシグのサポートやドキュメントの改善、
  Trezorでの`OP_RETURN`アウトプットの支払いのサポートなどが含まれています。

- [Rust-Lightning 0.0.13][]は、このLNライブラリの最新リリースで、
  [マルチパス・ペイメント][topic multipath payments]との前方互換性や
  [Taproot][topic taproot]などの将来のスクリプト・アップグレードを目的とした改善が含まれています。

- [BTCPay Server 1.0.7.0][]は、このセルフホスト型の支払い処理ソフトウェアの最新リリースです。
  注目すべき改善点は、より機能的で視覚的に分かりやすいウォレットセットアップウィザードや、
  Specterを使って作成されたウォレットのインポート、[bech32 アドレス][topic bech32]用のより効率的なQRコードなどです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #21007][]では、新しい設定オプション`-daemonwait`が追加されました。
  Bitcoin Coreは、初期の頃のバージョンから`-daemon`設定オプションを指定してプログラムを起動することで、
  バックグラウンドのデーモンプロセスとして実行することが可能でした。
  `-daemon`オプションを指定すると、プログラムはすぐにバックグランドでデーモンプロセスを開始します。
  新しい`-daemonwait`オプションも同様ですが、初期化の完了後にデーモンプロセスをバックグランドで起動します。
  これにより、ユーザーや親プロセスは、プログラムの出力や終了コードを観察することで、
  デーモンの起動が成功したかどうかをより簡単に知ることができます。

- [C-Lightning #4404][]では、`keysend` RPC（[ニュースレター #107][news107 keysend]参照）
  がこの機能をサポートしていることを明示的に通知していないノードにもメッセージを送信できるようになりました。
  [議論されている][fromknecht keysend]ように、通知は標準化されておらず、
  LNDで実装されている手順は通知に依存していないため、
  この変更によりC-LightningはLNDが対応できるノードとほぼ同じノードにメッセージを送信できるようになります。

- [C-Lightning #4410][]は、デュアル・ファンドチャネルの実験的な実装を、
  最新の[ドラフト仕様][bolts #851]の変更に合わせています。
  最も注目すべき点は、少なくとも一時的にProof of Discrete Log Equivalency (PODLE)の使用をやめたことです
  （PODLEのオリジナルの議論は[ニュースレター #83][news83 podle]を、
  代替手段についての議論は[ニュースレター #131][news131 podle]を参照）。
  このマージに続いて、特別なビルドフラグでC-Lightningをコンパイルする必要なく（ただし、特別な設定オプションは必要）、
  デュアル・ファンディングの実験がより利用しやすくなる[新しいPR][c-lightning #4427]が公開されました。

- [LND #5083][]では、[PSBT][topic psbt]を標準入力（stdin）のファイルディスクリプタからではなく、
  ファイルから読み込めるようになりました。
  一部の端末では、標準入力に同時に追加（貼り付けなど）できる文字数に[制限][lnd #5080]があり、
  base64形式で4096文字（3,072バイトのバイナリに相当）を超えるPSBTは使用できませんでした。
  特に、いくつかのハードウェアウォレットでは、Segwitの使用のために以前のトランザクションを含むPSBTを必要としているため
  （[ニュースレター #101][news101 segwit overpayment]参照）、3KiBを超えるサイズのPSBTを作成するのが普通になっています。

- [LND #5033][]は、`updatechanstatus` RPCを追加し、
  チャネルが無効になったこと（ノードがオフラインになったのと同様）、
  再度有効になったことを（ノードがオンラインになったのと同様）を通知できるようになりました。

- [Rust-Lightning #826][]は、チャネルを一方的に閉じたノードへ支払うアウトプットに対する
  `OP_CHECKSEQUENCEVERIFY`の遅延の最大値を2,016ブロックに増やしました。
  これにより、これまでのRust-Lightningの最大値である1,008ブロックよりも大きい、
  2,016ブロックまでの遅延を要求する可能性があるLNDでチャネルを開く際の相互運用性の問題が修正されました。

- [HWI #488][]では、`displayaddress`コマンドに`--desc`オプションで
  [output script descriptor][topic descriptors]を使用した場合のマルチシグアドレスの扱い方について、
  互換性のない変更がされました。これまで、HWIは関連するデバイスに基づいて
  [BIP67][]の辞書式のキーソートを自動的に適用していました（例えば、ColdcardデバイスにはBIP67を適用し、Trezorデバイスには適用しない）。
  この実装方法では、BIP67のキーソートを実装する`sortedmulti` descriptorをユーザーが明示的に指定した際に問題が発生していました。
  今回の変更により、descriptorのユーザーは、辞書式のソートを必要とするデバイスには`sortedmulti`を、
  必要としないデバイスには`multi`を指定する必要があります。

{% include references.md %}
{% include linkers/issues.md issues="21007,4404,854,4410,4427,5083,5080,5033,826,488,851" %}
[hwi 2.0.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.0.0
[rust-lightning 0.0.13]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.13
[btcpay server 1.0.7.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.7.0
[news51 cl2672]: /en/newsletters/2019/06/19/#c-lightning-2672
[news92 lnd4079]: /en/newsletters/2020/04/08/#lnd-4079
[russell funding rescue]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-March/002981.html
[decker funding rescue]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-March/002982.html
[news107 keysend]: /en/newsletters/2020/07/22/#c-lightning-3792
[fromknecht keysend]: https://github.com/ElementsProject/lightning/issues/4299#issuecomment-781606865
[news83 podle]: /ja/newsletters/2020/02/05/#ln
[news131 podle]: /ja/newsletters/2021/01/13/#ln-utxo
[news101 segwit overpayment]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
