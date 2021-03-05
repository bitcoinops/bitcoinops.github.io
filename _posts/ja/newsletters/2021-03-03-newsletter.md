---
title: 'Bitcoin Optech Newsletter #138'
permalink: /ja/newsletters/2021/03/03/
name: 2021-03-03-newsletter-ja
slug: 2021-03-03-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、BIP70のペイメントプロトコルの一部の機能について期待される代替案に関する議論と、
Discreet Log Contract (DLC)の不正の証明（Fraud Proof）を交換するための標準化された方法の提案の要約を掲載しています。
また、新しいソフトウェアリリースや利用可能なリリース候補、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき変更点について説明する通常のセクションも含まれています。

## ニュース

- **<!--discussion-about-a-bip70-replacement-->BIP70の代替に関する議論:**
  Thomas Voegtlinは、[BIP70][]ペイメントプロトコルの一部の機能、
  特に署名された支払い要求を受信する機能の代替について、
  Bitcoin-Devメーリングリストで[スレッド][voegtlin bip70 alt]を開始しました。
  Voegtlinは、彼が支払いをしたアドレスが実際に（取引所などの）
  受信者によって提供されたアドレスであることを証明できるようにしたいと考えています。
  Charles HillとAndrew Kozlikは、それぞれが取り組んでいるプロトコルに関する情報を返信しました。
  Hillの[スキーム][hill scheme]は、[LNURL][]での使用を意図したものですが、
  Voegtlinの意図したユースケースに再利用することができます。Kozlikの[スキーム][kozlik scheme]は、
  BIP70の精神に近いものの、[X.509証明書][X.509 certificates]の使用をやめ、
  取引所ベースのコインスワップの機能（例：BTCをアルトコインと取引する、もしくはその逆）を追加します。

- **<!--fraud-proofs-in-the-v0-discreet-log-contract-dlc-specification-->v0 Discreet Log Contract (DLC)の仕様における不正の証明:**
  Thibaut Le Guillyは、バージョン0のDLCの仕様に不正の証明を含めるという[目標][dlcv0 fraud proofs]について、
  DLC-devメーリングリストで[議論][le guilly post]を開始しました。そこでは2種類の不正について議論されました:

    - *<!--equivocation-->多義性:* オラクルが同じイベントに複数回署名し、矛盾する結果を生成する不正。
      この不正の証明は、第三者を信用することなく、ソフトウェアによって自動的に検証できます。

    - *<!--lying-->偽り:* オラクルが、ユーザーが間違いだと分かっている結果に署名する不正。
      これはほとんどの場合、ユーザーのコントラクトソフトウェアが利用できない証拠に依存するため、
      この種の不正の証明は、元のコントラクトとオラクルが署名した結果を比較できるユーザーが、
      手動で検証する必要があります。

    議論の参加者は全員、v0の仕様に対して手間がかかりすぎるのではないかという懸念がありましたが、
    多義性に対する証明の提供に賛成しているようでした。中間段階の解決策として、
    偽りに対する不正の証明へ焦点をあてる提案がされました。
    これらの証明の形式が確立されると、ソフトウェアを更新して、
    同じオラクルとイベントに対する2つの偽りに対する不正の証明を利用して、多義性の証明を作成できるようになります

    偽りの証明に関する１つの懸念事項は、ユーザーが偽の証明によってスパムを受け、
    偽の証明の検証に時間を浪費するか、不正の証明の検証を完全に放棄せざるをえなくなる可能性があることです。
    反論には、オンチェーン・トランザクションから証明の一部を取得できること（誰かがオンチェーン手数料を支払う必要がある）、
    ユーザーが不正の証明をダウンロードする場所を選択でき、
    正確な情報のみを配信することで知られているソースから取得することを好むことが含まれていました。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #16546][]では、新しい署名者用のインターフェースが導入され、
  Bitcoin Coreが、[HWI][topic hwi]や同じインターフェースを実装した他のアプリケーションを介して、
  外部のハードウェア署名デバイスと連携できるようになりました。

    Bitcoin Coreは、[Bitcoin Core バージョン 0.18以降][hwi release]、
    HWIを使用してハードウェア署名者と連携できるようになりました。
    しかし、このPRまでは、Bitcoin CoreとHWIの間でデータを転送するのにコマンドラインを[使用する必要がありました][hwi old process]。
    このPRでは、Bitcoin CoreがHWIと直接通信できるようにすることで、ユーザーエクスペリエンスを簡単にします。
    このPRには、HWIと新しい署名者用インターフェースを使用する方法について[完全なドキュメント][hwi new process]が含まれています。

    新しい署名者用インターフェースは、現在のところRPCでしかアクセスできません。
    GUIに署名者用インターフェースのサポートを追加する[PRのドラフト][signer gui]では、
    コマンドラインを使用することなくBitcoin Coreでハードウェア署名者を使用できるようになっています。

- [Rust-Lightning #791][]は、
  起動時に`BlockSource`インターフェースをポーリングしてブロックとヘッダーを同期するためのサポートを追加し、
  同期中にフォークを検出します。[ニュースレター #135][news135 blocksource]で説明したように、BlockSourceを使用すると、
  ソフトウェアが標準的なBitcoin Core互換ノード以外のソースからデータを取得できるようになるため、
  [エクリプス攻撃][topic eclipse attacks]や他のセキュリティ問題を防ぐのに役立つ冗長性が得られます。

- [Rust-Lightning #794][]では、シャットダウン開始時に将来のsegwitバージョンを許可する
  [BOLT2][]の`option_shutdown_anysegwit`機能のサポートを有効にします。
  `option_shutdown_anysegwit`がネゴシエートされた場合、
  チャネルを閉じるためにシャットダウンメッセージを送信するチャネル参加者は、
  *version byte*（`OP_1`から`OP_16`の1バイトのプッシュopcode）に
  *witness program*（2〜40バイトのバイトベクトルのプッシュ）が続く標準的な[BIP141][] witness program形式に準拠している
  支払い用のscriptpubkeyを送信することができます。
  これらのシャットダウンスクリプトは、高額な手数料がかかるスクリプトや
  非標準であるため伝播しない巨大なスクリプトを持つトランザクションを避けるため、標準形式に限定されています。
  （2019年11月にリリースされた）Bitcoin Core 0.19.0.1で任意のsegwitスクリプトへの支払いの中継が[可能に][0.19.0 segwit]なったため、
  LNの標準形式に[それらを含める][bolts #672]のが安全になりました。

- [HWI #413][]、[#469][hwi #469]、[#463][hwi #463]、[#464][hwi #464]、
  [#471][hwi #471]、[#468][hwi #468]および[#466][hwi #466]では、
  HWIのドキュメントが大幅に更新、拡張されています。特に注目すべき変更点は、
  [ReadTheDocs.io][hwi rtd]上のドキュメントへのリンク、新規のまた更新された[例][hwi examples]、
  新しいデバイスがHWIにサポートされるために満たすべき基準を記述した新しい[ポリシー][hwi policy]などです。

- [Rust Bitcoin #573][]では、新しいメソッド`SigHashType::from_u32_standard`を追加し、
  提供されたsighashバイトがBitcoin Coreがデフォルトで中継、マイニングする[標準の値][sighash types]の１つであることを保証します。
  各署名のsighashバイトは、トランザクションのどの部分に署名する必要があるかを示します。
  Bitcoinのコンセンサスルールでは、非標準のsighash値は`SIGHASH_ALL`と同等の値として扱われると規定されていますが、
  デフォルトでそれらは中継したりマイニングされないという事実は、理論的に、
  オフチェーンのコミットメントを使用しているソフトウェアを騙し強制力のない支払いを受け入れさせるのに使用することができます。
  Rust Bitcoinを使用しているそのようなソフトウェアの開発者は、
  コンセンサスで有効な任意のsighashバイトを受け入れる`SigHashType::from_u32`メソッドから、
  この新しいメソッドに切り替えることができます。

- [BIPs #1069][]は、[BIP8][]を更新し、アクティベーションの閾値を設定可能にし、
  最近の[Taprootのアクティベーションの議論][news137 taproot activation]に基づいて、
  以前の95%から減少して90%を推奨値として含めるようにしました。

{% include references.md %}
{% include linkers/issues.md issues="16546,573,791,794,413,469,463,464,471,468,466,1069,672" %}
[voegtlin bip70 alt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018443.html
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[hill scheme]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018446.html
[kozlik scheme]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018448.html
[le guilly post]: https://mailmanlists.org/pipermail/dlc-dev/2021-February/000020.html
[dlcv0 fraud proofs]: https://github.com/discreetlogcontracts/dlcspecs/blob/master/v0Milestone.md#simple-fraud-proofs-in-progress
[hwi old process]: https://github.com/bitcoin-core/HWI/blob/7b34fc72c5b2c5af216d8b8d5cd2d2c92b6d2457/docs/examples/bitcoin-core-usage.rst
[hwi release]: /en/newsletters/2019/05/07/#basic-hardware-signer-support-through-independent-tool
[hwi new process]: https://github.com/bitcoin/bitcoin/blob/master/doc/external-signer.md
[signer gui]: https://github.com/bitcoin-core/gui/pull/4
[hwi rtd]: https://hwi.readthedocs.io/en/latest/?badge=latest
[hwi examples]: https://hwi.readthedocs.io/en/latest/examples/index.html
[hwi policy]: https://hwi.readthedocs.io/en/latest/devices/index.html#support-policy
[X.509 certificates]: https://ja.wikipedia.org/wiki/X.509
[sighash types]: https://btcinformation.org/en/developer-guide#signature-hash-types
[news137 taproot activation]: /ja/newsletters/2021/02/24/#taproot
[news135 blocksource]: /ja/newsletters/2021/02/10/#rust-lightning-774
[0.19.0 segwit]: https://bitcoincore.org/ja/releases/0.19.0.1/#mempool-and-transaction-relay
