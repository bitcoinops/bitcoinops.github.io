---
title: 'Bitcoin Optech Newsletter #408'
permalink: /ja/newsletters/2026/06/05/
name: 2026-06-05-newsletter-ja
slug: 2026-06-05-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、BIP324のトランスポート層の暗号化を量子耐性のあるものにするためのアイデアと、
miniscriptウォレット向けにQRベースの署名ペイロードを標準化する提案について掲載しています。
また、Bitcoinのコンセンサスルールの変更に関する提案や議論の要約や、新しいリリースおよびリリース候補の発表、
人気のBitcoin基盤ソフトウェアにおける注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **BIP324のポスト量子対応への道**: Olaoluwa Osuntokunは、
  [BIP324][]を量子耐性のあるものにするために必要なアップグレードについての考えを
  Bitcoin-Devメーリングリストに[投稿しました][pq bip324 ml]。BIP324は、
  P2Pプロトコルに[トランスポート層の暗号化][topic v2 p2p transport]を導入し、
  ピア間でプライバシーとセキュリティを改善した形でネットワーク上のメッセージを交換できるようにするもので、
  初回のハンドシェイクおよび通信全体が外部の観測者からは完全にランダムに見えるように設計されています。
  Osuntokunによると、P2Pプロトコルの変更はコンセンサスの変更のように広範な合意を必要とせず、
  Bitcoinを量子耐性のあるものにするためのより容易な第一歩になり得るとのことです。

  正式なBIPを提案する前に、Osuntokunは2つの主要な設計上の論点について議論を呼びかけました。
  1つめは、どの[鍵カプセル化メカニズム][wiki kem](KEM)を使用すべきかという点で、
  ハイブリッドなアプローチか純粋なポスト量子アプローチのいずれかであり、
  どちらもモジュール格子ベースのKEM(ML-KEM)という新しいプリミティブを活用します。
  2つめの設計上の論点は、初回のハンドシェイクが依然としてランダムなバイト列と区別できないものであるべきかどうかという問題を扱っています。

  1つめの点について、著者は現行のECDHアルゴリズムとML-KEMを組み合わせたハイブリッドなアプローチの方が、
  より優れた保証を提供できると述べています。これは、2つのアルゴリズムのいずれかが破られた場合でも保護を提供できるためです。
  実際、ECDHは将来の暗号的に意味のある量子コンピューター（CRQC）によって破られる可能性がある一方、
  量子安全なアルゴリズムはまだ十分に検証されておらず、数学的な欠陥によって破綻する可能性が残っています。

  2つめの点について、Osuntokunは、ハンドシェイクがランダムなバイト列と区別できないという要件を維持する必要がある場合に備えて、
  可能な代替案を示しました。1つめのアプローチは、まず現行のBIP324ハンドシェイクを使って古典的なチャネルを開き、
  それを使ってポスト量子チャネルをネゴシエートするというものです。もう1つのアプローチは、
  OEINC（Outer Encrypts Inner Nested Combiner）に基づくもので、外側のKEMを使ってもう1つの内側のKEMを暗号化し、
  単一ステップでポスト量子チャネルを実現します。

- **miniscriptウォレット向けQR署名ペイロードの議論**: Pythは、[miniscript][topic miniscript]ベースの支払いポリシーを使用する際に、
  ウォレットコーディネーターとエアギャップされた署名デバイスとの間でQRコードを介して交換されるデータペイロードを標準化する提案を
  Delving Bitcoinに[投稿しました][pyth delving qr]。既存のQRベースのプロトコルは標準的なm-of-nマルチシグを扱えますが、
  miniscriptの可変的なポリシーには、現行のスキームがカバーしていない追加の機能が必要です。彼の提案では、
  xpubの取得、[ディスクリプター][topic descriptors]の登録、アドレスの検証、署名のためのペイロードタイプを定義しています。
  Pythは、提案されたペイロードについて署名デバイスおよびウォレット開発者からのフィードバックを求めています。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **CTVのみのVaultの概念実証**: Ademanは、[CTV][topic op_checktemplateverify]（[BIP119][]）[Vault][topic vaults]プロジェクトである
  [MCCV][mccv](More Complicated CTV Vault)の0.1.0リリースをDelving Bitcoinで[発表しました][ademan delving mccv]。
  MCCVは、フル機能のVault(James O'Beirneの[simple-ctv-vault][jamesob ctv vault]ほど単純ではないもの。[ニュースレター #191][news191 simple vault]参照)を、
  `OP_VAULT`([BIP345][])や[`OP_CHECKCONTRACTVERIFY`][topic matt]([BIP443][])のような
  より複雑なopcodeを使わずにどのように構築できるか、というアイデアをいくつか実装しています。具体的には、
  MCCVはCTVトランザクションの有向非巡回グラフ(DAG)を使用して単一UTXOのVaultを実装しており、
  これは最終的にVaultのリカバリー鍵で支払い可能になるまでに多くのやり取りを経て存在できます。
  可能な引き出しスクリプトの[Taproot][topic taproot]スクリプトツリー(それぞれ異なる金額と[タイムロック][topic timelocks]を持つ)を使用して、
  MCCVはレート制限を実装しています。また、スクリプトツリーには、さまざまな金額の追加資金をVaultに加えることを可能にするデポジットCTVハッシュも含まれています。
  MCCVは、Vault UTXOのコレクションではなく、拡張・縮小される単一のVault UTXOを使用することで、
  BIP345および443が解決する根本的な問題の1つ、すなわちVaultインプットの結合を回避しています。
  すべてのCTVベースのVaultの設計と同様に、デポジットまたは引き出し可能な金額は正確であり、
  作成時に列挙されていなければなりません。これはBIP345および443では必要とされない点です。ただし、
  MCCVのレート制限は複数UTXOのVaultでは完全には実現できません。MCCVは`OP_TEMPLATEHASH`([BIP446][])でも実装可能です。

- **<!--post-quantum-lightning-discussion-->ポスト量子ライトニングの議論**: Olaoluwa Osuntokun(roasbeef)は、
  [ポスト量子][topic quantum resistance]ライトニングネットワークがレイヤーごとにどのようなものになりうるかの内訳を
  Delving Bitcoinに[投稿しました][oo delving ln lbl]。Osuntokunは、利用可能なポスト量子暗号システムの全体像と、
  必要な各暗号プリミティブに暗号システムを対応付けるためのライトニングネットワークのレイヤーを概説しました。
  ポスト量子ライトニングは全体的な構造を維持できますが、現在依存している単一のノード鍵を手放さざるを得ない可能性があります。
  単一のポスト量子暗号システムや鍵では、必要なプリミティブのすべてを提供することはできません。Osuntokunは、
  鍵交換を含む特定のライトニングネットワークの機能には格子ベースの暗号が最も適していることを発見しました。
  彼はまた、ポスト量子暗号要素のサイズが大きいため、複数のポスト量子スキームに弱点があった場合に備えてセキュリティを提供するために、
  楕円曲線暗号を並行して使い続けることが理にかなう可能性が高いと指摘しています。

- **<!--quantum-attack-game-theory-->量子攻撃のゲーム理論**: Jameson Loppは、
  量子攻撃のゲーム理論に関する彼の[ブログ記事][jl delving qag]をDelving Bitcoinに[投稿しました][jl qag]。
  Loppは、公開鍵からBitcoinの秘密鍵を明らかにできる量子コンピュータが構築された場合の、
  さまざまな市場参加者の潜在的なインセンティブと行動について説明しています。彼が示すシナリオは予測不可能であり、
  量子攻撃者は、他の大口保有者に伴うProof of Workや資本投下なしに、
  大量のBitcoinへのアクセスを急速に獲得する可能性があります。

- **BIP54の64 byteトランザクションと正当な利用の可能性**: Jeremy Rubinは、
  witnessを除去した64 byteのトランザクションの正当な利用の可能性についてBitcoin-Devメーリングリストに[投稿しました][jr ml 64]。
  [コンセンサスクリーンアップ][topic consensus cleanup]([BIP54][])提案には、witnessを除去した64 byteのトランザクションを
  コンセンサス上無効にする変更が含まれています。この変更は、ある種の[マークルツリーの脆弱性][topic merkle tree vulnerabilities]を不可能にし、
  それによってSPVウォレットや同様のヘッダーベースの支払い検証スキームの実装をより安全にすることを意図しています。
  64 byteのトランザクションは最大で1つのインプットと1つの誰でも使用可能なアウトプットしか持てないため、
  [BIP54][]の著者らはそれらを保護する価値はないと考えていました。Rubinは、現在または将来のプロトコルが
  そのようなトランザクションを利用し得る、いくつかの潜在的なシナリオを提案しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 26.06][]は、この人気のLNノード実装のメジャーリリースです。
  新しい`graceful`、`sendamount`、`xkeysend` RPCを追加し、`xpay`を優先して`pay`の非推奨化サイクルを開始し、
  実験的な[BOLT12][topic offers]支払い証明のサポートを追加します。追加の詳細については[変更履歴][cln 26.06 changelog]をご覧ください。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #35269][]は、Bitcoin Coreの内部MuSig2署名セッション識別子に各参加者の公開ナンスを含めることで、
  [MuSig2][topic musig]の[PSBT][topic psbt]署名を修正します。これまでは、同じナンスのないPSBTに対して
  `walletprocesspsbt`を複数回呼び出すと、同じ内部セッションIDを持つ新しい公開ナンスが生成され、
  ナンスの再利用を防ぐためのアサーションがトリガーされる可能性がありました。新しいセッション識別子は、
  異なる公開ナンスを持つ署名セッションを区別しますが、秘密鍵の漏洩を防ぐため、
  同じナンスが再利用されていると見なされる場合は依然としてクラッシュします。

- [Bitcoin Core #34644][]は、Mining IPCインターフェースに`submitBlock`メソッドを追加し(ニュースレター [#310][news310 mining]および
  [#323][news323 mining]参照)、[Stratum v2][topic pooled mining]クライアントが
  検証および処理のために完全に組み立てられたブロックを送信できるようにします。これは、Stratum v2のジョブ宣言子が、
  Bitcoin Coreに対応する`BlockTemplate`オブジェクトが存在しない解決済みのブロックを受け取った場合に、
  既存の`submitSolution`メソッドでは不十分な場面で役立ちます（[ニュースレター #325][news325 ipc]を参照）。
  新しいメソッドは`submitblock` RPCに似ていますが、重複・判定不能・無効なブロックについて、
  ブール値の結果と却下の詳細を返します。RPCとは異なり、IPCの呼び出し元は、witnessコミットメントが存在する場合は
  コインベースwitnessを含む完全なブロックを送信しなければなりません。

- [Bitcoin Core #34198][]は、2011年にウォレットのベストブロックレコードが追加される前に作成された
  非常に古いレガシーウォレットに影響する移行の失敗を修正します。空のベストブロックロケーターを持つウォレットを
  [ディスクリプター][topic descriptors]ウォレットに移行できるようになりましたが、
  移行が完了する前にチェーン全体の再スキャンが必要です。

- [LND #10813][]は、[Tor][topic anonymity networks] v2オニオンサービスの生成のサポートを削除します。
  これはLND 0.20で非推奨となっていました(ニュースレター [#375][news375 tor]参照)。
  非推奨の`tor.v2`オプションは削除されますが、v2アドレスはピアアナウンスメント内に保持されるため、
  既存のゴシップメッセージは引き続き検証および再ブロードキャストできます。Tor v2オニオンサービスは
  2021年10月以降廃止されており、ユーザーは代わりにTor v3を使用すべきです。

- [Rust Bitcoin #6250][]は、コインベーストランザクションがwitnessコミットメントを含む場合は常に、
  コインベースインプットが32 byteのwitness reserved valueを含むことの検証を開始し、
  rust-bitcoinのブロック検証を[BIP141][]に整合させます。これまでは、
  rust-bitcoinはブロックが他の[segwit][topic segwit]トランザクションを含む場合にのみこのチェックを実行していたため、
  コインベースwitnessコミットメントを持つがコインベースwitness reserved valueを持たないブロックを受け入れる可能性がありました。

- [BOLTs #1338][]は[BOLT2][]を更新し、チャネルのファンディングトランザクションがコインベーストランザクションである場合、
  ノードが`channel_ready`を送信する前に少なくとも100ブロック待つことを必須とし、
  マイナーが成熟していないコインベースアウトプットをすぐに使ってチャネルを開くことを防ぎます。

- [BOLTs #1326][]は[BOLT4][]を更新し、転送ノードだけでなく最終ノードも`invalid_onion_version`、
  `invalid_onion_hmac`、`invalid_onion_key`エラーを返せるようにします。これまでは、
  これらのエラーは最終ノードが使用してはならないルールの下に誤って配置されていました。このPRはまた、
  転送ノードは、最終受取人が行うように既に支払い済みのペイメントハッシュを扱ってはならないことを明確化しています。

{% include snippets/recap-ad.md when="2026-06-09 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35269,34644,34198,10813,6250,1338,1326" %}

[ademan delving mccv]: https://delvingbitcoin.org/t/ctv-only-vault-concept-v0-1-0-release/2539
[jamesob ctv vault]: https://github.com/jamesob/simple-ctv-vault
[news191 simple vault]: /ja/newsletters/2022/03/16/#ctv
[mccv]: https://github.com/LNHANCE-Expedition/mccv
[oo delving ln lbl]: https://delvingbitcoin.org/t/post-quantum-lightning-layer-by-layer/2479
[jl delving qag]: https://delvingbitcoin.org/t/quantum-attack-game-theory/2524
[jl qag]: https://blog.lopp.net/quantum-attack-game-theory/
[jr ml 64]: https://groups.google.com/g/bitcoindev/c/iCuq6bFKt5Y/m/MCATyQ4zAAAJ
[pq bip324 ml]: https://groups.google.com/g/bitcoindev/c/n_5WuKVYqwI/m/lBooLis3AQAJ
[wiki kem]: https://en.wikipedia.org/wiki/Key_encapsulation_mechanism
[pyth delving qr]: https://delvingbitcoin.org/t/qr-based-signing-flow-payloads-in-miniscript-context/2464
[Core Lightning 26.06]: https://github.com/ElementsProject/lightning/releases/tag/v26.06
[cln 26.06 changelog]: https://github.com/ElementsProject/lightning/blob/v26.06/CHANGELOG.md
[news310 mining]: /ja/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /ja/newsletters/2024/10/04/#bitcoin-core-30510
[news325 ipc]: /ja/newsletters/2024/10/18/#bitcoin-core-30955
[news375 tor]: /ja/newsletters/2025/10/10/#lnd-10254
