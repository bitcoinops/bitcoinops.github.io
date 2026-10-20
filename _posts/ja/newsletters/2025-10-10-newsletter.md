---
title: 'Bitcoin Optech Newsletter #375'
permalink: /ja/newsletters/2025/10/10/
name: 2025-10-10-newsletter-ja
slug: 2025-10-10-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、閾値署名におけるユーザビリティとセキュリティのトレードオフに関する研究と、
ネストされた閾値署名を単層の署名グループに変換するアプローチの概要、
制限されたルールセットの下でUTXOセットにデータを埋め込むことができる範囲の検証について掲載しています。
また、Bitcoin Core PR Review Clubミーティングの概要や、
新しいリリースとリリース候補の発表、人気のBitcoinインフラストラクチャプロジェクトにおける注目すべき更新など、
恒例のセクションも含まれています。

## ニュース

- **<!--optimal-threshold-signatures-->最適な閾値署名**:
  Sindura Saraswathiは、[マルチシグ][topic multisignature]方式で最適な閾値を決定するKorok Rayとの研究を
  Delving Bitcoinに[投稿しました][sindura post]。この研究では、
  ユーザビリティとセキュリティパラメーターおよび、それらの関係性、
  そしてそれらがユーザーが選択すべき閾値にどのように影響するかについて考察しています。
  p(τ)とq(τ)を定義し、それらを閉形式の解に組み合わせることで、
  セキュリティとユーザビリティの間のギャップを明らかにしています。
  Saraswathiはまた、初期段階では高い閾値を使用し、後の段階では徐々に閾値を下げる
  劣化型[閾値署名][topic threshold signature]の使用についても探求しています。
  これは時間の経過とともに攻撃者が資金を奪うためのアクセス権限を拡大することを意味します。
  また、[Taproot][topic taproot]を用いることで、
  Taptreeと[タイムロック][topic timelocks]やマルチシグを含むより複雑なコントラクトを通じて、
  これらの新しい可能性が利用可能になる可能性があるとも述べています。

- **<!--flattening-certain-nested-threshold-signatures-->特定のネストされた閾値署名のフラット化:**
  ZmnSCPxjは、安全性が証明されていない場合のネストされた[Schnorr署名][topic schnorr signatures]の使用を回避する方法について
  Delving Bitcoinに[投稿しました][zmnscpxj flat]。たとえばアリスが、
  ボブ、キャロル、ダンのグループと契約を締結するとします。すべての取引は、
  ボブ、キャロル、ダンのうち少なくとも2人とアリスの承認を得る必要があります。
  理論的には、これは[マルチシグ][topic multisignature]（例：[MuSig][topic musig]）で実現できます。
  アリスが1つの部分署名を提供し、[閾値署名][topic threshold signature]（例：FROST）を使って
  ボブ、キャロル、ダンがもう１つの部分署名を生成します。ただしZmnSCPxjは、
  「現時点ではFROST-in-MuSigが安全であるという証明はありません」と書いています。
  代わりに、ZmnSCPxjは閾値署名のみを使ってこの例を実現することができると指摘しています。
  アリスには複数のシェアが与えられます。充足数を妨げるのには十分なものの一方的には署名できない数です。
  他の署名者にはそれぞれ1つずつシェアが与えられます。

  この機能の用途としては、マルチオペレーターのステートチェーン、
  複数の署名デバイスを使用したいLNユーザー、そしてZmnSCPxjの
  LSP強化型の[冗長的過払い][topic redundant overpayments]の提案（
  [ニュースレター #372][news372 lspover]参照）などが挙げられます。

- **UTXOセットへのデータ埋め込みに関する理論的制限:** Adam "Waxwing" Gibsonは、
  Bitcoinトランザクションの制限的なルールセットの下で、
  どの程度までデータをUTXOセットに埋め込むことができるかについての[議論][gibson embed]をメーリングリストで開始しました。
  Gibsonが「ぞっとする」と表現する主な新ルールは、すべての[P2TR][topic taproot]アウトプットに、
  そのアウトプットが使用可能であることを証明する署名の添付を要求するというものです。
  Gibsonは、任意のデータを公開鍵として偽装できるようにこのルールを回避する方法は3つしかないことを証明しようとしています:

  1. Bitcoinの[Schnorr署名][topic schnorr signatures]が、
    たとえば誤った仮定に基づいているなど、破綻している場合。現時点では明らかにそういうことはありません。

  2. 公開鍵のグラインドによって少量の任意のデータを埋め込むことができる場合（
     つまり、多数の異なる秘密鍵を生成し、対応する公開鍵を導出し、
     抽出可能な方法でエンコードされた望ましいデータを含まない公開鍵を持つ秘密鍵をすべて破棄します）。
     この方法でUTXOセットに _n_ bitの任意のデータを含めるには、
     約2<sup>n</sup>の総当り計算が必要であり、アウトプットあたり数十 bit（数byte）を超える場合は非現実的です。

  3. 第三者が容易に計算できる秘密鍵を使用する場合。これは「秘密鍵の漏洩」の一種です。

  3つめのケースでは、秘密鍵の漏洩により、第三者がアウトプットを使用できるようになり、
  UTXOセットからアウトプットが削除される可能性があります。しかし、このスレッドへの返信では、
  Bitcoinのような洗練されたシステムではそれを回避できる可能性があると指摘されました。
  Anthony Townsからの[返信][towns embed]では、「システムを興味深い方法でプログラム可能にすれば、
  データの埋め込みはほぼ即座に可能になると思います。
  あとは、最適なエンコード率とトランザクションがどれだけ簡単に識別できるかのトレードオフの問題になります。
  ただし、データの効率を低下させてまでデータを隠蔽しようとすると、
  システムの他のユーザーが利用できるリソースが少なくなるだけで、私にはまったくメリットがないように思えます」と
  付け加えられています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Compact block harness][review club 33300]は[Crypt-iQ][gh crypt-iq]によるPRで、
[コンパクトブロックリレー][topic compact block relay]ロジック用のテストハーネスを追加することで
[ファジングテスト][fuzz readme]のカバレッジを向上させます。ファジングとは、
コードにランダムな入力を与え、バグや予期せぬ動作を発見するテスト方法です。

このPRはまた、テストハーネス実行時のパフォーマンスを向上させるために、
テスト専用の新しい`-fuzzcopydatadir`起動オプションも導入されています。

{% include functions/details-list.md
  q0="ファジングテストは、`high_bandwidth`をランダムに設定した`SENDCMPCT`メッセージを送信します。
  高帯域幅ピアは何台まで許可され、ファジングハーネスはこの制限をテストしますか？
  より一般的には、ピアが高帯域幅または低帯域幅を選択する理由は何ですか？"
  a0="高帯域幅ピアの場合、コンパクトブロックは通知なしで、検証が完了する前に送信されます。
  これにより、ブロックの伝播速度が大幅に向上します。帯域幅のオーバーヘッドを削減するため、
  ノードは高帯域幅モードでコンパクトブロックを送信するピアを最大3つまでしか選択しません。
  このモードは、`cmpctblock`ファジングターゲットでは特にテストされません。"
  a0link="https://bitcoincore.reviews/33300#l-66"
  q1="ハーネスの`create_block`を確認してください。生成されたブロックにはいくつのトランザクションが含まれ、
  それらはどこから取得されるのですか？ブロック内のトランザクションが少数の場合、
  どのようなコンパクトブロックのシナリオを見逃す可能性がありますか？"
  a1="生成されたブロックには1〜3個のトランザクションが含まれます。
  コインベーストランザクション（常に存在）、オプションでmempoolのトランザクション、
  オプションでmempoolにないトランザクションです。ブロックは少数のトランザクションに制限されているため、
  トランザクションが多いと発生しやすくなるショートIDの衝突処理のテストなど、
  一部のシナリオが見逃される可能性があります。Review Clubの参加者は、
  カバレッジを向上させるためにトランザクション数を増やすことを提案しました。"
  a1link="https://bitcoincore.reviews/33300#l-132"
  q2="コミット[ed813c4][review-club ed813c4]は、ポインタアドレスではなく
  ブロックハッシュで`m_dirty_blockindex`をソートします。これはどのような非決定性を修正するのでしょうか？
  作者は、これによりプロダクションコードの速度は低下するが、
  プロダクション版のメリットはないと[指摘しています][q1 note]。
  なぜここで[`EnableFuzzDeterminism()`][code enablefuzzdeterminism]を使用できないのでしょうか？
  この非決定性は、（PRで現在実装されている方法以外で）どのように処理するのが最適だと思いますか？"
  a2="`m_dirty_blockindex`セットはポインタメモリアドレスでソートされますが、
  このアドレスは実行毎に異なるため、非決定的な動作が発生します。この修正では、
  代わりにブロックハッシュを使用することで、決定的なソート順序を実現します。
  `std::set`のコンパレーターはその型のコンパイル時のプロパティであり、
  実行時に切り替えることができないため、`EnableFuzzDeterminism()`のような実行時ソリューションは使用できません。
  この非決定性は実行パスに影響を与えるため、セットへの挿入毎にファジングツールのコードカバレッジ分析を誤導します。
  PRの作者は、ファジングにおけるカバレッジフィードバックの仕組みに関する参考資料として、
  [afl-fuzzホワイトペーパー][afl fuzz]を推奨しています。"
  a2link="https://bitcoincore.reviews/33300#l-147"
%}

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Inquisition 29.1][]は、提案中のソフトフォークやその他の主要なプロトコル変更を実験するために設計された、
  [signet][topic signet]フルノードのリリースです。Bitcoin Core 29.1で導入された
  新しい[最小リレー手数料率のデフォルト][topic default minimum transaction relay feerates]（0.1 sat/vb）、
  Bitcoin Core 30.0で予定されている`datacarrier`制限の拡大、
  `OP_INTERNALKEY`（ニュースレター[#285][news285 internal]および[#332][news332 internal]参照）のサポート、
  新しいソフトフォークをサポートするための新しい内部インフラが含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33453][]は、多くのユーザーがこれらのオプションの使用継続を望んでおり、
  廃止計画が不明確で、廃止を取り消すことによるデメリットが最小限であることから、
  `datacarrier`と`datacarriersize`設定オプションの廃止を取り消します。
  このトピックに関する追加の文脈については、ニュースレター[#352][news352 data]と[#358][news358 data]をご覧ください。

- [Bitcoin Core #33504][]は、承認済みトランザクションがブロックの再編成により
  mempoolに再び入る際、[TRUC][topic v3 transaction relay]トポロジー制限に違反していても、
  TRUCチェックの実施をスキップします。これまでは、これらのチェックを実施すると多くのトランザクションが誤って排除されていました。

- [Core Lightning #8563][]は、チャネルが閉じられ忘れられた時点で古い[HTLC][topic htlc]を削除するのではなく、
  ノードが再起動されるまで削除を延期します。これにより、すべてのCLNプロセスを停止させる不要な一時停止を回避し、
  パフォーマンスが向上します。このPRはまた、閉じたチャネルのHTLCを除外するように`listhtlcs`を更新しています。

- [Core Lightning #8523][]は、`decode` RPCおよび`onion_message_recv`フックから
  以前に非推奨とされ無効化されていた`blinding`フィールドを削除しました。これは、
  `first_path_key`に置き換えられたためです。`experimental-quiesce`および
  `experimental-offers`オプションも削除されました。これらの機能はデフォルトであるためです。

- [Core Lightning #8398][]は、試験的な[BOLT12][]定期[オファー][topic offers]に
  `cancelrecurringinvoice`コマンドを追加しました。これにより支払人は、
  受信者に対し、そのシリーズからのインボイス要求の受信を停止するよう通知できます。
  [BOLTs #1240][]の最新の仕様変更に合わせて、他にもいくつかの更新が行われました。

- [LDK #4120][]は、ピアが切断するか`tx_abort`を送信した場合、
  署名フェーズの前に[スプライシング][topic splicing]のネゴシエーションが失敗した際に、
  インタラクティブファンディング状態をクリアし、スプライシングをクリーンに再試行できるようにします。
  ピアが`tx_signatures`の交換を開始した後に`tx_abort`を受信した場合、
  LDKはこれをプロトコルエラーとして扱い、チャネルを閉じます。

- [LND #10254][]は、[Tor][topic anonymity networks] v2 onionサービスのサポートを廃止します。
  これは、次の0.21.0リリースで削除される予定です。設定オプション`tor.v2`は現在非表示になっており、
  ユーザーは代わりにv3を使用してください。

{% include snippets/recap-ad.md when="2025-10-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33453,33504,8563,8523,8398,4120,10254,1240" %}
[sindura post]: https://delvingbitcoin.org/t/optimal-threshold-signatures-in-bitcoin/2023
[Bitcoin Inquisition 29.1]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.1-inq
[news285 internal]: /ja/newsletters/2024/01/17/#lnhance
[news332 internal]: /ja/newsletters/2024/12/06/#bips-1534
[news352 data]: /ja/newsletters/2025/05/02/#bitcoin-core-op-return
[news358 data]: /ja/newsletters/2025/06/13/#bitcoin-core-32406
[review club 33300]: https://bitcoincore.reviews/33300
[gh crypt-iq]: https://github.com/crypt-iq
[fuzz readme]: https://github.com/bitcoin/bitcoin/blob/master/doc/fuzzing.md
[review-club ed813c4]: https://github.com/bitcoin-core-review-club/bitcoin/commit/ed813c48f826d083becf93c741b483774c850c86
[q1 note]: https://github.com/bitcoin/bitcoin/pull/33300#issuecomment-3308381089
[code enablefuzzdeterminism]: https://github.com/bitcoin/bitcoin/blob/acc7f2a433b131597124ba0fbbe9952c4d36a872/src/util/check.h#L34
[afl fuzz]: https://lcamtuf.coredump.cx/afl/technical_details.txt
[zmnscpxj flat]: https://delvingbitcoin.org/t/flattening-nested-2-of-2-of-a-1-of-1-and-a-k-of-n/2018
[news372 lspover]: /ja/newsletters/2025/09/19/#lsp
[gibson embed]: https://gnusha.org/pi/bitcoindev/0f6c92cc-e922-4d9f-9fdf-69384dcc4086n@googlegroups.com/
[towns embed]: https://gnusha.org/pi/bitcoindev/aOXyvGaKfe7bqTXv@erisian.com.au/
