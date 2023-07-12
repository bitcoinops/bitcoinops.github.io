---
title: 'Bitcoin Optech Newsletter #259'
permalink: /ja/newsletters/2023/07/12/
name: 2023-07-12-newsletter-ja
slug: 2023-07-12-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNの仕様から最近のノードには関係のなくなった詳細を削除する提案と、
mempoolポリシーに関する限定週刊シリーズの最後から2つめの記事を掲載しています。
さらに、Bitcoin Core PR Review Clubの要約や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **LN仕様のクリーンアップの提案:** Rusty Russellは、
  最近のLN実装でサポートされなくなったいくつかの機能を削除し、
  他の機能は常にサポートされることを前提とした提案を行う[PR][bolts #1092]を
  Lightning-Devメーリングリストに[投稿しました][russell clean up]。
  提案された変更に関連して、Russellはゴシップメッセージにしたがってパブリックノードの機能を調査した結果も提供しています。
  彼の結果は、ほぼすべてのノードが次の機能をサポートしていることを示唆しています:

  - *可変サイズのOnionメッセージ:* TLV（Type-Length-Value）フィールドを使用するように仕様が更新されたのとほぼ同時に、
    2019年に仕様の一部になりました（[ニュースレター #58][news58 bolts619]参照）。
    これは、各ホップが固定長のメッセージを使用し、ホップ数を20に制限していた暗号化Onionルーティングの元のフォーマットを置き換えるものです。
    可変サイズのフォーマットにより、任意のデータを特定のホップにリレーすることが非常に容易になりました。
    唯一の欠点は、メッセージ全体のサイズが一定のままなので、送信するデータ量が増えると最大ホップ数が減ることです。

  - *<!--gossip-queries-->ゴシップクエリ:* 2018年に仕様の一部になりました（[BOLTs #392][]参照）。
    これにより、ノードはネットワーク上の他のノードによって送信されたゴシップメッセージのサブセットのみをピアに要求できるようになりました。
    たとえば、ノードは、帯域幅を節約し処理時間を短縮するために、古い更新を無視して、
    最近のゴシップの更新のみを要求する場合があります。

  - *Data Loss Protection:* 2017年に仕様の一部になりました（[BOLTs #240][]参照）。
    この機能を使用するノードは、再接続時に最新のチャネルステートに関する情報を送信します。
    これにより、ノードがデータを失ったことを検知できる可能性があり、
    データを失っていないノードに最新のステートでチャネルを閉じるように促すことができます。
    詳細については、[ニュースレター #31][news31 data loss]をご覧ください。

  - *Static remote-party key:* 2019年に仕様の一部になりました（[ニュースレター #67][news67 bolts642]参照）。
    これにより、ノードは、すべてのチャネルの更新でノードの非[HTLC][topic htlc]資金を
    同じアドレスに送信することをコミットするように要求できます。
    以前は、チャネルの更新毎に異なるアドレスが使用されていました。
    この変更後、このプロトコルをオプトインしてデータを失ったノードは、
    ほとんどの場合、最終的に[HDウォレット][topic bip32]など、
    選択したアドレスで少なくとも資金の一部を受け取ることになります。

  クリーンアップ提案のPRに対する最初の返信は好意的なものでした。

## 承認を待つ #9: ポリシーの提案

_トランザクションリレーや、mempoolへの受け入れ、マイニングトランザクションの選択に関する限定週刊[シリーズ][policy series]です。
Bitcoin Coreがコンセンサスで認められているよりも制限的なポリシーを持っている理由や、
ウォレットがそのポリシーを最も効果的に使用する方法などが含まれます。_

{% include specials/policy/ja/09-proposals.md %}

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Stop relaying non-mempool txs][review club 27625]は、Marco Falke (MarcoFalke)によるPRで、
大量のメモリ消費を引き起こす可能性があり、もはや必要ないか、少なくとも非常に僅かなメリットしかない
インメモリデータ構造である`mapRelay`を削除することで、Bitcoin Coreクライアントを簡素化するものです。
このマップには、mempoolにある場合も、ない場合もあるトランザクションが含まれており、
ピアからの[`getdata`][wiki getdata]リクエストに返信するために使用されることがあります。

{% include functions/details-list.md
  q0="<!--what-are-the-reasons-to-remove-maprelay-->`mapRelay`を削除する理由は何ですか？"
  a0="このデータ構造のメモリ消費量には制限がありません。通常、メモリ使用量は多くありませんが、
      データ構造のサイズが外部エンティティ（ピア）の動作によって決定され、最大値がない場合、
      DoS脆弱性が発生する可能性があるため懸念されています。"
  a0link="https://bitcoincore.reviews/27625#l-19"

  q1="なぜ`mapRelay`のメモリ使用量は判断しにくいのですか？"
  a1="`mapRelay`内の各エントリーは、トランザクション（`CTransaction`）への共有ポインタであり、
      mempoolには別のポインタが保持されている可能性があります。
      同じオブジェクトへの２つめのポインタは、単一のポインタと比較して、ほとんど追加のスペースを使用しません。
      共有トランザクションがmempoolから削除されると、そのスペースはすべて`mapRelay`エントリーに帰属するようになります。
      つまり、`mapRelay`のメモリ使用量は、トランザクションの数やその個々のサイズにだけ依存するのではなく、
      mempoolに存在しなくなったトランザクションの数にも依存するため、予測が困難です。"
  a1link="https://bitcoincore.reviews/27625#l-33"

  q2="`m_most_recent_block_txs`を導入することでどのような問題が解決されるのですか？（これは、最後に受信したブロックのトランザクションのみのリスト）"
  a2="これが無いと、`mapRelay`が利用できないため、mempoolから削除されてしまうので、
      （最新のブロックで）マイニングされたばかりのトランザクションを要求するピアに提供できなくなります。"
  a2link="https://bitcoincore.reviews/27625#l-45"

  q3="`mapRelay`を何も置き換えずにただ削除するのではなく、`m_most_recent_block_txs`を導入する必要があると思いますか？"
  a3="この質問については、Review Clubの出席者の間でもいくらか不確実なものでした。
      `m_most_recent_block_txs`がブロックの伝播速度を向上させる可能性があるという意見がありました。
      これは、受信したばかりのブロックをまだピアが持っていない場合、
      我々のノードのそのトランザクションを提供する機能が
      ピアの[Compact Block][topic compact block relay]を完成させるのに役立つ可能性があるからです。
      もう１つの意見は、チェーン分岐の場合に役立つかもしれないというものでした。
      ピアが私たちとは異なる先頭を持つ場合、ブロックを介してそのトランザクションを持っていない可能性があります。"
  a3link="https://bitcoincore.reviews/27625#l-54"

  q4="`m_most_recent_block_txs`のメモリ要件は、`mapRelay`と比較してどうですか？"
  a4="`m_most_recent_block_txs`内のエントリー数は、ブロック内のトランザクション数によって制限されます。
      ただし、`m_most_recent_block_txs`のエントリーは（トランザクションへの）共有ポインタであり、
      また（すでに）`m_most_recent_block`によってポイントされているため、
      メモリ要件は、トランザクション数よりも少なくなります。"
  a4link="https://bitcoincore.reviews/27625#l-65"

  q5="<!--are-there-scenarios-in-which-transactions-would-be-made-available-for-a-shorter-or-longer-time-than-before-as-a-result-of-this-change-->この変更の結果、トランザクションが以前よりも短期間、もしくは長期間利用可能になるシナリオはありますか？"
  a5="最後のブロックからの時間が15分（`mapRelay`にエントリーが残っている時間）を超える場合は長くなり、
      それ以外の場合は短くなります。15分という時間はかなり恣意的なものであるため、これは許容できると思われます。
      ただし、この変更により、非ベストチェーンに固有のトランザクションが保持されなくなるため、
      1ブロックを超えるチェーン分岐が発生した場合（これは非常に稀ですが）、
      トランザクションの可用性が低下する可能性があります。"
  a5link="https://bitcoincore.reviews/27625#l-70"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND v0.16.4-beta][]は、このLNノードソフトウェアのメンテナンスリリースで、
  一部のユーザーに影響を与える可能性のあるメモリリークを修正しています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #27869][]は、ニュースレター[#125][news125 descriptor wallets]や
  [#172][news172 descriptor wallets]、[#230][news230 descriptor wallets]で言及したように、
  ユーザーがレガシーウォレットから[ディスクリプター][topic descriptors]に移行するのを支援するために、
  [Bitcoin Core #20160][]で概説されている継続的な取り組みの一環として、
  レガシーウォレットをロードする際に非推奨の警告を出すようにしました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="1092,392,240,20160,27869" %}
[news58 bolts619]: /en/newsletters/2019/08/07/#bolts-619
[policy series]: /ja/blog/waiting-for-confirmation/
[news31 data loss]: /en/newsletters/2019/01/29/#fn:fn-data-loss-protect
[news67 bolts642]: /ja/newsletters/2019/10/09/#bolts-642
[lnd v0.16.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.4-beta
[russell clean up]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/004001.html
[review club 27625]: https://bitcoincore.reviews/27625
[wiki getdata]: https://en.bitcoin.it/wiki/Protocol_documentation#getdata
[news125 descriptor wallets]: /en/newsletters/2020/11/25/#how-will-the-migration-tool-from-a-bitcoin-core-legacy-wallet-to-a-descriptor-wallet-work
[news172 descriptor wallets]: /ja/newsletters/2021/10/27/#bitcoin-core-23002
[news230 descriptor wallets]: /ja/newsletters/2022/12/14/#with-legacy-wallets-deprecated-will-bitcoin-core-be-able-to-sign-messages-for-an-address-bitcoin-core
