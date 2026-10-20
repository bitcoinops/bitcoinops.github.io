---
title: 'Bitcoin Optech Newsletter #411'
permalink: /ja/newsletters/2026/06/26/
name: 2026-06-26-newsletter-ja
slug: 2026-06-26-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、旧バージョンのLNDに影響するサービス拒否(DoS)脆弱性の責任ある開示について掲載しています。
また、Bitcoin Stack Exchangeから選んだ質問とその回答、新しいリリースおよびリリース候補のお知らせ、
人気のBitcoin基盤ソフトウェアにおける注目すべき更新を紹介する恒例のセクションも掲載しています。

## ニュース

- **LNDのゼロタイムスタンプのゴシップDoSの開示:** Nishant Bansalは、
  LNDのゴシップ処理に対するステートマシンファジングを通じて発見したサービス拒否(DoS)脆弱性を
  Delving Bitcoinに[投稿し][lnd gossip dos delving]、開示しました。
  v0.20.1-betaより前のバージョンのLNDは、タイムスタンプがゼロの`channel_update`または
  `node_announcement`ゴシップメッセージによってクラッシュする可能性がありました。
  [BOLT7][]は`channel_update`のタイムスタンプがゼロより大きいことを要求していますが、
  そのルールに違反するメッセージをノードがどう扱うべきかは規定しておらず、
  LNDによるその値に対する処理がクラッシュを引き起こしていました。

  脆弱なノードがこれらのゼロタイムスタンプメッセージのいずれかを処理しようとすると、
  内部のブックキーピングエラーによってデータ構造が無効な状態のまま残され、
  ランタイムパニックが発生してノードが終了していました。攻撃者は、実在の公開チャネル、
  または攻撃者が管理する2-of-2アウトプットに資金を入れて作成した合成チャネルのいずれかについて
  アナウンスをブロードキャストすることで、このバグを引き起こせました。
  後者はライトニングノードを動かさずに安価に繰り返せるものです。

  この脆弱性は[責任を持って開示され][topic responsible disclosures]、Matt Morehouseによって独自に確認され、
  パース時にタイムスタンプがゼロのゴシップメッセージを脆弱なコードに到達する前に拒否することで
  [LND 0.20.1-beta][news393 lnd 0201]で修正されました。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Tapscriptのオペコードに`OP_IF`が含まれているのはバグですか?]({{bse}}130785)
  Antoine Poinsotは、あらゆる支払いポリシーは1つのパスにつき1つの[Taproot][topic taproot]リーフとして表現できるものの、
  それが常に最も効率的なエンコードであるとは限らないと説明しています。パスの数と各パスがどれくらいの頻度で使われるかによっては、
  単一の[Tapscript][topic tapscript]リーフ内の`OP_IF`の方が、パスを複数のリーフに分割したり、
  P2WSHに切り替えたりするよりも支払い時のデータサイズを小さくできる場合があります。

- [<!--why-would-forbidding-op-if-in-tapscript-be-a-problem-->Tapscriptで`OP_IF`を禁止すると、どのような問題が生じるのでしょうか?]({{bse}}130815)
  Murchは、Taprootアウトプットはリーフスクリプトをハッシュとしてコミットしているため、
  [miniscript][topic miniscript]ベースの劣化型マルチシグウォレットのように、
  どの既存UTXOが`OP_IF`に依存しているかを知ることは不可能だと指摘します。
  そのような構成を持つユーザーは、もしその支払いパスが有効でなくなれば、
  アクティベーション後に受け取った資金を意図せずロックしてしまう恐れがあります。

- [<!--does-a-softfork-always-succeed-->ソフトフォークは常に成功しますか?]({{bse}}130775)
  Murchは、強制的なシグナリングを用いる[ソフトフォーク][topic soft fork activation]が
  ハッシュレートの少数派にしか支持されていないシナリオを順を追って説明しています。
  この場合、シグナリングを行うチェーンがProof of Workの蓄積で遅れをとり、
  ネットワークの残りに新ルールの採用を強制するのではなく、チェーンの進行が停滞してしまうことになります。

- [<!--how-to-set-up-bitcoin-core-to-mine-a-valid-block-after-the-bip110-activation-in-august-2026-->2026年8月のBIP110アクティベーション後に有効なブロックをマイニングするために、Bitcoin Coreをどう設定すればよいですか?]({{bse}}130770)
  Antoine Poinsotは、Bitcoin CoreはBIP110のルールを強制しておらず、
  BIP110が無効とみなすトランザクションを除外したブロックテンプレートを構築する機能も持たないと指摘します。
  BIP110準拠のブロックをマイニングしたいノード運用者は、外部のブロックテンプレート構築ソフトウェアを使ってトランザクションを選択するか、
  空ブロックをマイニングする必要があります。

- [BIP110ブロックを含む難易度の低いブランチは有効とみなされますか?]({{bse}}130827)
  Pieter Wuilleは、チェーンが有効であることと、アクティブであることを区別しています。
  各ブランチの難易度調整はそのブランチ自身のブロックのみに依存するため、
  潜在的により遅いBIP110ブランチも現行ルールに従うノードにとっては有効ですが、
  メインチェーンよりも多くの累積Proof of Workを蓄積しない限り、それがアクティブなチェーンになることはありません。

- [Bitcoinのテストネットワークにはどのような経緯があるのでしょうか?]({{bse}}130806)
  MurchとAntoine Poinsotが、testnet1から提案中のtestnet5までの[testnet][topic testnet]の歴史を振り返ります。
  これには各ネットワークが収益化されるたびに繰り返されたリセットや、
  testnet3で繰り返し発生したブロックストームの原因となった20分間の難易度例外([ニュースレター #311][news311 block storm]参照)も含まれます。

- [`-datacarriersize`はなぜ2022年に再定義され、2023年のそれを拡張する提案はなぜマージされなかったのですか?]({{bse}}128027)
  昨年回答された質問を改めて取り上げ、Murchは補足説明を行いました。`datacarrier`および
  `datacarriersize`オプションは、Bitcoin Core 0.10.0で導入されて以来`OP_RETURN`アウトプットのみを指すものであったことを、
  元のコードとリリースノートを引用して明らかにしています。

- [<!--are-chains-of-26-unconfirmed-transactions-prohibited-by-the-wallet-in-bitcoin-core-31-0-->26個の未承認トランザクションのチェーンはBitcoin Core 31.0のウォレットで禁止されていますか?]({{bse}}130777)
  Pol Espinasaは、mempool自体は新しい[クラスターmempool][topic cluster mempool]の上限のもとで
  より長いチェーンを許可するものの、Bitcoin Coreのウォレットはコイン選択時に依然として25トランザクションの制限を強制するため、
  より長いチェーンはウォレット機能を使わずに構築する必要があると明確にしています。

- [Bitcoin Core 29.0にメモリ使用量に影響する変更はありますか?]({{bse}}127887)
  Antoine Poinsotは、見かけ上の増加はプロセスのメモリ使用量が増えたのではなく、
  レポート上の現象であると明確にしています。Bitcoin Core 29.0は空きメモリがある場合に
  chainstateデータベースのキャッシュにより多くのデータを保持できるようになっており、
  そのキャッシュは他のプロセスがメモリを必要とするときに解放される仕組みになっています。

- [Bitcoin Coreのリリーススケジュールはどうなっていますか?]({{bse}}130817)
  Murchは、Bitcoin Coreが4月と10月の固定スケジュールでメジャーバージョンをリリースする方針について説明しています。
  これは、以前の「前回のリリースから6か月後」を目標とする方式（スケジュールが遅延する可能性があった）から変更されたものです。
  マイナーリリースは引き続き必要に応じてバグ修正を提供します。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LDK v0.1.10][]は、LN対応ウォレットおよびアプリケーションを構築するためのこのライブラリのメンテナンスリリースです。
  複数のサービス拒否(DoS)脆弱性とサニタイズの問題に加え、非同期チャネルモニターの永続化、
  Electrumとの同期、[BOLT12オファー][topic offers]の検証、オニオンメッセージの処理、
  [MPP][topic multipath payments]の[keysend][topic spontaneous payments] [HTLC][topic htlc]、
  およびルートベースの支払い送信に関連するバグも修正しています。

- [LDK v0.2.3][]は、LN対応ウォレットおよびアプリケーションを構築するためのこのライブラリのメンテナンスリリースです。
  サービス拒否(DoS)脆弱性、アンカーチャネルのリザーブ計算の誤り、サニタイズの問題を含む複数のセキュリティ問題に加え、
  非同期チャネルモニターの永続化、LSPSの処理、[ゼロ手数料コミットメントチャネル][topic v3 commitments]、
  BOLT12オファー、オニオンメッセージング、Rapid Gossip Syncのメモリ使用に関連するバグも修正しています。

- [BTCPay Server 2.4.0][]は、このセルフホスト型ペイメントプロセッサのリリースです。
  グローバル検索、パスキー認証、ガイド付きマルチシグウォレットセットアップ、より細かいウォレット権限設定、
  サブスクリプションおよびPOSの改善、ウォレットトランザクションの検索とフィルタリング、プラグインエコシステムの改善、
  更新されたライトニングサポートを追加する一方で、いくつかの非推奨となったライトニングバックエンドを削除しています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #35070][]は、`m_blocks_unlinked`への重複エントリーの追加を防止する変更を行いました。
  これは、先行するブロックデータが不足しているためまだ接続できないダウンロード済みブロックを追跡するための検証用内部構造です。
  これまでは、大規模な再編成に直面したプルーニングノードがこの構造に誤って重複エントリーを追加してしまうことがありました。
  その結果、不足データを受信した後に`ReceivedBlockTransactions()`関数が同じブロックを複数回再検討し、
  その`nSequenceId`を変更したうえで`setBlockIndexCandidates`に再追加してしまう事態が生じていました。
  これにより、候補となるチェーン先端のインメモリ順序が破損し、未定義動作につながるおそれがありました。
  このPRは、エントリーを重複排除する新しい`AddUnlinkedBlock()`ヘルパー経由で挿入処理を行うようにし、
  重複が存在しないことを保証するために`CheckBlockIndex()`を強化しています。

- [Bitcoin Core #35182][]、[#34411][bitcoin core #34411]は、
  RPCおよびRESTで使われているlibeventベースのHTTPサーバーを、Bitcoin Core内でメンテナンスされる
  新しいHTTPおよびソケット処理の実装に置き換えます。新しいサーバーは独自のI/Oスレッドで動作し、ソケットを直接扱い、
  受け付けたリクエストを既存のHTTPワーカープールにディスパッチします。後続のPRは、残っていたlibeventのビルド、
  CI、依存関係、CMakeの構成要素を削除しています。これらの変更は、外部依存を減らし、
  ソースからBitcoin Coreをビルドすることを簡素化するプロジェクトの取り組みの一環です。

- [BIPs #2198][]は、P2MR提案である[BIP360][]([ニュースレター #393][news393 p2mr] 参照)を更新し、
  深さゼロのスクリプトツリー内の単一のリーフを知り、それを公開した者が、
  そのスクリプトを実行せずにアウトプットを使えるようにします。これにより、単一パスのP2MRアウトプットは意図的に安全でないものとなります。
  ユーザーが支払いを試みてリーフを公開すると、マイナーがその公開されたリーフを使って、
  そのアウトプットを代わりに自分宛に使ってしまえるからです。この変更は、
  ウォレットがウィットネスのバイト数を節約するためだけに[ポスト量子][topic quantum resistance]
  またはその他のフォールバックリーフを省略することを抑止することを意図しています。

- [LDK #4713][]は、Rapid Gossip Sync (RGS)([ニュースレター #308][news308 rgs] 参照)に対するサービス拒否(DoS)耐性を強化します。
  RGSはライトニングネットワークのゴシップデータを素早くインポートするためのLDKのフォーマットです。
  ドキュメントには、RGSソースは半トラストとみなすべきであるとの警告が加わりました。
  RGSのデータソースはデータを省略することで経路探索を妨害したり、クライアントのネットワークグラフを肥大化させようとする可能性があるためです。
  LDKは、ノードやチャネルの更新数が不自然なスナップショットは拒否するようになりました。
  また、グラフ内のチャネル数が予想される数の10倍を超えた場合、
  新しい[チャネルアナウンスメント][topic channel announcements]の追加をスキップします。

- [LDK #4684][]は、再接続後に重複した`revoke_and_ack`が送信される原因となり得る、
  非同期署名者(async signer)とチャネルモニターの処理順序に関する稀なバグを修正します。
  これまでは、モニターの更新が保留中であるにもかかわらず、署名者のブロックが解除されたパスが未送信の`revoke_and_ack`
  を再生成して送信すると、その後、モニター復旧後のパスも同じメッセージを再生成してしまうことがありました。
  これにより、ピアが重複したシークレットを拒否して強制閉鎖に至る恐れがありました。今回の修正により、
  署名者保留パスが`revoke_and_ack`を返した時点で、モニター保留の`revoke_and_ack`フラグもクリアするようになりました。
  そのメッセージがモニター保留状態での再送要件も同時に満たすためです。

{% include snippets/recap-ad.md when="2026-06-30 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2198,34411,35070,35182,4684,4713" %}

[news311 block storm]: /ja/newsletters/2024/07/12/#bitcoin-core-pr-review-club
[lnd gossip dos delving]: https://delvingbitcoin.org/t/lnd-zero-timestamp-gossip-dos-disclosure/2621
[news393 lnd 0201]: /ja/newsletters/2026/02/20/#lnd-0-20-1-beta
[LDK v0.1.10]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.10
[LDK v0.2.3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.3
[BTCPay Server 2.4.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.0
[news393 p2mr]: /ja/newsletters/2026/02/20/#bips-1670
[news308 rgs]: /ja/newsletters/2024/06/21/#ldk-3098
