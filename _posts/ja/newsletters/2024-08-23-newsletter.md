---
title: 'Bitcoin Optech Newsletter #317'
permalink: /ja/newsletters/2024/08/23/
name: 2024-08-23-newsletter-ja
slug: 2024-08-23-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ウォレットとデバイス間の通信が1往復のみで済む流出防止プロトコルに関する議論を掲載しています。
また、クライアントとサービスのアップデートや、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの最近の変更など恒例のセクションも含まれています。

## ニュース

- **<!--simple-but-imperfect-anti-exfiltration-protocol-->シンプルな（ただし不完全な）流出防止プロトコル:** 開発者のMoonsettlerは、
  [流出防止][topic exfiltration-resistant signing]プロトコルの説明を
  Delving Bitcoinに[投稿しました][moonsettler exfil1]。
  同じプロトコルは以前にも紹介されています（ニュースレター[#87][news87 exfil]および[#88][news88 exfil]参照）。
  Pieter Wuilleは、流出防止技術に関する最も古い説明として、
  Gregory Maxwellによる[2014年の投稿][maxwell exfil]を[挙げています][wuille exfil1]。

  このプロトコルは、sign-to-contractプロトコルを使用して、
  ソフトウェアウォレットがハードウェア署名デバイスによって選択されたnonceにエントロピーを付与できるようにします。
  これによりソフトウェアウォレットは、後でエントロピーが使用されたことを検証できます。
  sign-to-contractは、[pay-to-contract][topic p2c]のバリエーションです。
  pay-to-contractでは受信者の公開鍵が調整され、sign-to-contractでは送信者の署名nonceが調整されます。

  このプロトコルの利点は、BitBox02やJadeハードウェア署名デバイス用に実装されたプロトコル（[ニュースレター
  #136][news136 exfil]参照）と比べて、ソフトウェアウォレットとハードウェア署名デバイス間の通信が1往復で済むことです。
  この1往復は、シングルシグまたはスクリプト化されたマルチシグトランザクションに署名するために必要な他の手順と組み合わせることができるため、
  この手法はユーザーのワークフローに影響を与えません。現在展開されている手法も、
  sign-to-contractに基づいており、2往復が必要です。これは今日のほとんどのユーザーにとって必要以上ですが、
  [スクリプトレスマルチシグ][topic multisignature]や
  [スクリプトレス閾値署名][topic threshold signature]を使用するようにアップグレードするユーザーの場合は、
  複数の往復が必要になる場合があります。署名デバイスをコンピューターに直接接続するユーザーや、
  Bluetoothなどの双方向のワイヤレス通信プロトコルを使用するユーザーにとっては、往復の回数は問題になりません。
  ただし、デバイスをエアギャップにしておきたいユーザーの場合、各往復に2回の手動介入が必要になります。
  これは、頻繁に署名する場合や、スクリプト化されたマルチシグ用に複数のデバイスを使用したりする場合には、
  すぐに煩わしい作業量になります。

  このプロトコルの欠点は、Maxwellが彼の最初の説明で言及したとおりで、
  「グラインディングにより追加ビットあたりのコストが指数関数的に増加する[サイドチャネル][topic side channels]攻撃は残りますが、
  [...]単一の署名ですべてが漏洩される明白で非常に強力な攻撃は排除することができます。
  これは明らかに完全とは言えませんが、2回のプロトコルであるため、対策の使用を検討しない多くの場所で、
  プロトコル仕様の要素としてこれを追加コストなしで採用できます。」

  このプロトコルは、流出防止をまったく使用しない場合に比べて明らかにアップグレードされており、
  Pieter Wuilleは、これがおそらく1ラウンド署名による流出防止としては最善であると[指摘しています][wuille exfil2]。
  ただし、Wuilleは、グリンディングベースの流出さえも防止するため、2ラウンドの流出防止プロトコルを推奨しています。

  この記事の執筆時点では、議論は進行中です。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Proton Walletの発表:**
  Protonは、複数のウォレットや[bech32][topic bech32]、[バッチ][topic payment batching]送金、
  [BIP39][]ニーモニックおよび彼らのメールサービスとの統合をサポートする[オープンソース][proton github]の
  Proton Walletを[発表しました][proton blog]。

- **CPUNet testnetの発表:**
  [braidpool][braidpool github]マイニング[プール][topic pooled mining]プロジェクトのコントリビューターが、
  テストネットワーク[CPUNet][cpunet github]を[発表しました][cpunet post]。
  CPUNetは、一般的な[testnet][topic testnet]よりも一貫したブロックレートを実現することを目的として、
  ASICマイナーを除外するために変更されたproof-of-workアルゴリズムを使用しています。

- **Lightning.Pubのローンチ:**
  [Lightning.Pub][lightningpub github]は、暗号化通信と鍵ベースのアカウントIDにnostrを使用し、
  共有アクセスとチャネルの流動性の調整を可能にするLNDのノード管理機能を提供します。

- **Taproot Assets v0.4.0-alphaリリース:**
  [v0.4.0-alpha][taproot assets v0.4.0]リリースは、オンチェーンでのアセットの発行と
  [PSBT][topic psbt]を使用したアトミックスワップおよびライトニングネットワークを介したアセットのルーティングを
  mainnetで実現する[Taproot Assets][topic client-side validation]プロトコルをサポートします。

- **Stratum v2ベンチマークツールのリリース:**
  最初の[0.1.0リリース][sbm 0.1.0]では、さまざまなマイニングシナリオにおける
  Stratum v1とStratum v2[プロトコル][topic pooled mining]のパフォーマンスのテスト、
  レポート、比較をサポートします。

- **signetでのSTARK検証PoC:**
  StarkWareは、[signet][topic signet]テストネットワーク上で[OP_CAT][topic op_cat] opcodeを使用して（
  [ニュースレター #304][news304 inquisition]参照）ゼロ知識証明を検証する[STARK verifier][bcs github]を[発表しました][starkware tweet]。

- **SeedSigner 0.8.0リリース:**
  Bitcoinハードウェア署名デバイスプロジェクトの[SeedSigner][seedsigner website]は、
  [0.8.0][seedsigner 0.8.0]リリースで、P2PKHおよびP2SHマルチシグの署名機能、
  追加の[PSBT][topic psbt]をサポート、デフォルトで[Taproot][topic taproot]サポートを有効にしました。

- **Floresta 0.6.0リリース:**
  [0.6.0][floresta 0.6.0]では、Florestaは[コンパクトブロックフィルター][topic compact block filters]、
  signetでのFraud Proofおよび、既存のウォレットやクライアントアプリケーションに統合するためのデーモンである
  [`florestad`][floresta blog]のサポートを追加しました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 24.08rc2][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。

- [LND v0.18.3-beta.rc1][]は、この人気のLNノード実装の軽微なバグ修正のリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #28553][]は、mainnetのブロック840,000の[assumeUTXO][topic assumeutxo]
  スナップショットパラメーター（ブロックハッシュ、そのブロックまでのトランザクション数、
  そのブロックまでのシリアライズされたUTXOセットのSHA256ハッシュ）を追加します。
  これは、複数のコントリビューターによるテストの結果で、期待されるSHA256チェックサムを持つ
  同じ[スナップショットファイル][snapshot file]を再現でき、スナップショットがロードされると正常に機能することが確認されています。

- [Bitcoin Core #30246][]は、`asmap-tool`ユーティリティに`diff_addrs`サブコマンドを導入し、
  ユーザーがASMap（[自律システム][auto sys]）の2つのマップを比較し、
  異なるAS番号に再割り当てされたノードネットワークアドレスの数に関する統計を計算できるようにします。
  この機能は、時間の経過と共にASMapが劣化する度合いを定量化します。これは、
  Bitcoin Coreのリリースで事前計算されたASMapを出荷し、
  Bitcoin Coreの[エクリプス攻撃][topic eclipse attacks]に対する耐性をさらに高めるための重要なステップです。
  ニュースレター[#290][news290 asmap]をご覧ください。

- [Bitcoin Core GUI #824][]は、`Migrate Wallet`メニューの項目を単一のアクションからメニューリストに変更し、
  ユーザーが、ロードできないウォレットを含む、ウォレットディレクトリ内の任意のレガシーウォレットを移行できるようにします。
  この変更は、[ディスクリプター][topic descriptors]ウォレットがデフォルトになり、
  レガシーウォレットがBitcoin Coreにロードできなくなる可能性がある将来に備えたものです。
  移行するウォレットを選択する際、ウォレットにパスフレーズがある場合、GUIがユーザーにその入力を求めます。

- [Core Lightning #7540][]は、ネットワーク内でランダムに選択されたチャネルが少なくとも1 msatを転送できる確率を表す
  定数乗数を追加することで、`renepay`プラグイン（ニュースレター[#263][news263 renepay]参照）で
  チャネルを経由してルーティングが成功する確率を計算する式を改善します。
  デフォルト値は0.98に設定されていますが、これは今後さらにテストを行った後に変更される可能性があります。

- [Core Lightning #7403][]は、非常に低い`max_htlc`を持つチャネルを無効にする
  チャネルフィルタリングペイメント修飾子を`renepay`プラグインに追加します。
  これは、将来拡張され、他の理由で望ましくないチャネル（基本手数料が高い、キャパシティが低い、
  高レイテンシーなど）を除外できます。さらに、手動でノードやチャネルを無効にするための
  新しい`exclude`コマンドラインオプションが追加されました。

- [LND #8943][]は、コードベースに[Alloy][alloy model]を導入しました。これは、[LND #8751][]のバグ修正に触発されたもので、
  [Linear Fee Function][lnd linear]の手数料引き上げメカニズム用の最初のAlloyモデルから始まります。
  Alloyは、システムコンポーネントの正しさを検証するための軽量な形式手法を提供し、
  初期実装中にバグを見つけやすくします。本格的な形式手法のようにモデルが常に正しいことを証明しようとするのではなく、
  Alloyは制限されたパラメーターのセットと反復の入力に基づいて動作し、
  優れたビジュアライザーと共に、特定のアサーションに対する反例を見つけようとします。
  モデルは、P2Pシステムでプロトコルを定義するためにも使用できるため、ライトニングネットワークに特に適しています。

- [BDK #1478][]は、`bdk_chain`クレートの`FullScanRequest`および`SyncRequest`のリクエスト構造をいくつか変更します。
  リクエストの構築と使用を分離するビルダーパターンを使用し、
  `chain_tip`パラメーターをオプションにしてユーザーが`LocalChain`の更新をオプトアウトできるようにし（
  `LocalChain`なしで`bdk_esplora`を使用している場合に便利です）、同期の進行状況を確認する際の人間工学を改善します。
  さらに、`bdk_esplora`クレートは、`TxGraph`の更新に常に以前のトランザクションアウトプットを追加し、
  `/tx/:txid`エンドポイントを使用してAPI呼び出し回数を削減することで最適化されています。

- [BDK #1533][]は、`Wallet::create_single`メソッドを追加することで、
  単一の[ディスクリプター][topic descriptors]ウォレットのサポートを有効にし、
  `Wallet`構造に内部（お釣り）ディスクリプターが必要になった以前の更新を元に戻しています。
  以前の変更の理由は、パブリックなElectrumまたはEsploraサーバーに依存する際に、
  ユーザーのお釣り用のアドレスのプライバシーを保護するためでしたが、
  すべてのユースケースを含むよう元に戻されています。

- [BOLTs #1182][]は、[BOLT4][]仕様の[ルートブラインド][topic rv routing]と
  [Onionメッセージ][topic onion messages]のセクションの明確さと完全性を向上させるために以下の変更を加えました。
  ルートブラインドのセクションを1レベル上に移動して、（Onionメッセージだけではない）支払いへの適用性を強調し、
  `blinded_path`型とその要件についてより具合的な詳細を提供し、
  `blinded_path`のライターの責任と説明を拡張し、`blinded_path`のリーダーのセクションを`blinded_path`と`encrypted_recipient_data`の別々の部分に分離し、
  `blinded_path`のコンセプトの説明を改善し、ダミーホップの使用を推奨し、
  `onionmsg_hop`の名前を`blinded_path_hop`に変更し、その他の明確化のための変更を加えました。

- [BLIPs #39][]は、受信側のノードに支払うための[ブラインドパス][topic rv routing]を伝えるために
  [BOLT11][]インボイスにオプションフィールド`b`を追加する[BLIP39][]を追加しました。
  これはLNDに実装されており（ニュースレター[#315][news315 blinded]参照）、
  [オファー][topic offers]プロトコルがネットワークで広く展開されるまで使用することを目的としています。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28553,30246,824,7540,7403,8943,1478,1533,1182,39,8751" %}
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[moonsettler exfil1]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081
[wuille exfil1]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081/3
[wuille exfil2]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081/7
[news87 exfil]: /ja/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news88 exfil]: /ja/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[maxwell exfil]: https://bitcointalk.org/index.php?topic=893898.msg9861102#msg9861102
[news136 exfil]: /ja/newsletters/2021/02/17/#anti-exfiltration
[proton blog]: https://proton.me/blog/proton-wallet-launch
[proton github]: https://github.com/protonwallet/
[braidpool github]: https://github.com/braidpool/braidpool
[cpunet post]: https://x.com/BobMcElrath/status/1823370268728873411
[cpunet github]: https://github.com/braidpool/bitcoin/blob/cpunet/contrib/cpunet/README.md
[lightningpub github]: https://github.com/shocknet/Lightning.Pub
[taproot assets v0.4.0]: https://github.com/lightninglabs/taproot-assets/releases/tag/v0.4.0
[sbm 0.1.0]: https://github.com/stratum-mining/benchmarking-tool/releases/tag/0.1.0
[starkware tweet]: https://x.com/StarkWareLtd/status/1813929304209723700
[bcs github]: https://github.com/Bitcoin-Wildlife-Sanctuary/bitcoin-circle-stark
[news304 inquisition]: /ja/newsletters/2024/05/24/#bitcoin-inquisition-27-0
[seedsigner website]: https://seedsigner.com/
[seedsigner 0.8.0]: https://github.com/SeedSigner/seedsigner/releases/tag/0.8.0
[floresta 0.6.0]: https://github.com/vinteumorg/Floresta/releases/tag/0.6.0
[floresta blog]: https://medium.com/vinteum-org/floresta-update-simplifying-bitcoin-node-integration-for-wallets-6886ea7c975c
[auto sys]: https://ja.wikipedia.org/wiki/自律システム_(インターネット)
[news290 asmap]: /ja/newsletters/2024/02/21/#asmap
[news263 renepay]: /ja/newsletters/2023/08/09/#core-lightning-6376
[alloy model]: https://alloytools.org/about.html
[lnd linear]: https://github.com/lightningnetwork/lnd/blob/b7c59b36a74975c4e710a02ea42959053735402e/sweep/fee_function.go#L66-L109
[news315 blinded]: /ja/newsletters/2024/08/09/#lnd-8735
[snapshot file]: magnet:?xt=urn:btih:596c26cc709e213fdfec997183ff67067241440c&dn=utxo-840000.dat&tr=udp%3A%2F%2Ftracker.bitcoin.sprovoost.nl%3A6969
