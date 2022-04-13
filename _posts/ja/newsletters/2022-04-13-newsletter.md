---
title: 'Bitcoin Optech Newsletter #195'
permalink: /ja/newsletters/2022/04/13/
name: 2022-04-13-newsletter-ja
slug: 2022-04-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、BitcoinのトランザクションやLNの支払いで
ビットコイン以外のトークンを転送するためのプロトコルと、
MuSig2マルチシグプロトコルのBIP提案のリンクを掲載しています。
また、Bitcoin Core PR Review Clubミーティングの要約や、
新しいソフトウェアリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **<!--transferable-token-scheme-->転送可能なトークン方式:** Olaoluwa Osuntokunは、
  Bitcoinのブロックチェーン上でBitcoin以外のトークンの作成や転送を記録可能にする*Taro*プロトコルのBIP提案のセットを
  Bitcoin-DevメーリングリストとLightning-Devメーリングリストに[投稿しました][osuntokun taro]。
  例えば、アリスは100トークンを発行し、50トークンをボブに転送し、
  ボブはさらにそのうちの25トークンをキャロルと10 BTCで交換するといったことが可能になります。
  このアイディアは、Bitcoin用に実装された過去のアイディアと似ていますが、
  [Taproot][topic taproot]のいくつかの設計要素を再利用して、新規に書く必要のあるコードの量を減らしたり、
  特定の操作が行われたことを証明するために転送する必要のあるデータの量を減らすためにマークルツリーを使用するなど、
  詳細は異なります。

    Taroは、ルーティング可能なオフチェーン転送のためにLNと一緒に使用されれることを[想定しています][gentry taro]。
    LN上のクロスアセット転送に関する以前の提案と同様、
    支払いをルーティングするだけの中間ノードは、Taroのプロトコルや転送されるアセットの詳細について認識する必要はなく、
    他のLN支払いと同じプロトコルを使ってBTCを転送するだけです。

    このアイディアは、今週メーリングリスト上で適度な議論が行われています。

- **MuSig2の提案BIP:** Jonas Nick、Tim RuffingおよびElliott Jinは、
  公開鍵と署名作成用の[マルチシグ][topic multisignature]プロトコルである[MuSig2][topic musig]の
  [BIP提案][musig2 bip]をBitcoin-Devメーリングリストに[投稿しました][nick musig2]。
  異なる参加者やソフトウェアによって制御される複数の秘密鍵は、
  MuSig2を使って、各参加者が互いに秘密情報を共有することなく集約公開鍵を導出することができます。
  その後、集約署名も作ることができますが、この場合も秘密の情報を共有する必要はありません。
  集約公開鍵と集約署名は、第三者からは他の公開鍵や[Schnorr署名][topic schnorr signatures]のように見えるため、
  集約公開鍵や署名の作成に何人の参加者や秘密鍵が関与したか明らかにされることはなく、
  個別の公開鍵や署名の数が明らかになるオンチェーンマルチシグのプライバシーを改善します。

    MuSig2は、（現在*MuSig1*と呼ばれている）元のMuSigの提案 よりも、
    ほぼすべての想定される用途において優れています。
    MuSig2は、代替の（決定性nonceを使用する）MuSig-DNよりも実装が簡単ですが、
    MuSig2とMuSig-DNにはトレードオフがあり、アプリケーション開発者は、
    どちらのプロトコルを使用するか選択する際に考慮が必要です。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Prevent block index fingerprinting by sending additional getheaders messages][reviews 24571]は、
Niklas Göggeによる、ブロックインデックスに基づくフィンガープリントを防止するためのPRです。

{% include functions/details-list.md

  q0="<!--what-is-the-block-index-and-what-is-it-used-for-->ブロックインデックスとは何で、何のために使用されるものですか？"
  a0="ブロックインデックスは、ディスク上のブロックヘッダーとブロックデータの位置を検索するためのメモリ内のインデックスです。
再編成に対応するためにブロック「ツリー」の複数のブランチ（つまり、古いブロックヘッダーを含む）を保持することができます。"
  a0link="https://bitcoincore.reviews/24571#l-17"

  q1="<!--should-we-keep-stale-blocks-in-the-block-index-why-or-why-not-->ブロックインデックスに古いブロックを保持すべきなのは何故？あるいは何故そうすべきではないのですか？"
  a1="複数のブランチが存在する場合、それをインデックスしておくことで、最も作業量の多いチェーンが変化した際に、
ノードがブランチを迅速に切り替えることができます。参加者の中には、再編成の可能性は極めて低いので、
非常に古いブロックを保持するのはあまり有用ではないかもしれないと指摘する人もいました。
しかし、これらのヘッダーはほとんどストレージ領域を使用せず、ノードはそれらを保存する前にProof of Workの検証をするため、
ノードのリソースを使い果たすことを期待して有効なPoWの古いヘッダーを送信すると不釣り合いなコストがかかります。"
  a1link="https://bitcoincore.reviews/24571#l-68"

  q2="<!--describe-the-attack-using-a-node-s-block-index-for-fingerprinting-->フィンガープリントにノードのブロックインデックスを使用する攻撃の説明"
  a2="IBDの間、ノードは最初のヘッダー同期中に知った最も作業量の多いチェーンに属するブロックのみを要求し、ダウンロードします。
そのため、ブロックインデックスにある古いブロックは通常IBDが終わった後にマイニングされたものですが、
これは自然に変化するか、過去の古いヘッダーの大規模なコレクションを持つ攻撃者によって操作される可能性があります。
ヘッダーHとH+1の古いブランチを持つ攻撃者は、H+1をノードに送信できます。
ノードがH+1の前のHをブロックインデックスに持っていない場合、ノードは`getdata`メッセージを使ってHを要求するでしょう。
既にHを持っている場合、それを要求することはありません。"
  a2link="https://bitcoincore.reviews/24571#l-75"

  q3="<!--why-is-it-important-to-prevent-node-fingerprinting-->何故ノードのフィンガープリントを防ぐことが重要なのですか？"
  a3="ノード運用者は、例えばTorを使用するなど、自分のノードのIPアドレスを難読化するためのさまざまな技術を採用することができます。
しかし、攻撃者が両方のネットワーク上で動作しているノードのIPv4とTorのアドレスをリンクさせることができると、
プライバシーの利点は制限されたり、無効になる可能性があります。ノードがTorのみで実行されている場合、
フィンガープリントを使用して同じノードに属する複数のTorアドレスをリンクしたり、
IPv4に切り替えた場合に、ノードを識別することができます。"
  a3link="https://bitcoincore.reviews/24571#l-84"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LDK 0.0.106][]は、このLNノードライブラリの最新リリースです。
  これには、LDKがいくつかのケースでプライバシーを強化するために使用する、
  [BOLTs #910][]で提案されているチャネル識別子の`alias`フィールドのサポートが追加されており、
  他のいくつかの機能とバグ修正が含まれています。

- [BTCPay Server 1.4.9][]は、この人気のあるペイメントプロセッサソフトウェアの最新リリースです。

- [Bitcoin Core 23.0 RC4][]は、この重要なフルノードソフトウェアの次のメジャーバージョンのリリース候補です。
  [リリースノートのドラフト][bcc23 rn]には、複数の改善点が記載されており、
  上級ユーザーとシステム管理者には最終リリース前の[テスト][test guide]が推奨されます。

- [LND 0.14.3-beta.rc1][]は、この人気のあるLNノードソフトウェアのいくつかのバグ修正を含むリリース候補です。

- [Core Lightning 0.11.0rc1][]は、この人気のあるLNノードソフトウェアの次のメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #24152][]は、[パッケージ手数料率][package feerate]を導入し、
  個別の手数料率に代わって使用することで、child-with-unconfirmed-parentsパッケージによる[CPFP][topic cpfp]の手数料引き上げを可能にします。
  [ニュースレター #186][news186 package]に掲載したように、
  これはCPFPと[RBF][topic rbf]の両方の手数料引き上げの柔軟性と信頼性を強化するための一連の変更の一部です。
  このパッチはまた、[最初に個々のトランザクションを検証し][validates individual transactions first]、
  「親が子のために支払う」または「兄弟が兄弟のために支払う」動作などのインセンティブの互換性のないポリシーを回避します。

- [Bitcoin Core #24098][]は、`/rest/headers/` RPCおよび`/rest/blockfilterheaders/` RPCを更新し、
  エンドポイント（`/<count/`のような）の代わりに追加オプション（`?count=<count>`のような）のクエリパラメーターを使用できるようにしました。
  エンドポイントパラメーターよりもクエリパラメーターの使用を推奨するようドキュメントが更新されました。

- [Bitcoin Core #24147][]は、[Miniscript][topic miniscript]のバックエンドサポートを追加しました。
  後続のPR[#24148][bitcoin core #24148]と[#24149][bitcoin core #24149]がマージされると、
  [Output Script Descriptor][topic descriptors]とウォレットの署名ロジックでMiniscriptを使用するためのサポートが追加される予定です。

- [Core Lightning #5165][]は、C-Lightningプロジェクトの名称を[Core Lightning][core lightning repo]またはCLNに更新しました。

- [Core Lightning #5068][]は、`option_payment_metadata`インボイスデータを支払いに添付するためのサポートを追加し、
  [ステートレスインボイス][topic stateless invoices]の支払い者側のサポートを追加しました。
  このPRでは、受信者側のサポートはCLNに追加されていません。

{% include references.md %}
{% include linkers/issues.md v=2 issues="24152,24098,24147,24148,24149,5165,5068,910" %}
[bitcoin core 23.0 rc4]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bcc23 rn]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Notes-draft
[test guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Candidate-Testing-Guide
[lnd 0.14.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.3-beta.rc1
[core lightning 0.11.0rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.0rc1
[gentry taro]: https://lightning.engineering/posts/2022-4-5-taro-launch/
[osuntokun taro]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003539.html
[nick musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020198.html
[musig2 bip]: https://github.com/jonasnick/bips/blob/musig2/bip-musig2.mediawiki
[ldk 0.0.106]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.106
[btcpay server 1.4.9]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.4.9
[reviews 24571]: https://bitcoincore.reviews/24571
[news186 package]: /ja/newsletters/2021/09/22/#mempool-rbf
[package feerate]: https://gist.github.com/glozow/dc4e9d5c5b14ade7cdfac40f43adb18a#fee-related-checks-use-package-feerate
[validates individual transactions first]: https://gist.github.com/glozow/dc4e9d5c5b14ade7cdfac40f43adb18a#always-try-individual-submission-first
