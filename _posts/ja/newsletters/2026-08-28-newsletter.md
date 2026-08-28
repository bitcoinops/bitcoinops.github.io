---
title: 'Bitcoin Optech Newsletter #420'
permalink: /ja/newsletters/2026/08/28/
name: 2026-08-28-newsletter-ja
slug: 2026-08-28-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、予定されているCore Lightningのセキュリティリリースに関する事前告知と、
将来のフォークに備えたオプトイン方式のリプレイ保護に関する議論、
HWI（Hardware Wallet Interface）プロジェクトのメンテナンスモードへの移行、
block-rangeフィルターの利用に関するコメント募集について掲載しています。また、
新しいリリースとリリース候補の発表、人気のBitcoin基盤ソフトウェアへの注目すべき更新など恒例のセクションも含まれています。

## アクションアイテム

- **来たるCore Lightningのセキュリティリリースに備えましょう:** Christian Deckerは、
  CLN v26.06.7のポイントセキュリティリリースについて[説明しました][cln v26.06.7]。
  既知の脆弱性が実際に悪用されている形跡はないとのことです。プロジェクトは約24時間以内に
  公開制限付きのリリースを行う予定で、バイナリは公開するものの、攻撃者が修正内容をリバースエンジニアリングするのを遅らせるため、
  ソースコードは14日間公開しない方針です。ソースコードが公開されれば、
  CLNの[再現可能ビルド][topic reproducible builds]の仕組みによって、
  ユーザーはバイナリがソースコードと一致することを検証できます。ソースコードが公開されるまでアップデートを待ちたい運用者は、
  `--offline`フラグを付けて再起動する必要があります（このフラグはノードがピア接続を行ったり受け入れたりするのを停止しつつ、
  不正を試みるピアに対するオンチェーンでの強制執行機能は維持します）。

## ニュース

- **<!--discussion-on-universal-opt-in-replay-protection-->ユニバーサルなオプトイン方式のリプレイ保護に関する議論**:
  Moonsettlerは、将来のフォークに備えてオプトイン方式のリプレイ保護メカニズムを導入する可能性についての議論を
  Delving Bitcoinに[投稿しました][replay del]。このアイデアは、マイノリティチェーンがリプレイ攻撃の対象となった最近の出来事を受けたものです。
  リプレイ攻撃とは、フォークした一方のチェーンで有効な署名済みトランザクションがもう一方のチェーンで再ブロードキャストされ、
  意図せず両方のネットワークで同等のコインを消費してしまうタイプの攻撃です。著者は、
  [Taproot annex][topic annex]を使って、直前のブロックハッシュを含む34 byteのペイロード（
  つまり`<0xFAF0><32-byte-prior-block-hash>`）をコミットすることを提案しています。

  これに続く議論で、Anthony Townsはデータ量を6 byteに削減するため、
  代わりにブロック高とブロックハッシュのサフィックスを使うことを提案しました。Moonsettlerはこのアプローチに同意し、
  さらにノードがUTXOにブロックコミットメントを注記して、その情報をユーザーに提供できると有用だと付け加えました。
  また著者は、新しいコミットメントの深さに上限（理想的には`assumevalid`の高さ）を設けること、
  およびノードがコミットメントを最大`100`ブロック分追跡することを提案しました。さらにTownsは、
  ブロックの再編成を考慮して、明示的な`nLocktime`を設定することで
  一定ブロック数が経過するまでトランザクションがマイニングされないようにする、成熟度の制約に似た仕組みを追加することを提案しました。

- **HWIリポジトリがメンテナンスモードへ移行**: Ava Chow（achow101）は、
  [HWI（Hardware Wallet Interface）][topic hwi]プロジェクトをメンテナンスのみの作業に縮小し、
  最終的にはアーカイブする予定であると[発表しました][hwi future]。
  HWIは[Bitcoin Core][bitcoin core repo]やその他のソフトウェアがハードウェア署名デバイスと通信できるようにするものですが、
  ほぼ1人だけで開発されてきており、ここ数年は新規開発がほとんど行われていませんでした。Chowは、
  Bitcoin Coreにハードウェアウォレットのサポートをもたらすという当初の目的の大半は達成されたものの、
  Pythonのコードベースが目標達成の足かせになっていると述べています。というのも、
  Pythonでは[再現可能なビルド][topic reproducible builds]ができず、Bitcoin Coreに同梱できないためです。

  メンテナンスモードに入る前に、プロジェクトは進行中の[MuSig2][topic musig]サポートを完了させ、
  最後になると見込まれるリリースを行う予定です。MuSig2を除き、新機能や追加デバイスのサポート受け入れは停止されます。
  Chowは代替候補として、Wizardsardineが開発中のRust実装である[BHWI][bhwi]を挙げました。

- **block-rangeフィルターの利用に関するコメント募集**: Optoutは、
  [コンパクトブロックフィルター][topic compact block filters]利用時のダウンロードサイズを削減するために
  block-range filterを使う提案についてコメント募集をDelving Bitcoinに[投稿しました][rfc del]。
  個々のブロックフィルターをすべてダウンロードする代わりに、ブロックの範囲に対するフィルターを作成できるというものです。
  あるスクリプトがいずれかの範囲内で見つかった場合には、その範囲の個々のブロックフィルタをダウンロードし、
  以降は[BIP157][]に記載されたとおりに動作します。マッチした範囲については
  block-rangeフィルターとブロックフィルターの両方をダウンロードすることになりますが、
  他の範囲のブロックフィルターをすべてダウンロードせずに済むため、サイズが節約できます。

  暫定的な結果は有望に見えます。著者は約3万ブロック分のシミュレーションデータに対し、
  異なる範囲サイズでシミュレーションを実行しました。スクリプトのセットは2種類使用され、
  1つはトランザクション数が非常に少ないもの（4〜6トランザクション）、
  もう1つはより多いもの（20〜30トランザクション）です。block-rangeフィルターの合計サイズは
  範囲が大きくなるほど減少します。しかし、範囲を大きくしすぎると節約分の大半は打ち消されてしまいます。
  著者によれば、最良のトレードオフは256ブロックの範囲にあり、
  テストされたスクリプトセットに対して総ダウンロードサイズを約70〜80%削減しました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [BTCPay Server 2.4.3][]は、このセルフホスト型ペイメントプロセッサのセキュリティリリースです。
  特に複数ユーザーでサーバーを共有している場合は、アップグレードが推奨されます。

- [Eclair 0.14.2][]は、このLNノード実装のセキュリティリリースです。
  支払い失敗とチャネル処理のバグ（[ニュースレター #418][news418 eclair fixes]参照）、
  チャネルリザーブのチェック漏れ（[ニュースレター #419][news419 eclair reserves]参照）、
  および[オンザフライ][topic jit channels]ファンディングの問題（[ニュースレター #419][news419 eclair funding]参照）が修正されています。
  また、[ゴシップクエリ][topic channel announcements]（[ニュースレター #419][news419 eclair gossip]参照）と
  保留中の受信接続が消費するリソースに制限を設け、[オニオンメッセージ][topic onion messages]とTorの設定変更も含まれています。
  悪意あるノードが修正されたバグの一部を悪用する可能性があるため、アップグレードが強く推奨されます。
  運用者はEclairと同じマシンで`bitcoind`を実行するか、暗号化・認証されたトンネル経由で接続し、
  設定変更については[リリースノート][eclair 0.14.2 notes]を確認してください。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #34075][]は、既存の承認ベースのブロックポリシー推定器と並んで、
  mempoolベースの[手数料率推定器][topic fee estimation]を導入します。
  新しい推定器は、次のブロックの中間および最後の四分位点における[チャンク手数料率][topic cluster mempool]を、
  それぞれ保守的および経済的な推定値として使用します。
  承認を待っているトランザクションが少なすぎる場合、
  [最小リレー手数料率][topic default minimum transaction relay feerates]とmempool最小手数料率のうち高い方にフォールバックします。
  デフォルトでは、`estimatesmartfee`はmempool推定値とブロックポリシー推定値のうち低い方を返すようになり、
  mempoolの状況によって手数料率の推定値を下げることはできても上げることはできません。
  新しい`fee_rate_estimator`オプションを使うと、いずれか一方のアプローチだけに基づく推定値を取得できます。

- [Bitcoin Core #35730][]は、HTTPサーバーに同時接続できるクライアント数を制限する
  `-rpcmaxconnections`設定オプション（デフォルト16）を追加します（[ニュースレター #411][news411 http]参照）。
  上限に達すると、追加の接続はスロットが空くまでアプリケーションのメモリを消費することなくOSのソケットキューに留まります。
  Bitcoin Coreはこれらの接続のファイルディスクリプタ使用量を制限・追跡できるようになり、
  RPCを多用するとファイルディスクリプタが枯渇して無関係な処理が失敗するという長年の問題に対処します。
  この変更はまた、I/Oループの各イテレーションで1接続だけを受け入れるのではなく、
  上限までキューに溜まった接続をすべて受け入れるようにすることで、接続処理も改善しています。

- [Bitcoin Core #35580][]は、実際の[BIP141][]のウェイトではなく、
  トランザクションチャンクのsigops調整後のウェイト（[ニュースレター #416][news416 sigops]参照）を
  最大ブロックウェイトと比較していたブロックテンプレート構築のバグを修正します。
  sigops調整後のウェイトは実効手数料率によってチャンクを順位付けするためのものですが、
  ブロックの有効性は実際のウェイトとsigopコストを別々に制約します。したがって、これまでの動作では、
  両方の制限を満たしているにもかかわらずsigopを多く含む高手数料率のチャンクを誤って除外し、
  マイニング収益を減らしてしまう可能性がありました。

- [Bitcoin Core #35665][]、[#36025][bitcoin core #36025]、[#35516][bitcoin core #35516]は、
  [PSBT][topic psbt]のcombineやjoinに関するいくつかの問題を修正します。1つめの修正は、
  2つのグローバルxpubレコードをマージする際の問題に対処します。PSBTのシリアライズでは
  xpubによってレコードが識別されるにもかかわらず、
  これまでのBitcoin Coreはkey origin（フィンガープリントと導出パス）でレコードをグループ化していました。
  その結果、同じxpubが矛盾するoriginを伴って重複キーとしてシリアライズされ、
  `decodepsbt` RPCが拒否する不正なPSBTが生成されていました。2つめのPRは、
  [Tapscript][topic tapscript]レコードにおける同様の不一致を修正します。
  Tapscriptレコードは内部的にはリーフスクリプトでグループ化されますが、
  コントロールブロックによってシリアライズされます。これまでは、1つのコントロールブロックが異なるスクリプトに関連付けられている場合に
  マージが重複キーを生成したり、同じスクリプトに対する有効なコントロールブロックを破棄したりする可能性がありました。
  3つめのPRは、一部のグローバルメタデータを省いてしまう個別のシャッフル済みPSBTを構築するのではなく、
  マージされたPSBTをその場でシャッフルすることで、`joinpsbts` RPCがグローバルxpubおよびメタデータのレコードを削除する問題を解決します。

- [Bitcoin Core #35933][]と[#34697][bitcoin core #34697]は、
  [MuSig2][topic musig]の[PSBT][topic psbt]処理と[ディスクリプター][topic descriptors]に関するいくつかの問題を修正します。
  1つめのPRは、無効または矛盾したMuSig2の導出メタデータが原因で`analyzepsbt`、`finalizepsbt`、`descriptorprocesspsbt`
  の各RPCが中止されるのを防ぎます。強化導出は通常どおり失敗するようになり、一致しない集約鍵はスキップされるので、
  別の一致する鍵を試すことができます。2つめのPRは、ディスクリプターのパース時に、
  利用可能な秘密鍵情報を用いて強化導出を含む鍵表現を比較することで、ディスクリプター内の重複鍵の検出を改善します。
  これまでは、異なる表現がいずれも解決できずに誤って重複と見なされることがあり、
  同じ参加者を異なる導出パスで再利用する有効な`musig()`ディスクリプターが拒否されていました。
  また、再利用されたMuSig2参加者のkey originが、
  PSBTに保存されている[Taproot][topic taproot]導出メタデータの先頭に二重に付加されるのも防ぎます。

- [Core Lightning #9374][]は、[デュアルファンディング][topic dual funding]チャネルにおいて、
  最新の試行ではなく以前の[RBF][topic rbf]試行が承認された場合に発生し得るチャネル状態のエラーを修正します（
  Eclairにおける類似のバグについては[ニュースレター #418][news418 eclair]参照）。これまでは、
  Core Lightningがまだブロックチェーンに追いついている最中にピアが再接続すると、最新のRBF試行が承認されたものと想定し、
  未承認のファンディングトランザクションにチャネルをロックしてしまう可能性がありました。現在、
  Core Lightningは実際に承認されたファンディングの試行を、そのブロックを処理した時点で記録し、
  チャネルの再確立時にその試行を使用します。

- [Eclair #3342][]は、[BOLTs #1343][]で規定された`option_onion_messages_only_channels`機能ビットを実装します（
  [ニュースレター #416][news416 onion]参照）。チャネルを持つピアに対してのみ[オニオンメッセージ][topic onion messages]をリレーするよう設定されている場合、
  Eclairはこの機能ビットを通知するようになりました。すべてのピアに対してリレーする場合は、
  `option_onion_messages`機能ビットを通知します。

- [Eclair #3321][]は、[BOLTs #1344][]で規定された`update_fulfill_htlc`メッセージへのオプションフィールド
  `fulfillment_payload`のサポートを実装し、[失敗の帰属][topic attributable failures]を成功した支払いにも拡張します（
  [ニュースレター #416][news416 fulfillment]参照）。Eclairはfulfillment payloadをリレーし、
  attributionデータの一部としてそれを認証でき、また自身が支払人である場合には復号できますが、
  支払いの受取人である場合にそれを生成する機能はまだありません。このPRでは、
  成功した支払い経路にattributionデータを先行して追加していたLDK（[ニュースレター #364][news364 ldk attribution]参照）との相互運用性が報告されています。

- [LND #11008][]は、LNDの[PSBT][topic psbt]によるチャネル開設フローにおけるデッドロックの問題を修正します。
  従来は、PSBTのファンディング検証と、キャンセルされたチャネル予約のクリーンアップが同時に実行された場合、
  それぞれの処理が相手の保持するリソースを待つ可能性がありました。これによりLNDの単一の予約ハンドラがスタックし、
  ノードがチャネルを開設したり受け入れたりできなくなり、新たにファンディングされたチャネルが再起動まで動かなくなる可能性がありました。
  この修正では共有状態にアクセスする順序を変更し、2つの処理が互いを無期限にブロックしないようにしています。

- [HWI #841][]は、`displayaddress`コマンドを拡張し、登録済みの[BIP388][]ウォレット[ディスクリプター][topic descriptors]ポリシーに対応するアドレスを、
  アドレスインデックスと受取用/おつり用ブランチで選択してハードウェアデバイス上に表示できるようにします。
  このコマンドは`registerdescriptor`コマンドが返す登録情報を受け取り、BitBox02、Coldcard、Jade、
  Ledgerの各デバイスをサポートします。これは[ニュースレター #419][news419 hwi]で説明されたディスクリプター登録サポートを基盤としています。

- [HWI #849][]は、Coldcardのサポートを更新し、Coldcard Edgeデバイス上でシングルシグの[Taproot][topic taproot]アドレスを表示できるようにします。
  また、PSBTv2をサポートするColdcardファームウェアで署名する際、常にPSBTをバージョン0に変換するのではなく、
  PSBTv2形式を維持するようになりました。このPRではColdcard Edgeシミュレータのカバレッジを追加し、
  シングルシグのトランザクション署名テストを復活させ、テスト対象のColdcardファームウェアをバージョン5.6.0に更新しています。

- [Rust Bitcoin #6755][]は、非標準ながらコンセンサス上は有効なECDSAの署名ハッシュ（sighash）値を使用するトランザクションについて、
  segwit v0の署名検証を修正します。従来、`EcdsaSighashType`はそうした値を`ALL`、`NONE`、`SINGLE`、
  `ANYONECANPAY`と同等の動作を持つ標準的なsighashタイプにマッピングしており、元の値が失われていました。
  厳密な値はsegwit v0の署名ハッシュにも含まれるため、これによりRust Bitcoinが誤ったsighashを計算し、
  コンセンサス上有効で既に承認済みのトランザクションの署名を検証できなくなる可能性がありました。
  新しい表現では元の値が保持され、標準的なsighashタイプを必要とする呼び出し側は引き続き
  `from_standard`を使用できます（[ニュースレター #138][news138 sighash]参照）。

{% include snippets/recap-ad.md when="2026-09-01 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34075,35730,35580,35665,36025,35516,35933,34697,9374,3342,1343,3321,1344,11008,841,849,6755" %}

[cln v26.06.7]: https://x.com/Snyke/status/2092989040098181170
[replay del]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792
[hwi future]: https://github.com/bitcoin-core/HWI/issues/850
[bhwi]: https://github.com/wizardsardine/bhwi
[BTCPay Server 2.4.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.3
[Eclair 0.14.2]: https://github.com/ACINQ/eclair/releases/tag/v0.14.2
[eclair 0.14.2 notes]: https://github.com/ACINQ/eclair/blob/v0.14.2/docs/release-notes/eclair-v0.14.2.md
[news411 http]: /ja/newsletters/2026/06/26/#bitcoin-core-35182
[news416 sigops]: /ja/newsletters/2026/07/31/#bitcoin-core-32800
[news418 eclair]: /ja/newsletters/2026/08/14/#eclair-3346
[news416 onion]: /ja/newsletters/2026/07/31/#bolts-1343
[news416 fulfillment]: /ja/newsletters/2026/07/31/#bolts-1344
[news419 hwi]: /ja/newsletters/2026/08/21/#hwi-842
[news364 ldk attribution]: /ja/newsletters/2025/07/25/#ldk-3801
[news138 sighash]: /ja/newsletters/2021/03/03/#rust-bitcoin-573
[news418 eclair fixes]: /ja/newsletters/2026/08/14/#eclair-3346
[news419 eclair reserves]: /ja/newsletters/2026/08/21/#eclair-3352
[news419 eclair funding]: /ja/newsletters/2026/08/21/#eclair-3351
[news419 eclair gossip]: /ja/newsletters/2026/08/21/#eclair-3345
[rfc del]: https://delvingbitcoin.org/t/rfc-block-range-filters-a-k-a-hierarchical-filters/2735
