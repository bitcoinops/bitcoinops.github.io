---
title: 'Bitcoin Optech Newsletter #433'
permalink: /ja/newsletters/2026/11/27/
name: 2026-11-27-newsletter-ja
slug: 2026-11-27-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、古いバージョンのBitcoin Coreに影響する脆弱性と、
Core Lightningのサービス拒否（DoS）脆弱性の開示の概要、BIPエディターチームの刷新に関する議論を掲載しています。
また、Bitcoin Stack Exchangeから選ばれた質問とその回答、新しいリリースとリリース候補の発表、
人気のBitcoin基盤ソフトウェアの注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **Bitcoin Coreの中程度の重大度の脆弱性の開示:**
  Greg Sandersは、ピアがノードのブロックおよびトランザクションの処理を一時的に停止させることができた脆弱性に関する
  Bitcoin Coreの[セキュリティアドバイザリー][core orphan inv stall]をBitcoin-Devメーリングリストに[投稿しました][sanders adv ml]。
  この脆弱性は、29.xのすべてのリリース、[30.5][core 30.5]より前の30.x、
  および[31.3][core 31.3]より前の31.xに影響します。バージョン32.1にはすでに修正が含まれています。
  29.xシリーズはサポート終了となっており修正は提供されないため、
  そのユーザーはメンテナンスされているリリースにアップグレードする必要があります。

  Bitcoin Coreは、親トランザクションをまだ確認していないトランザクションをオーファンとして保存します。
  29.0以降、ピアが保存されたオーファンのwtxidをアナウンスするたびに、
  ノードはそのオーファンのすべての親を自身のmempoolおよび最近確認したトランザクションのフィルターと照合していました。
  `inv`メッセージには最大50,000件のアナウンスを含めることができ、重複はスキップされませんでした。
  攻撃者は、数千の親が欠落したオーファンを送信し、続いてそのwtxidを50,000回繰り返した
  `inv`メッセージを送信することができました。アドバイザリーによると、
  そのようなメッセージ1つにつきノードは十数秒以上停止し、その間、
  ブロックを含む他のピアからのメッセージは一切処理されませんでした。[Bitcoin Core
  #35878][]では、アナウンスされた各トランザクションを`inv`メッセージごとに1回だけ処理するようになりました。

  この脆弱性は、7月にProject Loupeによって発見され、Sandersによって[責任ある開示][topic responsible disclosures]が行われ、
  8月にstutxoによって独立して報告されました。容易に発見可能なものとして分類されたため
  （[ニュースレター #429][news429 policy]参照）、アドバイザリーは30.5および31.3と同時に公開されました。

- **CLNのDoS脆弱性の開示:** Nishant Bansalは、
  バージョン[0.12.0][cln 0.12.0]（2022年8月）から[26.06.7][cln 26.06.7]（2026年8月）までに影響し、
  攻撃者が被害者のノードを繰り返しクラッシュさせることができた
  Core Lightning（CLN）のサービス拒否（DoS）脆弱性の[責任ある開示][topic responsible disclosures]をDelving Bitcoinに[投稿しました][cln vuln del]。
  このバグは攻撃者に資金への直接的なアクセスを与えるものではありませんでしたが、
  ノードを継続的にクラッシュさせることでそのチャネルの資金が危険にさらされる可能性がありました。
  ユーザーは直ちに最新バージョンにアップグレードすることが推奨されます。この脆弱性は、
  CLNのバージョン26.06.8で修正されました（[ニュースレター #424][news424 cln rel]参照）。

  この脆弱性は、複数のv1チャネルが同じ`channel_id`を共有することに関連していました。
  悪意のあるピアは、別のチャネルのファンディングアウトポイントを提供してチャネルを開設することができました。
  [BOLT2][]によると、`channel_id`はそのアウトポイントから導出されるため、2つのチャネルのIDが一致することになります。
  CLNはチャネルごとに`channeld`サブデーモンを実行し、`connectd`は`channel_id`に基づいてメッセージを
  正しいサブデーモンにルーティングします。CLNは`channel_id`が一意であることを前提としているため、
  衝突によってノードがクラッシュしました。

  悪意のあるピアがノードをクラッシュさせる方法は2つありました。1つは再接続時のもので、
  ライトニングネットワーク実装用のスナップショットファジングフレームワークである[smite][gh smite]を使って検出されました。
  もう1つはチャネル閉鎖時のもので、開発者のEugene Siegelによって発見されました:

  - ピアが再接続すると、メインデーモンの`lightningd`は`channeld`サブデーモンを起動し、
    それらを`connectd`に引き渡します。最初の`channel_id`の検索ではすべて正常に動作します。
    しかし、2回目のリクエストでは、接続がまだアクティブでないことを確認する`assert`によって`connectd`が中断され、
    ノードがダウンしました。再起動後も両方のチャネルがデータベースに残っているため、
    新たな再接続を試みると再びノードがクラッシュしました。

  - CLNは、以前に閉鎖されたチャネルを`channel_id`をキーとするハッシュテーブルでメモリ内に保持しています。
    攻撃者が既に閉鎖されたチャネルと同じ`channel_id`を持つチャネルを閉鎖すると、
    マップに重複が追加されていないことを確認するアサーションが失敗しました。1つめのケースとは異なり、
    その後ノードは、アップグレードされるまで、攻撃者がそれ以上何もしなくても再起動のたびにクラッシュします。
    この攻撃ベクトルは、バージョン[25.05][cln 25.05]以降にのみ影響しました。

- **<!--discussion-on-refreshing-bip-editors-->BIPエディターの刷新に関する議論:** Mark "Murch" Erhardtは、
  [BIPリポジトリ][bips repo]でエディターのレビューを待っている提出物が滞留していることを挙げ、
  BIPエディターチームを刷新するという自身の4月の提案（エディターの構成に関する以前の記事については、ニュースレター
  [#299][news299 bip editors]および[#418][news418 bip editors]参照）を再び取り上げるために
  Bitcoin-Devメーリングリストに[投稿しました][erhardt bip editors]。
  Erhardtは、アクティブなエディターを追加するか、エディターが新しい提出物のフォーマットのみをチェックするように
  基準を下げるかという2つの選択肢を示し、全員が定期的に貢献する3人のエディターでチームを刷新することを強く支持しました。
  また、期限のない関与に慎重なボランティアは、12〜24ヶ月など期間を限定して務めることを申し出ることもできると付け加えました。
  この投稿を受けて数名が立候補し、現エディターのOlaoluwa Osuntokunは年末に退任する予定であることを表明しました。
  執筆時点では議論が続いています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-does-a-policy-that-is-valid-with-rust-miniscript-throw-a-compile-error-on-the-sipa-site-->rust-miniscriptでは有効なポリシーが、sipaのサイトではコンパイルエラーになるのはなぜですか？]({{bse}}131089)
  Pieter Wuilleは、自身の[Miniscript][topic miniscript]ポリシーコンパイラーのサイトでは、
  シンボル名を鍵に対してのみ受け付け、ハッシュのプリイメージには受け付けないこと、
  また改変可能なスクリプトを許可していないことを説明しています（[ニュースレター #230][news230 malleable]参照）。
  質問者のポリシーの分岐の1つは、144ブロック後にプリイメージを公開するだけで満たすことができ、
  署名を含まないため本質的に改変可能です。

- [<!--how-can-i-repair-corrupted-undo-data-rev-dat-checksum-mismatch-without-a-full-reindex-->完全な再インデックスを行わずに、破損したundoデータ（rev*.datのチェックサムの不一致）を修復するにはどうすればいいですか？]({{bse}}131107)
  P22は、`-txindex`を有効にしたノードで、破損したundoレコードを再構築する方法を説明しています。
  ブロックのundoデータは、そのインプットが使用したアウトプットのリストであるため、
  各レコードをバイト単位で正確に再構築し、元の位置に書き戻すことができます。
  Bitcoin Coreは、まだundoの位置を持たないブロックに対してのみundoデータを書き込むため、
  `-reindex-chainstate`は役に立ちません。

- [<!--why-does-no-bitcoin-opcode-push-data-about-the-spending-transaction-onto-the-stack-->使用するトランザクションに関するデータをスタックにプッシュするBitcoinのopcodeが存在しないのはなぜですか？]({{bse}}131130)
  LearnBitcoinは、`OP_NOP` opcodeを再定義するソフトフォークはスクリプトを失敗させることしかできないと回答しています。
  スタックに値を残すと、古いノードと新しいノードで有効性の判断が一致しなくなるためです。
  提案されている[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]が検証のみを行うのはそのためです。
  [Tapscript][topic tapscript]では、スタックへの書き込みも可能な`OP_SUCCESSx` opcodeが追加されており
  （[ニュースレター #416][news416 success]参照）、[コベナンツ][topic covenants]の提案である
  `OP_TXHASH`と`OP_TEMPLATEHASH`はこれを利用して定義されています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 31.3][]と[30.5][Bitcoin Core 30.5]は、主要なフルノード実装のメンテナンスリリースです。
  どちらも上記のDoS脆弱性を修正しています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #36387][]は、既存の暗号化されていないウォレットを暗号化する`encryptwallet` RPCを非推奨にしました。
  このRPCを使用するには、Bitcoin Coreを`-deprecatedrpc=encryptwallet`フラグ付きで起動する必要があり、
  将来のメジャーリリースで削除される予定です。既存のウォレットを暗号化しても、
  暗号化されていない秘密鍵のデータがディスクから削除されることは保証できません。
  また、新しい[シード][topic bip32]が生成される可能性があるため、
  以前のバックアップでは新しく生成されたアドレスに送られた資金を復元できない場合があります。
  ウォレットを暗号化したいユーザーは、代わりに`createwallet`に`passphrase`引数を指定して
  暗号化されたウォレットを作成する必要があります（[ニュースレター #47][news47 createwallet]参照）。
  既存の暗号化されたウォレットは引き続きサポートされます。

- [BIPs #2301][]は、[v2 P2Pトランスポート][topic v2 p2p transport]を使用するピアが、
  送信メッセージに独自の1 byteのメッセージタイプIDを選択できるようにするドラフト[BIP333][]を追加しました
  （[ニュースレター #426][news426 aliases]参照）。現在、[BIP324][]は固定テーブルを通じて1 byteのIDを割り当てており、
  新しいエントリーを追加するには調整が必要です。提案されている`set324alias`メッセージにより、
  相手のピアが[BIP434][]を通じてサポートを通知した後、各ピアは独自のエイリアスをアナウンスできるようになります。

- [Core Lightning #9718][]は、Bitcoin Coreの`gettxout` RPCの呼び出しが失敗した場合に、
  アウトプットが使用済みまたは存在しないと誤って解釈される可能性があったバグを修正しました。
  これは、Bitcoin Coreに到達できない場合や、起動中の場合に発生する可能性がありました。
  外部から資金提供されたチャネルの開設時（[ニュースレター #51][news51 external funding]参照）に、
  `fundchannel_cancel` RPCが、ファンディングトランザクションが既にブロードキャストされているチャネルを
  忘れてしまう可能性がありました。`bcli`プラグインは現在、一時的な接続エラーおよび起動時のエラーをリトライし、
  失敗した呼び出しはエラーとして報告します。要求されたアウトポイントに未使用のアウトプットが存在しないことを示す
  成功レスポンスのみが、アウトプットが利用できないことの根拠と見なされます。

- [LDK #5663][]は、チャネルの復旧状態を非同期で保存する際に、
  転送された資金が失われる可能性があった問題を修正しました。受信チャネルのピアが強制閉鎖した後、
  更新によって[HTLC][topic htlc]のプリイメージがメモリに記録されるものの、
  閉鎖されたチャネルのコミットメント状態を変更しようとするとエラーが返される場合がありました。
  LDKは受信HTLCの請求トランザクションもブロードキャストします。これまでLDKは、
  この情報のディスクへの永続化を開始していましたが、エラーのためにその書き込みを保留中として追跡していませんでした。
  チャネルの閉鎖を記録する別の書き込みが先に完了すると、LDKはプリイメージが安全に保存されたと誤って判断し、
  送信チャネルがそのコピーを破棄することを許可してしまう可能性がありました。
  プリイメージが保存される前にノードがクラッシュし、請求トランザクションが有効期限までに承認されなかった場合、
  送信HTLCを支払った後に受信した支払いを失う可能性がありました。LDKは現在、
  これらの更新を永続化し、書き込みが完了するまで追跡します。

- [LDK #5678][]は、ピアが失効したコミットメントトランザクションをブロードキャストした際の
  [ペナルティトランザクション][topic ln-penalty]に使用される[手数料目標][topic fee estimation]を修正しました。
  これまでLDKは、最新のコミットメントに保留中の[HTLC][topic htlc]が含まれている場合にのみ緊急の目標を選択しており
  （[ニュースレター #319][news319 targets]参照）、オンチェーンのコミットメントが失効しているかどうかを別途チェックしていませんでした。
  手数料の高い状態が続くと、[手数料の引き上げ][topic rbf]を行ってもペナルティが未承認のまま残り、
  ピアの[タイムロック][topic timelocks]が期限切れになって、ピアが失効した資金を使用できるようになる可能性がありました。
  LDKは現在、オンチェーンの相手方のコミットメントが失効していると判断した場合には常に、
  緊急のオンチェーンスイープ目標を使用します。

- [LND #11607][]は、失効した相手方のコミットメントから[HTLC][topic htlc]アウトプットを使用する
  [ペナルティトランザクション][topic ln-penalty]のweightの見積もりを修正しました。
  これまでLNDは、ペナルティのwitnessは正しく構築していましたが、そのサイズを
  自身のコミットメントトランザクションからHTLCを使用するかのように見積もっていました。
  実際にはペナルティはピアのコミットメントのアウトプットを使用しており、そのHTLCスクリプトはより大きい可能性があるため、
  weightが過小に見積もられていました。[最小リレー手数料率][topic default minimum transaction relay feerates]を
  目標とする場合、これにより手数料が不足し、mempoolで拒否される可能性がありました。
  LNDは現在、[アンカーチャネル][topic anchor outputs]で使用される追加のスクリプトバイトを含め、
  使用されるスクリプトに見積もりを一致させます。

- [LND #11247][]は、承認や使用を見逃す可能性があり、チャネルが開設中または閉鎖中のまま停止してしまう可能性があった
  過去のチェーンスキャンを修正しました。LNDは、同じトランザクションまたはアウトプットを監視するリクエスト間でスキャンを共有します。
  これまでは、最初のリクエストのスキャン開始が遅すぎた場合、より早い開始ブロック高を指定した後のリクエストが、
  欠落した以前のブロックをチェックすることなくそのスキャンを再利用する可能性がありました。
  キャッシュされた開始ブロック高によって、この欠落が再起動後も維持される可能性がありました。
  LNDは現在、欠落した範囲をスキャンし、キャッシュされた進捗とともにその開始ブロック高を記録します。
  これは[ニュースレター #431][news431 hints]で取り上げたキャッシュキーの修正を補完するものです。
  アップグレード後もチャネルが停止したままの場合は、`--height-hint-cache-query-disable`オプションを付けて
  LNDを一度再起動し、復旧後にこのオプションを削除する必要がある場合があります。

- [LND #11268][]は、切断後に不要な強制閉鎖を引き起こす可能性があった永続化のバグを修正しました。
  これは、ローカルのイニシエーターノードがまだコミットメントを失効させていないチャネルで手数料の更新を送信し、
  その変更をディスクに保存せずにピアの確認応答を受信した場合に発生する可能性がありました。
  その後、LNDがピアの次のコミットメント署名を受信する前に接続が切断されると、
  古い手数料でコミットメントを再構築し、有効な署名を拒否する可能性がありました。
  この修正では、確認応答されたローカルの更新の保存をスキップしていたデータベース更新の早期リターンを削除しています。

- [Rust Bitcoin #7160][]は、`TestnetVersion::V5`の値、ジェネシスブロック、チェーン識別子、
  プルーフ・オブ・ワークのパラメーター、ネットワークメッセージのマジックを含む、
  [testnet5][topic testnet]（[BIP95][]）のサポートを追加しました。また、testnet5を認識するように
  ネットワークの解析とアドレスの処理も更新しています。ジェネシスのパラメーターについては、
  [ニュースレター #432][news432 testnet5]で取り上げています。

- [BTCPay Server #7846][]は、許可されたコマンドを制限するクレデンシャルであるruneを使用して、
  Core Lightning 24.11以降の組み込みの`clnrest`サービス（[ニュースレター #262][news262 clnrest]参照）を介して
  接続するためのサポートを追加しました。これにより、支払いを送信する権限なしに、
  インボイスの作成と監視を行う接続が可能になります。Core LightningのRPCインターフェースへの
  既存の直接接続も引き続きサポートされます。この依存関係の更新により、証明書の処理も変更され、
  `allowinsecure`、`certthumbprint`、`certfilepath`の接続文字列オプションは無視されるようになりました。
  自己署名証明書を使用する外部のライトニングノードを利用しているオペレーターは、
  BTCPay Serverを実行する環境で信頼を設定する必要があります。

- [BTCPay Server #7850][]と[#7851][btcpay server #7851]は、ライトニングのペイアウトの誤った状態を修正しました。
  1つめは、LNDhubアダプターを更新し、HTTP 200レスポンスで返される支払いエラーを保持するようにしました。
  これまでは、これらのエラーが破棄され、失敗したペイアウトが支払い済みとして報告される可能性がありました。
  現在の呼び出しで何も送信されなかったことを証明する既知のエラーは、失敗として報告されるようになりました。
  結果が曖昧な場合は引き続き不明として扱われます。2つめは、送信処理がエラーを返した後に
  支払いの照会で成功が確認された場合に、ペイアウトを完了としてマークし、
  [支払いの証明][topic proof of payment]を保持します。

{% include snippets/recap-ad.md when="2026-12-01 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35878,36387,2301,9718,5663,5678,11607,11247,11268,7160,7846,7850,7851" %}
[sanders adv ml]: https://groups.google.com/g/bitcoindev/c/lFzWO5W9pBE
[core orphan inv stall]: https://bitcoincore.org/en/2026/11/20/disclose-orphan-inv-stall/
[core 31.3]: https://bitcoincore.org/en/2026/11/20/release-31.3/
[core 30.5]: https://bitcoincore.org/en/2026/11/20/release-30.5/
[news429 policy]: /ja/newsletters/2026/10/30/#bitcoin-core
[cln vuln del]: https://delvingbitcoin.org/t/disclosure-dos-vulnerability-fixed-in-core-lightning-v26-06-8/3072
[cln 0.12.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0
[cln 26.06.7]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.7
[news424 cln rel]: /ja/newsletters/2026/09/25/#core-lightning-26-06-8
[gh smite]: https://github.com/lnfuzz/smite
[cln 25.05]: https://github.com/ElementsProject/lightning/releases/tag/v25.05
[erhardt bip editors]: https://groups.google.com/g/bitcoindev/c/zCmHEGbCADQ/m/0nXgyto-AQAJ
[news299 bip editors]: /ja/newsletters/2024/04/24/#bip
[news418 bip editors]: /ja/newsletters/2026/08/14/#bips-2248
[news230 malleable]: /ja/newsletters/2022/12/14/#when-is-a-miniscript-solution-malleable-miniscript
[news416 success]: /ja/newsletters/2026/07/31/#bip342-op-successx-opcode
[Bitcoin Core 31.3]: https://bitcoincore.org/bin/bitcoin-core-31.3/
[Bitcoin Core 30.5]: https://bitcoincore.org/bin/bitcoin-core-30.5/
[LDK #5663]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5663
[LDK #5678]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5678
[news47 createwallet]: /en/newsletters/2019/05/21/#bitcoin-core-15006
[news426 aliases]: /ja/newsletters/2026/10/09/#bip324-1-byte-id
[news51 external funding]: /en/newsletters/2019/06/19/#c-lightning-2672
[news319 targets]: /ja/newsletters/2024/09/06/#ldk-3268
[news431 hints]: /ja/newsletters/2026/11/13/#lnd-11481
[news432 testnet5]: /ja/newsletters/2026/11/20/#bips-2356
[news262 clnrest]: /ja/newsletters/2023/08/02/#core-lightning-6389
