---
title: 'Bitcoin Optech Newsletter #169'
permalink: /ja/newsletters/2021/10/06/
name: 2021-10-06-newsletter-ja
slug: 2021-10-06-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinにトランザクションヘリテージ識別子を追加する提案と、
Taprootの準備に関する情報や、新しいリリースおよびリリース候補のリスト、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点をまとめた恒例のセクションを掲載しています。

## ニュース

- **<!--proposal-for-transaction-heritage-identifiers-->トランザクションヘリテージ識別子の提案:**
  匿名の開発者John Lawによる[投稿][rubin-law iids]が、
  Bitcoin-DevおよびLightning-Devメーリングリストに送信されました。
  Lawは、現在のインプットに繋がるトランザクションの祖先のtxidとアウトプットの位置を参照できるようにする
  *Inherited Identifiers* (IIDs)を追加するソフトフォークを提案しました。
  例えば、`0123...cdef:0:1`は、現在のトランザクションインプットが、
  txid `0123...cdef`の最初のアウトプットの２つめの子を使用していることを示します。
  これにより、マルチパーティプロトコルの参加者は、
  特定のアウトプットを生成するトランザクションのtxidを知ることができない場合でも、
  そのアウトプットを支払いに使用するための署名を作成することができます。

    これは、提案中の[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]ソフトフォークによって可能になり、
    [eltoo][topic eltoo]プロトコルの一部として定義されている*フローティング・トランザクション*のアプローチと比較されます。
    フローティング・トランザクションでは、参加者は特定のアウトプットのScriptの条件を満たしていれば、
    そのアウトプットのtxidを知らなくても署名を作成することができます。

    Lawは、eltooおよび[Channel Factories][topic channel factories]の代替案を含む拡張[論文][law iids]で、
    IIDsによって可能になる4つの異なるプロトコルに加えて、[Watchtower][topic watchtowers]の設計を簡単にするアイディアについて説明しています。
    Anthony Townsは、新しい開発であるもののIIDsの機能はanyprevoutを使ってシミュレートできるのではないかと[提案しました][towns iids]が、
    Lawは、シミュレーションの可能性については[同意しませんでした][law nosim]。

    すべての参加者がメーリングリストの利用を希望している訳ではなかったため、
    アイディアの議論は複雑になりました。メーリングリストでの議論が再開された場合は、
    今後のニュースレターで注目すべき更新をまとめていきます。

## Taprootの準備 #16: アウトプットのリンク

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/15-output-linking.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.13.3-beta][]は、資金の損失に繋がる脆弱性である[CVE-2021-41593][]を修正したセキュリティリリースです。
  また、リリースノートには、すぐにアップグレードできないノードに対する緩和策の提案も含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core GUI #416][]では、"Enable RPC server"チェックボックスが追加され、
  Bitcoin CoreのRPCサーバーをオン/オフできるようになりました（再起動が必要）。

    {:.center}
    ![Screenshot of the Enable RPC server configuration option](/img/posts/2021-10-gui-rpc-server.png)

- [Bitcoin Core #20591][]では、ウォレットに関連するトランザクションの履歴ブロックを再スキャンする際に、
  ブロックのタイムスタンプのみを使用するよう、ウォレットの時間計算ロジックが変更されています。
  `rescanblockchain` RPCを使って再スキャンを手動で呼び出すユーザーやアプリケーションは、
  承認された時間ではなくスキャンされた時間で不正確にラベル付されたトランザクションを確認することはなくなり、
  時折発生する混乱と不満の原因が解消されます。

- [Bitcoin Core #22722][]では、`estimatesmartfee` RPCが更新され、
  設定済みおよび動的な最小トランザクションリレー手数料の両方よりも高い手数料率のみを返すようになりました。
  例えば、見積もりツールが1 sat/vbyteの手数料を計算し、設定値が2 sat/vbyteで、
  動的な最小値が3 sat/vbyteに上昇している場合、3 sat/vbyteの値が返されます。

- [Bitcoin Core #17526][]では、第3の[コイン選択][topic coin selection]の戦略として、
  [Single Random Draw][srd review club] (SRD)アルゴリズムを追加しました。
  これでウォレットは、分枝限定法（BnB）、ナップザック、SRDアルゴリズムのそれぞれからコイン選択結果を取得し、
  以前紹介した[wasteヒューリスティック][news165 waste]を使用して、
  3つの中から最も費用対効果の高い結果を選択してトランザクションに資金を供給します。

  約8,000の支払いを元にしたシミュレーションで、PRの作成者は、SRDアルゴリズムの追加により、
  全体的なトランザクション手数料が6%削減され、お釣りのないトランザクションの発生が5.4%から9.0％に増加したことを発見しました。
  お釣りのアウトプットを作成しないことで、トランザクションweightおよび手数料が減少し、
  ウォレットのUTXOプールサイズも減少し、お釣りのアウトプットを後で使用するコストが削減され、
  ウォレットのプライバシーが向上すると考えられます。

- [Bitcoin Core #23061][]では、`-persistmempool`設定オプションが修正されました。
  これまでは、パラメーターが渡されない場合、シャットダウン時にmempoolをディスクに永続化しませんでした（実際に永続化するためには、
  `-persistmempool=1`を渡す必要がありました。
  今後は素の`-persistmempool`オプションのみでmempoolが永続化されます（これはデフォルトのままなので、パラメーターを渡す必要はありません）。

- [Bitcoin Core #23065][]では、ウォレットのUTXOのロックをディスクに永続化できるようになりました。
  Bitcoin Coreのウォレットでは、ユーザーが1つ以上のUTXOをロックし、
  それを自動的に作成されるトランザクションで使用されるのを防ぐことができます。
  `lockunspent` RPCには、設定をディスクに保存する`persistent`パラメーターが追加され、
  GIUではユーザーが選択したロックが自動的にディスクに永続化されるようになりました。
  ロックの永続化の用途としては、[金額の小さいスパム][topic output linking]アウトプットや、
  ユーザーのプライバシーを損なう可能性のあるアウトプットの支払いの防止が挙げられます。

- [C-Lightning #4806][]では、ユーザーがノードの手数料設定を変更してから新しい設定が適用されるまで、
  デフォルトで10分の遅延が追加されました。
  これにより、最近値上がりした手数料の支払いに失敗して支払いがリジェクトされる前に、
  ノードによる新しい手数料の通知がネットワーク全体に伝播されます。

- [Eclair #1900][]と[Rust-Lightning #1065][]は、[BOLTs #894][]を実装しています。
  これによりコミットメントトランザクションでsegwitアウトプットの使用のみが許可されるため、
  LNプロトコルがより厳密になります。この制限を実行することで、
  LNプログラムは、より低い[dust limit][topic uneconomical outputs]を使用することができ、
  これにより（手数料率が低い場合に）、チャネルの強制クローズ時にマイナーに渡って失われる可能性のある金額を減らすことができます。

- [LND #5699][]では、支払いの試行を削除するための`deletepayments`コマンドが追加されました。
  デフォルトでは、失敗した支払いの試行のみが削除されます。安全性のため、
  成功した支払いの試行を削除するためには、追加のフラグを渡す必要があります。

- [LND #5366][]では、データベースのバックエンドとしてPostgreSQLを使用するための初期サポートを追加しました。
  既存のbboltバックエンドと比較して、PostgreSQLは複数のサーバーにレプリケーションすることができ、
  停止することなくデータベースの圧縮を行い、より大きなデータセットを扱うことができ、
  I/Oロックの競合を改善する可能性のあるより詳細なロックモデルを提供します。

- [Rust Bitcoin #563][]は、[P2TR][topic taproot]アウトプットに[bech32m][topic bech32]アドレスのサポートしました。

- [Rust Bitcoin #644][]は、[Tapscriptの][topic tapscript]新しい`OP_CHECKMULTISIGADD`opcodeと`OP_SUCCESSx`opcodeをサポートしました。

- [BDK #376][]は、データベースのバックエンドとしてsqliteをサポートしました。

{% include references.md %}
{% include linkers/issues.md issues="416,20591,22722,17526,23061,23065,4806,1900,1065,894,5699,5366,563,644,376" %}
[news165 waste]: /ja/newsletters/2021/09/08/#bitcoin-core-22009
[srd review club]: https://bitcoincore.reviews/17526
[rubin-law iids]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019470.html
[law iids]: https://github.com/JohnLaw2/btc-iids/raw/main/iids14.pdf
[towns iids]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019471.html
[law nosim]: https://github.com/JohnLaw2/btc-iids/blob/main/response_to_towns_20210918_113740.txt
[CVE-2021-41593]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003257.html
[lnd 0.13.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.3-beta
[series preparing for taproot]: /ja/preparing-for-taproot/
