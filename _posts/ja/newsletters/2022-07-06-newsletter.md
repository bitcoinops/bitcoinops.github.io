---
title: 'Bitcoin Optech Newsletter #207'
permalink: /ja/newsletters/2022/07/06/
name: 2022-07-06-newsletter-ja
slug: 2022-07-06-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、長期的なブロック報酬の調達、BIP47の再利用可能なペイメントコードの代替案、
LNチャネルのスプライスを通知するためのオプション、
LNルーティング手数料の徴収戦略およびオニオンメッセージのレート制限について掲載しています。
また、新しいソフトウェアリリースおよびリリース候補の発表や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点など、恒例のセクションも含まれています。

## ニュース

- **<!--long-term-block-reward-funding-->長期的なブロック報酬の調達:** 表向きは[Covenants][topic covenants]に関するBitcoin-Devメーリングリストのスレッドで、
  Bitcoinの長期的なセキュリティは、現在ブロックスペースの需要に依存しているという指摘がありました。
  その需要は、攻撃者がBitcoinユーザーを混乱させるために購入しようとする金額を超える、
  Proof of Work（PoW）に対して支払うトランザクション手数料を生み出す必要があます。
  開発者のPeter Toddは、Bitcoinプロトコルが永続的な報酬を生むように修正されれば、
  この依存性を取り除くことができると[指摘しました][todd subsidy]。
  何人かの回答者は、永続的な報酬が無い方が良いと考えていることを示し、
  他の回答者は、代替案や[デマレージ][demurrage]などの明白な同等物を挙げました。

  この記事を書いている時点では、このスレッドは、
  近い将来にBitcoinを変更するための特定の提案を支持するというよりも、
  カジュアルな会話で構成されているようでした。

- **BIP47の再利用可能なペイメントコードの代替案のアップデート:**
  開発者のAlfred Hodlerは、運用環境での使用中に発見されたいくつかの問題に対処しようとする[BIP47][]の代替案を
  Bitcoin-Devメーリングリストに[投稿しました][hodler new codes]。
  BIP47では、アリスがペイメントコードを公開し、誰でもそれを自分の鍵と組み合わせて使用することで、
  自分とアリスしか知らないアリスのプライベートアドレスを無制限に作成することができ、
  [アドレスの再利用][topic output linking]という最悪の問題を回避することができます。

  しかし、BIP47の問題の1つは、支払い者のボブから受信者のアリスへの最初のトランザクションが、
  ペイメントコードに関連付けられた特別なアドレスを使用する*通知トランザクション*であるということです。
  これは、アリスのペイメントコードを知っている第三者に、誰かが支払いを始める予定であることが確実に漏れます。
  もし、ボブのウォレットが通知トランザクションに使用される資金を分離するよう慎重に設計されていない場合、
  そのトランザクションは、ボブがアリスに対して支払いをしようとしていることを漏らすかもしれません。
  これは、BIP47のメリットを減らす、あるいは無くすことになるかもしれません。

  Hodlerの方式は、この情報を漏らす可能性は低くなりますが、
  このプロトコルを実装するクライアントがブロックチェーンから学習する必要のあるデータ量が増えるため、
  軽量クライアントには不向きです。Ruben Somsenは、
  Somsenのサイレントペイメントのアイディア（[ニュースレター #194][news194 silent payments]参照）、
  Robin Linusの[2022年のステルスアドレス][2022 stealth addresses]のアイディア、
  BIP47の改良についてメーリングリストに投稿された[過去の議論][prauge bip47]など、
  調査可能ないくつかの代替案を示しました。

- **<!--announcing-splices-->スプライスの通知:**
  Lightning-Devメーリングリストの[PR][bolts #1004]と[議論][osuntokun splice]において、
  開発者は、オンチェーンで閉じられたように見えるチャネルが、
  実際はチャネルに資金が追加または削除された[スプライス][topic splicing]であることを伝える最良の方法について議論しました。

  1つの提案は、オンチェーンでクロージング・トランザクションが確認されてからある程度の時間が経つまで、
  ノードはチャネルを閉じたとみなさないというものでした。これにより、
  新しい（スプライス後の）チャネルの通知が伝播するするための時間が与えられます。
  スプライスされたチャネルは、新しいチャネルを開くトランザクションが適切な数の承認を受ける前でも、
  完全なLNのセキュリティで支払いを転送できるため、
  その間、ノードは閉じられたように見えるチャネルを通じて支払いをルーティングしようとします。

  もう1つの提案は、クロージング・トランザクションの一部として、
  スプライスが進行中であることを示すシグナルをオンチェーンに含め、
  ノードにそれを通じて支払いの転送の試みを継続できることを伝えるというものでした。

  この要約が書かれた時点では、議論は明確な結論に至っていません。

- **LN転送ノードの基本的な手数料徴収戦略:** 開発者ZmnSCPxjは、
  LN転送ノードがルーティング支払いの手数料を徴収する際に使える3つの戦略
  （手数料を徴収しない戦略を含む）を[まとめました][zmnscpxj forwarding]。
  そして、ZmnSCPxjは、異なる戦略によって起こりうる結果を分析しています。
  これは、[ニュースレター #204][news204 fee signal]に掲載した、
  支払いの成功率を向上させるためにノードがルーティング手数料を使用するという彼の提案に関連しているようで、
  この1週間でAnthony Townsからも重要な[追加のコメント][towns fee signal]が寄せられています。

- **<!--onion-message-rate-limiting-->オニオンメッセージのレート制限:** Bastien Teinturierは、
  Rusty Russellが提案した[オニオンメッセージ][topic onion messages]の制限に関するアイディアの要約を[投稿しました][teinturier rate limit]。
  この提案では、各ノードが各ピア毎に32バイトの情報を追加で保存し、
  過剰なトラフィックを送信するピアに確率的にペナルティを与えることができます。
  提案されたペナルティは、過剰なトラフィックを中継するピアのレート制限を約30秒間半減させるというものです。
  この軽量なペナルティは、このアイディアで起こりうるように、時折間違ったピアに対して適用されることがあっても許容できます。
  この提案では、メッセージの発信者は、どの下流のノードがメッセージをレート制限しているかを（これも確率的に）知ることができ、
  別のルートでメッセージを再送信する機会を得ます。

  Olaoluwa Osuntokunは、データ中継に課金することでオニオンメッセージの悪用を防ぐという
  彼の以前の提案（[ニュースレター #190][news190 onion pay]参照）の再考を[提案しました][osuntokun onion pay]。
  この記事を書いている時点では、他の開発者からの回答は、
  オニオンメッセージに対する支払いという複雑な方法を追加する前に、
  まず軽量なレート制限を試して、それがうまくいくかどうか確認することが望ましいとしています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LDK 0.0.109][]は、このLNノードライブラリの新しいリリースで、
  以下の*注目すべき変更*のセクションでLDKについて説明されている両方の新機能が含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #24836][]は、
  将来[パケージリレー][topic package relay]を使用する予定のL2プロトコルおよびアプリケーション開発者が、
  Bitcoin Coreのデフォルトのパッケージポリシーに対してトランザクションをテストできるように、
  regtest専用のRPCである`submitpackage`を追加しました。
  現在のポリシーは[ここに][packages doc]まとめられています。
  このRPCは、提案中のパッケージRBFルールなど、将来の追加や変更をテストするためにも使用できます。

- [Bitcoin Core #22558][]は、[Taproot][topic taproot]用の[BIP371][]の追加の[PSBT][topic psbt]
  フィールド（[ニュースレター #155][news155 psbt extensions]参照）のサポートを追加しました。

- [Core Lightning #5281][]は、複数のログファイルに書き込むために`log-file`設定オプションを複数回設定できるようにしました。

- [LDK #1555][]は、経路探索のコードをアップデートし、
  チャネルにコミットされた金額の半分以上の支払いを受け入れないと宣言しているチャネルを経由するルーティングをわずかに優先するようにしました。
  これは、第三者がチャネルを探査する（決済するつもりのない支払い（[HTLC][topic htlc]）を送信する）ことで発見できる残高情報の量を制限することで、
  プライバシーをわずかに向上させると考えられています。
  もし、チャネルの合計額までの支払いのセットが送信可能であれば、探索者は異なる支払いのセットを、全てが受け入れられるまで試すことで、
  チャネルのほぼ正確な残高を知ることができます。しかし、送信可能な支払いのセットがチャネル残高の半分に制限されている場合、
  探索者は、チャネルの一方が資金不足のために支払いが拒否されているのか、
  それとも自ら課した制限（`max_htlc_in_flight_msat`の制限）のために拒否されているのかを判断するのが困難になります。
  [BOLT2][]の`max_htlc_in_flight_msat`の制限はゴシップされないため、
  LDKは代わりに各チャネルでゴシップされた[BOLT7][]の`htlc_maximum_msat`の値を代替値として使用します。

- [LDK #1550][]は、ローカルの禁止リストにノードを追加する機能を提供し、
  これらのノードを経由した支払いの経路探索を防止します。

- [LND #6592][]は、サブサーバーに新しい`requiredreserve`RPCを追加し、
  ウォレットが一方的にコントロールするUTXOでリザーブしているsatoshiの量を出力し、
  必要に応じて[Anchor Output][topic anchor outputs]による手数料の引き上げを行うようにしました。
  追加の`--additionalChannels` RPCパラメーターは、整数の引数を取り、
  その数の追加のチャネルが開設された場合にウォレットがリザーブするsatoshiの量をレポートします。

- [Rust Bitcoin #1024][]は、開発者が[`SIGHASH_SINGLE` "バグ"][shs1]を回避するのに役立つコードを追加しました。
  これは、Bitcoinのプロトコルで、`SIGHASH_SINGLE`の署名を含むインプットが、
  トランザクション内のアウトプットのインデックス番号よりも大きい場合に、値`1`に署名されることを想定するものです。

- [BTCPay Server #3709][]は、[LNURLの引き出し][LNURL withdraw]によって受け取られるプルペイメントをサポートしました。

- [BDK #611][]は、新しいトランザクションのnLockTimeをデフォルトで最新ブロックの高さに設定し、
  [アンチ・フィー・スナイピング][topic fee sniping]を有効にしました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="24836,22558,5281,1555,1550,1024,3709,611,1004,6592" %}
[ldk 0.0.109]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.109
[lnurl withdraw]: https://github.com/fiatjaf/lnurl-rfc/blob/luds/03.md
[todd subsidy]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020551.html
[hodler new codes]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020605.html
[news194 silent payments]: /ja/newsletters/2022/04/06/#delinked-reusable-addresses
[prauge bip47]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020549.html
[osuntokun splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003616.html
[zmnscpxj forwarding]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003617.html
[news204 fee signal]: /ja/newsletters/2022/06/15/#using-routing-fees-to-signal-liquidity
[towns fee signal]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003624.html
[teinturier rate limit]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003623.html
[osuntokun onion pay]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003631.html
[news190 onion pay]: /ja/newsletters/2022/03/09/#onion
[2022 stealth addresses]: https://gist.github.com/RobinLinus/4e7467abaf0a0f8a521d5b512dca4833
[demurrage]: https://en.wikipedia.org/wiki/Demurrage_%28currency%29
[shs1]: https://www.coinspect.com/capture-coins-challenge-1-sighashsingle/
[packages doc]: https://github.com/bitcoin/bitcoin/blob/09f32cffa6c3e8b2d77281a5983ffe8f482a5945/doc/policy/packages.md
[news155 psbt extensions]: /ja/newsletters/2021/06/30/#taproot-psbt
