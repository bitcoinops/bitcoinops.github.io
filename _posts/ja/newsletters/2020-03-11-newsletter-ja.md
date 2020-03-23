---
title: 'Bitcoin Optech Newsletter #88'
permalink: /ja/newsletters/2020/03/11/
name: 2020-03-11-newsletter
slug: 2020-03-11-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、ハードウェア・ウォレットがトランザクション・シグネチャを介して個人情報を漏洩するのを防ぐ方法の説明、BIP322 generic 「signmessage」プロトコルの更新、Bitcoin Core PR Review Clubの最近の会議の要約をお届けします。また、新しいリリースと、Bitcoinインフラストラクチャプロジェクトの注目すべきマージに関する通常のセクションもお届けします。

## Action items

*今週はなし。*

## News

- **抽出耐性ナンスプロトコル:** Pieter Wuilleは、ECDSAschnorr署名を行う際に生成するナンスにバイアスをかけることにより、ハードウェア・ウォレットまたはその他のオフライン署名デバイスが秘密情報を第三者に送信するのを防ぐ技術の概要をBitcoin-Devメーリングリストに[送信][wuille overview]しました。メールの内容は明確かつ情報満載なため、外部署名者の安全な使用に関心がある人は、読むことをお勧めします。

- **BIP322 generic `signmessage`---進行中または消滅:** [BIP322][]著者のKarl-Johan Almは、[generic `signmessage` protocol][topic generic signmessage]のサポートを追加する彼のPRは、過去数か月間、マージに向けた進展が見られなかったと指摘しました。彼は、---「フィルタリングされていない批判」を含む---別のアプローチを取るか、単に提案を放棄するかについて[フィードバック][alm feedback]を求めました。[以前][segwit signmessage]で説明したように、現在、ウォレットがレガシーP2PKHアドレス以外の署名付きメッセージを作成および検証するための広く採用されている方法はありません。ウォレット開発者がP2SH、P2WPKH、P2WSH、および（taprootがアクティブ化されている場合）P2TRアドレスに対してこの機能を有効にしたい場合は、Almの電子メールを確認し、優先パスに関するフィードバックを提供することをお勧めします。

## Bitcoin Core PR Review Club

_[Bitcoin Core PR Review Club][]は、ビットコインコアプロジェクトの新しい貢献者がレビュープロセスについて学ぶための週次のIRCミーティングです。経験豊富なビットコインコアの貢献者が、選択したPRの背景の説明し、IRCのディスカッションをリードします。_

_Review Clubは、Bitcoinプロトコル、Bitcoin Coreリファレンス実装、およびBitcoinに変更を加えるプロセスについて学ぶための優れた方法です。メモ、質問、会議ログは、リアルタイムで参加できない人のために、またBitcoin Core開発プロセスについて学びたい人のための永続的なリソースとして、ウェブサイトに投稿されています。_

_このセクションでは、最近のビットコインコアPRレビュークラブ会議をまとめ、重要な質問と回答のいくつかを強調します。以下の質問をクリックすると、会議の回答の概要が表示されます。_

**[再起動中にブロックリレーのみのアウトバウンド接続を保持する][review club 17428]**は、Hennadii StepanovによるPR（[＃17428][Bitcoin Core #17954]）であり、 _アンカー接続_ の概念をビットコインコアに追加します。ノードは再起動中に特定のピアに再接続（アンカー接続）します。これらの永続的な接続は、いくつかのクラスの[エクリプス攻撃][topic eclipse attacks]を緩和する可能性があります。

議論はエクリプス攻撃の基本的な概念を確立することから始まりました:

<div class="review-club-questions"></div>
- <details><summary>エクリプス攻撃とは何ですか？</summary>
  Eclipse攻撃は、ノードをすべての正直なピアから隔離する攻撃です。</details>
- <details><summary>敵はどのようにノードを食いつぶしますか？</summary>
  IPアドレスリストに攻撃者が所有するアドレスを入力し、攻撃者に強制的に再起動させるか、攻撃者が再起動するのを待ちます。</details>
- <details><summary>ノードが食された場合、攻撃者は被害者に対してどのような攻撃を実行できますか？</summary>
  ブロックの差し押さえ、取引の検閲、（匿名性が担保されているべき）トランザクションソースの暴露。</details>

次に、PRの変化を分析しました:

<div class="review-club-questions"></div>
- <details><summary>このPRはエクリプス攻撃をどのように緩和しますか？</summary>
  接続したいくつかのノードのリストを保持し（アンカー接続）、再起動時にそれらに再接続します。</details>
- <details><summary>ピアがアンカーになるための条件は何ですか？</summary>
  ピアは、ブロックリレーのみのピアである必要があります。</details>

会議の後半で、PRのトレードオフと設計決定についての議論がありました:

<div class="review-club-questions"></div>
- <details><summary>ブロックリレーのみのピアのみがアンカーとして使用されるのはなぜですか？</summary>
  ネットワークトポロジの推測をより困難にし、ネットワークプライバシーを保護するため。</details>
- <details><summary>ノードをリモートクラッシュできるアンカーを選択するとどうなりますか？</summary>
  悪意のあるピアは、再起動時にノードを繰り返しクラッシュさせる可能性があります。</details>

Review Clubの参加者数名がPRについてコメントし、デザインの決定に関する議論が続けられています。

## Releases and release candidates

*Bitcoinインフラストラクチャプロジェクトの主なリリース及びリリース候補。新しいリリースにアップグレードするか、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 0.19.1][]がリリースされ、いくつかのバグが修正されました。詳細については、[リリースノート][bitcoin core 0.19.1 notes]を参照してください。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Eclair #1323][]により、ノードは、以前の制限である約0.168 BTCよりも高い値でチャネルオープンを受け入れることをアドバタイズできます。これは、最近[BOLT9][merged large_channel]に追加された`init`メッセージの新しい`option_support_large_channel`機能を使用して行われます。0.168 BTCを超えるサポートチャネル容量は、「wumbo」として非公式に知られる機能セットの一部です。詳細については、[Newsletter#22][news22 wumbo]をご覧ください。

{% include references.md %}
{% include linkers/issues.md issues="1323,17954" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[bitcoin core 0.19.1 notes]: https://bitcoincore.org/en/releases/0.19.1/
[wuille overview]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017667.html
[alm feedback]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017668.html
[segwit signmessage]: /en/bech32-sending-support/#message-signing-support
[merged large_channel]: /ja/newsletters/2020/02/26/#bolts-596
[news22 wumbo]: /en/newsletters/2018/11/20/#wumbo
[Bitcoin Core PR Review Club]: https://bitcoincore.reviews
[review club 17428]: https://bitcoincore.reviews/17428
