---
title: 'Bitcoin Optech Newsletter #368'
permalink: /ja/newsletters/2025/08/22/
name: 2025-08-22-newsletter-ja
slug: 2025-08-22-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、フルノード間でブロックテンプレートを共有するためのBIPドラフトと、
スクリプト評価の信頼する委任を可能にするライブラリ（Bitcoinのネイティブスクリプト言語ではできない機能を含む）の発表を
掲載しています。また、サービスとクライアントソフトウェアの最近のアップデートや、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき更新など、
恒例のセクションも含まれています。

## ニュース

- **ブロックテンプレート共有のためのBIPドラフト:** Anthony Townsは、
  ノードが次のブロックでマイニングしようとしているトランザクションをピアに伝える方法（
  [ニュースレター #366][news366 templshare]参照）についてのBIPの
  [ドラフト][towns bipdraft]をBitcoin-Devメーリングリストに[投稿しました][towns bipshare]。
  これにより、ノードが自身のmempoolおよびマイニングポリシーで受け入れるトランザクションを、
  通常であればピアが自身のポリシーにより拒否する可能性のある場合でも共有できます。
  これによりピアは、これらのトランザクションがマイニングされた場合に備えてトランザクションをキャッシュすることができます（
  これにより、[コンパクトブロックリレー][topic compact block relay]の効率が向上します）。
  ノードのブロックテンプレートに含まれるトランザクションは通常、
  そのノードが認識している未承認トランザクションの中で最も収益性が高いため、
  これまでポリシー上の理由でこれらのトランザクションを拒否していたピアも、
  これらのトランザクションを改めて検討する価値があると判断する可能性があります。

  BIPのドラフトで規定されているプロトコルはシンプルです。ピアとの接続の開始直後に、
  ノードはブロックテンプレートを送信する意思があることを示す、
  `sendtemplate`メッセージを送信します。その後、ピアは、
  `gettemplate`メッセージでテンプレートを要求できます。その要求への応答として、
  ノードは[BIP152][]のコンパクトブロックメッセージと同じ形式の短いトランザクション識別子のリストを含む
  `template`メッセージで応答します。ピアは、（BIP152と同様に）
  `sendtransactions`メッセージにその短い識別子を含めることで、必要なトランザクションを要求できます。
  BIPドラフトでは、テンプレートのサイズは、現在の最大ブロックウェイト制限の2倍よりわずかに大きいサイズまで許容されています。

  テンプレートの共有に関するDelving Bitcoinの[スレッド][delshare]では、
  今週、提案の帯域幅効率を向上させる方法について追加の議論が行われました。
  議論されたアイディアには、前回のテンプレートとの[差分のみ][towns templdiff]を送信する案（推定90%の帯域幅の節約）、
  （より大きなテンプレートを効率的に共有可能な）[minisketch][topic minisketch]で有効になる
  [セット調整][jahr templerlay]プロトコルを使用する案、
  [コンパクトブロックフィルター][topic compact block filters]と同様にテンプレートに
  ゴロム・ライス[符号][wuille templgr]を使用する案（推定25%の効率化）などがありました。

- **<!--trusted-delegation-of-script-evaluation-->スクリプト評価を信頼する委任:**
  Josh Domanは、自身が作成したライブラリについてDelving Bitcoinに[投稿しました][doman tee]。
  このライブラリは[TEE][]（_Trusted Execution Environment_）を使用し、
  支払いを含むトランザクションがスクリプトを満たす場合にのみ、
  [Taproot][topic taproot]のkeypath支払いに署名をします。
  このスクリプトには、現在Bitcoinでアクティブでないopcodeや、完全に異なる形式のスクリプト（
  [Simplicity][topic simplicity]や[bll][topic bll]など）を含めることができます。

  このアプローチでは、スクリプトに資金を送信する側がTEEを信頼する必要があります。
  つまり、将来署名のために利用可能であること、そして制約スクリプトを満たす支払いにのみ署名することを信頼する必要があります。
  しかし、これにより実際の金銭的価値を持ちながら、Bitcoinの新機能提案を実験することが可能になります。
  TEEが利用可能であり続けることへの信頼を減らすため、バックアップの支払いパスを含めることができます。
  たとえば、参加者がTEEに資金を預託してから1年後に一方的に資金を使用できるようにする[タイムロック][topic timelocks]パスなどです。

  このライブラリは、AWS（Amazon Web Services）のNitroエンクレーブの使用を想定して設計されています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **ZEUS v0.11.3リリース:**
  [v0.11.3][zeus v0.11.3]リリースには、ピア管理の改善、[BOLT12][topic offers]および
  [サブマリンスワップ][topic submarine swaps]機能が含まれています。

- **RustのUtreexoリソース:**
  Abdelhamid Bakhtaは、インタラクティブな[教材][rustreexo webapp]や
  [WASMバインディング][rustreexo wasm]を含む、[Utreexo][topic utreexo]用のRustベースのリソースを[投稿しました][abdel tweet]。

- **Peer-observerツールと行動の呼びかけ:**
  0xB10Cは、自身の[peer-observer][peer-observer github]プロジェクトの動機、
  アーキテクチャ、コード、サポートライブラリ、調査結果について[投稿しました][b10c blog]。
  彼は、「Bitcoinネットワークの監視という共通の関心を持つ、緩やかで分散化されたグループ。
  アイディア、議論、データ、ツール、洞察などを共有できる共同体」の構築を目指しています。

- **Bitcoin Core Kernelベースノードの発表:**
  [Bitcoin Core Kernel][kernel blog]ライブラリをBitcoinノードの基盤として使用するデモとして、
  Bitcoin backboneが[発表されました][bitcoin backbone]。

- **SimplicityHLリリース:**
  [SimplicityHL][simplcityhl github]は、Rustライクなプログラミング言語で、
  Liquidで[最近有効化された][simplicity post]低レベル言語[Simplicity][simplicity]にコンパイルされます。
  詳細については、[関連するDelvingのスレッド][simplicityhl delving]をご覧ください。

- **BTCPay Server用のLSPプラグイン:**
  [LSPプラグイン][lsp btcpay github]は、インバウンドチャネル用の仕様である
  [BLIP51][]のクライアント側の機能をBTCPay Serverに実装します。

- **Protoマイニングハードウェアおよびソフトウェアの発表:**
  Protoは、これまでの[コミュニティからのフィードバック][news260 mdk]に基づいて構築された、
  新しいBitcoinマイニングハードウェアとオープンソースのマイニングソフトウェアを[発表しました][proto blog]。

- **CSFSを使用したオラクル解決のデモ:**
  Abdelhamid Bakhtaは、[CSFS][topic op_checksigfromstack]、nostr、
  MutinyNetを使用してイベントの結果のアテステーションに署名するオラクルのデモを[投稿しました][abdel tweet2]。

- **RelaiがTaprootをサポート:**
  Relaiが[Taproot][topic taproot]アドレスへの送信をサポートしました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND v0.19.3-beta][]は、この人気のLNノード実装のメンテナンスバージョンのリリースで、
  「重要なバグ修正」が含まれています。最も注目すべきは、
  「オプションの移行で[…] ノードのディスクおよびメモリ要件が大幅に削減される」ことです。

- [Bitcoin Core 29.1rc1][]は、主要なフルノードソフトウェアのメンテナンスバージョンのリリース候補です。

- [Core Lightning v25.09rc2][]は、この人気のLNノード実装の新しいメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32896][]では、`createrawtransaction`、`createpsbt`、`send`、
  `sendall`、`walletcreatefundedpsbt`の各RPCに`version`パラメーターを追加することで、
  未承認の[TRUC][topic v3 transaction relay]（Topologically Restricted Until Confirmation）トランザクションの作成と使用をサポートします。
  ウォレットは、ウェイト制限、兄弟の競合、未承認TRUCトランザクションと非TRUCトランザクション間の非互換性に関する
  TRUCトランザクションの制限を適用します。

- [Bitcoin Core #33106][]では、デフォルトの`blockmintxfee`が1 sat/kvB（最小値）に引き下げられ、
  デフォルトの[`minrelaytxfee`][topic default minimum transaction relay feerates]と
  `incrementalrelayfee`が100 sat/kvB（0.1 sat/vB）に引き下げられました。
  これらの値は設定が可能ですが、`minrelaytxfee`と`incrementalrelayfee`の値は合わせるように調整することをお勧めします。
  その他の最低手数料率は変更ありませんが、ウォレットのデフォルトの最低手数料率は将来のバージョンで引き下げられる予定です。
  この変更の理由は、1 sat/vB未満のトランザクションをマイニングするブロック数と、
  これらのトランザクションをマイニングするプール数の増加から、Bitcoinの為替レートの上昇まで多岐にわたります。

- [Core Lightning #8467][]は、`xpay`（[ニュースレター #330][news330 xpay]参照）を拡張し、
  （satoshi@bitcoin.comのような）[BIP353][] HRN（Human Readable Names）への支払いをサポートし、
  [BOLT12オファー][topic offers]への直接支払いも可能にすることで、
  `fetchinvoice`コマンドを最初に実行する必要がなくりました。内部的には、
  `xpay`は[Core Lightning #8362][]で導入された`cln-bip353`プラグインの
  `fetchbip353` RPCコマンドを使って支払い指示を取得します。

- [Core Lightning #8354][]は、[MPP][topic multipath payments]で送信された
  特定の支払いのパーツのステータスに関する`pay_part_start`および`pay_part_end`イベント通知の発行を始めます。
  `pay_part_end`通知は、支払いの所要時間と、支払いが成功したか失敗したかを示します。
  支払いが失敗した場合はエラーメッセージが表示され、エラーOnionが破損していない場合は、
  エラーの原因や失敗コードなどの追加情報が提供されます。

- [Eclair #3103][]は、[Simple Taproot Channel][topic simple taproot channels]のサポートを導入し、
  [MuSig2][topic musig]スクリプトレス[マルチシグ][topic multisignature]を活用することで、
  トランザクションのウェイト消費を15%削減し、トランザクションのプライバシーを向上させます。
  ファンディングトランザクションと、協調クローズは、他の[P2TR][topic taproot]トランザクションと区別が付きません。
  このPRはまた、Simple Taproot Channelにおける[デュアルファンディング][topic dual funding]と
  [スプライシング][topic splicing]のサポートも含まれており、
  スプライシングトランザクション中に新しいTaproot形式への
  [チャネルコミットメントのアップグレード][topic channel commitment upgrades]を可能にします。

- [Eclair #3134][]は、[HTLCエンドースメント][topic htlc endorsement]のピアレピュテーション（
  [ニュースレター #363][news363 reputation]参照）のスコアリング時に、
  スタックした[HTLC][topic htlc]のペナルティウェイト乗数を
  [CLTV expiry delta][topic cltv expiry delta]に置き換え、
  スタックしたHTLCが流動性を拘束する期間をより適切に反映します。
  最大CLTV expiry deltaを持つスタックしたHTLCへの過大なペナルティを軽減するため、
  このPRはレピュテーションの減衰パラメーター（`half-life`）を15日から30日に、
  スタック支払いのしきい値（`max-relay-duration`）を12秒から5分に調整します。

- [LDK #3897][]は、バックアップ取得中に失われたチャネル状態を検出することで、
  [ピアストレージ][topic peer storage]の実装を拡張します。これは、ピアのコピーをデシリアライズし、
  ローカルの状態と比較することで行われます。

{% include snippets/recap-ad.md when="2025-08-26 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32896,33106,8467,8354,3103,3134,3897,8362" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[lnd v0.19.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta
[core lightning v25.09rc2]: https://github.com/ElementsProject/lightning/releases/tag/v25.09rc2
[towns bipshare]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aJvZwR_bPeT4LaH6@erisian.com.au/
[towns bipdraft]: https://github.com/ajtowns/bips/blob/202508-sendtemplate/bip-ajtowns-sendtemplate.md
[news366 templshare]: /ja/newsletters/2025/08/08/#mempool
[delshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906/13
[towns templdiff]: https://delvingbitcoin.org/t/sharing-block-templates/1906/7
[jahr templerlay]: https://delvingbitcoin.org/t/sharing-block-templates/1906/6
[wuille templgr]: https://delvingbitcoin.org/t/sharing-block-templates/1906/9
[doman tee]: https://delvingbitcoin.org/t/confidential-script-emulate-soft-forks-using-stateless-tees/1918/
[tee]: https://en.wikipedia.org/wiki/Trusted_execution_environment
[news330 xpay]: /ja/newsletters/2024/11/22/#core-lightning-7799
[news363 reputation]: /ja/newsletters/2025/07/18/#eclair-2716
[zeus v0.11.3]: https://github.com/ZeusLN/zeus/releases/tag/v0.11.3
[abdel tweet]: https://x.com/dimahledba/status/1951213485104181669
[rustreexo webapp]: https://rustreexo-playground.starkwarebitcoin.dev/
[rustreexo wasm]: https://github.com/AbdelStark/rustreexo-wasm
[b10c blog]: https://b10c.me/projects/024-peer-observer/
[peer-observer github]: https://github.com/0xB10C/peer-observer
[bitcoin backbone]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9812cde0-7bbb-41a6-8e3b-8a5d446c1b3cn@googlegroups.com
[kernel blog]: https://thecharlatan.ch/Kernel/
[simplcityhl github]: https://github.com/BlockstreamResearch/SimplicityHL
[simplicity]: https://blockstream.com/simplicity.pdf
[simplicityhl delving]: https://delvingbitcoin.org/t/writing-simplicity-programs-with-simplicityhl/1900
[simplicity post]: https://blog.blockstream.com/simplicity-launches-on-liquid-mainnet/
[lsp btcpay github]: https://github.com/MegalithicBTC/BTCPayserver-LSPS1
[proto blog]: https://proto.xyz/blog/posts/proto-rig-and-proto-fleet-a-paradigm-shift
[news260 mdk]: /ja/newsletters/2023/07/19/#mining-development-kit
[abdel tweet2]: https://x.com/dimahledba/status/1946223544234659877
