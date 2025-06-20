---
title: 'Bitcoin Optech Newsletter #359'
permalink: /ja/newsletters/2025/06/20/
name: 2025-06-20-newsletter-ja
slug: 2025-06-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreリポジトリへの一般参加を制限する提案と、
BitVMスタイルのコントラクトの大幅な改良の発表、LNチャネルのリバランスに関する研究の概要を掲載しています。
また、クライアントとサービスの最近の更新や、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャソフトウェアの最近の更新など、恒例のセクションも含まれています。

## ニュース

- **Bitcoin Coreプロジェクトの議論へのアクセス制限の提案:**
  Bryan Bishopは、非コントリビューターによる混乱を軽減するために、
  Bitcoin Coreプロジェクトがプロジェクトの議論への一般参加者の参加を制限する提案を
  Bitcoin-Devメーリングリストに[投稿しました][bishop priv]。
  彼はこれを「Bitcoin Coreのプライベート化」と呼び、
  複数のBitcoin Coreコントリビューターがいるプライベートオフィスで
  既にアドホックに行われているプライベート化の例を挙げ、
  対面でのプライベート化は遠隔地のコントリビューターを除外してしまう可能性があると警告しました。

  Bishopの投稿では、オンラインでのプライベート化を提案していますが、
  Antoine Poinsotはその方法が目的を達成できるかどうか[疑問視][poinsot priv]しています。
  Poinsotはまた、多くのプライベートオフィスでの話し合いは、
  世間からの非難を恐れているのではなく、「対面での話し合いの自然な利点」により行われているのではないかと示唆しました。

  いくつかの返信では、現時点では大幅な変更はおそらく必要ないが、
  リポジトリのコメントのモデレーションを強化することで、最も重大なタイプの混乱を軽減できる可能性があると提案されました。
  しかし、他の返信では、より協力なモデレーションにはいくつかの課題があることが指摘されました。

  （執筆時点でこのスレッドに返信したアクティブなBitcoin Coreコントリビューターである）
  Poinsot、Sebastian "The Charlatan" KungおよびRussell Yanofskyは、
  大きな変更は必要ないと[考えている][kung priv]か、変更は時間をかけて段階的に行うべきだと[示しました][yanofsky priv]。

- **BitVMスタイルのコントラクトの改良:** Robin Linusは、
  [BitVM][topic acc]スタイルのコントラクトに必要なオンチェーンスペースの大幅な削減の発表を
  Delving Bitcoinに[投稿しました][linus bitvm3]。新しい暗号プリミティブに基づく
  Jeremy Rubinの[アイディア][rubin garbled]を基に、
  この新しいアプローチは「以前の設計と比較して、紛争時のオンチェーンコストを1,000倍以上削減」し、
  反証トランザクションは「わずか200 byte」になります。

  しかし、Linusの論文では、このアプローチのトレードオフとして、
  「数TBのオフチェーンデータのセットアップが必要」であると指摘しています。
  論文では、約50億個のゲートと妥当なセキュリティパラメーターを備えたSNARK検証回路の例が示されています。
  これには5 TBのオフチェーンセットアップ、結果のアサーションに必要な56 kBのオンチェーントランザクション、
  そして当事者がアサーションの無効性を証明する必要がある場合の最小限のオンチェーントランザクション（約200 byte）が必要です。

- **<!--channel-rebalancing-research-->チャネルリバランスの研究:**
  Rene Pickhardtは、ネットワーク全体の支払い成功率を最大化するためのチャネルリバランスに関する考察を
  Delving Bitcoinに[投稿しました][pickhardt rebalance]。彼のアイディアは、
  [friend-of-a-friendリバランス][topic jit routing]（[ニュースレター #54][news54 foaf rebalance]参照）のような、
  チャネルの小規模グループを対象としたアプローチと比較することができます。

  Pickhardtは、グローバルアプローチにはいくつかの課題があると指摘し、
  このアプローチを追求する価値があるのか、特定の実装の詳細にどのように対処すべきかなど、
  関心のある関係者にいくつかの質問への回答を求めています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Cove v1.0.0リリース:**
  最近のCoveの[リリース][cove github]には、コインコントロールのサポートと、
  [BIP329][]ウォレットラベル機能が追加されました。

- **Liana v11.0リリース:**
  最近のLianaの[リリース][liana github]には、マルチウォレット機能、
  コインコントロール機能の追加、ハードウェア署名デバイスのサポートの強化などが含まれています。

- **Stratum v2 STARK証明のデモ:**
  StarkWareは、ブロック内のトランザクションを明かすことなく、
  ブロックの手数料が有効なブロックテンプレートに属していることを証明するために、
  STARK証明を用いた[改良版Stratum v2マイニングクライアント][starkware sv2]の[デモ][starkware tweet]を行いました。

- **Breez SDKがBOLT12とBIP353を追加:**
  Breez SDK Nodeless [0.9.0][breez github]では、[BOLT12][]と[BIP353]を使った受取のサポートが追加されました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 25.05][]は、この人気のLNノード実装の次期メジャーバージョンのリリースです。
  支払いのリレーと解決のレイテンシーを短縮し、手数料管理を改善し、
  Eclairと互換性のある[スプライシング][topic splicing]をサポートし、
  [ピアストレージ][topic peer storage]をデフォルトで有効化します。
  注：[リリースドキュメント][core lightning 25.05]には、
  `--experimental-splicing`設定オプションを使用するユーザーへの警告が記載されています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Eclair #3110][]では、ファンディングアウトプットが使用された後、
  チャネルをクローズとマークするまでの遅延を12ブロック（ニュースレター[#337][news337 delay]参照）から
  [BOLTs #1270][]で規定されている72ブロックに引き上げ、[スプライシング][topic splicing]の更新の伝播を可能にします。
  この遅延が引き上げられたのは、一部の実装では、`splice_locked`を送信する前にデフォルトで8承認が必要とされており、
  ノードオペレーターがその閾値を引き上げることができるため、12ブロックでは短すぎることが判明したからです。
  この遅延はテスト目的で設定可能になり、ノードオペレーターがより長く待機できるようになりました。

- [Eclair #3101][]では、[BOLT12 offer][topic offers]フィールドを人が読める形式にデコードする`parseoffer`
  RPCが導入されました。これにより、ユーザーは`payoffer` RPCに渡す前に金額を確認できます。
  `payoffer` RPCは、法定通貨で指定された金額を受け入れるように拡張されています。

- [LDK #3817][]は、[失敗の帰属][topic attributable failures]（ニュースレター[#349][news349 attributable]参照）
  のサポートをテスト専用フラグに設定してロールバックしました。これにより、
  ピアペナルティロジックが無効化され、失敗の[onionメッセージ][topic onion messages]から機能TLVが削除されました。
  まだアップグレードしていないノードが誤ってペナルティを受けていたため、
  この機能が適切に動作するには、より広範なネットワーク導入が必要であることが示されています。

- [LDK #3623][]は、[ピアストレージ][topic peer storage]（ニュースレター[#342][news342 peer]参照）を拡張し、
  自動暗号化ピアバックアップを提供します。各ブロックで、`ChainMonitor`はバージョン管理され、タイムスタンプが付けられ、
  シリアライズされた`ChannelMonitor`構造体のデータを`OurPeerStorage`ブロブにパッケージします。
  そして、そのデータを暗号化し、`SendPeerStorage`イベントを発生させて、
  そのブロブを`peer_storage`メッセージとして各チャネルピアにリレーします。さらに、
  `ChannelManager`が更新され、`peer_storage_retrieval`リクエストを処理できるように、
  新しいブロブ送信をトリガーします。

- [BTCPay Server #6755][]は、コイン管理ユーザーインターフェースを強化し、
  新しい最小・最大額フィルター、作成日前後フィルター、フィルター用のヘルプセクション、
  「すべて選択」UTXOチェックボックス、そして大きなページサイズオプション（100、200または500 UTXO）を追加しました。

- [Rust libsecp256k1 #798][]は、ライブラリ内の[MuSig2][topic musig]実装を完了させ、
  下流のプロジェクトが堅牢な[スクリプトレスマルチシグ][topic multisignature]プロトコルにアクセスできるようにしました。

{% include snippets/recap-ad.md when="2025-06-24 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3110,3101,3817,3623,6755,1270" %}
[Core Lightning 25.05]: https://github.com/ElementsProject/lightning/releases/tag/v25.05
[bishop priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CABaSBax-meEsC2013zKYJnC3phFFB_W3cHQLroUJcPDZKsjB8w@mail.gmail.com/
[poinsot priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/4iW61M7NCP-gPHoQZKi8ZrSa2U6oSjziG5JbZt3HKC_Ook_Nwm1PchKguOXZ235xaDlhg35nY8Zn7g1siy3IADHvSHyCcgTHrJorMKcDzZg=@protonmail.com/
[kung priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/58813483-7351-487e-8f7f-82fb18a4c808n@googlegroups.com/
[linus bitvm3]: https://delvingbitcoin.org/t/garbled-circuits-and-bitvm3/1773
[rubin garbled]: https://rubin.io/bitcoin/2025/04/04/delbrag/
[pickhardt rebalance]: https://delvingbitcoin.org/t/research-update-a-geometric-approach-for-optimal-channel-rebalancing/1768
[rust libsecp256k1 #798]: https://github.com/rust-bitcoin/rust-secp256k1/pull/798
[news54 foaf rebalance]: /en/newsletters/2019/07/10/#brainstorming-just-in-time-routing-and-free-channel-rebalancing
[yanofsky priv]: https://github.com/bitcoin-core/meta/issues/19#issuecomment-2961177626
[cove github]: https://github.com/bitcoinppl/cove/releases
[liana github]: https://github.com/wizardsardine/liana/releases
[breez github]: https://github.com/breez/breez-sdk-liquid/releases/tag/0.9.0
[starkware tweet]: https://x.com/dimahledba/status/1935354385795592491
[starkware sv2]: https://github.com/keep-starknet-strange/stratum
[news337 delay]: /ja/newsletters/2025/01/17/#eclair-2936
[news349 attributable]: /ja/newsletters/2025/04/11/#ldk-2256
[news342 peer]:/ja/newsletters/2025/02/21/#ldk-3575
