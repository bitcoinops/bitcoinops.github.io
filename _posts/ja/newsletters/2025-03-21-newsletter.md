---
title: 'Bitcoin Optech Newsletter #346'
permalink: /ja/newsletters/2025/03/21/
name: 2025-03-21-newsletter-ja
slug: 2025-03-21-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNDの更新された動的手数料率調整システムに関する説明を掲載しています。
また、サービスやクライアントソフトウェアの最近の更新や、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャソフトウェアの最近の変更点など、恒例のセクションも含まれています。

## ニュース

- **LNDの動的手数料率調整システムに関する説明:** Matt Morehouseは、
  オンチェーントランザクション（[RBF][topic rbf]による手数料の引き上げを含む）に使用する手数料率を決定する、
  最近書き換えられたLNDの _スイーパー_ システムの説明をDelving Bitcoinに[投稿しました][morehouse sweep]。
  彼はまず、LNノードの手数料管理の安全上重要な側面と、過払いを避けたいという自然な欲求について簡単に説明します。
  次に、LNDが使用する2つの一般的な戦略について説明します:

  - ローカルのBitcoin Coreノードやサードパーティの外部の手数料率推定器に問い合わせる。
    これは主に、初期手数料率の選択と、緊急性のないトランザクションの手数料の引き上げに使用されます。

  - 指数関数的な手数料の引き上げ。期限が迫っている場合に使用され、
    ノードのmempoolや[手数料の推定][topic fee estimation]に関する問題によってタイムリーな承認が妨げられないようにします。
    たとえば、Eclairは期限が6ブロック以内の場合、指数関数的に手数料を増額します。

  Morehouseは次に、LNDの新しいスイーパーシステムでこの2つの戦略がどのように組み合わされているかを説明します。
  「期限が一致する[HTLC][topic htlc]の請求は、1つの[バッチトランザクション][topic
  payment batching]に[集約されます]。バッチトランザクションの予算は、
  トランザクション内の個々のHTLCの予算の合計として計算されます。トランザクションの予算と期限に基づいて、
  期限が近づくにつれて予算のどれだけを使用するかを決定する手数料関数が計算されます。
  デフォルトでは、（最小リレー手数料率または外部の推定器によって決まる）低めの手数料からスタートし、
  期限が1ブロック先に迫ったら予算全体が手数料に割り当てられる線形手数料関数が使用されます。」

  彼はさらに、新しいロジックが[置換サイクル][topic replacement cycling]攻撃に対する保護にどう役立つかを説明し、
  次のように結論づけています。「LNDのデフォルトパラメーターでは、
  攻撃者が置換サイクル攻撃を成功させるには、通常、HTLCの金額の少なくとも20倍を使用する必要があります。」
  また、新しいシステムによってLNDの[ピンニング攻撃][topic transaction pinning]に対する防御も向上すると付け加えています。

  彼は最後に、改善されたロジックによって行われた「LND固有のバグと脆弱性の修正」リンクを掲載しています。
  Abubakar Sadiq Ismailは、すべてのLN実装（および他のソフトウェア）が
  Bitcoin Coreの手数料推定をより効果的に使用する方法についていくつかの提案を[返信しました][ismail sweep]。
  他の何人かの開発者もコメントし、説明にニュアンスを加え、新しいアプローチを称賛しました。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Wally 1.4.0リリース:**
  [libwally-core 1.4.0リリース][wally 1.4.0]では、[Taproot][topic taproot]のサポート、
  [BIP85][] RSA鍵の導出のサポート、追加の[PSBT][topic psbt]と[ディスクリプター][topic descriptors]機能が追加されました。

- **Bitcoin Core Config Generatorの発表:**
  [Bitcoin Core Config Generator][bccg github]プロジェクトは、
  Bitcoin Coreの`bitcoin.conf`設定ファイルを作成するためのターミナルインターフェースです。

- **regtest開発環境コンテナ:**
  [regtest-in-a-pod][riap github]リポジトリは、
  ブログ記事[Using Podman Containers for Regtest Bitcoin Development][podman
  bitcoin blog]で説明されているように、Bitcoin Core、Electrum、Esploraで構成された
  [Podman][podman website]コンテナを提供します。

- **Exploraトランザクション視覚化ツール:**
  [Explora][explora github]は、トランザクションのインプットとアウトプットを視覚化し
  ナビゲートするためのWebベースのエクスプローラです。

- **Hashpool v0.1タグ:**
  [Hashpool][hashpool github]は、マイニングシェアが[ecash][topic ecash]トークンとして表現される（
  [ポッドキャスト #337][pod337 hashpool]参照）[Stratum v2参照実装][news247 sri]に基づく
  [マイニングプール][topic pooled mining]です。

- **DMNDがプールマイングを開始:**
  [DMND][dmnd website]は、以前のソロマイニングの[発表][news281 demand]に基づいて、
  Stratum v2プールマイングを開始しました。

- **KruxがTaprootとminiscriptをサポート:**
  [Krux][news273 krux]は、[embit][embit website]ライブラリを活用して、
  [miniscript][topic miniscript]とTaprootのサポートを追加しました。

- **<!--source-available-secure-element-announced-->ソースが利用可能なセキュアエレメントの発表:**
  [TROPIC01][tropic01 website]は、RISC-V上に構築されたセキュアエレメントで、
  監査可能な[オープンアーキテクチャ][tropicsquare github]を採用しています。

- **NunchukがGroup Walletを発表:**
  [Group Wallet][nunchuk blog]は、[マルチシグ][topic multisignature]の署名、
  Taproot、コイン制御、[Musig2][topic musig]をサポートし、
  [BIP129][] BSMS（Bitcoin Secure Multisig Setup）ファイルのアウトプットディスクリプター再利用することで、
  参加者間の安全な通信をサポートします。

- **FROSTRプロトコルの発表:**
  [FROSTR][frostr github]は、FROST[閾値署名スキーム][topic threshold signature]を使用して、
  nostr用のk-of-n署名と鍵管理を実現します。

- **Barkがsignetでローンチ:**
  [Ark][topic ark]の[Bark][new325 bark]実装が[signet][topic signet]で[利用可能になり][second blog]、
  テスト用のFaucetとデモストアが提供されています。

- **Cove Bitcoinウォレットの発表:**
  [Cove Wallet][cove wallet github]は、PSBTや[ウォレットラベル][topic wallet labels]、
  ハードウェア署名デバイスなどのテクノロジーをサポートする、BDKベースのオープンソースのBitcoinモバイルウォレットです。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 29.0rc2][]は、ネットワークの主要なフルノードの次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31649][]は、数年前に実装されたヘッダーの事前同期ステップ（ニュースレター [#216][news216 presync]参照）
  以降は不要になったすべてのチェックポイントロジックを削除します。この事前同期ステップにより、
  ノードは初期ブロックダウンロード（IBD）中に、トータルのPoW（proof of work）を事前定義された閾値
  `nMinimumChainWork`と比較することで、ヘッダーのチェーンが有効かどうかを判断できます。
  トータルのPoWがこの値を超えるチェーンのみが有効とみなされ保存されるため、
  作業量の少ないヘッダーによるメモリDoS攻撃を効果的に防止できます。これにより、
  集中化の要因と見なされることが多かったチェックポイントが不要になります。

- [Bitcoin Core #31283][]は、`BlockTemplate`インターフェースに新しい`waitNext()`メソッドを導入します。
  このメソッドは、チェーンの先頭が変更された場合、またはmempoolの手数料が`MAX_MONEY`閾値を超えた場合にのみ、
  新しいテンプレートを返します。これまでは、マイナーはリクエスト毎に新しいテンプレートを受け取っていたため、
  不要なテンプレートの生成が発生していました。この変更は、[Stratum V2][topic pooled mining]プロトコル仕様に準拠しています。

- [Eclair #3037][]は、`listoffers`コマンド（ニュースレター [#345][news345 offers]参照）を強化し、
  生のTLV（Type-Length-Value）データだけでなく、`createdAt`および`disabledAt`タイムスタンプを含む
  すべての関連する[オファー][topic offers]データを返します。さらにこのPRでは、
  同じオファーを2回登録しようとするとノードがクラッシュするバグを修正しています。

- [LND #9546][]は、`lncli constrainmacaroon`サブコマンド（ニュースレター [#201][news201 constrain]参照）に
  `ip_range`フラグを追加し、ユーザーがmacaroon（認証トークン）を使用する際に、
  リソースへのアクセスを特定のIP範囲に制限できるようにします。これまでは、
  macaroonは範囲ではなく特定のIPアドレスに基づいてのみアクセスを許可または拒否できていました。

- [LND #9458][]は、サーバーの初期アクセス権限を管理するために、
  `--num-restricted-slots`フラグで構成可能な、特定のピアに対する制限付きアクセススロットを導入します。
  ピアには、チャネル履歴に基づいてアクセスレベルが割り当てられます。
  承認済みのチャネルを持つピアには保護されたアクセスが与えられ、
  未承認のチャネルを持つピアには一時的なアクセスが与えられ、その他のピアには制限されたアクセスが与えられます。

- [BTCPay Server #6581][]では、[RBF][topic rbf]のサポートが追加され、
  子孫がなく、すべてのインプットがストアのウォレットのもので、
  ストアのお釣り用アドレスを1つ含むトランザクションの引き上げが可能になります。
  ユーザーは、トランザクションの手数料の引き上げを選択する際に、
  [CPFP][topic cpfp]とRBFのどちらかを選択できるようになります。
  手数料の引き上げには、NBXplorerバージョン2.5.22以降が必要です。

- [BDK #1839][]では、新しい`TxUpdate::evicted_ats`フィールドを導入することで、
  キャンセルされた（二重使用された）トランザクションの検出と処理のサポートが追加されました。
  このフィールドは、`TxGraph`の`last_evicted`タイムスタンプを更新します。
  トランザクションの`last_evicted`タイムスタンプが`last_seen`タイムスタンプを超えている場合、
  そのトランザクションは排除されたと見なされます。正規化アルゴリズム（ニュースレター
  [#335][news335 algorithm]参照）は、推移規則により正規の子孫が存在する場合を除いて、
  排除されたトランザクションを無視するように更新されています。

- [BOLTs #1233][]は、ノードがプリイメージを知っている場合は
  上流の[HTLC][topic htlc]を失敗させないようにノードの動作を更新し、
  HTLCが適切に解決されることを保証します。これまでは、プリイメージが分かっていても、
  承認済みのコミットメントにHTLCがない場合は、未処理の上流のHTLCを失敗させることが推奨されていました。
  0.18未満のLNDにはバグがあり、DoS攻撃を受けたノードは、プリイメージを知っているにもかかわらず、
  再起動後に上流のHTLCを失敗させ、HTLCの金額が失われていました（ニュースレター [#344][news344 lnd]参照）。

{% include snippets/recap-ad.md when="2025-03-25 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31649,31283,3037,9546,9458,6581,1839,1233" %}
[bitcoin core 29.0rc2]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[morehouse sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512
[ismail sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512/3
[news216 presync]: /ja/newsletters/2022/09/07/#bitcoin-core-25717
[news345 offers]: /ja/newsletters/2025/03/14/#eclair-2976
[news201 constrain]: /ja/newsletters/2022/05/25/#lnd-6529
[news344 lnd]: /ja/newsletters/2025/03/07/#lnd
[news335 algorithm]: /ja/newsletters/2025/01/03/#bdk-1670
[wally 1.4.0]: https://github.com/ElementsProject/libwally-core/releases/tag/release_1.4.0
[bccg github]: https://github.com/jurraca/core-config-tui
[riap github]: https://github.com/thunderbiscuit/regtest-in-a-pod
[podman website]: https://podman.io/
[podman bitcoin blog]: https://thunderbiscuit.com/posts/podman-bitcoin/
[explora github]: https://github.com/lontivero/explora
[hashpool github]: https://github.com/vnprc/hashpool
[news247 sri]: /ja/newsletters/2023/04/19/#stratum-v2
[pod337 hashpool]: /en/podcast/2025/01/21/#continued-discussion-about-rewarding-pool-miners-with-tradeable-ecash-shares-transcript
[news281 demand]: /ja/newsletters/2023/12/13/#stratum-v2
[dmnd website]: https://www.dmnd.work/
[embit website]: https://embit.rocks/
[news273 krux]: /ja/newsletters/2023/10/18/#krux
[tropic01 website]: https://tropicsquare.com/tropic01
[tropicsquare github]: https://github.com/tropicsquare
[nunchuk blog]: https://nunchuk.io/blog/group-wallet
[frostr github]: https://github.com/FROSTR-ORG
[new325 bark]: /ja/newsletters/2024/10/18/#bark-ark
[second blog]: https://blog.second.tech/try-ark-on-signet/
[cove wallet github]: https://github.com/bitcoinppl/cove
