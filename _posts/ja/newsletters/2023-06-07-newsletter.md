---
title: 'Bitcoin Optech Newsletter #254'
permalink: /ja/newsletters/2023/06/07/
name: 2023-06-07-newsletter-ja
slug: 2023-06-07-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、MATT提案を使用してJoinpoolを管理し、
`OP_CHECKTEMPLATEVERIFY`提案の機能を再現することに関するメーリングリストでの議論を掲載しています。
また、mempoolポリシーに関する限定週刊シリーズの新しい記事に加えて、
新しいソフトウェアリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **CTVの再現とJoinpoolの管理にMATTを使用する:** Johan Torås Halsethは、
  MATT(Merklize All The Things)の提案（ニュースレター[#226][news226 matt]と[#249][news249 matt]を参照）の
  `OP_CHECKOUTPUTCONTRACTVERIFY` opcode（COCV）を使用して
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]の提案機能を再現することについて
  Bitcoin-Devメーリングリストに[投稿しました][halseth matt-ctv]。
  複数のアウトプットを持つトランザクションにコミットする場合、
  各アウトプットは異なるCOCV opcodeを使用する必要があります。
  それに比べて、単一のCTV opcodeはすべてのアウトプットにコミットすることができます。
  そのため、COCVの効率は低下しますが、彼が指摘するように「十分にシンプルで面白い」。

    Halsethは、機能の説明だけではなく、[Tapsim][]を使った動作の[デモ][halseth demo]も提供しています。
    このツールは、「Bitcoinスクリプトのプリミティブを操作し、スクリプトのデバッグを支援し、
    スクリプト実行時のVMの状態を視覚化することを目的したBitcoin Tapscriptトランザクションのデバッグツール」です。

    別のスレッドで、HalsethはMATTと[OP_CAT][]を使用して[Joinpool][topic joinpools]
    （_Coinpool_ や a _Payment pool_ とも呼ばれる）を作成することについても[投稿しました][halseth matt-joinpool]。
    ここでも、Tapsimを使った[インタラクティブなデモ][demo joinpool]が提供されています。
    また、実験的な実装の結果に基づき、MATTの提案に含まれるopcodeの修正案をいくつか提示しています。
    MATTの提案者であるSalvatore Ingalaは、好意的に[答えています][ingala matt]。

## 承認を待つ #4: 手数料率の推定

_トランザクションリレーや、mempoolへの受け入れ、マイニングトランザクションの選択に関する限定週刊[シリーズ][policy series]です。
Bitcoin Coreがコンセンサスで認められているよりも制限的なポリシーを持っている理由や、
ウォレットがそのポリシーを最も効果的に使用する方法などが含まれます。_

{% include specials/policy/ja/04-feerate-estimation.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.16.3-beta][]は、この人気のLNノード実装のメンテナンスリリースです。
  リリースノートには、「このリリースには、バグ修正のみが含まれており、
  最近追加されたmempoolの監視ロジックを最適化し、
  不注意による強制クローズの疑いがあるいくつかの要因を修正することを目的としています」と記載されています。
  mempool監視ロジックの詳細については、[ニュースレター #248][news248 lnd mempool]をご覧ください。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #26485][]では、`options`オブジェクトパラメーターを受け入れるRPCメソッドが、
  名前付きパラメーターと同じフィールドを受け入れられるようになりました。
  たとえば、`bumpfee` RPCは、`src/bitcoin-cli -named bumpfee txid options='{"fee_rate": 10}'`の代わりに、
  `src/bitcoin-cli -named bumpfee txid fee_rate=10`と呼び出すことができます。

- [Eclair #2642][]は、ノードの閉鎖されたチャネルに関するデータを提供する`closedchannels` RPCを追加しました。
  [ニュースレター #245][news245 listclosedchannels]で紹介した
  Core Lightningの同様のPRもご覧ください。

- [LND #7645][]は、`OpenChannel`、`CloseChannel`、`SendCoins`、`SendMany`のRPC呼び出しにおいて、
  ユーザーが提供する手数料率が「リレー手数料率」を下回らないようにしました。
  この変更には、「手数料率はバックエンドによって若干異なる意味があります。
  bitcoindの場合、それは実質的にmax(リレー手数料、mempoolの最小手数料)になります。」と記載されています。

- [LND #7726][]は、チャネルをオンチェーンで決済する必要がある場合、
  常にローカルノードに支払うすべてのHTLCを使用するようになりました。
  たとえ、それらを回収するのに、その金額以上にトランザクション手数料がかかるとしても、そのHTLCを回収しようとします。
  [先週のニュースレター][news253 sweep]で紹介したEclairのPRと比較すると、
  Eclairの方は[経済的に見合わない][topic uneconomical outputs]HTLCを回収しようとはしません。
  PRのスレッドのコメントでは、
  LNDは（オフチェーンとオンチェーンの両方で）HTLCの決済に関連するコストと利益を計算する機能を強化する他の変更に取り組んでおり、
  将来的には最適な意思決定を行うことができるようになると記載されています。

- [LDK #2293][]は、ピアから適切な時間内に応答がない場合、いったん切断してから再接続するようになりました。
  これは、他のLNソフトウェアが時々応答を停止し、チャネルが強制的に閉じられることがある問題を軽減する可能性があります。

{% include references.md %}
{% include linkers/issues.md v=2 issues="2642,26485,7645,7726,2293" %}
[policy series]: /ja/blog/waiting-for-confirmation/
[news226 matt]: /ja/newsletters/2022/11/16/#covenant-bitcoin
[news249 matt]: /ja/newsletters/2023/05/03/#matt-vault
[news253 sweep]: /ja/newsletters/2023/05/31/#eclair-2668
[news245 listclosedchannels]: /ja/newsletters/2023/04/05/#core-lightning-5967
[halseth matt-ctv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021730.html
[halseth demo]: https://github.com/halseth/tapsim/blob/b07f29804cf32dce0168ab5bb40558cbb18f2e76/examples/matt/ctv2/README.md
[tapsim]: https://github.com/halseth/tapsim
[halseth matt-joinpool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021719.html
[demo joinpool]: https://github.com/halseth/tapsim/tree/matt-demo/examples/matt/coinpool
[ingala matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021724.html
[news248 lnd mempool]: /ja/newsletters/2023/04/26/#lnd-7564
[lnd 0.16.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.3-beta
