---
title: 'Bitcoin Optech Newsletter #273'
permalink: /ja/newsletters/2023/10/18/
name: 2023-10-18-newsletter-ja
slug: 2023-10-18-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNユーザーに影響する最近のセキュリティの開示について言及し、
任意のプログラムを実行した結果に応じて支払いを行うことに関する論文および、
MuSig2用のPSBTフィールドのBIP提案の発表を掲載しています。
また、クライアントとサービスの改善や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **LNに影響する問題のセキュリティ開示:** Antoine Riardは、
  BitcoinプロトコルおよびさまざまなLN実装に取り組む開発者に以前[責任を持って開示した][topic responsible disclosures]問題の
  完全な開示をBitcoin-DevメーリングリストおよびLightning-Devメーリングリストに[投稿しました。][riard cve]
  Core Lightning、Eclair、LDK、LNDの最新バージョンはすべて、
  根本的な懸念を排除するものではありませんが、攻撃の実用性を低下させる緩和策を含んでいます。

    この情報開示は、Optechの通常のニュースの締め切り後に行われたため、
    今週のニュースレターでは、上記リンクのみを提供します
    来週のニュースレーターで、概要をお届けします。

- **<!--payments-contingent-on-arbitrary-computation-->任意の計算を条件にした支払い:** Robin Linusは、
  _BitVM_ について書いた[論文][linus paper]をBitcoin-Devメーリングリストに[投稿しました][linus post]。
  BitVMは、任意のプログラムが正常に実行されたことを証明することに成功した人にビットコインを支払えるようにする方法の組み合わせです。
  注目すべきは、これは現在のBitcoinで可能であり、コンセンサスの変更は必要ないということです。

    Bitcoinのよく知られた機能は、スクリプトに関連付けられたビットコインを使用するために、
    誰かが（_Script_ と呼ばれる）プログラム式を満たすことを要求します。たとえば、
    公開鍵を含むスクリプトは、対応する秘密鍵で支払いトランザクションにコミットする署名を作成する場合のみそれが満たされます。
    スクリプトはコンセンサスによって強制されるため、（_Script_ と呼ばれる）Bitcoinの言語で書かなければなりませんが、
    Scriptは意図的に柔軟性が制限されています。

    Linusの論文は、その制限の一部を回避しています。アリスは、
    プログラムが正しく実行されなかった場合にボブが行動を起こすことを信頼しますが、
    それ以外のことについてボブを信頼したくない場合、アリスは資金を[Taproot][topic taproot]ツリーに支払うことができます。
    このツリーでは、アリスが任意のプログラムを正しく実行するのに失敗したことをボブが実証できたら、ボブはその資金を請求できるようになります。
    アリスが正しくプログラムを実行した場合、ボブがアリスを止めようとしてもアリスは資金を使用することができます。

    任意のプログラムを使用するためには、それを非常に基本的なプリミティブ（[NANDゲート][NAND gate]）に分解し、
    ゲート毎にコミットメントを作成する必要があります。これには、とても大量のデータ（
    かなり基本的なプログラムであっても数GBになる可能性があります）をオフチェーンで交換する必要があります。
    しかし、アリスがプログラムを正しく実行したことをボブが同意した場合、必要なのは1つのオンチェーントランザクションのみです。
    ボブが同意しない場合は、比較的少数のオンチェーントランザクションでアリスの失敗を実証できるはずです。
    セットアップがアリスとボブのペイメントチャネルで行われた場合、チャネルのセットアップと、
    ボブがアリスが任意のプログラムロジックを正しく実行するのに失敗したことを実証しようとする協調クローズもしくは強制クローズのいずれかを除いて、
    オンチェーンのフットプリントなしで、複数のプログラムを並行にも順番にも実行できます。

    BitVMは、アリスとボブが敵対関係であるような場合、
    たとえばチェスのゲームに勝った方に資金が支払われるアウトプットに資金を支払うような場合に、
    これをトラストレスに行えます。両者は2つの（ほとんど同じ）任意のプログラムを使用し、
    それぞれが同じ任意のチェスの手を実行します。
    一方のプログラムはアリスが勝った場合にtrueを返し、もう一方のプログラムはボブが勝った場合にtrueを返します。
    次にどちらか一方が、自分のプログラムがtrueと評価された（自分が勝った）と主張するトランザクションをオンチェーンで公開します。
    相手は、その主張を受け入れるか（資金の損失を認めるか）、それが虚偽であることを証明します（成功した場合、資金を受け取れます）。
    アリスとボブが敵対関係にない場合、
    アリスはボブがアリスが正しく計算できなかったことを証明できれば資金ボブに提供するようにすることで、
    正しい計算を検証するようボブにインセンティブを与えることができます。

    このアイディアは、メーリングリストだけでなく、
    TwitterやBitcoinにフォーカスしたさまざまなポッドキャストでも多くの議論を呼びました。
    今後数週間、数ヶ月にわたって議論が続くことを期待しています。

- **MuSig2用のPSBTフィールドのBIP提案:** Andrew Chowは、
  Sanket Kanjalkarによる[先行作業][kanjalkar mpsbt]を一部ベースとした[BIPドラフト][mpsbt-bip]を
  Bitcoin-Devメーリングリストに[投稿しました][chow mpsbt]。
  この提案では、「[MuSig2][topic musig]で生成される鍵およびパブリックナンス、部分署名」用のいくつかのフィールドを
  全バージョンの[PSBT][topic psbt]に追加します。

  Anthony Townsは、提案されているBIPに[アダプター署名][topic adaptor signatures]用のフィールドも含めるかどうか
  [尋ねました][towns mpsbt]が、議論を続けた結果、おそらく別のBIPで定義する必要があることが示されました。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **BIP-329 Python Libraryリリース:**
  [BIP-329 Python Library][]は、[BIP329][]準拠のウォレットラベルファイルの読み取り、書き込み、
  暗号化および復号ができるツールのセットです。

- **LNテストツールDopplerの発表:**
  最近[発表された][doppler announced][Doppler][]は、LND、CLNおよびEclairの実装を一緒にテストするために、
  ドメイン固有言語（DSL）を使用してBitcoinおよびLightningノードのトポロジーと
  オンチェーン/オフチェーン支払いのアクティビティを定義することをサポートします。

- **Coldcard Mk4 v5.2.0リリース:**
  ファームウェアの[アップデート][coldcard blog]には、バージョン2[PSBT][topic psbt]の[BIP370][]サポートと、
  追加の[BIP39][]サポートおよびマルチシード機能が含まれれています。

- **Tapleaf circuits: BitVMのデモ:**
  [Tapleaf circuits][]は、ニュースレターの前半で説明したBitVMアプローチを使用したBristol回路の概念実証の実装です。

- **Samourai Wallet 0.99.98iリリース:**
  [0.99.98i][samourai blog]のリリースには、追加のPSBT、UTXOのラベル付および、バッチ送信機能が含まれています。

- **Krux: 署名デバイスファームウェア:**
  [Krux][krux github]は、汎用ハードウェアを使用してハードウェア署名デバイスを構築するためのオープンソースのファームウェアプロジェクトです。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 24.2rc2][]と[Bitcoin Core 25.1rc1][]は、
  Bitcoin Coreのメンテナンスバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #27255][]は、[miniscript][topic miniscript]を[tapscript][topic tapscript]に移植します。
  このコードの変更により、miniscriptがP2TR[アウトプット・ディスクリプター][topic descriptors]のオプションとなり、
  「TapMiniscript descriptors」の監視と署名の両方がサポートされるようになりました。
  これまでは、miniscriptはP2WSHのアウトプット・ディスクリプターでのみ利用可能でした。
  作者は、P2WSHディスクリプターにおける`multi`セマンティクスに合致する、
  P2TRディスクリプター専用の新しい`multi_a`フラグメントが導入されたことに言及しています。
  PRの議論では、作業の大部分は、Tapscriptのリソース制限の変更の適切な追跡のために行われました。

- [Eclair #2703][]は、ノードの残高が少なく、おそらく支払いを拒否する必要がある場合に、
  利用者がローカルノードを経由して支払いを転送するのを抑制します。
  これは、ノードがHTLCの上限額を下げたことをアドバタイズすることで実現されます。
  支払いの拒否を防ぐことで、支払人の体験を向上させ、
  最近の支払いの転送に失敗したノードを考慮する経路探索システムによってローカルノードがペナルティを受けるのを回避するのに役立ちます。

- [LND #7267][]は、[ブラインド・パス][topic rv routing]への経路を作成できるようにし、
  LNDのブラインドペイメントの完全なサポートに大きく近づきました。

- [BDK #1041][]は、プログラムのRPCインターフェースを使用して、
  Bitcoin Coreからブロックチェーンのデータを取得するためのモジュールを追加しました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27255,2703,7267,1041" %}
[linus post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021984.html
[linus paper]: https://bitvm.org/bitvm.pdf
[nand gate]: https://ja.wikipedia.org/wiki/NANDゲート
[Bitcoin Core 24.2rc2]: https://bitcoincore.org/bin/bitcoin-core-24.2/
[Bitcoin Core 25.1rc1]: https://bitcoincore.org/bin/bitcoin-core-25.1/
[riard cve]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021999.html
[mpsbt-bip]: https://github.com/achow101/bips/blob/musig2-psbt/bip-musig2-psbt.mediawiki
[kanjalkar mpsbt]: https://gist.github.com/sanket1729/4b525c6049f4d9e034d27368c49f28a6
[chow mpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021988.html
[towns mpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/021991.html
[BIP-329 Python Library]: https://github.com/Labelbase/python-bip329
[Doppler]: https://github.com/tee8z/doppler
[doppler announced]: https://twitter.com/voltage_cloud/status/1712171748144070863
[coldcard blog]: https://blog.coinkite.com/5.2.0-seed-vault/
[Tapleaf circuits]: https://github.com/supertestnet/tapleaf-circuits
[samourai blog]: https://blog.samourai.is/wallet-update-0-99-98i/
[krux github]: https://github.com/selfcustody/krux
