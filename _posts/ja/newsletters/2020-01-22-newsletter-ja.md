---
title: 'Bitcoin Optech Newsletter #81'
permalink: /ja/newsletters/2020/01/22/
name: 2020-01-22-newsletter-ja
slug: 2020-01-22-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNDの次のメジャーバージョンのプレリリーステストの公募、チャウミアン・コインジョインの一部として支払いを送信する方法のレビューの募集、開発中であるプロトコル「Discreet Log Contract」の仕様の関連情報、およびBitcoinの人気サービス、クライアント・ソフトウェア、インフラストラクチャ・プロジェクトなどの主要な変更についてお送りします。

## Action items

- **LND 0.9.0-beta-rc3 テストのヘルプ:** LNDの次のメジャーバージョンである、この[プレリリース][lnd 0.9.0-beta]には、いくつかの新機能とバグ修正が含まれています。経験があるユーザーは、リリース前に問題を特定して修正できるように、ソフトウェアのテストを支援することをお勧めします。

## News

- **新しいCoinjoin mixing手法の提案:** Max Hillebrandは、Bitcoin-Devメーリングリストで*Wormhole*について[スレッド][wormhole thread]を立ち上げました。これは、チャウミアン・コインジョインの一部として支払いを送信するため、[Wasabiデザインディスカッション][Wasabi design discussion]中に開発された方法です。このプロトコルは、（匿名設定の制限内で）支払い者でさえ、受け手側のビットコインアドレスを知ることを防ぎます。開発者のZmnSCPxjは、この手法はトラストレスなチャウミアン・ペイメントサービスを提供する[tumblebit][]に似ていると[述べて][zmn note]います。 Hillebrandは、今後実装されるのを期待して、設計に関するフィードバックを求めています。

- **Discreet Log Contracts（DLC）のプロトコル仕様:** [DLC][DLCs]は（単一または複数の）オラクルによって決定される特定のイベントの結果に応じて、2人の当事者が資金を交換することに同意する契約プロトコルです。イベントが発生した後、オラクルはイベントの結果に対するコミットメントをデジタル署名の形式で公開し、勝者はこれを利用して資金を請求できます。オラクルは契約の条件を（更には契約の有無さえ）知る必要はありません。この契約は、LNのオンチェーン部分のトランザクションのように見えるか、将来的にはLNチャネル内で実行されることも考えられます。これにより、DLCは他のオラクルベースの契約方法よりもプライベートかつ効率的なものとなります。また、誤った結果を犯したオラクルの明確な証拠を残すため、より安全とも言えるでしょう。

    今週、Chris Stewartは、LNを含む、さまざまなソフトウェア間で使用する相互運用可能な設計の構築を目的として、複数の開発者がDLCを使用するための仕様に取り組んでいると[発表][stewart dlc]しました。現在の仕様については、[リポジトリ][dlcspecs]をご覧ください。 DLCに興味がある人は、プロトコルを契約するためのデジタル署名スキームの、他のクレバーな応用をまとめた[scriptless scripts][scriptless scripts examples]リポジトリを確認することもできます。

## Changes to services and client software
*この月刊セクションでは、Bitcoinウォレットとサービスの注目すべきアップデートをお送りします。*

- **さまざまなBitcoin技術を活用するRiver Financial:** [Twitter][river twitter thread]で、River Financialは彼らの提供する製品におけるデフォルトでの[PSBT][topic psbt]、[script descriptors][topic descriptors]、LN、および[ネイティブsegwitアドレス][topic bech32] の使用状況を共有しました。

- **Wasabiのインカミング・トランザクションにおけるRBF記述:** Wasabiのインカミング・トランザクション通知は、[RBF(Replace-by-Fee)シグナル][wasabi rbf notification]と、そのトランザクションがリプレース・トランザクションであるかどうかを伝達するようになりました。プライバシーを強化するために、Wasabiは[RBF(Replace-by-Fee)トランザクションの2%][wasabi rbf signaling]をランダムに通知します。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Bitcoin Improvement Proposals(BIPs)][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #17843][]は、[再利用回避][news52 #13756]を使用したウォレットで発生する、`listunspent`と`getbalances` RPCにおける再利用アドレスの決定方法の不一致を解決するのに役立ちます。解決するまでは、この問題により、`getbalances` RPCが使用可能な資金の量を過剰に算出していた可能性がありました。

- [Eclair #1247][]では、[Newsletter #72][news72 sphinx]で説明したSphinxプライバシーリークを（ルーティングノードがソースノードに戻るパスの長さの下限を推定できる可能性あった）修正されます。

- [Eclair #1283][]は、マルチパス・ペイメント（MPP）が通知されていなかったチャネルの通過を可能にします。これは、eclair-mobileがMPPを行うために必要なものです。

- [LND #3900][]では、支出者が支払いとともにカスタムデータレコードを送信できます。`lncli`を使用すると、ユーザーは`--data`フラグをレコードIDと16進数のデータ（例えば`65536=c0deba11ad`）とともに渡すことができます。カスタムデータレコードの使用例としてはプライベートメッセージをLN経由でルーティングする[WhatSat][]プログラムなどがあります。<!-- source: "custom record sending" in　https://github.com/joostjager/whatsat/commit/7c172ff8a63e56ec52005028b0f0d6b0a88867ec -->

{% include references.md %}
{% include linkers/issues.md issues="17843,1247,1283,3900" %}
[lnd 0.9.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.0-beta-rc3
[wormhole thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017585.html
[wasabi design discussion]: https://github.com/zkSNACKs/Meta/issues/49
[tumblebit]: https://eprint.iacr.org/2016/575.pdf
[zmn note]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017587.html
[dlcs]: https://adiabat.github.io/dlc.pdf
[stewart dlc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017563.html
[dlcspecs]: https://github.com/discreetlogcontracts/dlcspecs/
[scriptless scripts examples]: https://github.com/ElementsProject/scriptless-scripts
[whatsat]: https://github.com/joostjager/whatsat
[news72 sphinx]: /ja/newsletters/2019/11/13/#ln-1
[river twitter thread]: https://twitter.com/philipglazman/status/1216849483184476165
[wasabi rbf notification]: https://bitcoinops.org/en/compatibility/wasabi/#receive-notification
[wasabi rbf signaling]: https://github.com/zkSNACKs/WalletWasabi/pull/2405
[news52 #13756]: /en/newsletters/2019/06/26/#bitcoin-core-13756
