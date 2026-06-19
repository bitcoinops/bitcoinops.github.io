---
title: 'Bitcoin Optech Newsletter #410'
permalink: /ja/newsletters/2026/06/19/
name: 2026-06-19-newsletter-ja
slug: 2026-06-19-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ウォレットが作成するトランザクションからオプトイン方式のRBFシグナリングを削除する議論を掲載しています。
また、サービスとクライアントソフトウェアの最近の更新や、人気のBitcoin基盤ソフトウェアの注目すべき更新など、
恒例のセクションも含まれています。

## ニュース

- **ウォレットトランザクションからRBFシグナリングを削除する議論**:
  rkruxは、ウォレットがトランザクションの[オプトインRBF][topic rbf]シグナリングを停止する提案について
  Bitcoin-Devメーリングリストに[投稿しました][bip125 ml]。トランザクションは、
  [BIP125][]において、インプットの少なくとも1つの`nSequence`を`MAX-1`未満（`MAX`は`0xffffffff`）に
  設定した場合に置換可能であることをシグナリングします。しかし、フルRBFがデフォルトとなり（[ニュースレター #315][news315 fullrbf]参照）、
  `mempoolfullrbf`オプトアウトが削除されたため（[ニュースレター #329][news329 fullrbf]参照）、
  このシグナリングはトランザクションの置換可能性に影響を与えなくなりました。Bitcoin Coreのデフォルトリレーポリシーを使用するノードは、
  `nSequence`の値に関係なくすべてのトランザクションを置換します。現在、シグナリングは主に
  トランザクションを作成したウォレットを識別するために使用されているため、投稿ではウォレットが単一の値に収束すべきだと主張しています。

  rkruxは、`nSequence = MAX - 1`を使用してBitcoin Coreウォレットがデフォルトでシグナリングしないよう
  [Bitcoin Core #35405][]を公開し、他のウォレット開発者にどの値であれば標準化可能かを尋ねました。
  MurchとElectrum WalletのコントリビューターであるSomberNightは、
  `MAX - 2`が既に主流の値であり、[mainnet Observer][bip125 graph]によるとトランザクションの約75%、
  Electrum Walletのトランザクションほぼすべてで使用されていると指摘しました。ほとんどのトランザクションは、
  依然としてシグナルを発信しており、Bitcoin Coreをシグナルを発信しない`MAX-1`に移行すると、
  そのトランザクションは紛れ込むどころかかえって目立ってしまうことになるため、両者とも`MAX-2`への収束を支持しました。
  rkruxはこのフィードバックを受けて、プルリクエストをクローズしました。

## サービスとクライアントソフトウェアの更新

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Sparrow Wallet 2.5.0がサイレントペイメントの受信に対応:**
  Sparrow [2.5.0][sparrow 2.5.0]は、エアギャップ環境のハードウェアウォレット署名者を含む
  [サイレントペイメント][topic silent payments]の受信ウォレットに対応しました。
  これは2.3.0で追加された送信サポート([ニュースレター #377][news377 sparrow] 参照)をベースとしています。

- **BarkがBitcoin mainnetで稼働開始:**
  Secondは、同社の[Ark][topic ark]プロトコル実装であるBarkがBitcoinのmainnetで稼働を開始したことを[発表しました][bark mainnet]。
  公開Arkサーバーに加え、開発者向けのBark SDKと`barkd`デーモンが提供されます。Barkは以前
  signetで立ち上げられていました([ニュースレター #346][news346 bark] 参照)。

- **Arké Arkウォレットの発表:**
  [Arké][arke]は、[Ark][topic ark]プロトコルをオンチェーン([BDK][bdk repo])および
  ライトニング支払いと統合したネイティブiOSウォレットで、3つのレイヤーすべてのトランザクションを単一の統合された履歴として表示します。
  現在はsignet上で稼働しており、mainnet対応は開発中です。

- **Noah Arkウォレットの発表:**
  [Noah][noah]は、[Ark][topic ark]プロトコル上に構築されたクロスプラットフォームのモバイルウォレットで、
  ライトニングサポートと信頼を最小に抑えた設計になっています。現在はベータ版です。

- **Alby Hub v1.23.0のリリース:**
  Alby Hub [v1.23.0][alby hub v1.23.0]は、着信支払いを受け入れるために自動的に開かれる
  [JITチャネル][topic jit channels]や、実験的な[Ark][topic ark]支払いバックエンドなど、各種の改善を追加しました。

- **JoinMarket NG 0.32.0のリリース:**
  [coinjoin][topic coinjoin]実装のコミュニティ管理フォークであるJoinMarket-NGは、
  [Neutrino][topic compact block filters]バックエンド向けのmempoolサポートを[リリースしました][joinmarket 0.32.0]。
  これにより、テイカーがメイカーのブロードキャストを検証できるようになり、フィデリティボンドや信頼性に関する改善も含まれています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #35221][]は、[BIP434][]のピア機能ネゴシエーションフレームワーク(ニュースレター [#386][news386 bip434]および
  [#390][news390 bip434]参照)のサポートを追加します。これは、`version`と`verack`の間で交換され得る
  `feature` P2Pメッセージを追加してオプションのピア機能を通知し、P2Pプロトコルバージョン番号を
  `70017`に引き上げます。Bitcoin Coreは現在、ネゴシエーション機構を実装しており、
  未知の有効な機能IDは無視し、不正な形式の`feature`メッセージを送信したり、`verack`の後にそれらを送信したり、
  互換性のあるプロトコルバージョンをネゴシエートせずに送信したりするピアを切断します。
  ただし、特定のオプション機能はまだ通知していません。

- [Bitcoin Core #35254][]は、使用後に追加の鍵導出材料をメモリから消去します。
  `CHMAC_SHA256`と`CHMAC_SHA512`は、[BIP32][topic bip32]のチェーンコードや
  [BIP324][topic v2 p2p transport] HKDF鍵材料から導出されたデータを含む可能性のある一時的な`rkey`
  および内部ハッシュ用の`temp`スタックバッファをクレンジングするようになりました。`ChainCode`の型は
  `uint256`のtypedefから`memory_cleanse()`デストラクタを持つ型に変更され、
  これらのオブジェクトが破棄される際に拡張鍵やローカル変数内の[BIP32][]チェーンコードを消去します。

- [Bitcoin Core #35498][]は、切断中のピアにブロックを要求する際の`FetchBlock`
  RPCパスにおける競合状態を修正します。`FetchBlock`は`cs_main`をロックする前に有効なピア参照を取得できましたが、
  `BlockRequested()`が要求を記録する前にピアのクリーンアップによってピアの`CNodeState`が削除される可能性があり、
  アサーションエラーを引き起こしていました。この修正では、ピアを検索する前に`cs_main`をロックすることで、
  ブロック要求が登録されている間にピアの状態が削除されないようにします。

- [Eclair #3318][]は、Eclairが新たにロックされた[スプライシング][topic splicing]ファンディングトランザクションのローカル状態を
  `splice_locked`を送信せずに更新してしまう、再接続時のエッジケースを修正します。これは、
  Eclairが`channel_reestablish`を送信した後、ピアの`channel_reestablish`を受信する前に発生する可能性があり、
  どのファンディング状態が`commit_sig`メッセージを必要とするかについてピア間の同期がずれ、
  強制閉鎖を引き起こしていました。Eclairは再接続中に資金ロックイベントを処理し、
  必要に応じて`splice_locked`を送信するようになりました。

- [LND #10789][]は、[BOLT12オファー][topic offers]の実装に向けた基盤を整えます。すなわち、
  `Offer`メッセージ型とそれをサポートする`lnwire`TLVインフラを備えた、デーモン非依存の`bolt12`コーデックパッケージです。
  新しいコーデックはエンコード前にメッセージを検証し、診断やファジング向けに低レベルのデコードを許容し、
  未知の符号付き範囲TLVを保持することで、デコードと再エンコードをまたいで`offer_id`が安定するようにします。

- [Rust Bitcoin #6321][]は、攻撃者が要素数を操作して過剰なメモリ割り当てが引き起こされるのを防ぐため、
  [Segwit][topic segwit]のウィットネスデコードを堅牢化します。これまでは、
  わずか数byteの入力で大きなウィットネススタックを占有し、ウィットネスインデックス領域に約16MBの割り当てを強制できました。
  新しいデコーダーは受信したウィットネスbyteをコンテンツバッファに追加し、ウィットネスデータのデコード後に
  `end()`で要素インデックスを構築することで、従来の一括割り当てパスを排除します。

- [LDK #4685][]は、[BOLT12][topic offers]インボイス検証に使用されるナンスを、
  インボイスリクエストまたはリファンドのpayerメタデータに戻します。このナンスは以前、
  [ブラインド応答パス][topic rv routing]の`OffersContext`にも保存されていたため削除されていましたが、
  それによってインボイスの検証がインボイスリクエストやリファンド自体の外部にある状態に依存することになり、
  今後の[BOLT12][][ペイメントプルーフ][topic proof of payment]と互換性がありませんでした([ニュースレター #405][news405 proof] 参照)。
  アウトバウンドのofferおよびリファンドのreply-pathコンテキストは、現在では期待される
  `PaymentId`のみを保存するようになり、これは受信したインボイスのpayerメタデータから復元されたpayment IDと照合されます。

{% include snippets/recap-ad.md when="2026-06-23 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35405,35221,35254,35498,3318,10789,6321,4685" %}

[bip125 ml]: https://groups.google.com/g/bitcoindev/c/C7zNIk8llew/m/YAdpwe33AgAJ
[bip125 graph]: https://mainnet.observer/charts/transactions-signaling-explicit-rbf/
[news315 fullrbf]: /ja/newsletters/2024/08/09/#bitcoin-core-30493
[news329 fullrbf]: /ja/newsletters/2024/11/15/#bitcoin-core-30592
[sparrow 2.5.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.5.0
[news377 sparrow]: /ja/newsletters/2025/10/24/#sparrow-2-3-0
[bark mainnet]: https://blog.second.tech/bark-now-on-bitcoin-mainnet/
[arke]: https://github.com/GBKS/arke
[noah]: https://github.com/smolcars/noah
[news346 bark]: /ja/newsletters/2025/03/21/#bark-signet
[alby hub v1.23.0]: https://github.com/getAlby/hub/releases/tag/v1.23.0
[joinmarket 0.32.0]: https://github.com/joinmarket-ng/joinmarket-ng/releases/tag/0.32.0
[news386 bip434]: /ja/newsletters/2026/01/02/#peer-feature-negotiation
[news390 bip434]: /ja/newsletters/2026/01/30/#bips-2076
[news405 proof]: /ja/newsletters/2026/05/15/#core-lightning-9116
