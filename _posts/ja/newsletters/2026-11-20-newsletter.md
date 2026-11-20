---
title: 'Bitcoin Optech Newsletter #432'
permalink: /ja/newsletters/2026/11/20/
name: 2026-11-20-newsletter-ja
slug: 2026-11-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、分散型マイニングプールの支払い方法に関する分析と、
Eclairで修正されたサービス拒否（DoS）の脆弱性の開示、
ステイルチップリレーでブロックデータもリレーすべきかどうかについての議論の続きを掲載しています。
また、サービスとクライアントソフトウェアの最近の更新、新しいリリースとリリース候補の発表、
人気のBitcoin基盤ソフトウェアの注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **<!--framework-for-decentralized-mining-pool-payouts-->分散型マイニングプールの支払いのためのフレームワーク:**
  開発者の7d5x9は、分散型[マイニングプール][topic pooled mining]がコインベーストランザクションから
  マイナーに直接支払う方法に関する分析をDelving Bitcoinに[投稿しました][7d5x9 dcpp]。
  投稿ではこれを分散型コインベースペイメントプロトコル（DCPP）と呼んでいます。
  各マイナーに個別のアウトプットを与える方法は、マイニングファームウェアがコインベーストランザクションのサイズを制限し、
  各アウトプットが手数料を支払うトランザクションを圧迫してしまうため、スケールしません。
  投稿では、プールのマイナー数がアウトプット数を上回る場合、
  作業量でマイナーを順位付けするルールはどれも _リッチリスト攻撃_ を許してしまうと主張しています。
  これは、大規模なマイナーが自身のハッシュレートを複数のIDに分割し、
  それぞれのIDが最小規模のマイナーよりも上位になることで、小規模マイナーをコインベーストランザクションから排除してしまう攻撃です。

  7d5x9によると、これまでの設計はこの問題を移動させているだけでした。Braidpoolは、
  問題を誰がアウトプットを受け取るかから、誰がプールの閾値鍵を管理するかへと移しています（[ニュースレター
  #340][news340 braidpool]参照）。一方的な離脱が可能な[Joinpool][topic joinpools]に支払う
  単一のコインベースアウトプットの場合、障害となるのは、
  マイナーが追加のnonce空間を得るためにコインベーストランザクションを変化させるため、そのtxidが不明となり、
  ブロックが見つかるまで離脱トランザクションに署名できないことです。7d5x9は、
  [BIP448][]で提案されているような再バインド可能な署名をソフトフォークで有効にするまでは（[ニュースレター
  #397][news397 bip448]参照）、このアウトプットは単一の鍵または一定数の鍵によって管理されることになると考えています。
  Sparkスタイルの[ステートチェーン][topic statechains]と[Ark][topic ark]に基づくスケッチでは、
  サブツリーごとに1つの小さな請求を保持する攻撃者が安価な協調的決済をブロックでき、
  マイナーのコストを上昇させる可能性がありますが、Arkの場合はこれはそれほど深刻ではないとされています。

  投稿では、どのアウトプットをコインベーストランザクションに含めるかはJoinpoolが決めるものではないと結論付けています。
  そのための選択肢として、金額で重み付けしたランダムな抽選（Matt Coralloによるアイディア）か、
  指定されたオペレーター用に予約されたアウトプットの2つを挙げています。

  公開P2Poolノードを運用していたLearnBitcoin.comは、2,545件のP2Poolのコインベーストランザクションを[調査し][lb p2pool]、
  P2Poolは1ブロックあたり0.001 BTC未満しか稼げないと見込まれるマイナーのシェア難易度を引き上げていたため、
  攻撃者がいなくても成長だけで小規模マイナーが締め出されたと主張しました。後継のP2Poolv2について、
  junglyは現在のファームウェアを考慮してアウトプットの数を16までに制限することを[提案しました][jungly dcpp]。
  これに対しSteven Rooseは、[コベナンツ][topic covenants]なしで検討に値するスキームは思いつかないと[返信しました][roose dcpp]。
  コベナンツがあれば、コインベースアウトプットがArkトランザクションツリーに決定論的にコミットし、
  同じArkサーバーを使用するすべてのマイナーに支払うことができます。

- **EclairのDoS脆弱性の開示:** rorpは、Eclairバージョン[0.14.0][eclair 0.14.0]に影響し、
  2026年7月にリリースされたバージョン[0.14.1][eclair 0.14.1]で修正された
  メモリ枯渇によるサービス拒否（DoS）脆弱性の[責任ある開示][topic responsible disclosures]を
  Delving Bitcoinに[投稿しました][eclair vuln del]。脆弱なノードに接続できるピアであれば、
  そのノードとチャネルを持っていなくても、ノードをクラッシュさせることができました。
  このバグは攻撃者に資金への直接的なアクセスを与えるものではありませんでしたが、
  ノードを繰り返しクラッシュさせることでそのチャネルの資金が危険にさらされる可能性がありました。
  0.14.0をまだ実行しているユーザーはアップグレードする必要があります。

  この攻撃ベクトルは、Eclairにおけるサイズチェックの欠如を利用したものです。[BOLT2][]によると、
  メッセージは`start_batch`メッセージを通じてバッチで送信し、単一の論理的な更新として扱うことができます。
  このメッセージには他のフィールドに加えて`batch_size`が含まれています。仕様によると、
  このサイズは`20`以下かつ`1`より大きくなければなりません。Eclairは上限はチェックしていましたが、
  下限はチェックしていませんでした。

  攻撃者は、`batch_size = 0`の`start_batch`メッセージを送信し、
  その後に[スプライシング][topic splicing]中にバッチで送信される`commitment_signed`メッセージを送信することで、
  この脆弱性を悪用できました。コードは受信したメッセージ数が`batch_size`に達した時点で初めて内部バッチへのメッセージの追加を停止していましたが、
  `batch_size`は`0`であったため受信メッセージ数より常に小さくなり、
  リストは成長を止めることなくメモリ枯渇に至りました。
  この脆弱性は、BOLT2で規定されているとおり、
  コードで下限もチェックするようにすることで修正されました。

- **<!--continued-discussion-of-stale-tip-relay-->ステイルチップリレーに関する議論の続き:**
  Antoine Poinsotは、[BIP332][]のステイルチップリレーに関する
  Bitcoin-Devメーリングリストのスレッド（ニュースレター[#417][news417 staletip]
  および[#423][news423 staletip]参照）に対し、
  ノードは最初はステイルブロック（競合により採用されなかったブロック）のヘッダーのみをリレーすることを[提案しました][poinsot staletip]。
  Poinsotは、ステイルブロックを認識可能にするにはヘッダーで十分だと主張しました。ブロックデータもリレーすると、
  ノードはステイルブロックの上に構築されたチェーンへより速く再編成できるようになります。
  これにより、ブロック競争に負けた後もしばらく自身のブロック上でマイニングを続けるマイナーの期待収益が高まる可能性があります。
  Poinsotは、その影響は極めて小さいと考えられるため、厳密に検討するほどの価値はないとの[見解を示しました][poinsot staletip2]。

  これに対しAnthony Townsは、恩恵を受けるマイナーであれば誰でも、
  ステイルブロックのリレーを自分で安価に実装できるはずだと[返信しました][towns staletip]。Townsは、
  ネットワークのハッシュレートの20%を持つプールは、同じ高さで先に見た競合ブロックではなく自身のブロック上でマイニングすることで、
  すでに年間約16.1 BTCの利益を得ており、結果として生じる1ブロックの再編成のリレー遅延を5秒から1秒に短縮すると、
  それが16.36 BTCに増えると[見積もりました][towns staletip2]。Townsはまた、
  ステイルブロックのヘッダーは[セルフィッシュマイニング][topic selfish mining]の可能性などの懸念を引き起こし得ますが、
  そうした懸念を解消できるのはブロックデータだけだと主張しました。Poinsotは、
  この見積もりは正直なマイニングのインセンティブへの影響をカバーしているようだと[同意し][poinsot staletip3]、
  依然として価値の大部分はヘッダーにあると考えつつも、完全なブロックのリレーを阻止するつもりはないとしました。

## サービスとクライアントソフトウェアの更新

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Liana v16.0リリース:** [Liana v16.0][liana v16.0]は、
  暗号化された[ディスクリプター][topic descriptors]のバックアップを[BIP138][]形式（[ニュースレター
  #424][news424 bip138]参照）で書き込むようになり、新しいウォレットのデフォルトを[Taproot][topic taproot]にしました。

- **COLDCARDファームウェアがcodex32バックアップを追加:** Coinkiteは、
  COLDCARDファームウェアバージョン5.6.3および1.5.3Qを[発表しました][coldcard 5.6.3]。
  これらのバージョンでは、[codex32][topic codex32]シークレットの生成とインポートのサポート、
  および後の復元のためにデバイスのウォレットを2〜9個のシャミアシェアに分割するサポートが追加されています。
  また、[PSBTv2][topic psbt]トランザクションにおけるインプットごとの高さおよび時間ベースのロックタイムのサポートも追加されています。

- **Wavelengthがメインネットでリリース:** Lightning Labsは、
  [Ark][topic ark]ライクな支払いツールキットであるWavelength（[ニュースレター #415][news415 wavelength]参照）が、
  アカウントあたり300,000 satsまでという制限付きのアルファ版としてメインネットで利用可能になったことを[発表しました][wavelength mainnet]。

- **Bull Bitcoinが取引所の注文でPayjoinをデフォルトに:** Bull Bitcoinは、
  Bull Bitcoin Mobileウォレットを通じて同社の取引所で行われるオンチェーンの売買取引で、
  デフォルトで[Payjoin][topic payjoin]を使用するようになったことを[発表しました][bull payjoin blog]（[ニュースレター #338][news338 bull]参照）。
  ウォレットのバージョン[6.14.0][bull 6.14.0]では、
  [サイレントペイメント][topic silent payments]の送受信の実験的なサポートも追加されています。

- **Breez SDKがサイレントペイメントの送信を追加:** SparkベースのBreez SDKのバージョン[0.28.0][breez 0.28.0]では、
  [サイレントペイメント][topic silent payments]アドレスへの送信のサポートが追加されました。

- **Electrumプラグイン用のサイレントペイメントスキャナー:** Ali Sheriefは、
  [ニュースレター #419][news419 sp electrum]で取り上げたElectrumの送信プラグインと連携する
  監視専用の[サイレントペイメント][topic silent payments]スキャナーであるspscandを[発表しました][spscand delving]。
  ユーザー自身のBitcoin Coreノード、BlindBitサーバー、またはBlindBitサーバーと
  P2Pピアからの[コンパクトブロックフィルター][topic compact block filters]を組み合わせて、
  支払いをスキャンできます。

- **Stratum v2のリリースとプールでの採用:** [Stratum v2][topic pooled mining]のリファレンス実装は
  [sv2-apps v0.9.0][]をリリースしました。このリリースでは、IPCインターフェースを介した発見ブロックの送信を含む
  Bitcoin Core 32.xのサポートが追加され、Job Declarator Clientが強化されています
  （以前の経緯は[ニュースレター #384][news384 sv2]参照）。これとは別に、
  MARA FoundationはMARAがStratum v2を使って初めてのブロックをマイニングしたことを[発表し][mara sv2]、
  Foundryは自社のプールでStratum v2のテストを開始したことを[発表しました][foundry sv2]。

- **CoinswapがOpenSwapに名称変更:** [OpenSwap v0.2.3][]は、
  以前Coinswapと呼ばれていた[coinswap][topic coinswap]プロトコル実装
  （[ニュースレター #415][news415 coinswap]参照）の新しい名称での最初のリリースです。
  Electrumサーバーのバックエンドオプション、第三者のアドレスに支払うスワップ、
  そしてライトニングサポートを有効にしてビルドした場合は、
  LDK Server（[ニュースレター #406][news406 ldk server]参照）を通じたオンチェーン資金とLN間のスワップが追加されています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 26.12rc1][]は、この人気のあるLNノード実装の次期メジャーバージョンのリリース候補です。
  26.06以来初のメジャーリリースとなり、2つのリリースサイクルをカバーします。
  チャネル状態の損失後に[HTLC][topic htlc]アウトプットを回収するためのツールの追加（後述のCore Lightning #9730参照）、
  支払いの経路探索の改善（ニュースレター[#418][news418 impressions]および[#430][news430 xpay]参照）、
  新しい協調閉鎖プロトコルの実験的サポートの追加（[ニュースレター #413][news413 simpleclose]参照）が含まれています。
  リリースノートではまた、27.03で`xpay`が`pay`を置き換えることが発表されています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #36757][]は、[TorおよびI2P][topic anonymity networks]経由のアドレス検出における
  プライバシーリークを修正しました。これまでは、ノードが悪意のあるTorまたはI2Pピアにアウトバウンド接続した場合、
  そのピアは`version`メッセージで、当該ノードが任意のルーティング可能なIPアドレスから接続しているかのように主張することができました。
  するとBitcoin Coreは、自身のクリアネットのリスニングポートとともに、そのアドレスをピアに伝達してしまう可能性がありました。
  この際、特徴的なポートであれば、同じポートを使用していることが観測されたクリアネットノードとその接続を関連付けるのに役立つ可能性がありました（Torのリスニングポートに関する以前の修正については[ニュースレター #52][news52 port]参照）。Bitcoin Coreは現在、TorおよびI2Pピアがノードを見かけていると報告するアドレスを無視します。

- [BIPs #2356][]は、[BIP95][]のプレースホルダーのジェネシスパラメーターを、マイニングされた[testnet5][topic testnet]のジェネシスブロックのパラメーターに置き換え、BIPを`Deployed`としてマークしました。ジェネシスコインベースには、2026-11-14という日付とメインネットのブロック975,744のハッシュが含まれています。このハッシュにコミットすることで、testnet5のジェネシスブロックはメインネットがその高さに達した後にしかマイニングできなかったことが保証されます（[ニュースレター #431][news431 testnet5]参照）。

- [Core Lightning #9730][]は、ローカルのチャネル状態を失った後に
  [HTLC][topic htlc]アウトプットを手動で回収するための`lightning-hsmtool recoverhtlc`コマンドを追加しました。
  ピアが最新のコミットメントトランザクションを公開すると、復旧中のノードは
  [静的チャネルバックアップ][topic static channel backups]を使って自身のアウトプットを回収できます（[ニュースレター #421][news421
  recovery]参照）。
  新しいコマンドは、ローカルの`hsm_secret`、チャネルとHTLCの詳細、
  およびピアのper-commitment pointが与えられると、一致するHTLCアウトプットを特定します。このツールは、
  タイムアウト後に送信HTLCを回収したり、プリイメージが既知の受信HTLCを請求したりするための署名済みトランザクションを構築します。
  ただし、オペレーターはトランザクションを手動で確認してブロードキャストする必要があります。
  協力的なCLNピアは、`dumpcommitments --point-only`コマンドを使って、
  シークレットを明かすことなく公開ポイントをエクスポートできます。

- [LDK #5561][]は、ピアが`revoke_and_ack`を送信した場合に、
  LDK側が対応する`commitment_signed`メッセージを送信する前であっても、
  転送中の資金が失われる可能性があった問題を修正しました。これまでLDKは、この早すぎる確認応答を受け入れ、
  内部のコミットメント番号を進めてしまう可能性がありました。その結果、
  オンチェーンモニターに記録されているものとは異なるコミットメントに署名する可能性がありました。
  もしピアがそのコミットメントを公開した場合、LDKは（プリイメージを知っているにもかかわらず）、
  送信HTLCを支払った後であっても、受信HTLCを請求できない可能性がありました。LDKは現在、
  早すぎる確認応答を拒否し、チャネルを強制閉鎖します。この修正はLDK 0.2.8でリリースされました（[ニュースレター #431][news431 ldk]参照）。
  なお、[ニュースレター #426][news426 ldk5057]では、再接続中に署名済みのコミットメントが監視対象からはずれてしまうという
  別バグについて解説しています。

- [LDK #5562][]と[#5545][ldk #5545]は、悪意のあるピアが自身のチャネルと
  LDKノードの間で作り出すことができたチャネルIDの衝突を修正しました。具体的には、
  ピアは強制閉鎖されたチャネルの既知のIDを、新しいチャネルの一時IDとして再利用できました。これにより、
  LDKが閉鎖されたチャネルのモニターに転送された支払いのプリイメージを記録できなくなり、
  送信HTLCが支払われた後も受信[HTLC][topic htlc]が未請求のまま残る可能性がありました。2つめのケースでは、
  ピアはファンディングトランザクションからチャネルの将来の最終IDを計算し、
  その一時的なIDで別の開設要求を送信できました。アプリケーションが新しい要求を受け入れる前に元のチャネルが最終IDを採用した場合、
  その受け入れによって元のチャネルのファンディング済みの状態が上書きされる可能性がありました。LDKは現在、
  競合するIDを拒否し、受け入れ時にも再チェックします。これらの修正はどちらもLDK 0.2.8でリリースされました。
  EclairでDoSを引き起こす可能性があった関連するチャネルIDの衝突については、[ニュースレター
  #427][news427 channelid]をご覧ください。

- [LDK #5557][]は、Electrumバックエンドを使用するノードで、
  悪意のあるピアがトランザクションの監視を妨害できた脆弱性を修正しました。具体的には、
  ピアがチャネルを提案する際、既に監視対象となっているアウトポイントをファンディングアウトプットとして指定しつつ、
  ロックスクリプトを本来とは異なるものに設定することが可能でした。その提案が登録されると、
  たとえLDKがその後チャネルを拒否したとしても、正当な監視対象として保存済みのスクリプトが上書きされる可能性がありました。
  その結果、LDKは偽のスクリプトに関連するトランザクションをElectrumに問い合わせ、
  実際のアウトプットを使用するトランザクションを見逃し、チャネルの閉鎖に適時に対応できなくなる可能性がありました。
  LDKは現在、アウトポイントに登録された異なるスクリプトをすべて保持するため、
  偽の登録によって正当な監視が抑制されることはありません。この修正もLDK 0.2.8でリリースされました。

- [LDK #5558][]と[#5482][ldk #5482]は、支払いが手数料予算を超える可能性があった2つのケースを修正しました。
  1つめのPRは、静的な[BOLT12][topic offers]インボイスを使用する
  [非同期支払い][topic async payments]（[ニュースレター #321][news321 async]参照）において、
  手数料上限の設定が省略された場合の処理に対処しています。LDKは現在、アプリケーションがこの設定を省略した場合、
  支払額の1%に50 satsを加えたデフォルトの上限を適用します。これまでは、設定を省略すると上限が完全に撤廃され、
  悪意のある受信者が過大な手数料を持つ[ブラインドパス][topic rv routing]を提供できました。
  この修正はLDK 0.2.8でリリースされました。2つめのPRは、
  HTLCの最小値を満たすためにルートが金額を上乗せする場合のリトライに対処しています。
  LDKは上乗せされた金額を要求された支払いの一部として扱い、リトライ時に失敗したパスの手数料予算を復元していたため、
  総支出額が上限を超える可能性がありました。LDKは現在、残りの未払い額のみをリトライし、
  超過分は残りの手数料予算に充当されるようになります。

- [LND #11555][]は、LNDが非[AMP][topic amp]インボイスを決済済みとして報告する方法を変更しました。
  アプリケーションはすでに個々の[HTLC][topic htlc]の決済がオフチェーンで確定したタイミングを監視できましたが
  （[ニュースレター #224][news224 finality]参照）、
  LNDはプリイメージが公開されるとすぐにインボイスを決済済みとしてマークする可能性がありました。現在は、
  プリイメージの公開時にインボイスは`PENDING_SETTLE`状態になります。
  支払いに含まれるすべてのHTLCのオフチェーンまたはオンチェーンでの最終的な結果が確定すると、
  LNDはすべてのパートが回収された場合はインボイスを`SETTLED`、
  いずれかが失敗した場合は`CANCELED`としてマークします。
  キャンセルされたインボイスにも回収済みの一部のパートが残っている可能性があり、それらは返金されないため、
  アプリケーションは確定して成功したHTLCの金額のみを入金処理すべきです。
  インボイスの`preimage_released`フラグは、LNDがプリイメージの公開にコミットしたかどうかを記録します。
  AMPの支払いセットは引き続きプリイメージの公開時に決済されます。

- [LND #11551][]は、[マルチパスペイメント][topic multipath payments]および
  [AMP][topic amp]支払いの完了時の有効期限の検証を修正しました。これまでLNDは、
  各HTLCを到着時にチェックしていました。受信者が残りのパートを待っている間にさらにブロックがマイニングされた場合、
  以前のHTLCがオンチェーンで回収するために必要な[有効期限のマージン][topic cltv expiry delta]をもはや満たしていなくても、
  LNDはプリイメージを公開してしまう可能性がありました。現在LNDは、最後のパートが到着した時点で、
  すべてのパートを現在のブロック高と照らして再チェックします。以前に受け入れたパートの有効期限が近すぎる場合、
  LNDはそのセットを失敗させ、別の試行のためにインボイスをオープンのままにします
  （個々のAMPセットをキャンセルする仕組みについては[ニュースレター #424][news424 amp]参照）。

- [LND #11472][]と[#10842][lnd #10842]は、バックエンドの一時的なエラーや特定の不適切なインプットが原因で、
  本来実行可能なスイープ処理が阻害される可能性があったケースを修正しました。1つめは、
  mempool受け入れチェック中の一時的なエラーや未分類のエラーの後も、
  インプットをリトライ可能な状態に保ちます（[ニュースレター #373][news373 sweeper]参照）。
  これはLND 0.21.8-betaおよび0.20.8-betaでリリースされました（[ニュースレター #431][news431 lnd]参照）。
  2つめは、ブロードキャストされることのない診断用トランザクションを使って、
  拒否されたバッチのサブセットをテストします。無効なインプットや競合するインプットを特定できた場合、
  LNDは次の試行からそれを除外し、残りのインプットでリトライします。

- [LND #11542][]は、チャネル再接続後の転送[HTLC][topic htlc]を復旧する際の不具合を修正しました。
  これまでのLNDでは、保存された転送バッチを再生する際、既に承認済みのHTLCを除外した後、
  残りのエントリーの新しい位置を使って、元の位置でインデックスされたメタデータを検索してしまう可能性がありました。
  これにより、未解決のHTLCがスキップされたり、誤って関連付けられたりする可能性がありました。さらに、
  LNDがバッチを記録した後、HTLCを引き渡す前にチャネルのHTLCハンドラーが停止した場合、不完全なレコードが残り、
  リトライが重複として破棄される可能性がありました。LNDは現在、元のバッチインデックスを保持し、
  引き渡しに失敗した後は不完全なレコードを削除するため、未解決のHTLCをリトライできるようになりました。
  この修正はLND 0.21.8-betaおよび0.20.8-betaでリリースされました（[ニュースレター #431][news431 lnd]参照）。

{% include snippets/recap-ad.md when="2026-11-24 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="36757,2356,9730,5561,5562,5545,5557,5558,5482,11555,11551,11472,10842,11542" %}
[7d5x9 dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060
[news340 braidpool]: /ja/newsletters/2025/02/07/#braidpool
[news397 bip448]: /ja/newsletters/2026/03/20/#bips-1974
[lb p2pool]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/2
[jungly dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/5
[roose dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/4
[eclair vuln del]: https://delvingbitcoin.org/t/disclosure-memory-exhaustion-dos-in-eclair-0-14-0/3057
[eclair 0.14.0]: https://github.com/ACINQ/eclair/releases/tag/v0.14.0
[eclair 0.14.1]: https://github.com/ACINQ/eclair/releases/tag/v0.14.1
[poinsot staletip]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/qJIADCfABgAJ
[news417 staletip]: /ja/newsletters/2026/08/07/#stale-tip-bip
[news423 staletip]: /ja/newsletters/2026/09/18/#bips-2241
[poinsot staletip2]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/ORRffqwZAgAJ
[towns staletip]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/NF7UNdJoAQAJ
[towns staletip2]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/Kt4orC5bAAAJ
[poinsot staletip3]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/NqK6HjiAAQAJ
[liana v16.0]: https://github.com/wizardsardine/liana/releases/tag/v16.0
[news424 bip138]: /ja/newsletters/2026/09/25/#bips-1951
[coldcard 5.6.3]: https://blog.coinkite.com/coldcard-firmware-563-153q/
[wavelength mainnet]: https://lightning.engineering/posts/2026-10-23-wavelength-mainnet-launch/
[news415 wavelength]: /ja/newsletters/2026/07/24/#wavelength
[bull payjoin blog]: https://www.bullbitcoin.com/blog/payjoin-trading
[news338 bull]: /ja/newsletters/2025/01/24/#bull-bitcoin-mobile-wallet-payjoin
[bull 6.14.0]: https://github.com/SatoshiPortal/bullbitcoin-mobile/releases/tag/v6.14.0
[breez 0.28.0]: https://github.com/breez/spark-sdk/releases/tag/0.28.0
[spscand delving]: https://delvingbitcoin.org/t/silent-payments-for-electrum/3078
[news419 sp electrum]: /ja/newsletters/2026/08/21/#electrum
[sv2-apps v0.9.0]: https://github.com/stratum-mining/sv2-apps/releases/tag/v0.9.0
[news384 sv2]: /ja/newsletters/2025/12/12/#stratum-v2
[mara sv2]: https://x.com/MARAFoundation_/status/2120520367500308580
[foundry sv2]: https://x.com/FoundryServices/status/2121279504475709625
[openswap v0.2.3]: https://github.com/citadel-foss/openswap/releases/tag/v0.2.3
[news415 coinswap]: /ja/newsletters/2026/07/24/#coinswap-v0-2-2
[news406 ldk server]: /ja/newsletters/2026/05/22/#ldk-server
[LDK #5561]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5561
[LDK #5562]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5562
[LDK #5545]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5545
[LDK #5557]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5557
[LDK #5558]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5558
[LDK #5482]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5482
[news52 port]: /en/newsletters/2019/06/26/#bitcoin-core-15651
[news431 testnet5]: /ja/newsletters/2026/11/13/#testnet5
[news421 recovery]: /ja/newsletters/2026/09/04/#core-lightning-9435
[news426 ldk5057]: /ja/newsletters/2026/10/09/#ldk-5057
[news427 channelid]: /ja/newsletters/2026/10/16/#eclair-v0-14-1-2-dos
[news321 async]: /ja/newsletters/2024/09/20/#ldk-3140
[news224 finality]: /ja/newsletters/2022/11/02/#lnd-6517
[news424 amp]: /ja/newsletters/2026/09/25/#lnd-11198
[news373 sweeper]: /ja/newsletters/2025/09/26/#lnd-10189
[news431 ldk]: /ja/newsletters/2026/11/13/#ldk-v0-2-8
[news431 lnd]: /ja/newsletters/2026/11/13/#lnd-v0-21-8-beta
[news418 impressions]: /ja/newsletters/2026/08/14/#core-lightning-9150
[news430 xpay]: /ja/newsletters/2026/11/06/#core-lightning-9592
[news413 simpleclose]: /ja/newsletters/2026/07/10/#core-lightning-9104
[Core Lightning 26.12rc1]: https://github.com/ElementsProject/lightning/releases/tag/v26.12rc1
