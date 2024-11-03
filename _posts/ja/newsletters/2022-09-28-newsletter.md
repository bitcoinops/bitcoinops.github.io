---
title: 'Bitcoin Optech Newsletter #219'
permalink: /ja/newsletters/2022/09/28/
name: 2022-09-28-newsletter-ja
slug: 2022-09-28-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNノードがキャパシティ依存の手数料率を配信できるようにする提案と、
signet上での主要なプロトコルの変更のテストにフォーカスしたBitcoin Coreソフトウェアのフォークの発表を掲載しています。
また、Bitcoin Stack Exchangeの人気のある質問と回答の概要や、
新しいリリースおよびリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **LN手数料のレートカード:** Lisa Neigutは、ノードが転送手数料について4段階の手数料率を配信できるようにする
  *手数料レートカード*の提案をLightning-Devメーリングリストに[投稿しました][neigut ratecards]。
  たとえば、支払いの転送により、その後の支払いを転送するために利用可能なアウトバウンドキャパシティの25%未満がチャネルに残る場合、
  利用可能なアウトバウンドキャパシティが75%残る支払いよりも比例して多くの手数料を支払う必要があります。

  開発者のZmnSCPxjは、レートカードの簡単な使用法を[説明しました][zmnscpxj ratecards]。
  「レートカードは、同じ２つのノード間で、それぞれ異なるコストを持つ4つの別々のチャネルとしてモデル化することができる。
  最も低コストのパスが失敗すると、ホップ数は増えるが実効コストの低い経路を試すか、より高いコストで同じチャネルを試す。」

  この提案では負の手数料も認めています。たとえば、あるチャネルが75%以上のアウトバウンドキャパシティを持っている場合、
  そのチャネル経由で転送された支払いに対して、支払額1,000 satoshi毎に1 satoshiを補助できます。
  マーチャントは、負の手数料を利用して、
  支払いの受け取りに頻繁に使用されるチャネルのインバウンドキャパシティを回復するよう他者にインセンティブを与えることができます。

  Neigutは、一部のノードは既にチャネルのキャパシティに応じて手数料を調整しており、
  手数料レートカードは、LNのゴシップネットワークを介して頻繁に新しい手数料率を配信するよりも、
  ノードオペレーターがネットワークに自分の意図を伝えるための効率的な方法になると指摘しています。

- **signetでソフトフォークをテストするために設計されたBitcoinの実装:**
  Anthony Townsは、彼が取り組んでいるBitcoin CoreのフォークについてBitcoin-Devメーリングリストに[投稿しました][towns bi]。
  このフォークは、デフォルト[signet][topic signet]上でのみ動作し、高品質な仕様と実装を備えたソフトフォークの提案のルールを適用します。
  これにより、ある変更と別の類似の変更を直接比較する（たとえば、[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]と
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]の比較）ことを含め、ユーザーが変更案を実験するのがより簡単になるはずです。
  Townsはまた、トランザクションのリレーポリシーに対する主要な変更案（[パッケージリレー][topic package relay]のような）も含める予定です。

  Townsは、[Bitcoin Inquisition][]と呼ばれるこの新しいテスト実装のアイディアについて、
  建設的な批判と、それにソフトフォークの初期セットとして追加する[プルリクエスト][bi prs]のレビューを求めています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--is-it-possible-to-determine-whether-an-hd-wallet-was-used-to-create-a-given-transaction-->あるトランザクションの作成にHDウォレットが使われたかどうかを判断することは可能ですか？]({{bse}}115311)
  Pieter Wuilleは、[HDウォレット][topic bip32]を使って作られたUTXOを識別することはできないが、
  その他のオンチェーンデータを使えば、使用したインプットの種類、作成されたアウトプットの種類、トランザクション内の各インプットとアウトプットの順序、
  [コイン選択][topic coin selection]アルゴリズム、[タイムロック][topic timelocks]の使用など、
  ウォレットソフトウェアを特定するのは可能であると指摘しています。

- [<!--why-is-there-a-5-day-gap-between-the-genesis-block-and-block-1-->ジェネシスブロックとブロック１との間に5日間のギャップがあるのは何故ですか？]({{bse}}115344)
  Murchは、時系列のギャップは、ジェネシスブロックが必要以上に高い難易度を設定していたこと、
  Satoshiがブロックのタイムスタンプを過去に設定していたこと、
  または[オリジナルのBitcoinソフトウェア][github jrubin annotated]がマイニングを始まる前にピアを待っていたことで説明できると指摘しています。

- [<!--is-it-possible-to-set-rbf-as-always-on-in-bitcoind-->bitcoindでRBFを常時オンに設定することは可能ですか？]({{bse}}115360)
  Michael FolksonとMurchは、`walletrbf`設定オプションについて説明し、
  GUIでの[RBF][topic rbf]のデフォルト設定や、RPCでのRBFのデフォルト設定、
  [`mempoolfullrbf`][news208 mempoolfullrbf]を使用した通知なしの置換を可能にすることについて、
  一連の変更点を挙げています。

- [<!--why-would-i-need-to-ban-peer-nodes-on-the-bitcoin-network-->Bitcoinネットワークでピアノードを禁止する必要があるのは何故ですか？]({{bse}}115183)
  [ピアを阻止するのとは対照的に][bitcoin 23.x banman]、
  ユーザーRedGrittyBrickは、ピアが誤動作をしていたり、悪意あるノードもしくは監視ノードの疑いがあったり、
  クラウドプロバイダーのネットワークの一部であるなどの理由があれば、
  ノードオペレーターは[`setban`][setban rpc] RPCを使ってピアを手動で禁止することを選択できると説明しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 0.12.1][]は、いくつかのバグ修正を含むメンテナンスリリースです。

- [Bitcoin Core 24.0 RC1][]は、ネットワークで最も広く使われているフルノード実装の次期バージョンの最初のリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #26116][]では、ウォレットの秘密鍵が暗号化されていても、
  `importmulti` RPCで監視用のアイテムをインポートできるようになりました。
  これは、古い`importaddress` RPCの動作と一致します。

- [Core Lightning #5594][]では、`autoclean`プラグインが古くなったインボイスや支払いおよび転送された支払いを削除できるように、
  いくつかのAPIの追加と更新を含む、いくつかの変更を行いました。

- [Core Lightning #5315][]では、特定のチャネルに対する*チャネルリザーブ*を選択できるようになりました。
  リザーブは通常、ノードが支払いまたは転送の一部としてチャネルピアから受け入れない金額のことです。
  もし後でピアが不正をしようとした場合、正直なノードはこのリザーブを使用できます。
  Core Lightningはデフォルトでチャネル残高の1%をチャネルリザーブとし、不正を行おうとするピアにその金額のペナルティを課します。

  このマージされたPRでは、ユーザーが特定のチャネルのリザーブを減らすことができ、ゼロにすることも可能です。
  リザーブを低くするほど、不正に対するペナルティが低くなり危険になりますが、ある種の状況下では有用です。
  特に、リザーブをゼロに設定すると、リモートピアがすべての資金を使用し、チャネルを空にすることができます。

- [Rust Bitcoin #1258][]は、2つのロックタイムを比較し、一方が他方を満たしているかどうかを判断するメソッドを追加しました。
  コードのコメントにあるように、「ロックタイムは、マイニングされてからnブロックもしくはn秒経過した際に満たされます。
  2つのロックタイム（同じ単位）がある場合に、大きい方のロックタイムが満たされれば、
  それは小さい方のロックタイムも満たされることを意味します（数学的な意味で）。この関数は、
  あるロックタイムを他のさまざまなロックとチェックしたい場合（たとえば満たせないロックタイムをフィルタリングしたい場合など）に便利です。
  また、スクリプトの1つのブランチ内に2つの`OP_CHECKLOCKTIMEVERIFY`操作の小さい方の値を除くのに使用することもできます。」

{% include references.md %}
{% include linkers/issues.md v=2 issues="26116,5594,5315,1258" %}
[bitcoin core 24.0 rc1]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[Core Lightning 0.12.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.1
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin/
[bi prs]: https://github.com/bitcoin-inquisition/bitcoin/pulls
[neigut ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003685.html
[zmnscpxj ratecards]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-September/003688.html
[towns bi]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020921.html
[github jrubin annotated]: https://github.com/JeremyRubin/satoshis-version/blob/master/src/main.cpp#L2255
[news208 mempoolfullrbf]: /ja/newsletters/2022/07/13/#bitcoin-core-25353
[bitcoin 23.x banman]: https://github.com/bitcoin/bitcoin/blob/23.x/src/banman.h#L28
[setban rpc]: https://github.com/bitcoin/bitcoin/blob/97f865bb76a9c9e8e42e4ee1227615c9c30889a6/src/rpc/net.cpp#L675
