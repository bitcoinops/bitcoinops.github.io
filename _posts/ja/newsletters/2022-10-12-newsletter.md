---
title: 'Bitcoin Optech Newsletter #221'
permalink: /ja/newsletters/2022/10/12/
name: 2022-10-12-newsletter-ja
slug: 2022-10-12-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、カジュアルなLNユーザーが一度に最大数ヶ月オフラインでいられるようにする提案と、
トランザクション情報サーバーが未使用のウォレットアドレスをホストできるようにすることに関するドキュメントを掲載しています。
また、Bitcoin Core PR Review Clubの概要や、新しいソフトウェアリリースおよびリリース候補の発表（重要なLNDの修正を含む）、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、恒例のセクションも含まれています。

## ニュース

- **タイムアウトの長いLNの提案:** John Lawは、
  カジュアルなライトニングユーザーが、チャネルパートナーとの間で資金を失うリスクなく最大数カ月間オフラインでいられるようにする[提案][law pdf]を
  Lightning-Devメーリングリストに[投稿しました][law post]。
  これは、現在のLNプロトコルでも技術的に可能ですが、清算の遅延パラメーターに高い値を設定する必要があり、
  嫌がらせをするユーザーや事故によって多数のチャネルが同じ期間使用できなくなります。
  Lawの提案は、2つのプロトコルの変更でこの問題を軽減します。:

  - *トリガーHTLC:* 支払いに使用する標準の[HTLC][topic htlc]では、
    既知のハッシュダイジェストに対して、ボブが未知の*プリイメージ*を公開できたら、
    アリスはボブにいくらかのBTCを提供します。もしくは、ボブがある時間までにプリイメージを公開しなければ、
    アリスはその資金を自分のウォレットに戻すことができます。

    Lawは、ボブは引き続きプリイメージを公開すればいつでも支払いを受けることができますが、
    アリスには追加の制限を課すことを提案しています。アリスは、オンチェーンで承認される*トリガー*トランザクションによって、
    自分のウォレットの資金を戻す意思をボブに明確に警告する必要があります。
    トリガートランザクションが一定のブロック数（もしくは時間）承認された場合のみ、アリスは資金を使用することができます。

    これにより、通常のHTLCがタイムアウトしてから数ヶ月経ったとしても、
    トリガートランザクションが合意した数の承認を得るまで、ボブがいつでも支払いを受けることができることを保証します。
    ボブは待ち時間に対して十分な補償があれば、アリスがその間オフラインのままであっても問題はないでしょう。
    アリスからボブを経由してルーティングされるHTLCについては、アリスとボブのチャネルのみが影響を受け、
    他のすべてのチャネルは（現在のLNプロトコルのように）速やかにHTLCを清算することになります。

  - *<!--asymmetric-delayed-commitment-transactions-->非対称の遅延コミットメントトランザクション:*
    LNチャネルの2人の参加者は、それぞれ未公開のコミットメントトランザクションを保持しており、
    いつでもそれを公開して承認させようとすることができます。
    この両者のトランザクションは同じUTXOを使用するため、競合します。つまり、実際に承認されるのはどちらか1つだけです。

    これは、アリスがチャネルを閉じたい場合に、単純に自分のコミットメントトランザクションを適切な手数料率でブロードキャストして、
    それが承認されると仮定することができないことを意味します。
    アリスは、ボブが代わりに彼のコミットメントトランザクションを承認させるかもしれないため、待機して確認する必要があります。
    この場合、ボブのトランザクションが最新のチャネル状態かどうか追加の確認をする必要があります。

    Lawは、アリスのコミットメントトランザクションは現在と同じままいつでも公開でき、
    ボブのトランザクションについてはタイムロックを含め、アリスが長期間アクティブでない場合にのみ公開できるようにすることを提案しています。
    理想的には、これによりアリスはボブが両立しないバージョンのトランザクションを公開できないことを認識して最新の状態を安全に公開することができ、
    公開後に安全にオフラインになることができます。

  Lawの提案は、この記事の執筆時点で、まだ初期のフィードバックを受けています。

- **<!--recommendations-for-unique-address-servers-->固有のアドレスサーバーについての推奨事項:** Ruben Somsenは、
  ユーザーがサードパーティのサービスを信頼したり、
  [BIP47][]や[Silent Payment][topic silent payments]など現在広くサポートされていない暗号プロトコルを使用したりすることなく、
  [アウトプットのリンク付け][topic output linking]を回避する方法について、別の提案を含む[ドキュメント][somsen gist]を
  Bitcoin-Devメーリングリストに[投稿しました][somsen post]。
  推奨される方法は、パブリックな[アドレスルックアップサーバー][topic block explorers]を使用しているウォレット（軽量ウォレットの大部分と考えられる）など、
  既にサードパーティにアドレスを提供しているウォレットを対象としています。

  この方法がどう機能するかの例として、アリスのウォレットがExample.comのelectrumスタイルのサーバーに100個のアドレスを登録したとします。
  次に、メールの署名に「example.com/alice」を含めます。
  ボブがアリスに寄付をしたい場合、彼はこのURLにアクセスしアドレスを入手し、
  アリスがそれに署名したことを確認してからそのアドレスに支払いをします。

  このアイディアは、一部の手動プロセスを介して多くのウォレットと互換性があり、
  おそらく自動化されたプロセスで簡単に実装できるという利点があります。
  欠点は、サーバーとアドレスを共有することで既にプライバシーを損なっているユーザーが、
  さらにプライバシーの喪失にコミットすることになることです。

  この要約が書かれている時点では、メーリングリストとドキュメントの両方で提案に関する議論が進行中でした。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Make AddrFetch connections to fixed seeds][review club 26114]は、Martin ZumsandeによるPRで、
`AddrMan`（ピアのデータベース）に追加するだけでなく、
[固定シード][fixed seeds]（ハードコードされたIPアドレス）への`AddrFetch`接続を作成します。

{% include functions/details-list.md
q0="<!--when-a-new-node-starts-up-from-scratch-it-must-first-connect-with-some-peers-from-whom-it-will-perform-initial-block-download-ibd-under-what-circumstances-does-it-connect-to-the-fixed-seeds-->
新しいノードがゼロから起動する際、最初にいくつかのピアと接続し、そこからIBD（Initial Block Download）を実行する必要があります。
どのような場合に固定シードに接続するのでしょうか？"
a0="ハードコードされたBitcoinのDNSシードノードから提供されるアドレスのピアに接続できない場合のみです。
これは、ノードがIPv4やIPv6を使用しないよう設定されている場合（例えば、`-onlynet=tor`）に最もよく発生します。"
a0link="https://bitcoincore.reviews/26114#l-27"

q1="<!--what-observable-behavior-change-does-this-pr-introduce-what-kinds-of-addresses-do-we-add-to-addrman-and-under-what-circumstances-->
このPRはどのような動作の変更をもたらしますか？どんな種類のアドレスをどんな状況下で`AddrMan`に追加するのですか？"
a1="ノードは、すぐに固定シードを`AddrMan`に追加しそれらのいくつかに完全な接続をするのではなく、
代わりにそれらのいくつかに`AddrFetch`接続を行い、返されたアドレスを`AddrMan`に追加します。
（`AddrFetch`はアドレスのフェッチのみに使用される短期接続です。）
その後、ノードは`AddrMan`内のいくつかのアドレスに接続し、IBDを実行します。
これにより、固定シードのノードへの完全な接続は少なくなり、
固定シードが教えるノードより大きなノードセットから、より多くの接続が試行されます。
`AddrFetch`接続は、例えば`tor`など、あらゆるタイプの接続を返すことができ、IPv4やIPv6に限定されません。"
a1link="https://bitcoincore.reviews/26114#l-63"

q2="<!--why-might-we-want-to-make-an-addrfetch-connection-instead-of-a-full-outbound-connection-to-fixed-seeds-why-might-the-node-operator-behind-a-fixed-seed-prefer-this-as-well-->
なぜ、固定シードへの完全なアウトバウンド接続より`AddrFetch`接続を行いたいのでしょうか？
固定シードのノードオペレーターがこれを好むのはなぜですか？"
a2="`AddrFetch`接続は、私達のノードがより大きなピアのセットからIBDピアを選択することを可能にし、
ネットワーク接続を全体的により分散させます。
固定シードのノードオペレーターは、同時に複数のIBDピアを持つ可能性が低くなり、
彼らのノードのリソース要件が減少します。"
a2link="https://bitcoincore.reviews/26114#l-77"

q3="<!--the-dns-seed-nodes-are-expected-to-be-responsive-and-serve-up-to-date-addresses-of-bitcoin-nodes-why-doesn-t-this-help-a-onlynet-tor-node-->
DNSシードは応答性が高く、Bitcoinノードの最新のアドレスを提供することが期待されます。
なぜこれが-onlynet=torのノードに役立たないのでしょうか？"
a3="TDNSシードノードは、IPv4およびIPv6アドレスのみを提供し、他の種類のアドレスは提供できません。"
a3link="https://bitcoincore.reviews/26114#l-35"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND v0.15.2-beta][]は、セキュリティ上重要な緊急リリースで、
  LNDが特定のブロックをパースできないパースエラーを修正しています。すべてのユーザーにアップグレードが必要です。

- [Bitcoin Core 24.0 RC1][]は、ネットワークで最も広く使われているフルノード実装の次期バージョンの最初のリリース候補です。
  [テストのガイド][bcc testing]が利用できるようになっています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [LND #6500][]では、Torの秘密鍵を平文で保存するのではなく、ウォレットの秘密鍵を使ってディスク上で暗号化する機能が追加されました。
  `--tor.encryptkey`フラグを使用すると、LNDは秘密鍵を暗号化し、暗号化Blobがディスク上の同じファイルに書き込まれます。
  これによりユーザーは同じ機能を維持しつつ（Hidden Serviceの参照など）、信頼されない環境で実行する際の保護を追加できます。

{% include references.md %}
{% include linkers/issues.md v=2 issues="6500" %}
[review club 26114]: https://bitcoincore.reviews/26114
[bitcoin core 24.0 rc1]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[law post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003707.html
[law pdf]: https://raw.githubusercontent.com/JohnLaw2/ln-watchtower-free/main/watchtowerfree10.pdf
[somsen post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020952.html
[somsen gist]: https://gist.github.com/RubenSomsen/960ae7eb52b79cc826d5b6eaa61291f6
[news113 witasym]: /en/newsletters/2020/09/02/#witness-asymmetric-payment-channels
[fixed seeds]: https://github.com/bitcoin/bitcoin/tree/master/contrib/seeds
[lnd v0.15.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.2-beta