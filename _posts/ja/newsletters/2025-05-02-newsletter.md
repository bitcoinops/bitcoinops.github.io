---
title: 'Bitcoin Optech Newsletter #352'
permalink: /ja/newsletters/2025/05/02/
name: 2025-05-02-newsletter-ja
slug: 2025-05-02-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、さまざまなクラスターリニアライゼーション手法の比較のリンクと、
Bitcoin Coreの`OP_RETURN`サイズ制限の増加または撤廃に関する議論の簡単な要約を掲載しています。
また、新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべきの変更点など、
恒例のセクションも含まれています。

## ニュース

- **<!--comparison-of-cluster-linearization-techniques-->クラスターリニアライゼーション手法の比較:**
  Pieter Wuilleは、3つの異なるクラスターリニアライゼーション手法間のトレードオフについてDelving Bitcoinに[投稿し][wuille clustrade]、
  それぞれの実装の[ベンチマーク結果][wuille clusbench]を共有しました。
  他の複数の開発者がその結果について議論し、質問を投げかけ、それにWuilleが回答しています。

- **Bitcoin Coreの`OP_RETURN`サイズ制限の引き上げまたは撤廃:**
  Bitcoin-Devメーリングリストのスレッドでは、
  複数の開発者がBitcoin Coreの`OP_RETURN`データキャリアアウトプットのデフォルト制限の変更または撤廃について議論しています。
  その後のBitcoin Coreの[プルリクエスト][bitcoin core #32359]でもさらに議論されました。
  ここでは、膨大な議論全体を要約するのではなく、変更に反対する賛否両論の意見の中で最も説得力のある議論要約します。

  - *<!--for-increasing-or-eliminating-the-limit-->制限の引き上げ（または撤廃）に賛成:*
    Pieter Wuilleは、トランザクションの標準ポリシーが、
    資金力がありマイナーに直接トランザクションを送信する組織によって作成された
    データキャリアトランザクションの承認を妨げる可能性は低いと[主張しました][wuille opr]。
    さらに、データキャリアトランザクションが含まれているかどうかに関わらず、
    ブロックは通常いっぱいであるため、ノードが保存する必要があるデータの総量はどちらの場合もほぼ同じであると主張しています。

  - *<!--against-increasing-the-limit-->制限の引き上げに反対:*
    Jason Hughesは、制限を引き上げることで、フルノードを実行するコンピュータに任意のデータを保存しやすくなり、
    そのデータの一部は非常に好ましくない（多くの地方で違法となる）可能性があると[主張しました][hughes opr]。
    ノードがディスク上のデータを暗号化したとしても（[ニュースレター #316][news316 blockxor]参照）、
    データの保存とBitcoin Core RPCを用いたデータの取得は、多くのユーザーにとって問題となる可能性があります。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND 0.19.0-beta.rc3][]は、この人気のLNノードのリリース候補です。
  おそらくテストが必要な主な改善の1つは、協調クローズにおける新しいRBFベースの手数料引き上げです。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31250][]は、レガシーウォレットの作成と読み込みを無効化し、
  2021年10月以降（ニュースレター[#172][news172 descriptors]参照）デフォルトとなっている
  [ディスクリプター][topic descriptors]ウォレットへの移行を完了します。
  レガシーウォレットで使用されていたBerkeley DBファイルは読み込みできなくなり、
  レガシーウォレットのすべての単体テストと機能テストは削除されます。
  一部のレガシーウォレットコードは残っていますが、後続のPRで削除される予定です。
  Bitcoin Coreは、レガシーウォレットを新しいディスクリプターウォレット形式に移行することも可能です（[ニュースレター #305][news305 bdbro]参照）。

- [Eclair #3064][]は、`ChannelKeys`クラスを導入することで、チャネルの鍵管理をリファクタリングします。
  各チャネルは独自の`ChannelKeys`オブジェクトを持つようになり、
  このオブジェクトはコミットメントポイントと組み合わせて、リモート/ローカル コミットメントおよび
  [HTLC][topic htlc]トランザクションの署名に使用する`CommitmentKeys`を導出します。
  強制閉鎖ロジックとスクリプト/witnessの作成も`CommitmentKeys`を使用するように更新されました。
  これまでは、外部署名者をサポートするために鍵生成がコードベースの複数のパーツに分散されていましたが、
  正しい公開鍵が提供されるようにするために型ではなく名前に依存していたため、エラーが発生しがちでした。

- [BTCPay Server #6684][]は、[BIP388][]ウォレットポリシー[ディスクリプター][topic descriptors]のサブセットをサポートし、
  シングルシグとk-of-nの両方のポリシーのインポートおよびエクスポートを可能にします。
  これには、SparrowがサポートするP2PKH、P2WPKH、P2SH-P2WPKHおよびP2TRといったフォーマットと、
  P2TRを除くマルチシグ版が含まれます。このPRの目標は、マルチシグウォレットの利用を改善することです。

- [BIPs #1555][]は、[BIP21][]を最新化し拡張したビットコインの支払い指示を記述するためのURIスキームを提案する
  [BIP321][]をマージしました。従来のパスベースのアドレスは維持しつつ、
  新しい支払い方法を独自のパラメーターで識別できるようにすることでクエリパラメーターの使用を標準化し、
  クエリパラメーターに少なくとも1つの指示が含まれる場合は、アドレスフィールドを空にできるようにします。
  また、受取人に支払いの証明を提供するためのオプションの拡張機能を追加し、
  新しい支払い指示を組み込む方法に関するガイダンスを提供します。

{% include snippets/recap-ad.md when="2025-05-06 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31250,3064,6684,1555,32359" %}
[lnd 0.19.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc3
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[wuille clusbench]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/73
[hughes opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/f4f6831a-d6b8-4f32-8a4e-c0669cc0a7b8n@googlegroups.com/
[wuille opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/QMywWcEgJgWmiQzASR17Dt42oLGgG-t3bkf0vzGemDVNVnvVaD64eM34nOQHlBLv8nDmeBEyTXvBUkM2hZEfjwMTrzzoLl1_62MYPz8ZThs=@wuille.net/
[news316 blockxor]: /ja/newsletters/2024/08/16/#bitcoin-core-28052
[news172 descriptors]: /ja/newsletters/2021/10/27/#bitcoin-core-23002
[news305 bdbro]: /ja/newsletters/2024/05/31/#bitcoin-core-26606