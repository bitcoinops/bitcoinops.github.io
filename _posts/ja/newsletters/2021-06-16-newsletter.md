---
title: 'Bitcoin Optech Newsletter #153'
permalink: /ja/newsletters/2021/06/16/
name: 2021-06-16-newsletter-ja
slug: 2021-06-16-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Taprootのソフトフォークのロックインをお祝いし、
アンチ・フィー・スナイピングを実装するために使用されるフィールドを変更することで
トランザクションのプライバシーを改善するドラフトBIPについて掲載し、
トランザクションの交換と支払いバッチの組み合わせの課題についての記事を特集しています。
また、新しいソフトウェアのリリースおよびリリース候補の発表や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更などの恒例のセクションも含まれています。

## ニュース

- **🟩  Taproot ロックイン:** BIP [340][bip340]、[341][bip341]および[342][bip342]で定義された
  [Taproot][topic taproot]のソフトフォークと関連する変更は、先週末にマイナーのシグナリングによりロックインされました。
  Taprootは、11月初旬から中旬と予想されるブロック709,632以降で安全に使用できるようになります。
  この猶予により、ユーザーが自分のノードをTaprootのルールを適用する（Bitcoin Core 0.21.1もしくはそれ以降の）
  リリースにアップグレードする時間が与えられ、ブロック709,632以降にTaprootのScriptで受け取った資金は、
  たとえマイナーに問題があったとしても安全であることが保証されます。

    開発者の皆さまには、アクティベーションが完了した時点で、効率性やプライバシー、
    ファンジビリティの向上の恩恵が受けられるよう[Taprootの実装][taproot uses]を始めることをお勧めします。

    Taprootのロックインを祝福する読者の皆さまは、
    開発者のPieter WuilleによるTaprootの起源と歴史についての[短いスレッド][wuille taproot]もお読みください。

- **TaprootトランザクションでウォレットがデフォルトでnSequenceをセットするためのBIPが提案される:**
  Chris Belcherは、ウォレットが[アンチ・フィー・スナイピング][topic fee sniping]を実装するための代替方法を提案するドラフトBIPを
  Bitcoin-Devメーリングリストに[投稿しました][belcher post]。
  代替方法は、シングルシグユーザーや[マルチシグ][topic multisignature]ユーザーおよび、
  Taproot対応のLNや高度な[Coinswap][topic coinswap]などの特定のコントラクトプロトコルのユーザーによって作られる
  トランザクションのプライバシーおよびファンジビリティを強化します。

    アンチ・フィー・スナイピングは、
    Bitcoinの安全性を確保するために費やされるproof wof workの量を減らし、
    承認スコアに頼るユーザー能力を制限するような方法で、
    マイナーが互いに手数料を盗もうとするのを阻止するために、一部のウォレットが実装する手法です。
    今日、アンチ・フィー・スナイピングを実装しているすべてのウォレットは、
    nLockTimeの高さのロックを使用していますが、
    [BIP68][]のnSequenceの高さのロックを使用して同じ保護を実装することも可能です。
    アンチ・フィー・スナイピングについてはこれ以上の効果はありませんが、
    通常のウォレットがnSequenceの値を、CoinswapやTaproot対応のLNのアイディアなど
    特定のマルチシグベースのコントラクトプロトコルのトランザクションで必要とされるのと同じ値を設定する良い理由になります。
    これにより通常のウォレットのトランザクションをコントラクトプロトコルのトランザクションのように見せることができ、その逆も可能です。

    Belcherの提案は、両方のオプションが利用可能な場合、
    ウォレットがnLockTimeとnSequenceのどちらを使用するか50%の確率でランダムに選択することを提案しています。
    全体的に、提案が実装されると、通常のシングルシグのトランザクションや簡単なマルチシグのユーザーが、
    コントラクトプロトコルのユーザーと一緒になり、お互いのプライバシーやファンジビリティを向上させることができるようになります。

## フィールドレポート: RBFと加法的バッチ処理の利用

{% include articles/ja/cardcoins-rbf-batching.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Rust Bitcoin 0.26.2][]は、同プロジェクトの最新のマイナーリリースです。
  前回のメジャーバージョンと比較して、いくつかのAPIの改善とバグ修正が含まれています。
  詳細は[変更ログ][rb changelog]をご覧ください。

- [Rust-Lightning 0.0.98][]は、いくつかの改善とバグ修正を含むマイナーリリースです。
  <!-- there's no release notes or changelog I can see, so not much to say here. -->

- [LND 0.13.0-beta.rc5][LND 0.13.0-beta]は、プルーニングされたBitcoinフルノードの使用をサポートし、
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

- [Bitcoin Core GUI #4][]では、GUIを介して[Hardware Wallet Interface (HWI)][topic hwi]の
  外部署名者を使用するための初期サポートを追加しています。
  この機能が完成すると、ユーザーはBitcoin CoreのGUIから直接HWI互換のハードウェアウォレットを使用できるようになります。

    {:.center}
    ![HWIパス設定オプションのスクリーンショット](/img/posts/2021-06-gui-hwi.png)

- [Bitcoin Core #21573][]では、Bitcoin Coreに含まれるlibsecp256k1のバージョンを更新しています。
  最も注目すべき変更は、ニュースレター[#136][news136 safegcd]および[#146][news146 safegcd]に掲載した
  最適化されたモジュラ逆数のコードを使用していることです。PRに投稿された性能評価によると、
  古いブロックの検証が約10%高速化されています。

- [C-Lightning #4591][]では、[bech32m][topic bech32]アドレスのパースのサポートを追加しています。
  C-Lightningは、`option_shutdown_anysegwit`機能をネゴシエートしたピアが、
  任意のv1以上のネイティブsegwitアドレスをクロージングまたは払い戻しの宛先として指定できるようになりました。

{% include references.md %}
{% include linkers/issues.md issues="4,21573,4591" %}
[Rust Bitcoin 0.26.2]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.26.2
[Rust-Lightning 0.0.98]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.98
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc5
[belcher post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019048.html
[news136 safegcd]: /ja/newsletters/2021/02/17/#faster-signature-operations
[news146 safegcd]: /ja/newsletters/2021/04/28/#libsecp256k1-906
[taproot uses]: https://en.bitcoin.it/wiki/Taproot_Uses
[wuille taproot]: https://twitter.com/pwuille/status/1403725170993336322
[rb changelog]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/CHANGELOG.md#0262---2021-06-08
