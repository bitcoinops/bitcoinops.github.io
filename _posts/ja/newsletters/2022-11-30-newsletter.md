---
title: 'Bitcoin Optech Newsletter #228'
permalink: /ja/newsletters/2022/11/30/
name: 2022-11-30-newsletter-ja
slug: 2022-11-30-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、レピュテーション・クレデンシャル・トークンを使用した
LNジャミング攻撃を緩和する提案を掲載しています。また、
新しいソフトウェアリリースとリリース候補の発表や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **LNジャミング攻撃を緩和するためのレピュテーション・トークンの提案:**
  Antoine Riardは、攻撃者が一時的に支払い（[HTLC][topic htlc]）スロットや金額をブロックし、
  正直なユーザーが支払いを送信できなくなるのを（[チャネルジャミング攻撃][topic channel jamming attacks]と呼ばれる）
  防ぐための、新しいクレデンシャルベースのレピュテーションシステムの[提案][riard proposal]を
  Lightning-Devメーリングリストに[投稿しました][riard credentials]。

    現在のLNでは、支払人は自分のノードから、独立した転送ノードが運営する複数のチャネルを経由して、
    受け取りノードに至るまでのパスを選択します。支払人は、
    各転送ノードが次に支払いをリレーする場所を記述したトラストレスな命令のセットを作成し、
    それを暗号化して、各ノードが作業を行う上で必要な最小限の情報のみを受け取れるようにしています。

    Riardは、各転送ノードが、その転送ノードが以前発行した1つ以上のクレデンシャル・トークンを含む場合にのみ、
    そのリレー命令を受け入れるべきだと提案しています。クレデンシャルには[ブラインド署名][blind signature]が含まれており、
    どのノードがクレデンシャルを発行したか転送ノードが直接判断できないようになっています（
    転送ノードが支払人のネットワークIDを学習するのを防止します）。
    各ノードは、独自のポリシーに従ってクレデンシャルを発行することができますが、
    Riardはいくつかの配布方法を提案しています:

    - *<!--upfront-payments-->前払い:* アリスのノードがボブを経由して支払いを転送したい場合、
      アリスのノードはまずLNでボブからクレデンシャルを購入します。

    - *<!--previous-success-->前回の支払いの成功:*
      アリスがボブのノードを経由して送信した支払いが最終的な受取人によって受理された場合、
      ボブのノードはアリスのノードにクレデンシャル・トークンを返すか、
      あるいは前回より多くのトークンを返し、アリスのノードが今後ボブのノードを介してさらに支払いをできるようにします。

    - *UTXOの所有権の証明または他の代替案:* Riardの最初の提案には必要ないものの、
      転送ノードによっては、BitcoinのUTXOを所有していることを証明するすべての人にクレデンシャルを与えるという実験もできます。
      おそらく、古いUTXOや価格が高いUTXOには、新しいUTXOや価格が低いUTXOよりも多くのクレデンシャルトークンを与えるということもあるでしょう。
      各転送ノードはクレデンシャル・トークンをどのように配布するかを自ら選択するため、その他の基準を使用することも可能です。

    [ニュースレター #226][news226 jam]で紹介したローカルレピュテーションに基づいた共著を提案したClara Shikhelmanは、
    クレデンシャル・トークンがユーザー間で転送可能かどうか、またそれがトークン市場の創造につながるかどうかについて
    [質問しました][shikelman credentials]。
    また、支払人のノードが受取人までの完全なパスを知らない[ブラインドパス][topic rv routing]ではどのように機能するかという問いもありました。

    Riardは、転送にはトラストが必要なため、クレデンシャル・トークンを再分配して市場を形成するのは困難であると[返信しました][riard double spend]。
    たとえば、ボブのノードがアリスに新しいクレデンシャルを発行し、
    アリスがそのクレデンシャルをキャロルに売ろうとした場合、
    キャロルがその支払いをした後でもアリスがそのトークンを自身で使用しないことを証明するトラストレスな方法は存在しません。

    ブラインドパスについては、受取人は必要なクレデンシャルを暗号化された形で提供することができ、
    二次的な脆弱性は[発生しないようです][harding paths]。

    この提案に対する追加のフィードバックは、関連する[プルリクエスト][bolts #1043]に寄せられています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.15.5-beta.rc2][]は、LNDのメンテナンスリリース用のリリース候補です。
  リリースノートによると、マイナーなバグ修正のみが含まれています。

- [Core Lightning 22.11rc3][]は、CLNの次のメジャーバージョンのリリース候補です。
  CLNのリリースでは引き続き[セマンティック バージョニング][semantic versioning]を使用していますが、
  このリリースは新しいバージョン番号体系を使用する最初のリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Core Lightning #5727][]は、数値のJSONリクエストIDを非推奨にし、
  文字列型のIDを採用するようになりました。文字列のIDのメリットと、
  その作成と解釈を最大限活用する方法について、[ドキュメント][cln json ids]が追加されました。

- [Eclair #2499][]は、[BOLT12 オファー][topic offers]を使って支払いを要求する際に、
  ブラインドされた経路を指定することができるようになりました。
  この経路には、ユーザーのノードに至るまでの経路と、そのノードを通過する追加のホップが含まれていることがあります。
  そのノードを通過するホップには使用されないものの、支払人がその経路内のブラインドされていない最後の転送ノードから
  受取人までのホップ数を判断するのが難しくなります。

- [LND #7122][]は、バイナリ[PSBT][topic psbt]ファイルを処理するためのサポートを`lncli`に追加しました。
  [BIP174][]では、PSBTはプレーンテキストのBase64かバイナリとしてファイルにエンコードされると定義されています。
  これ以前にも、LNDはBase64エンコードされたPSBTをプレーンテキストもしくはファイルからインポートするのをサポートしていました。

- [LDK #1852][]は、現時点でチャネルを開き続けるために十分な手数料率でなくても、
  チャネルピアから提案された手数料率の増加を受け入れるようになりました。
  新しい手数料率が完全に安全なものでないとしても、手数料率が高くなるのは、
  そのノードがこれまで使用していた金額よりも安全であることを意味するため、
  これまでの低い手数料率でチャネルを閉じるより、それを受け入れる方が良いでしょう。
  LDKの将来の変更により、低手数料率でチャネルがクローズされるかもしれません。
  また、[パッケージリレー][topic package relay]のような提案により
  [アンカーアウトプット][topic anchor outputs]や同様の技術が、
  現在の手数料率に関する懸念を解消するようになるかもしれません。

- [Libsecp256k1 #993][]は、デフォルトのビルドオプションにextrakeys（x-only公開鍵を扱う関数）や
  [ECDH][]および[Schnorr署名][topic schnorr signatures]のモジュールを含めるようになりました。
  署名から公開鍵を再構築するモジュールは、まだデフォルトではビルドされません。
  これは、「新しいプロトコルにECDSAのリカバリを推奨していないためです。
  特に、リカバリAPIは誤用されやすく、呼び出し元が公開鍵の検証をし忘れる（そして検証関数が常にtrueを返す）ことが多いためです。」"

{% include references.md %}
{% include linkers/issues.md v=2 issues="5727,2499,7122,1852,993,1043" %}
[bitcoin core 24.0]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc 24.0 rn]: https://github.com/bitcoin/bitcoin/blob/0ee1cfe94a1b735edc2581a05c4b12f8340ff609/doc/release-notes.md
[lnd 0.15.5-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc2
[core lightning 22.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v22.11rc3
[cln json ids]: https://github.com/rustyrussell/lightning/blob/a25c5d14fe986b67178988e6ebb79610672cc829/doc/lightningd-rpc.7.md#json-ids
[riard credentials]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003754.html
[riard proposal]: https://github.com/lightning/bolts/blob/80214c83190836c4f7699af9e8920769607f1a00/www-reputation-credentials-protocol.md
[blind signature]: https://ja.wikipedia.org/wiki/ブラインド署名
[news226 jam]: /ja/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[shikelman credentials]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003755.html
[riard double spend]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003765.html
[harding paths]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003767.html
[ecdh]: https://ja.wikipedia.org/wiki/楕円曲線ディフィー・ヘルマン鍵共有
[semantic versioning]: https://semver.org/spec/v2.0.0.html
