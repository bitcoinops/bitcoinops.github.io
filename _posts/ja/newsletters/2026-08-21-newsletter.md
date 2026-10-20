---
title: 'Bitcoin Optech Newsletter #419'
permalink: /ja/newsletters/2026/08/21/
name: 2026-08-21-newsletter-ja
slug: 2026-08-21-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNDのチャネル閉鎖における修正済みの再編成脆弱性の開示と、
`rawtr()`アウトプットスクリプトディスクリプターのBIPドラフトについて掲載しています。
また、サービスやクライアントソフトウェアの最近の更新や、
人気のBitcoin基盤ソフトウェアの注目すべき更新を紹介する恒例のセクションも含まれています。

## ニュース

- **LNDのチャネル閉鎖における再編成の脆弱性**: Bastien Teinturierは、
  [0.20.0][lnd v20.0]より前のバージョンのLNDに影響する脆弱性の[責任ある開示][topic responsible disclosures]を
  Delving Bitcoinに[投稿しました][lnd vuln del]。この脆弱性は2026年2月にリリースされた0.20.0で修正されています。
  古いバージョンを実行しているオペレーターはアップグレードが必要です。Teinturierの知る限り、この脆弱性による影響を受けた人はいません。

  当該バージョン以前のLNDノードは、協調的に閉鎖されたチャネルについて、
  クロージングトランザクションが最初にオンチェーンで承認された直後にそのチャネルに関する情報を破棄してしまう挙動がありました。
  これにより、チェーンの再編成に対する保護が失われていました。もし再編成によってその承認が取り消された場合、
  攻撃者はそのチャネルの古い（失効済みの）コミットメントトランザクションをブロードキャストすることができ、
  ノードは既にチャネルのことを忘れているためペナルティトランザクションを発行できず、
  攻撃者にチャネルの資金をすべて奪われる恐れがありました。

  この脆弱性は2025年2月に発見され、[LND #10331][]（[ニュースレター #389][news389 lnd10331]参照）で修正されました。
  この修正により、ノードはチャネル閉鎖を確定とみなす前により多くの承認（[BOLT5][]の再編成の安全性の扱いに従い、少なくとも6承認）を待つようになります。
  Teinturierの投稿には、regtestでの再現手順と開示のタイムラインが記載されています。

- **`rawtr()`アウトプットスクリプトディスクリプターのBIPドラフト**: Jean Pabloは、
  `rawtr()`[アウトプットスクリプトディスクリプター][topic descriptors]のBIP提案について
  Bitcoin-Devメーリングリストに[投稿しました][rawtr ml]。

  `rawtr()`ディスクリプターは、内部鍵やスクリプトツリーを必要とせず、
  アウトプット鍵によって直接P2TRアウトプットを表現するために使用できます。これは例えば、
  内部構造が分からない場合や、スクリプトツリーが所有者によって開示されていない場合に便利です。

  このディスクリプターはBitcoin Coreのバージョン24.0以降で利用可能でしたが、
  正式なBIPとして仕様化されていませんでした。いくつかの実装は、これをサポートしないか、
  他のBIPを引用することでこの問題を回避しています。今回の提案はこのギャップを埋めることを目指しています。
  BIPドラフトはテストベクターとともに公開されており、[BIPs #2251][]で議論されています。

## サービスとクライアントソフトウェアの更新

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Payjoin Dev Kit (rust-payjoin) 1.0.0のリリース:**
  Payjoin Dev Kitプロジェクトが、rust-payjoinの最初の安定版を[リリースしました][payjoin 1.0.0]。
  同期型のBIP78 [Payjoin][topic payjoin]と、セッションの永続化と再開が可能な非同期型のBIP77 Payjoinの両方をサポートします。

- **Electrum向けサイレントペイメント送信プラグイン:**
  Ali Sheriefは、シングルシグ・ソフトウェアウォレットであるElectrumデスクトップウォレットに
  [サイレントペイメント][topic silent payments]（BIP352）の送信機能（受信は非対応）を追加するプラグインを[リリースしました][sp electrum delving]。

- **Superscalarの実装の発表:**
  8144225309氏が、Superscalarの実装を[発表しました][superscalar delving]。Superscalarは、
  ZmnSCPxjによる[チャネルファクトリー][topic channel factories]の設計で、
  ソフトフォークなしで多数のセルフカストディ型ライトニングクライアントを単一のオンチェーンUTXOの背後に配置するものです（
  [Superscalarのディープダイブ・ポッドキャスト][superscalar deepdive]もご覧ください）。

- **Cofundマルチシグウォレットの発表:**
  Cofundが、ポリシーベースの[Taproot][topic taproot]（P2TR）アーキテクチャ上に構築され、
  マルチベンダーの鍵登録と階層型マルチシグを備えたセルフカストディ型[マルチシグ][topic multisignature]ウォレットを[発表しました][cofund x]。

- **Lexeが人が読みやすいアドレスとLNURL-withdrawを追加:**
  Lexeは、各ユーザーのノードをTEE（Trusted Execution Environment）内で実行することで、
  オペレーターが資産を管理することなくノードをオンラインに保つセルフカストディ型ライトニングウォレットです。
  同社は、[BIP353][]に基づく人が読みやすいビットコインアドレス（ライトニングアドレスとしても機能）と[LNURL-withdraw][topic lnurl]のサポートを[発表しました][lexe x]。

- **Ledger Bitcoinアプリ2.5.0が人が読みやすいポリシー説明を追加:**
  Salvatore Ingalaは、Ledger Bitcoinアプリのバージョン2.5.0を[発表しました][salvatoshi x]。
  このバージョンでは、多くの[Taproot][topic taproot] [Miniscript][topic miniscript]および[マルチシグ][topic multisignature]ウォレットポリシーについて、
  登録時に難解な[ディスクリプター][topic descriptors]テンプレートだけでなく、人が読みやすい説明を表示します。
  これにより、ユーザーがポリシーを検証し、登録前に悪意ある置き換え（3-of-5が1-of-5に置き換えられているなど）を発見することが容易になります。

- **Bark 0.5.0リリース:**
  Secondが、同社の[Ark][topic ark]実装であるBarkのバージョン0.5.0を[リリースしました][second x]。
  ニーモニックからウォレットのオフチェーン残高全体（VTXO）を復元する機能と、
  外部Arkアドレスへのライトニング受信のサポートが追加され、これによりノンカストディアルなライトニングアドレスサーバーが可能になります。

- **プライベートなUTXOクエリのためのBitcoin-PIR:**
  Weikeng Chenは、Bitcoin-PIRを[発表しました][bitcoinpir]。これはPIR（Private Information Retrieval）システムで、
  軽量クライアントが、どのUTXOに関心があるかをサーバーに明かすことなく、
  自身のアドレスやscriptPubKeyに対応するUTXOセットを確認できるようにするものです。DPF-PIR、HarmonyPIR、OnionPIRv2、
  そしてTEE（Trusted Execution Environment）を活用したORAMスキームという4つのPIRバックエンドを選択できます。

- **OP_TEMPLATEHASHを使用したArkのデモンストレーション:**
  Steven Rooseは、Second社の[Ark][topic ark]実装であるBarkを`OP_TEMPLATEHASH`を使用して動作させるsignetデモンストレーションを[立ち上げました][templatehash]。
  `OP_TEMPLATEHASH`は、Taprootネイティブな[CTV][topic op_checktemplateverify]スタイルの[コベナンツ][topic covenants] opcodeです。
  このデモはBarkの[リポジトリ][bark gitlab]の`templatehash`ブランチからビルドされています。

- **libshrincs: 形式検証されたハッシュベース署名:**
  Jonas Nickは、libshrincsを[発表しました][libshrincs delving]。これはremix7531氏によって書かれた、
  機械検証されたセキュリティ証明を伴う[耐量子性][topic quantum resistance]のあるハッシュベース署名のC言語実装です。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32784][]は、`derivehdkey`ウォレットRPCコマンドを追加します。
  このコマンドは、ウォレットが認識している[HD鍵][topic bip32]から、
  呼び出し元が指定した導出パス（少なくとも1回の強化導出ステップを含む必要がある）に基づいて、
  xpubおよびオプションでxprvも導出します。これは、各参加者がウォレットのデフォルトのシングルシグ[ディスクリプター][topic descriptors]とは
  異なるパスから導出したxpubを提供する、マルチシグウォレットのコーディネートに便利です。
  強化導出には秘密鍵が必要であるため、このRPCは監視専用ウォレットでは利用できず、
  暗号化されたウォレットはロックを解除する必要があります。

- [Bitcoin Core #35797][]は、[`descriptorprocesspsbt`][topic descriptors]
  RPC（[ニュースレター #253][news253 descriptorpsbt]参照）を使用する際に、
  インプットが追加される前に[PSBT][topic psbt]v2のアウトプットメタデータを設定できるようにします。
  これまで、`UpdatePSBTOutput`はアウトプットスクリプトを走査する際に、
  PSBTの未署名トランザクションの最初のインプットを使用しており、
  PSBTv2にアウトプットは含まれるがインプットが含まれない場合に失敗する可能性がありました。
  今回の変更により、PSBTを変更することなく、ダミーインプットを含む一時的なトランザクションを使用してメタデータの走査が行われるようになりました。

- [Bitcoin Core #35531][]は、トランザクション識別子と位置の保存方法を変更することで、
  `-txindex`オプション（[ニュースレター #161][news161 txindex]参照）が使用するディスク容量を削減します。
  32 byteのtxidとトランザクションのディスク位置をそのまま保存する代わりに、
  新しいフォーマットではtxidのソルト付き[SipHash][]の5 byteプレフィックスを使用し、
  データベースキーのコンパクトな6 byteサフィックスにブロックのシーケンス番号とトランザクションオフセットをエンコードし、値は空にします。
  ルックアップでは、プレフィックスを共有するすべてのエントリをスキャンし、
  ブロックインデックスを使って各候補のブロック位置を特定し、
  ディスクからトランザクションを読み込んだ後に完全なtxidを検証することで、衝突を安全に処理します。
  PR作成者のmainnetのテストでは、完全に再構築したインデックスは約66 GBから26 GBへ縮小し、
  インデックス作成時間は約1時間50分から1時間19分に短縮されました。
  既存のインデックスは引き続き読み取り可能ですが、容量を解放するには再構築が必要です。
  再構築後、古いバージョンのBitcoin Coreは新しいエントリを読み取れなくなり、
  ダウングレードする際にもインデックスの再構築が必要になります。

- [Bitcoin Core #35889][]は、大量のアウトポイントを確認する際の`gettxspendingprevout` RPCのパフォーマンスを改善します。
  これまでは、アウトポイントを消費するトランザクションがmempoolで見つかった場合、
  mempoolロックを保持したままそのアウトポイントがベクターの中央から消去され、
  残りのエントリのシフトを強いていました。今後、RPCは各リクエストを1回スキャンし、
  解決済みの結果を元のインデックス位置に保存し、未解決のアウトポイントのみを別のワークリストに収集して、
  オプションの`txospenderindex`（[ニュースレター #394][news394 txospender]参照）経由でルックアップします。
  これにより、mempoolの処理時間は二次オーダーではなく線形になります。
  PR作成者のベンチマークによると、mempoolのみの大規模なリクエストバッチは、
  Ryzen 7 3700Xで約9倍、Raspberry Pi 5で31倍高速に完了しました。

- [Bitcoin Core #35605][]は、`removeprunedfunds`ウォレットRPCを非推奨とし、デフォルトで無効にします。
  引き続き必要なユーザーは、`-deprecatedrpc=removeprunedfunds`起動オプションを使用する必要があります。
  このRPCは次のメジャーリリースで削除される予定です。削除の理由は、
  既知の有用な用途がないまま危険な動作を引き起こす可能性があるためです。このRPCは、
  関連する`importprunedfunds` RPC経由で追加されていないトランザクションを含め、
  ウォレットに属するすべてのトランザクションを削除できてしまいます。また、メンテナンスの負担にもなっています。
  このRPCに関連する過去のバグについては[ニュースレター #391][news391 removeprunedfunds]を参照してください。

- [Eclair #3352][]は、Eclairがシングルファンド型チャネルの受け手である場合に欠けていた[BOLT2][]のチャネル準備金チェックを修正し、
  いずれの当事者のダストリミットも相手方のチャネル準備金を超えないようにします。
  これらのチェックがないと、ピアは自身の残高を該当するダストリミットを下回る準備金まで使い切ることができ、
  そのアウトプットがコミットメントトランザクションから除外され、
  失効した状態を公開する際にリスクにさらされるオンチェーン資金がなくなる可能性がありました。
  またこのPRは、設定可能なチャネルサイズ制限`eclair.channel.max-funding-satoshis`を追加し、
  デフォルトは50億satoshi（50 BTC）に設定されます。
  これは、[Wumboチャネル][topic large channels]のサポートにより
  従来のプロトコル制限を超えるチャネルが許可されるようになった後の上限を復活させるものです。

- [Eclair #3351][]は、[オンザフライファンディング][topic jit channels]（[ニュースレター #323][news323 fly]参照）における複数のバグを修正します。
  この機能は現在、Phoenix WalletにおけるACINQのLSP（Lightning Service Provider）ノードで使用されています。
  具体的には、再起動後、Eclairは保留中のチャネル変更のみをチェックしていたため、
  [HTLC][topic htlc]が既に完全にクロス署名されていることを認識できないことがありました。
  これにより、同じ支払いが2回リレーされる可能性がありました。
  今後、Eclairはリレー前に現在のコミットメント状態もチェックするようになります。
  加えてこのPRは、対応する上流のHTLCが失敗した後にEclairが下流のピアに支払いを行わないように、
  複数のタイムアウトおよびオンチェーン障害パスを解決します。

- [Eclair #3345][]は、[BOLT7][]ゴシップクエリを通じて[チャネルアナウンスメント][topic channel announcements]を要求および同期する際に、
  各ピアが消費できるリソースを制限します。設定可能なレート制限（デフォルトで1秒あたり5リクエスト）が、
  接続ごとに`query_channel_range`と`query_short_channel_ids`にまたがって適用されます。
  Eclairは、トランスポートのバックプレッシャーを維持するため、クエリの応答が送信されるまで新たな処理を受け付けません。
  Eclairは応答の増幅を防ぐために重複するショートチャネルID（SCID）を無視し、不正な形式または重複するクエリを拒否します。
  また、同期中のメモリ使用量を抑えるため、ピアごとにキューに入れられる`query_short_channel_ids`リクエストの数を2,000件に制限しています。
  同様のリソース管理保護機能は以前LNDにも追加されました（ニュースレター[#366][news366 lnd gossip]および[#417][news417 lnd gossip]参照）。

- [LND #8754][]は、リモート署名者（[ニュースレター #172][news172 remote]参照）向けの実験的なアウトバウンド接続モードを実装します。
  リモート署名者は、秘密鍵操作を別の署名サーバーに委譲するものです。
  署名者は依然として受信したリクエストを独立して検証しないため、監視専用ノードから送信された任意のリクエストに署名します。
  この新しいモードで変わるのは両者の接続方法のみです。
  署名者がインバウンド接続を待ち受ける代わりに、監視専用ノード上の専用RPCリスナーに対してアウトバウンド接続を開始することで、
  署名者がインバウンド接続を受け付けることなく動作できるようになります。
  この構成については、以前[ニュースレター #326][news326 signer]で決定論的なmacaroon生成に関連して議論されました。

- [LND #11065][]は、実験的な`XCreateAccount` RPCおよび対応する`lncli wallet accounts create`コマンドを追加します。
  これらは、LNDのウォレットマスター鍵から鍵を導出する、名前付きで完全に使用可能なアカウントを作成するためのものです。
  これは、監視専用のxpubをインポートする既存の`ImportAccount` RPC（[ニュースレター #144][news144 lnd xpub]参照）とは異なります。
  [コイン選択][topic coin selection]、残高、アドレス導出およびお釣りをアカウント単位に管理でき、
  1つのウォレット内で分離された資金の領域（ポケット）を提供します。
  選択されたアドレスタイプは固定され、デフォルトは[Taproot][topic taproot]です。

- [HWI #842][]は、ウォレットからトランザクションに署名する前に、
  対応するハードウェア署名デバイスに名前付きの[アウトプットスクリプトディスクリプター][topic descriptors]を登録するための
  `registerdescriptor`コマンドを追加します。
  BitBox02、Coldcard、Jade、および非レガシーのLedgerデバイス向けの実装が追加されています。
  [BIP388][]ウォレットポリシー（[ニュースレター #302][news302 bip388]参照）を使用するデバイスの場合、
  HWIはディスクリプターをウォレットディスクリプターテンプレートと鍵情報ベクターに変換し、
  後の署名に必要なデバイス固有の登録データも返します。

{% include snippets/recap-ad.md when="2026-08-25 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="10331,2251,32784,35797,35531,35889,35605,3352,3351,3345,8754,11065,842" %}

[payjoin 1.0.0]: https://github.com/payjoin/rust-payjoin/releases/tag/payjoin-1.0.0
[sp electrum delving]: https://delvingbitcoin.org/t/silent-payments-sender-bip352-plugin-for-electrum/2743
[superscalar delving]: https://delvingbitcoin.org/t/superscalar-an-implementation-report/2705
[superscalar deepdive]: /en/podcast/2024/10/31/
[cofund x]: https://x.com/getcofund/status/2085389177193972164
[lexe x]: https://x.com/lexeapp/status/2079245197817548964
[salvatoshi x]: https://x.com/salvatoshi/status/2086727660353261863
[second x]: https://x.com/secondhq/status/2084716752789991614
[bitcoinpir]: https://bitcoinpir.org
[templatehash]: https://templatehash.com
[bark gitlab]: https://gitlab.com/ark-bitcoin/bark
[libshrincs delving]: https://delvingbitcoin.org/t/libshrincs-a-c-implementation-with-a-machine-checked-security-proof/2795
[lnd vuln del]: https://delvingbitcoin.org/t/disclosure-lnd-doesnt-wait-for-enough-confirmations-when-closing-channels/2800
[lnd v20.0]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta
[news389 lnd10331]: /ja/newsletters/2026/01/23/#lnd-10331
[rawtr ml]: https://groups.google.com/g/bitcoindev/c/CCZN_qQ5C1s
[SipHash]: https://en.wikipedia.org/wiki/SipHash
[news253 descriptorpsbt]: /ja/newsletters/2023/05/31/#bitcoin-core-25796
[news161 txindex]: /ja/newsletters/2021/08/11/#bitcoin-core-pr-review-club
[news394 txospender]: /ja/newsletters/2026/02/27/#bitcoin-core-24539
[news391 removeprunedfunds]: /ja/newsletters/2026/02/06/#bitcoin-core-34358
[news323 fly]: /ja/newsletters/2024/10/04/#eclair-2861
[news172 remote]: /ja/newsletters/2021/10/27/#lnd-5689
[news326 signer]: /ja/newsletters/2024/10/25/#lnd-9172
[news366 lnd gossip]: /ja/newsletters/2025/08/08/#lnd-10097
[news417 lnd gossip]: /ja/newsletters/2026/08/07/#lnd-10992
[news302 bip388]: /ja/newsletters/2024/05/15/#bips-1389
[news144 lnd xpub]: /ja/newsletters/2021/04/14/#lnd-5047