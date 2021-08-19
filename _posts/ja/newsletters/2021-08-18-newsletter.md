---
title: 'Bitcoin Optech Newsletter #162'
permalink: /ja/newsletters/2021/08/18/
name: 2021-08-18-newsletter-ja
slug: 2021-08-18-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、dust limitに関する議論の要約と、
サービスやクライアントソフトウェアの変更点、Taprootへの準備方法、新しいリリースとリリース候補、
および人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点などの恒例のセクションを掲載しています。

## ニュース

- **dust limitの議論:** Bitcoin Coreや他のノードソフトウェアは、 アウトプットの値が一定の金額
  （[dust limit][topic uneconomical outputs]）以下のトランザクションの中継やマイニングをデフォルトで拒否します
  （正確な金額はアウトプットの種類によって異なります）。
  これにより、ユーザーが*不経済なアウトプット*（保持する価値より手数料の方が多いUTXO）を作成するのが難しくなります。

    今週、Jeremy RubinはBitcoin-Devメーリングリストに、
    dust limitを撤廃するための5つの論点を[投稿し][rubin dust]、
    この制限の理由は「スパム」と「[dust fingerprint attack][topic output linking]」を防ぐためであるという信念を述べました。
    他の人々は、この制限は「スパム」の防止のためにあるのではなく、
    ユーザーが決して使用することに経済的なインセンティブを持たないUTXOを作成することで
    フルノードの運用者のリソースを恒久的に消費するのを防ぐためにあるという[反論][harding dust]で[応答しました][corallo dust]。
    議論の一部では、dust limitと不経済なアウトプットの両方がLNの一部に与える[影響][towns dust]についても[述べられました][riard dust]。

    この記事を書いている時点では、何の合意も得られそうにありませんでした。
    少なくとも短期的には、dust limitはこのままだと思われます。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Spark Lightning WalletがBOLT12のサポートを追加:**
  [Spark][spark github]の[v0.3.0rcリリース][spark v0.3.0rc]は、
  BOLT12の[Offer][topic offers]のサポートを追加しました。

- **Blockstreamが非カストディ型のLNクラウドサービスGreenlightを発表:**
  Blockstreamは最近の[ブログ記事][blockstream blog greenlight]で、
  ノード運用（Blockstream）とノードが保有する資金の管理（ユーザー）を分離する、
  ホスト型のC-Lightning-nodes-in-the-cloudサービスの詳細を発表しました。
  [Sphinx][sphinx website]と[Lastbit][lastbit website]は両方とも現在Greenlightサービスを利用しています。

- **BitGoがnative segwitのお釣り用アウトプットを発表:**
  Segwitの採用が75%を超えたことを受け、[BitGoのブログ記事][bitgo blog segwit change]では、
  デフォルトのお釣り用のアウトプットを、P2SHでラップしたものから
  [native segwit][topic bech32]のアウトプットに変更することが発表されました。

- **Blockstream Green desktop 0.1.10リリース:**
  [バージョン0.1.10][blockstream green desktop 0.1.10]では、
  segwitがデフォルトのシングルシグウォレットと、
  手動の[コイン選択][topic coin selection]機能が追加されています。

## Taprootの準備 #9: 署名アダプター

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/08-signature-adaptors.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 22.0rc2][bitcoin core 22.0]は、
  このフルノード実装とそれに付随するウォレットおよび他のソフトウェアの次のメジャーバージョンのリリース候補です。
  この新バージョンの主な変更点は、[I2P][topic anonymity networks]接続のサポート、
  [Tor v2][topic anonymity networks]接続の廃止、ハードウェアウォレットのサポートの強化などです。

- [Bitcoin Core 0.21.2rc1][bitcoin core 0.21.2]は、
  Bitcoin Coreのメンテナンス版のリリース候補です。
  いくつかのバグ修正と小さな改善が含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #22642][]は、次期バージョン22.0のBitcoin Coreのリリースプロセスを更新し、
  バイナリの[再現可能ビルド][topic reproducible builds]を行った
  全員のGPG署名をバッチ検証（[例][gpg batch]）可能な単一のファイルに連結しました。
  決定論的にビルドした人の署名は何年も前から入手可能でしたが、これによりアクセスしやすくなり、
  プロジェクトのリードメンテナーがリリースバイナリに署名するという既存の依存関係も軽減されるでしょう。

- [Bitcoin Core #21800][]は、mempoolにおけるパッケージ受け入れの祖先と子孫の制限を実装しています。
  Bitcoin Coreは、DoS攻撃に対する保護として、またマイナーがブロックの構築を扱いやすくするため、
  mempool内の関連トランザクションの数を制限しています。
  デフォルトでは、この[制限][bitcoin core mempool limits]によりmempool内のトランザクションは、
  mempool内にある関連する祖先と合わせて25トランザクションもしくはサイズが101KvB weightを超えることができません。
  同じルールがmempoolの子孫にも適用されます。

    これらの親子関係の制限は、トランザクションをmempoolに追加する際に適用されます。
    トランザクションを追加することでいずれかの制限を超える場合、トランザクションは拒否されます。
    パッケージのセマンティクスは確定していませんが、
    [#21800][bitcoin core #21800]は、任意のパッケージの検証をするための親子関係の制限のチェックを実装しています
   （つまり、複数のトランザクションが同時にmempoolに追加される際の検討）。
    mempoolパッケージの受け入れは、[#20833][mempool package test accept]でテスト用にのみ実装されていましたが、
    最終的には、[パッケージリレー][topic package relay]の一部としてP2Pネットワーク上で公開される予定です。

- [Bitcoin Core #21500][]は、`private`パラメーターで`listdescriptors`RPCを更新し、
  これがセットされている場合、各descriptorのプライベート形式を返します。
  プライベート形式には、既知の秘密鍵や、拡張秘密鍵（xprv）が含まれており、
  この更新されたコマンドを使ってウォレットをバックアップすることができます。

- [Rust-Lightning #1009][]は、チャネルの設定オプションに`max_dust_htlc_exposure_msat`を追加し、
  これにより金額が[dust limit][topic uneconomical outputs]を下回る保留中の"dusty HTLCs"の合計残高が制限されます。

  この変更は、[提案されている][BOLTs #873]`option_dusty_htlcs_uncounted` feature bitに備えるものです。
  これは、ノードが`max_accepted_htlcs`に対して"dusty HTLCs"をカウントしないことを配信します。
  `max_accepted_htlcs`は、主に強制クローズが発生した場合のオンチェーントランザクションの潜在的なサイズを制限するために使われていますが、
  "dusty HTLCs"はオンチェーンでは請求できず最終的なトランザクションサイズに影響を与えることがないため、
  ノード運用者はこのfeature bitを採用したいと考えています。

  新たに追加されたチャネルの設定オプション`max_dust_htlc_exposure_msat`により、
  `option_dusty_htlcs_uncounted`がオンになっていても、
  ユーザーは"dusty HTLCs"の総残高を制限することができます。
  この残高は強制クローズの際にマイナーへの手数料として失われてしまうからです。

{% include references.md %}
{% include linkers/issues.md issues="22642,21800,21500,1009,873" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[gpg batch]: https://gist.github.com/harding/78631dbcd65ff4a499e164c4e9dc85d4
[rubin dust]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019307.html
[corallo dust]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019308.html
[harding dust]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019310.html
[riard dust]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019327.html
[towns dust]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019333.html
[bitcoin core mempool limits]: /en/newsletters/2018/12/04/#fn:fn-cpfp-limits
[mempool package test accept]: /ja/newsletters/2021/06/02/#bitcoin-core-20833
[spark v0.3.0rc]: https://github.com/shesek/spark-wallet/releases/tag/v0.3.0rc
[spark github]: https://github.com/shesek/spark-wallet
[blockstream blog greenlight]: https://blockstream.com/2021/07/21/en-greenlight-by-blockstream-lightning-made-easy/
[sphinx website]: https://sphinx.chat/
[lastbit website]: https://gl.striga.com/
[bitgo blog segwit change]: https://blog.bitgo.com/native-segwit-change-outputs-for-bitcoin-c021406aaae2
[blockstream green desktop 0.1.10]: https://github.com/Blockstream/green_qt/releases/tag/release_0.1.10
[series preparing for taproot]: /ja/preparing-for-taproot/
