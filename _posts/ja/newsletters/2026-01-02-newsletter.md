---
title: 'Bitcoin Optech Newsletter #386'
permalink: /ja/newsletters/2026/01/02/
name: 2026-01-02-newsletter-ja
slug: 2026-01-02-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---

今週のニュースレターでは、ブラインドMuSig2を用いたVaultのようなスキームの概要と、
Bitcoinクライアントが新しいP2P機能のサポートをアナウンスしネゴシエーションするための提案を掲載しています。
また、コンセンサスの変更に関する議論や、新しいリリースとリリース候補の発表、
人気のBitcoin基盤ソフトウェアの注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **ブラインド共同署名者を用いたVaultの構築:** Jonathan T. Halsethは、
  ブラインド共同署名者を用いた[Vault][topic vaults]のようなスキームのプロトタイプを
  Delving Bitcoinに[投稿しました][halseth post]。共同署名者を用いた従来のセットアップとは異なり、
  このスキームは、[MuSig2][topic musig]の[ブラインド版][blinded musig]を用いることで、
  署名者が署名に関わる資金について可能な限り情報を持たないようにします。
  署名者が与えられたものに盲目的に署名するようなことを防ぐため、
  このスキームでは署名要求にゼロ知識証明を添付し、
  トランザクションが事前に定められたポリシー（この場合は[タイムロック][topic timelocks]）に従って有効であることを保証します。

  Halsethは、初期デポジット、リカバリー、Vaultの解除およびVaultの解除後のリカバリーという
  4つのトランザクションが事前署名されるスキームのグラフを提供しています。Vaultの解除時に、
  共同署名者は署名するトランザクションに適切な[タイムロック][topic timelocks]が正しく設定されていることのゼロ知識証明を要求します。
  これにより、不正なVaultの解除が行われた場合に、ユーザーまたはウォッチタワーが資金をスイープする時間を確保できます。

  Halsethは、regtestおよびsignetで利用可能な[プロトタイプ実装][halseth prototype]も提供しています。

- **<!--peer-feature-negotiation-->ピア機能のネゴシエーション**: Anthony Townsは、
  ピアが新機能のサポートをアナウンスおよびネゴシエーションできるようにするP2Pメッセージを定義した
  新しい[BIP][towns bip]の提案をBitcoin-Devメーリングリストに[投稿しました][peer neg ml]。
  このアイディアは2020年に[提案されたもの][feature negotiation ml]と似ており、
  Townsの[テンプレートの共有][news366 template]の取り組みを含む、さまざまなP2Pユースケースの提案に役立つでしょう。

  歴史的に、P2Pプロトコルの変更は、新機能のサポートを通知するためのバージョンの引き上げに依存しており、
  ピアが互換性のあるノードとのみネゴシエーションすることを保証していました。しかしこのアプローチは、
  特に共通の採用を必要としない機能について、実装間で不必要な調整の負担を発生させます。

  このBIPは、今後のP2Pアップグレードに対応できるように、[verack][verack]前のフェーズで
  アナウンスおよびネゴシエーションするための汎用的なP2Pメッセージを導入することで、
  [BIP339][]のメカニズムを一般化することを提案しています。
  これにより、調整負担の軽減、パーミッションレスな拡張性の実現、ネットワーク分断の防止、
  多様なクライアントとの互換性の最大化が可能になります。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **<!--year-2106-timestamp-overflow-uint64-migration-->2106年のタイムスタンプオーバーフローのuint64への移行**:
  Asher Haimは、Bitcoin開発者に対してブロックタイムスタンプをuint32からuint64へ移行する迅速な準備の呼びかけを
  Bitcoin-Devメーリングリストに[投稿しました][ah ml uint64 ts]。Haimは、
  2106年以降を参照する長期金融契約が驚くほど早く現れる可能性があることから、迅速な対応が必要な理由を説明しています。
  これはまだBIP形式の具体的な提案ではなく、タイムロックやBitcoinエコシステムの他のパーツに関連する多くの詳細を追加で詰める必要があります。
  2024年1月の[BitBlend][bb 2024]の提案が1つの具体的な解決策として挙げられています。

- **<!--year-2106-timestamp-overflow-uint64-migration-->2106年のソフトフォークに向けた[BIP54][]タイムスタンプ制限の緩和**:
  Josh Domanは、2106年のブロックタイムスタンプオーバーフロー問題に対するソフトフォークソリューションを可能にするため、
  [コンセンサスクリーンアップ提案][topic consensus cleanup]を修正して特殊なブロックタイムスタンプの動作をより許容するようにすることに価値があるかどうかの問いかけを
  Bitcoin-Dev[メーリングリスト][jd ml bip54 ts]と[Delving Bitcoin][jd delving bip54 ts]に投稿しました。
  ZmnSCPxjは、2021年に類似の[提案をしていました][zman ml ts2106]。両フォーラムの議論は、
  ハードフォークを追求すべき健全なエンジニアリング上の理由がある場合に、
  それを回避することに価値があるかどうかという問いに集中しました。Greg Maxwellは、
  [BIP54][]が解決しようとしている[タイムワープ][topic time warp]攻撃の修正を元に戻すリスクだけでも、
  このような形で制限を緩和しようとすべきでない十分な理由になると[述べました][gm delving bip54]。

- **CTVフットガンの理解と軽減**: Chris Stewartは、
  [`OP_CHECKTEMPLATEVERIFY` (CTV)][topic op_checktemplateverify]を用いた「フットガン」（
  自分の足を撃つような落とし穴）についての議論をDelving Bitcoinに[投稿しました][cs delving ctv]。
  具体的には、インプットが1つのCTVハッシュで、指定されたアウトプットの合計金額よりも低い金額が、
  そのCTVハッシュを無条件に要求する`scriptPubKey`に送金された場合、その結果のアウトプットは永遠に使えなくなります。
  彼は、CTVユーザーがすべてのCTVがハッシュを2つ以上のインプットにコミットすることで、
  この問題を軽減できると提案しています。こうすることで、常に追加のインプットを構築し、
  そのようなアウトプットを使用可能にすることができます。

  Greg Sandersはこのアプローチのいくつかの制限について回答し、
  1440000bytesはこれは次のトランザクションテンプレートが無条件に強制される場合にのみ適用されると言及しました。
  Greg Maxwellは、これがトランザクションテンプレート[コベナンツ][topic covenants]全般を避けるべき理由だと主張しました。
  Brandon Blackは、受け取りアドレスでのCTVの使用は確かにリスクのあるアプリケーション設計であり、
  [`OP_CHECKCONTRACTVERIFY`][topic matt]（[BIP443][]）などの別のopcodeをCTVと組み合わせることで、
  より安全なアプリケーションが可能になるかもしれないと示唆しました。

- **<!--ctv-activation-meeting-->CTVアクティベーション会議**: 開発者の1440000bytesは、
  CTV（[BIP119][]）アクティベーション[会議][ctv notes1]を[開催しました][fd0 ml ctv]。
  会議の参加者は、CTVアクティベーションクライアントは保守的なパラメーター（つまり、
  長いシグナリング期間とアクティベーション期間）と[BIP9][]を使用すべきであることに同意しました。
  執筆時点で、他の開発者はメーリングリストで意見を表明していません。

- **より安価なコンソリデーションを可能にする`OP_CHECKCONSOLIDATION`**: billymcbipは、
  コンソリデーション（統合）に特化して最適化されたopcodeを[提案しました][bmb delving cc]。
  `OP_CHECKCONSOLIDATION`（CC）は、同じトランザクション内のより先にあるインプットと同じ
  `scriptPubKey`を持つインプットに対して実行された場合にのみ1と評価されます。
  多くの議論は、同じ`scriptPubKey`の使用を義務付けることがアドレスの再利用を促進し、
  プライバシーを侵害するという点に集中しました。Brandon Blackは、
  `OP_CHECKCONTRACTVERIFY`（[BIP443][]）を用いた同様の（ただしbyte効率は落ちる）機能を提案しました。
  この提案は、Tadge Dryjaの以前の`OP_CHECKINPUTVERIFY`の[研究][news379 civ]に似ていますが、
  byte効率が大幅に高く汎用性は低いです。

- **Bitcoinのポスト量子時代にむけたハッシュベースの署名**: Mikhail KudinovとJonas Nickは、
  Bitcoinで使用するためのハッシュベースの署名の評価に関する取り組みについて、
  Bitcoin-Devメーリングリストに[投稿しました][mk ml hash]。
  彼らの研究では、現在の標準化された手法と比較して署名サイズを最適化できる大きな可能性が見出されたものの、
  [BIP32][]、[BIP327][]、[FROST][news315 frost]に代わる適切な手法は見つかりませんでした。
  複数の開発者が参加し、この研究や他の[ポスト量子署名][topic quantum resistance]メカニズム、
  そしてBitcoin開発の潜在的な方向性について議論しました。

  また、新しい署名検証メカニズムをbyteあたりのCPUサイクル数で比較するのが適切か、
  署名あたりのCPUサイクル数で比較するのが適切かについても議論されました。
  新しい署名検証が既存のウェイト制限と乗数によって制限され、支払いスループットが低下する場合は、
  byteあたりのCPUサイクル数の方が適切と思われます。新しい署名に独自の制限を設け、
  ポスト量子Bitcoinにおいて現在の支払いスループットに近い値を実現する場合は、
  署名あたりのCPUサイクル数で比較するのがより適切かもしれません。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [BTCPay Server 2.3.0][]は、この人気のセルフホスト型ペイメントソリューションのリリースで、
  ユーザーインターフェイスとAPIにサブスクリプション機能（[ニュースレター #379][news379 btcpay]参照）が追加され、
  ペイメントリクエストが改善され、その他の機能やバグ修正もいくつか含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33657][]は、ブロックのバイト範囲を返す新しいRESTエンドポイント
  `/rest/blockpart/<BLOCKHASH>.bin?offset=X&size=Y`を導入します。これにより、
  Electrsなどの外部インデックスがブロック全体をダウンロードする代わりに、
  特定のトランザクションのみを取得できるようになります。

- [Bitcoin Core #32414][]は、IBD中の既存の対応に加えて、
  再インデックス中にUTXOキャッシュを定期的にディスクにフラッシュするようになりました。
  これまでは、チェーンの先端に到達した場合のみフラッシュが行われていたため、
  `dbcache`に大きな値が設定されている場合、再インデックス中にクラッシュすると大きな進捗が失われる可能性がありました。

- [Bitcoin Core #32545][]は、以前導入されたクラスターリニアライゼーションアルゴリズム（[ニュースレター
  #314][news314 cluster]参照）を、処理困難なクラスターをより効率的に処理するよう設計された
  スパニング・フォレストリニアライゼーションアルゴリズムに置き換えました。
  過去のmempoolデータのテストでは、新しいアルゴリズムは最大64トランザクションまでの
  観測されたすべてのクラスターを数十マイクロ秒でリニアライゼーションできることが示されています。
  これは、[クラスターmempool][topic cluster mempool]プロジェクトの一部です。

- [Bitcoin Core #33892][]は、リレーポリシーを緩和し、親が非[TRUC][topic v3 transaction relay]であっても、
  パッケージ手数料率がノードの現在の最小リレー手数料を超えており、かつ子に最小手数料を下回る祖先が存在しない場合に、
  親が最小リレー手数料を下回っていても日和見的な1P1C[パッケージリレー][topic package relay]を許可するようにしました。
  これは以前、mempoolのトリミングに関する判断を簡素化するためにTRUCトランザクションのみに制限されていましたが、
  [クラスター mempool][topic cluster mempool]ではもはや懸念事項ではなくなりました。

- [Core Lightning #8784][]は、`xpay` RPCコマンド（[ニュースレター #330][news330 xpay]参照）に
  `payer_note`フィールドを追加し、支払人がインボイスを要求する際に支払いの説明を提供できるようにしました。
  `fetchinvoice`コマンドには既に同様の`payer_note`フィールドがあるため、このPRは`xpay`にも追加し、
  その値を基盤となるフローに渡すようにしました。

- [LND #9489][]および[#10049][lnd #10049]は、`BuildOnion`、`SendOnion`および`TrackOnion`
  RPCを備えた実験的な`switchrpc` gRPCサブシステムを導入し、
  外部コントローラーが[HTLC][topic htlc]の配信にLNDを使用しながら、
  経路探索と支払いのライフサイクルの管理を処理できるようにしました。
  サーバーのコンパイルは非デフォルトの`switchrpc`ビルドタグの背後に隠されています。
  [LND #10049][]は具体的に、外部からの試行の追跡のためのストレージ基盤を追加し、
  将来の冪等バージョンの基礎を築きました。現在、資金の損失を避けるため、
  switch経由で試行をディスパッチできるのは一度に1つのエンティティのみに制限されています。

- [BIPs #2051][]は、[BIP3][]の仕様にいくつかの変更を加えました。
  最近追加されたLLMの使用に対するガイダンス（[ニュースレター #378][news378 bips2006]参照）を取り消し、
  リファレンス実装のフォーマットを拡大し、変更履歴を追加し、その他のいくつかの改善と明確化を行いました。

- [BOLTs #1299][]は、[BOLT3][]仕様を更新し、取引相手`to_remote`への支払いアウトプットで
  プレコミットメントポイント`localpubkey`を使用することに関する曖昧な注記を削除しました。
  `option_static_remotekey`では、`to_remote`アウトプットは、
  プレコミットメントポイントなしで資金の回収を可能にするため、受取人の静的な`payment_basepoint`を使用することが期待されており、
  これはもはや有効ではなくなりました。

- [BOLTs #1305][]は、[BOLT11][]仕様を更新し、`n`フィールド（受け取りノードの33byteの公開鍵）が
  必須ではないことを明確にしました。これは、以前必須であると記載していた文章を修正するものです。

{% include snippets/recap-ad.md when="2026-01-06 17:30" %}
{% include references.md %} {% include linkers/issues.md v=2 issues="33657,32414,32545,33892,8784,9489,10049,2051,1299,1305" %}
[news315 frost]: /ja/newsletters/2024/08/09/#bip
[mk ml hash]: https://groups.google.com/g/bitcoindev/c/gOfL5ag_bDU/m/0YuwSQ29CgAJ
[fd0 ml ctv]: https://groups.google.com/d/msgid/bitcoindev/CALiT-Zr9JnLcohdUQRufM42OwROcOh76fA1xjtqUkY5%3Dotqfwg%40mail.gmail.com
[ctv notes1]: https://ctv-activation.github.io/meeting/18dec2025.html
[news379 civ]: /ja/newsletters/2025/11/07/#post-quantum-signature-aggregation
[bmb delving cc]: https://delvingbitcoin.org/t/op-cc-a-simple-introspection-opcode-to-enable-cheaper-consolidations/2177
[cs delving ctv]: https://delvingbitcoin.org/t/understanding-and-mitigating-a-op-ctv-footgun-the-unsatisfiable-utxo/1809
[bb 2024]: https://bitblend2106.github.io/bitcoin/BitBlend2106.pdf
[ah ml uint64 ts]: https://groups.google.com/g/bitcoindev/c/PHZEIRb04RY/m/ryatIL5RCwAJ
[jd ml bip54 ts]: https://groups.google.com/g/bitcoindev/c/L4Eu9bA5iBw/m/jo9RzS-HAQAJ
[jd delving bip54 ts]: https://delvingbitcoin.org/t/modifying-bip54-to-support-future-ntime-soft-fork/2163
[zman ml ts2106]: https://gnusha.org/pi/bitcoindev/eAo_By_Oe44ra6anVBlZg2UbfKfzhZ1b1vtaF0NuIjdJcB_niagHBS-SoU2qcLzjDj8Kuo67O_FnBSuIgskAi2_fCsLE6_d4SwWq9skHuQI=@protonmail.com/
[gm delving bip54]: https://delvingbitcoin.org/t/modifying-bip54-to-support-future-ntime-soft-fork/2163/6
[halseth post]: https://delvingbitcoin.org/t/building-a-vault-using-blinded-co-signers/2141
[halseth prototype]: https://github.com/halseth/blind-vault
[blinded musig]: https://github.com/halseth/ephemeral-signing-service/blob/main/doc/general.md
[peer neg ml]: https://groups.google.com/g/bitcoindev/c/DFXtbUdCNZE
[news366 template]: /ja/newsletters/2025/08/08/#mempool
[feature negotiation ml]: https://gnusha.org/pi/bitcoindev/CAFp6fsE=HPFUMFhyuZkroBO_QJ-dUWNJqCPg9=fMJ3Jqnu1hnw@mail.gmail.com/
[towns bip]: https://github.com/ajtowns/bips/blob/202512-p2p-feature/bip-peer-feature-negotiation.md
[verack]:https://developer.bitcoin.org/reference/p2p_networking.html#verack
[BTCPay Server 2.3.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.0
[news379 btcpay]: /ja/newsletters/2025/11/07/#btcpay-server-6922
[news314 cluster]: /ja/newsletters/2024/08/02/#bitcoin-core-30126
[news330 xpay]: /ja/newsletters/2024/11/22/#core-lightning-7799
[lnd #10049]: https://github.com/lightningnetwork/lnd/pull/10049
[news378 bips2006]: /ja/newsletters/2025/10/31/#bips-2006