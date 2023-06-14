---
title: 'Bitcoin Optech Newsletter #217'
permalink: /ja/newsletters/2022/09/14/
name: 2022-09-14-newsletter-ja
slug: 2022-09-14-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Core PR Review Clubの概要や、
新しいソフトウェアリリースおよびリリース候補のリスト、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点など、恒例のセクションを掲載しています。

## ニュース

*今週は重要なニュースはありませんでした。*

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Reduce bandwidth during initial headers sync when a block is found][review club 25720]は、
Suhas DaftuarによるPRで、Initial Block Download（IBD）のピアを含む、
ピアとのブロックチェーンの同期中のノードのネットワーク帯域幅要件を削減するものです。
Bitcoinの重要な特徴の一部は、ネットワークリソースを含む完全な検証ノードを実行する際のリソース要件を最小限に抑え、
より多くのユーザーにフルノードの実行を奨励することです。同期時間の高速化はこの目標も推進します。

ブロックチェーンの同期は2つのフェーズで実行されます。まず、
ノードはピアからブロックヘッダーを受信します。このヘッダーは（おそらく）ベストチェーン（最も計算量の多いチェーン）を決定するのに十分です。
続いて、ノードはこのベストチェーンのヘッダーを使用して、対応する完全なブロックをダウンロードします。
このPRは、最初のフェーズ（ヘッダーのダウンロード）にのみ影響します。

{% include functions/details-list.md
  q0="<!--why-do-nodes-mostly-receive-inv-block-announcements-while-they-are-doing-initial-headers-sync-even-though-they-indicated-preference-for-headers-announcements-bip-130-->
  ノードがヘッダーの通知を優先するよう指示したにも関わらず（[BIP 130][]）、初期のヘッダー同期中に（ほとんどの）ノードが`inv`でブロックの通知を受信するのはなぜですか？"
  a0="ノードがheadersメッセージを使用してピアに新しいブロックを通知しないのは、
  ピアが新しいヘッダーの接続先をそれまで送信しておらず、同期ノードがheadersメッセージを送信していない場合です。"
  a0link="https://bitcoincore.reviews/25720#l-30"

  q1="<!--why-is-bandwidth-wasted-during-initial-headers-sync-by-adding-all-peers-that-announce-a-block-to-us-via-an-inv-as-headers-sync-peers-->ヘッダーの同期ピアとして`inv`でブロックを通知するすべてのピアを追加することで、（初期のヘッダー同期中の）帯域幅が浪費されるのはなぜですか？"
  a1="これらのピアは、同じヘッダーのストリームの送信を始めます。
  `inv`は同じピアへの`getheaders`をトリガーし、その応答の`headers`は、そのブロックヘッダーの直後の範囲に対する別の`getheaders`をトリガーします。
  重複するヘッダーを受信しても、帯域幅を余計に消費する以外は無害です。"
  a1link="https://bitcoincore.reviews/25720#l-62"

  q2="<!--what-would-be-your-estimate-lower-upper-bound-of-how-much-bandwidth-is-wasted-->どの程度の帯域幅が浪費されているか（上限/下限）の推定値は？"
  a2="上限は、`(number_peers - 1) * number_blocks * 81`バイトで、
  下限はゼロです（ヘッダーの同期中に新しいブロックが届かない場合。同期ピアとネットワークが高速な場合、70万以上のヘッダーをすべてダウンロードするのに数分しかかかりません）。 "
  a2link="https://bitcoincore.reviews/25720#l-79"

  q3="<!--what-s-the-purpose-of-cnodestate-s-members-fsyncstarted-and-m-headers-sync-timeout-and-peermanagerimpl-nsyncstarted-if-we-start-syncing-headers-with-peers-that-announce-a-block-to-us-via-an-inv-why-do-we-not-increase-nsyncstarted-and-set-fsyncstarted-true-and-update-m-headers-sync-timeout-->
  CNodeStateのメンバー`fSyncStarted`と`m_headers_sync_timeout`および`PeerManagerImpl::nSyncStarted`は何のためのものですか？
  `inv`を使用してブロックを通知するピアとヘッダーの同期を始めた場合に、
  `nSyncStarted`を増加させ、`fSyncStarted = true`をセットし`m_headers_sync_timeout`を更新しないのは何故ですか？"
  a3="`nSyncStarted`は、`fSyncStarted`がtrueのピアの数をカウントし、
  この数はノード現在時刻に近いヘッダー（1日以内）を持つまで1より大きくなることはありません。
  この（任意の）ピアが、最初のヘッダー同期ピアになります。
  このピアが遅い場合、ノードはそのピアをタイムアウトさせ（`m_headers_sync_timeout`）、別の初期ヘッダー同期ピアを探します。
  しかし、ヘッダーの同期中にあるノードがブロックを通知する`inv`メッセージを送信すると、
  このPRがなければ、ノードは`fSyncStarted`フラグをセットせずに、このピアへのheadersの要求を開始します。
  これは冗長なheadersメッセージの原因であり、おそらく意図したものではありませんが、
  最初のヘッダー同期ピアに悪意があったり、壊れていたり、または遅い場合でもヘッダーの同期を続行できるというメリットがあります。
  このPRでは、ノードは（新しいブロックを通知したピアすべてに対してではなく）1つのピアに対してのみheadersを要求します。"
  a3link="https://bitcoincore.reviews/25720#l-102"

  q4="<!--an-alternative-to-the-approach-taken-in-the-pr-would-be-to-add-an-additional-headers-sync-peer-after-a-timeout-fixed-or-random-what-is-the-benefit-of-the-approach-taken-in-the-pr-over-this-alternative-->
  PRで採用されたアプローチの代替案は、タイムアウト（固定もしくはランダム）後にヘッダー同期ピアを追加するというものでした。
  この代替案に対するPRで採用されたアプローチの利点は何ですか？"
  a4="1つの利点は、`inv`を通知するピアが応答する確率が高くなることです。もう1つは、
  ブロックの`inv`を最初に送信できたピアは、多くの場合とても高速なピアです。
  そのため、何らかの理由で最初のピアが遅い場合に、別の遅いピアを選ぶことがありません。"
  a4link="https://bitcoincore.reviews/25720#l-135"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LDK 0.0.111][]は、[Onionメッセージ][topic onion messages]の作成、受信、リレーのサポートに加えて、
  いくつかの新機能およびバグ修正を追加しています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #25614][]は、[Bitcoin Core #24464][]に基づいて、
  addrdb、addrman、banman、i2p、mempool、netbase、net、net_processing、
  timedataおよびtorcontrolで特定の重大レベルのログを追加して追跡できるようになりました。

- [Bitcoin Core #25768][]は、ウォレットが常に未承認トランザクションの子トランザクションを再ブロードキャストしないバグを修正しました。
  Bitcoin Coreの組み込みウォレットは、まだ承認されていないトランザクションを定期的に再ブロードキャストしようとします。
  これらのトランザクションのいくつかは、他の未承認トランザクションのアウトプットを使用している可能性があります。
  Bitcoin Coreは、子トランザクションより前に未承認の親トランザクション（または、より一般的にはすべて子孫の前に未承認の祖先）を
  受け取ることを期待する別のBitcoin Coreサブシステムに送信する前にトランザクションの順序をランダム化していました。
  その結果、子トランザクションが親より前に受信されると、再ブロードキャストされるのではなく内部的に拒否されます。

- [Bitcoin Core #19602][]は、ウォレットをネイティブで[ディスクリプター][topic descriptors]を使用するウォレットに変換する`migratewallet` RPCを追加しました。
  これは、HDウォレット以前のウォレット（[BIP32][]が定義されたがBitcoin Coreに採用される前に作られたもの）やHDウォレットおよび秘密鍵のない監視専用ウォレットに対して動作します。
  この機能を実行する前に、[ドキュメント][managing wallets]を読み、
  非ディスクリプターウォレットとネイティブでディスクリプターをサポートするウォレットの間にいくつかのAPIの違いがあることに注意してください。

<!-- TODO:harding to separate dual funding from interactive funding -->

- [Eclair #2406][]は、実験的な[対話型のファンディングプロトコル][topic dual funding]の実装を構成するためのオプションを追加し、
  チャネルを開設するトランザクションに承認済みのインプット（承認済みトランザクションのアウトプットをインプットとする）のみを含めるよう要求します。
  これを有効にすると、チャネル開設者が低手数料率の巨大な未承認トランザクションでチャネルの開設を遅延させるのを防止します。

- [Eclair #2190][]は、[BOLTs #962][]でLNの仕様からの削除が提案されている、元の固定長のOnionデータフォーマットのサポートを削除しました。
  アップグレードされた可変長のフォーマットは、3年以上前に[仕様に追加され][bolts #619]、
  ネットワークのスキャン結果では17,000以上の公開ノードのうち、5つを除くすべてのノードでサポートされていることが示されています。
  また、Core Lightningも今年初めにサポートを終了しています（[ニュースレター #193][news193 cln5058]参照）。

- [Rust Bitcoin #1196][]は、以前追加された`LockTime`型（[ニュースレター #211][news211 rb994]参照）を
  `absolute::LockTime`に変更し、[BIP68][]および[BIP112][]を使用するロックタイムを表現する新しい`relative::LockTime`を追加しました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25614,24464,25768,19602,2406,2190,962,619,1196" %}
[managing wallets]: https://github.com/bitcoin/bitcoin/blob/master/doc/managing-wallets.md
[news193 cln5058]: /ja/newsletters/2022/03/30/#c-lightning-5058
[news211 rb994]: /ja/newsletters/2022/08/03/#rust-bitcoin-994
[ldk 0.0.111]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.111
[review club 25720]: https://bitcoincore.reviews/25720
[BIP 130]: https://github.com/bitcoin/bips/blob/master/bip-0130.mediawiki
