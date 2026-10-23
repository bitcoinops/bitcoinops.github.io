---
title: 'Bitcoin Optech Newsletter #428'
permalink: /ja/newsletters/2026/10/23/
name: 2026-10-23-newsletter-ja
slug: 2026-10-23-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、発行者の協力なしにユーザーがオンチェーンでビットコインを償還できる単一発行者型のレイヤー2の設計と、
アウトプットスクリプトディスクリプターにハッシュのプリイメージを含める提案を掲載しています。
また、サービスやクライアントソフトウェアの最近の更新、新しいリリースとリリース候補の発表、
人気のあるBitcoin基盤ソフトウェアの注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **<!--trust-minimized-exits-from-a-single-issuer-layer-2-->単一発行者型のレイヤー2におけるトラストを最小化した退出:**
  Adam Gibsonは、Lichenの[論文][lichen paper]と概念実証[コード][lichen repo]を
  Bitcoin-Devメーリングリストに[投稿しました][lichen ml]。Lichenは、
  Gibsonがハブと呼ぶ単一の発行者が、シーケンサーと呼ばれるサーバーが運営するレイヤー2の台帳上で、
  ビットコインと1対1で償還可能なトークンを発行する設計です。各ユーザーはハブとの2-of-2コントラクトを保持しており、
  ハブが拒否したりオフラインであったりしても、トークンを償還できます。そのため、
  ユーザーは台帳を正直に運営することについてはシーケンサーを信頼しますが、
  ビットコインを返還することについてハブを信頼する必要はありません。
  この設計はLN-GAP（[ニュースレター #427][news427 lngap]参照）をベースにしていますが、
  その正直な多数派による証明委員会を、完全にオンチェーンで解決される紛争処理に置き換えています。

  各ユーザーは、ハブとの自身の2-of-2アウトプットにビットコインをロックし、
  レイヤー2台帳上で同額のトークンを受け取ります。ユーザー間の支払いはこのレイヤー2台帳上で行われ、チェーンには記録されません。
  退出する場合、ユーザーはトークンをハブに返し、自身のアウトプットからビットコインを回収します。
  ユーザーが資金を引き出せるのはこのアウトプットのみであるため、
  ハブも各アウトプットに（LNのインバウンド流動性と同様に）合意された上限額まで自身のビットコインをロックしておきます。
  これにより、ユーザーは他のユーザーから受け取ったトークンをビットコインに償還可能になります。
  上限を超えて受け取ったトークンについては、ハブの裁量でのみ償還可能です。

  協調的なケースでは、ハブは単にユーザーに支払うアウトプットの決済に署名します。
  ハブが拒否したり応答しなかったりした場合、ユーザーは、
  「シーケンサーがトークンの返却を記録した状態に署名した」ことを示すGroth16証明を生成します。
  BitcoinのScriptはこのような証明を検証できないため、ユーザーは代わりに、オンチェーン上で
  「特定の検証プログラムがその証明を受け入れるはずである」と主張します。
  これに対してハブが異議を唱えた場合、事前署名された[BitVMX][topic acc]トランザクションによって、
  争点をScriptで検査可能な単一の実行ステップにまで絞り込みます。
  双方は紛争に負けた場合に没収される準備金をロックしており、これが虚偽の主張や拒否を抑止します。
  Gibsonは、ユーザーへの返却を省略したり、実際には到達していない状態に署名したりするシーケンサーが、
  依然としてユーザーやハブに資金の損失をもたらす可能性があることを認めており、
  有効性証明（validity proof）とシーケンサーの委員会を今後の課題として挙げています。

- **<!--descriptor-syntax-for-hash-preimages-->ハッシュのプリイメージ用のディスクリプター構文:**
  João Diasは、[miniscript][topic miniscript]にハッシュフラグメント用のプライベートな形式を追加するために
  [BIP379][]を拡張する提案をDelving Bitcoinに[投稿しました][desc del]。現時点では、
  使用条件を満たすためにプリイメージを必要とする資金を使用するために、
  Bitcoin Coreのウォレットにプリイメージを直接渡す方法はありません。外部ツールを使って、
  [PSBT][topic psbt]のハッシュフィールドのいずれか（例: `PSBT_IN_SHA256`）で提供することしかできません。
  著者は、この提案はディスクリプターの作成時にすでに判明しているプリイメージのみを対象としており、
  [HTLC][topic htlc]のように使用時に判明するものは対象としていないと述べました。

  Diasは、プリイメージは署名よりも鍵のように扱われるべきであると説明し、
  [ディスクリプター][topic descriptors]モデルにおける不整合を強調しました。彼のアイデアは、
  ウォレットがディスクリプターからシークレットをインポートし、
  トランザクションを直接構築して署名できるようにすることを目指しています。そのために、
  著者はディスクリプター用の特定の構文（例: `sha256(preimage(HEX))`）と、一連の制約を提案しました。
  制約には、素のhex値ではなく特定のマーカーを使用すること、
  すべてのハッシュフラグメントのサイズを32 byteに固定すること、プリイメージを他のシークレットと同様に扱い、
  バックアップや暗号化を行い、公開ディスクリプター文字列には決して表示しないことなどが含まれます。

  提案の正式化に進む前に、Diasは対処すべき未解決の点をいくつか挙げました。
  マーカーの構文をどうすべきか、BIP379を修正するか新しいBIPを起草すべきか、
  Bitcoin Coreがプリイメージを管理するためのRPCコールを追加する必要があるか、
  ハードウェア署名デバイスがプリイメージのシークレットを扱うべきか、それともソフトウェアウォレットのみに留めるべきか、
  鍵マテリアルからプリイメージを決定論的に導出することに関心があるかといった点です。

## サービスとクライアントソフトウェアの更新

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Ibis Wallet v5.0-betaのリリース:** [Ibis Wallet v5.0-beta][ibis v5.0]（[ニュースレター #406][news406 ibis]参照）は、
  Barkをベースにした[Ark][topic ark]のサポート、Spark[ステートチェーン][topic statechains]からの一方的な退出、
  [サイレントペイメント][topic silent payments]アドレスでの受け取りを追加しています。

- **ライトニングによるマイニング報酬支払い用のLandfallウォレット:** [Landfall][landfall gh]は、
  現在実現可能なUXを示す概念実証ウォレットで、マイニングプールOCEANがLN経由で報酬を支払うために必要とする支払いアドレス、
  [BOLT12オファー][topic offers]、[BIP322][topic generic signmessage]署名を
  Lexeがホストするノード（[ニュースレター #419][news419 lexe]参照）を使用して単一のシードから導出します。
  なお、本番環境での使用は想定されていません。

- **rbitcoin 0.8.0のリリース:** [rbitcoin 0.8.0][rbitcoin 0.8.0]は、
  Rustで書かれrust-bitcoinをベースに構築されたBitcoinフルノードで、全面的にAIによって書かれたとされています。
  ウォレットおよびライトニングのバックエンド向けで、UTXOセットをリレーショナルアーカイブに置き換え、
  ElectrumおよびEsploraスタイルのAPIを提供し、通信には[BIP324][topic v2 p2p transport]のみを使用します。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Eclair 0.14.4][]と[0.14.5][Eclair 0.14.5]は、このLNノード実装のセキュリティリリースです。
  バージョン0.14.4は、[ニュースレター #427][news427 eclair fixes]で説明した、
  [スプライシング][topic splicing]、[HTLC][topic htlc]の決済、[オンザフライファンディング][topic jit channels]、
  オニオンのパースに関連する複数の問題を修正しています。また、
  キャッシュされたHTTP Basic認証の認証情報を使ったクロスサイトリクエストフォージェリを防ぐため、
  `Origin`ヘッダーを持つAPIリクエストを拒否するようになりました（[ニュースレター #423][news423 eclair api]参照）。
  ブラウザベースの統合は、Eclairを呼び出すために独自のバックエンドを使用する必要があります。
  バージョン0.14.5は、後述するトランポリンルーティングとTaprootスプライシングの脆弱性を修正し、
  [ニュースレター #427][news427 eclair onion]で取り上げたオニオンペイロード長の検証に対する整数オーバーフローによるバイパスを塞いでいます。
  プロジェクトはアップグレードを強く推奨しています。

- [BDK chain 0.23.4][]は、Bitcoinウォレット構築用のBDKライブラリのメンテナンスリリースです。
  トランザクションの追跡と、過去に使用されたすべてのアドレスを確認し終える前にフルスキャンが停止してしまう問題を修正しています。
  付随するアップデートでは、再編成後のBitcoin Core RPC同期に関する修正や、
  以前に取り上げたElectrumの修正（[txidの検証][news403 bdk txid]、
  [最初のアウトプットが`OP_RETURN`であるトランザクションの承認検知][news405 bdk opreturn]、
  [再編成後の承認追跡][news427 bdk reorg]など）を含んでいます。

- [LND v0.21.5-beta.rc1][]と[v0.20.6-beta.rc1][LND v0.20.6-beta.rc1]は、
  この人気のあるLNノード実装のメンテナンスバージョンのリリース候補です。
  どちらも[ニュースレター #418][news418 lnd fees]で説明した手数料更新の処理とチャネルメッセージの制限に加え、
  コミットメントの手数料率の問題、TLVレコードのパース時の過剰なメモリ割り当て、
  SQLデータベースのデッドロックの修正を含んでいます。バージョン0.21.5は、
  [ニュースレター #427][news427 lnd aux]で説明した[Taproot Assets][topic client-side validation]チャネル向けの
  補助的な[HTLC][topic htlc]署名検証の修正も含まれており、ブロックチェーンの再編成中のウォレット同期に関する問題も修正しています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Eclair #3409][]は、悪意のある支払人が[トランポリンペイメント][topic trampoline payments]を転送するノードから
  資金を盗み出せる可能性のある脆弱性を修正しています。Eclairは、
  送信HTLCが受信HTLCより先に期限切れになることを保証するため、
  下流ルートの合計[CLTV expiry delta][topic cltv expiry delta]を制限するようになりました
  （関連する修正については[ニュースレター #423][news423 eclair cltv]参照）。これまでは、
  経路探索が失敗した場合、Eclairはルート長と有効期限の制限を緩和して再試行していたため、
  支払人は過大なexpiry deltaを持つルーティングヒントや[ブラインドパス][topic rv routing]を提供することができました。
  すると支払人は、受信HTLCが期限切れになった後にオンチェーンでそれを取り戻せる一方で、
  受信者は依然として送信HTLCを請求できる状態になります。Eclairは現在、ルート長の制限のみを緩和し、必要な有効期限の順序を維持します。

- [Eclair #3411][]は、悪意のあるチャネルピアがEclairに無効な[スプライシング][topic splicing]トランザクションへ署名させることで
  資金を盗み出せる可能性のある脆弱性を修正しています（関連する修正については[ニュースレター #427][news427 eclair splice]参照）。
  [Simple Taproot Channel][topic simple taproot channels]をスプライシングする際、
  ピアは完全なトランザクションの代わりに、インプットの前のアウトプットの金額とスクリプトのみを提供できます。
  これまでは、Eclairはこれらの値を検証せずに信頼していました。ピアはどちらのフィールドについても嘘をつくことができ、
  Taproot署名は使用されるインプットの実際の金額とスクリプトにコミットするため、
  Eclairに決して承認されることのないスプライシングトランザクションへ署名させることができました。それにもかかわらず、
  Eclairはその無効なスプライシングを最新のチャネルファンディング状態として扱っていました。ピアはその後、
  以前のファンディングアウトプットを使用する以前に署名済みのコミットメントを公開し、
  Eclairの対応する受信HTLCがタイムアウトして返金された後に、
  送信[HTLC][topic htlc]をそのペイメントプリイメージを使って請求することができ、
  Eclairは転送した支払いを回収できなくなります。Eclairは現在、署名する前に、
  主張されたアウトプットをBitcoinバックエンドと照合して検証します。

- [LDK #5126][]は、1ホップの[ブラインドパス][topic rv routing]を使用する[BOLT12][topic offers]支払いが、
  HTLCの有効期限が短すぎるという理由で拒否されてしまうバグを修正しています。これまでは、
  LDKは導入ノードが受信者でもある場合、パスの`cltv_expiry_delta`を無視していました。これは、
  その値に受信者が要求する[最終的なCLTV delta][topic cltv expiry delta]が含まれているという事実を見落としていました。
  その結果、支払いはLDKのランダムなCLTVオフセットが十分に大きい場合にのみ受信者の最小要件を満たすという状況が生じていました。
  これにより、Core Lightningに対するテストにおいて、断続的な支払い失敗が発生していました。LDKは現在、
  ルートを構築する際と、許容される合計CLTV deltaの最大値を確認する際に、通知されたdeltaを含めます。

- [LND #10919][]は、[チャネルジャミング攻撃][topic channel jamming attacks]を緩和するための
  実験的なローカルレピュテーションシステムを追加しています。これは提案されている
  HTLCアカウンタビリティスキーム（ニュースレター[#377][news377 jamming]および[#387][news387 accountability]参照）に基づいており、
  以前の[HTLCエンドースメント][topic htlc endorsement]アプローチを置き換えるものです。このシステムは、
  過去の転送活動とノードがアドバタイズする手数料に基づいて送信チャネルをスコア付けし、
  解決に時間がかかりすぎるアカウンタブルな[HTLC][topic htlc]にペナルティを課します。
  システムはデフォルトで有効になっており、転送の判断に影響を与えることなく、
  HTLCが保護されたリソースの対象となるかどうかをログに記録します。レピュテーションは再起動時にリセットされます。

- [BTCPay Server #7679][]は、ライトニング経由の支払いが重複する可能性があるバグを修正しています。
  これまでは、支払いが開始され、その後の支払い検索で結果が返されなかった場合、BTCPay Serverは支払いをキャンセルし、
  保存していたペイメントハッシュを破棄していました。これは支払いが成功していた場合でも発生していました。その結果、
  オペレーターはすでに成功した支払いに対して別の支払いを発行してしまう可能性がありました。BTCPay Serverは現在、
  進行中の支払いとそのペイメントハッシュを、後続の確認のために保持します。

- [BTCPay Server #7684][]は、Greenfield APIキーの認可における権限昇格を修正しています。
  これまでは、特定のストアに制限されたAPIキーが、その限定されたスコープにもかかわらず、
  サーバー全体またはアカウント全体の権限を行使できました。さらに、他のユーザーのAPIキーを作成する権限を持つキーは、
  自身よりも広い権限を付与することもできました。BTCPay Serverは現在、リクエストを認可する際に権限スコープを適用し、
  APIキーが自身の持たない権限を付与することを防止します。既存の無制限の管理者キーは、意図された機能を維持します。

- [BDK #2325][]と[#2360][bdk #2360]は、ウォレットが要求されたトランザクションデータを取得していないにもかかわらず、
  同期が成功したと報告する可能性がある2つのバグを修正しています。1つめは、個々のアウトポイントのElectrum同期に影響します。これまでは、
  BDKはそれらのトランザクションを取得する際に発生した接続失敗やタイムアウトを含むすべてのエラーを無視していました。
  これにより、使用済みのアウトプットが未使用として分類されたままになる可能性がありました。BDKは現在、
  このパスではElectrumプロトコルエラーは無視しつつ、その他の失敗は伝播させます。2つめのPRは、
  ElectrumおよびEsploraクライアントの`sync`と`full_scan`を修正しています。これまでは、
  Electrumの`batch_size`またはEsploraの`parallel_requests`をゼロに設定すると、
  要求されたスキャンやトランザクションの取得をスキップしながら成功を報告する可能性がありました。
  両クライアントは現在、これらのパラメータについてゼロを1として扱います。

- [BOLTs #1357][]は[BOLT11][]を更新し、インボイスの読み取り側に対して、
  ペイメントハッシュ（`p`）フィールドと支払いシークレット（`s`）フィールドがそれぞれ1つずつ含まれていない限りインボイスを拒否することを要求します。
  これまでは、仕様では支払人が最初の`p`フィールドを使用することを推奨していましたが、
  一部のインボイスパーサーは最後のものを使用していました。この不一致は[LNP2PBotに対して悪用されました][lnp2p incident]。
  LNP2PBotのインボイスパーサーとライトニングノードは、異なるペイメントハッシュを選択していました。その結果、
  ボットは完了した支払いを未払いとして扱い、攻撃者が重複した支払いを得ることを可能にしていました（[ニュースレター #425][news425 lnd]参照）。

- [BOLTs #1352][]は、[Simple Taproot Channel][topic simple taproot channels]の仕様とテストベクトルにおける複数の誤りを修正しています
  （[ニュースレター #404][news404 taproot]参照）。Taprootのアウトプットキー導出とコントロールブロック構築における誤りは、
  以前の仕様どおりに実装した場合、無効な支払いを生成する可能性がありました。このPRはまた、
  `commitment_signed`で交換される[HTLC][topic htlc]署名が`SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`を使用することを明確にしています。
  受信側のピアは、witnessを構築する際に64 byteの署名に`0x83`を追加します。
  手数料引き上げのために2段目のトランザクションを結合する際、各HTLCインプットとそれに対応するアウトプットは、
  結合後のトランザクションで同じインデックス位置にある必要があります。その他の修正は、
  [アンカーの使用パス][topic anchor outputs]、[MuSig2][topic musig]のnonceのエンコーディングと導出、
  ローカルおよびリモートのコミットメントテストベクトルに関するものです。これらの変更は、
  プロトコルの動作を変更することなく、仕様を既存のLNDおよびEclairの実装と整合させるものです。

{% include snippets/recap-ad.md when="2026-10-27 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3409,3411,5126,10919,7679,7684,2325,2360,1357,1352" %}

[lichen ml]: https://groups.google.com/g/bitcoindev/c/yZEZ5P1lj5E
[lichen paper]: https://github.com/AdamISZ/lichen/blob/master/papers/lichen-v0.1.pdf
[lichen repo]: https://github.com/AdamISZ/lichen
[news427 lngap]: /ja/newsletters/2026/10/16/#offchain-contracts-in-lightning-channels
[ibis v5.0]: https://github.com/aeonBTC/IbisWallet/releases/tag/v5.0.1-beta
[news406 ibis]: /ja/newsletters/2026/05/22/#ibis-wallet
[landfall gh]: https://github.com/vincenzopalazzo/landfall
[news419 lexe]: /ja/newsletters/2026/08/21/#lexe-lnurl-withdraw
[rbitcoin 0.8.0]: https://github.com/reardencode/rbitcoin/releases/tag/v0.8.0
[desc del]: https://delvingbitcoin.org/t/descriptor-syntax-for-hash-preimages/2935
[Eclair 0.14.4]: https://github.com/ACINQ/eclair/releases/tag/v0.14.4
[Eclair 0.14.5]: https://github.com/ACINQ/eclair/releases/tag/v0.14.5
[BDK chain 0.23.4]: https://github.com/bitcoindevkit/bdk/releases/tag/chain-0.23.4
[LDK #5126]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5126
[lnp2p incident]: https://x.com/negrunch/status/2097763741123166576
[news423 eclair api]: /ja/newsletters/2026/09/18/#eclair-3380
[news427 eclair fixes]: /ja/newsletters/2026/10/16/#注目すべきコードとドキュメントの更新
[news427 eclair onion]: /ja/newsletters/2026/10/16/#eclair-3395
[news403 bdk txid]: /ja/newsletters/2026/05/01/#bdk-2188
[news405 bdk opreturn]: /ja/newsletters/2026/05/15/#bdk-2195
[news427 bdk reorg]: /ja/newsletters/2026/10/16/#bdk-2319
[news423 eclair cltv]: /ja/newsletters/2026/09/18/#eclair-3376
[news427 eclair splice]: /ja/newsletters/2026/10/16/#eclair-3396
[news377 jamming]: /ja/newsletters/2025/10/24/#channel-jamming-mitigation-simulation-results-and-updates
[news387 accountability]: /ja/newsletters/2026/01/09/#lnd-10367
[news425 lnd]: /ja/newsletters/2026/10/02/#lnd-11190
[news404 taproot]: /ja/newsletters/2026/05/08/#bolts-995
[LND v0.21.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.5-beta.rc1
[LND v0.20.6-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.6-beta.rc1
[news418 lnd fees]: /ja/newsletters/2026/08/14/#lnd-11023
[news427 lnd aux]: /ja/newsletters/2026/10/16/#lnd-11068
