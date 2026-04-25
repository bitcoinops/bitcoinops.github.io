---
title: 'Bitcoin Optech Newsletter #402'
permalink: /ja/newsletters/2026/04/24/
name: 2026-04-24-newsletter-ja
slug: 2026-04-24-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Hornetノードによるコンセンサスルールの宣言的実行可能な仕様に関する取り組みと、
ライトニングネットワークにおけるオニオンメッセージのジャミングに関する議論を掲載しています。
また、Bitcoin Stack Exchangeから厳選された質問とその回答や、
新しいリリースおよびリリース候補の発表、人気のBitcoin基盤ソフトウェアの注目すべき更新など、
恒例のセクションも含まれています。

## ニュース

- **HornetノードによるBitcoinコンセンサスルールの宣言的実行可能な仕様**:
  Toby Sharpは、HornetノードプロジェクトのアップデートをDelving Bitcoinと
  Bitcoin-Dev[メーリングリスト][hornet ml post]に[投稿しました][topic hornet update]。
  Sharpは[以前][topic hornet]、初期ブロックダウンロードの時間を167分から15分に短縮する
  新しいノード実装Hornetについて説明していました。今回のアップデートでは、
  34個のセマンティック不変条件をシンプルな代数を使って構成した、
  非スクリプトブロック検証ルールの宣言的な仕様を完成させたことを報告しています。

  Sharpはまた、スクリプト検証への仕様の拡張を含む今後の作業について概説し、
  Eric Voskuilからのフィードバックを受けて、libbitcoinなどの他の実装との比較の可能性についても検討しています。

- **ライトニングネットワークにおけるOnionメッセージのジャミング**: Erick Cestariは、
  ライトニングネットワークに影響を与える[Onionメッセージ][topic onion messages]のジャミング問題について
  Delving Bitcoinに[投稿しました][onion del]。BOLT4は、Onionメッセージが信頼性のないものであることを認めており、
  レート制限技術を適用することを推奨しています。Cestariによれば、
  これらの技術こそがメッセージジャミングを可能にするとされています。攻撃者は悪意あるノードを立ち上げ、
  スパムメッセージでネットワークを溢れさせることでピアのレート制限を発動させ、
  正当なメッセージをドロップさせることができます。さらに、BOLT4は最大メッセージ長を強制していないため、
  攻撃者は単一のメッセージのリーチを最大化することが可能です。

  Cestariは、オニオンメッセージのジャミングに対するいくつかの緩和策をレビューし、
  より適切であると判断した技術について包括的な説明を提供しています:

  - *<!--upfront-fees-->前払い手数料*: この手法は、Carla Kirk-Cohenが
    [BOLTs #1052][]で最初に提案したものですが、容易に拡張ができます。ノードはメッセージ毎の定額手数料を通知し、
    それをオニオンペイロードに含めて各ホップで差し引きます。手数料が支払われない場合、メッセージはノードによってドロップされます。
    この手法は、チャネルピアへのメッセージ転送しかできないことや、P2Pオーバーヘッドの増加といったいくつかの制限があります。

  - *ホップ制限とチャネル残高に基づくProof of Stake*: この手法は、
    アルバータ大学のBashiriとKhabbazianによって[提案された][mitig2 onion]もので、2つの異なるコンポーネントを持ちます:
    - ホップ数の制限: メッセージを送れる最大ホップ数（例：3ホップまで）にハードキャップを設定するか、
      送信者にProof of Workのパズルを解かせ、その難易度をホップ数に応じて指数関数的に増加させます。
    - Proof of Stake転送ルール: 各ノードは、ピアの集約チャネル残高に応じてピア毎のレート制限を設定し、
      十分な資金を持つノードにより多くの転送能力を与えます。

    このアプローチのトレードオフは、大規模ノードが有利になることによる中央集権化への圧力と、
    3ホップのハードキャップが匿名セットの減少につながることです。

  - *<!--bandwidth-metered-payment-->帯域幅計測型支払い*:
    Olaoluwa Osuntokunによって[提案された][mitig3 onion]この手法は、
    前払い手数料と同様のスコープを持ちますが、セッションごとの状態を追加し、[AMP支払い][topic amp]を通じて決済します。
    送信者はまずAMP支払いを送信し、各中間ステップで手数料を落としながらセッションIDを届けます。
    その後、送信者はオニオンメッセージにそのIDを含めます。このアプローチの既知の制限は、
    チャネルピアへのメッセージ転送しかできないことと、同じセッションに属するすべてのメッセージをリンクできる可能性です。

  - *<!--backpropagation-based-rate-limiting-->逆伝播ベースのレート制限*:
    Bastien Teinturierによって[提案された][mitig4 onion]このアプローチは、
    統計的にスパムをその発信源までたどることができるバックプレッシャー機能を使用します。ピアごとのレート制限に達した場合、
    ノードは送信者にドロップメッセージを送り返し、送信者はそのメッセージをレート制限を半分にしてメッセージを転送した最後のピアにリレーします。
    正しい送信者は統計的に識別されますが、誤ったピアがペナルティを受ける可能性があります。
    さらに攻撃者はドロップメッセージを偽造し、正直なノードのレート制限を下げることもできます。

  最後にCestariは、最近[Torで起きたような][tor issue]長期的なDDoS攻撃がネットワークに及ぶ前に、
  この問題を緩和するための猶予がまだ残っているとして、LN開発者に議論への参加を呼びかけています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [BIP342はなぜCHECKMULTISIGからFindAndDeleteを削除するのではなく、新しいopcodeに置き換えたのですか？]({{bse}}130665)
  Pieter Wuilleは、[Tapscript][topic tapscript]における`OP_CHECKMULTISIG`から
  `OP_CHECKSIGADD`への置き換えは、将来のプロトコル変更で[Schnorr][topic schnorr signatures]署名のバッチ検証（
  [ニュースレター #46][news46 batch]参照）を可能にするために必要だったと説明しています。

- [SIGHASH_ANYPREVOUTはTapleafハッシュにコミットしますか？それともTaprootのマークルパス全体にコミットしますか？]({{bse}}130637)
  Antoine Poinsotは、[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]署名は現在、
  [Taproot][topic taproot]ツリーのマークルパス全体ではなく、Tapleafハッシュのみにコミットしていることを確認しています。
  ただし、BIPの共著者の1人が代わりにマークルパス全体にコミットすることを提案しており、この設計は議論中です。

- [MuSig2ライトニングチャネルにおいて、BIP86 tweakはアドレス形式以外に何を保証しますか？]({{bse}}130652)
  Ava Chowは、[MuSig2][topic musig]の署名プロトコルは署名集約が成功するためにすべての参加者が同じ
  [BIP86][] tweakを適用することを要求するため、このtweakは隠されたスクリプトパスの使用を防ぐと指摘しています。
  もし一方の当事者が、隠されたスクリプトツリーから導出したような異なるtweakを使用しようとした場合、
  その部分署名は有効な最終署名に集約されません。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 31.0][]は、ネットワークの主要なフルノード実装の最新のメジャーリリースです。
  [リリースノート][notes31]では、[クラスターmempool][topic cluster mempool]設計の実装や、
  `sendrawtransaction`の新しい`-privatebroadcast`オプション（[ニュースレター #388][news388 private]参照）、
  [エクリプス攻撃][topic eclipse attacks]から保護するためにオプションでバイナリに埋め込まれた`asmap`データ、
  4096 MiB以上のRAMを搭載したシステムにおける`-dbcache`のデフォルト値を1024 MiBに引き上げ、
  その他多くの更新など、いくつかの重要な改善について説明しています。

- [Core Lightning 26.04][]は、この人気のLNノード実装のメジャーリリースです。
  デフォルトで[スプライシング][topic splicing]を有効にし、
  スプライスアウトの宛先として2つ目のチャネルを対象にする`cross-splice`モードを含む
  新しい`splicein`および`spliceout`コマンドを追加し、収入のサマリ用の`bkpr-report`を再設計し、
  `askrene`での並行経路探索と複数のバグ修正を追加し、`offer` RPCと
  `payment-fronting-node`設定に`fronting_nodes`オプションを追加し、
  レガシーオニオンフォーマットのサポートを削除します。詳細は、[リリースノート][notes cln]をご覧ください。

- [LND 0.21.0-beta.rc1][]は、この人気のLNノードの次期メジャーバージョンの最初のリリース候補です。
  SQLiteまたはPostgreSQLバックエンドに対して`--db.use-native-sql`フラグを指定してノードを実行しているユーザーは、
  このバージョンでは、`--db.skip-native-sql-migration`によるオプトアウトにより、
  ペイメントストアがkey-value形式からネイティブSQLに移行されることに注意してください。
  [リリースノート][notes lnd]をご覧ください。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33477][]は、[assumeUTXO][topic assumeutxo]スナップショットに使用される
  過去のUTXOセットダンプを構築するための`dumptxoutset`
  RPCの`rollback`モード（[ニュースレター #72][news72 dump]参照）を更新します。
  ブロックを無効化してメインのchainstateをロールバックする代わりに、
  Bitcoin Coreは一時的なUTXOデータベースを作成し、要求された高さまでロールバックして、
  その一時データベースからスナップショットを書き出します。これにより、
  追加の一時ディスク容量とダンプの遅延というコストと引き換えに、メインのchainstateを保持し、
  ネットワーク活動を停止する必要性とロールバック時のフォーク関連の干渉リスクを排除します。
  新しい`in_memory`オプションは、一時UTXOデータベースをすべてRAM上に保持することで、
  より高速なロールバックを可能にしますが、mainnetでは10GB以上の空きメモリが必要です。
  深いロールバックを行う場合、数分かかる可能性があるため、RPCのタイムアウトをなしにする（
  `bitcoin-cli -rpcclienttimeout=0`）のを忘れないようにしてください。

- [Bitcoin Core #35006][]は、`bitcoin-cli`に`-rpcid`オプションを追加し、
  JSON-RPCリクエストの`id`として、デフォルトのハードコードされた値の`1`の代わりに
  カスタム文字列を設定できるようにします。これにより、複数のクライアントが同時に呼び出しを行う際に、
  リクエストとレスポンスを相関付けることができます。この識別子はサーバー側のRPCのデバッグログにも含まれます。

- [BIPs #1895][]は、[ポスト量子][topic quantum resistance]移行と
  レガシー署名の利用終了に関する抽象的な提案である[BIP361][]を公開しました。
  別途ポスト量子（PQ）署名スキームが標準化され展開されることを前提として、
  ECDSA/[Schnorr][topic schnorr signatures]署名スキームからの段階的移行を概説しています。
  現在のバージョンの提案は2つのフェーズに分かれています。フェーズAは、量子脆弱なアドレスの資金の送金を禁止し、
  それによってPQアドレスタイプの採用を加速させます。フェーズBでは、量子脆弱なUTXOからの盗難を防ぐために、
  ECDSA/Schnorr署名を使用する支払いの制限と量子安全なレスキュープロトコルが含まれています。

- [BIPs #2142][]は、[サイレントペイメント][topic silent payments]のBIP提案である[BIP352][]を更新し、
  インプットの鍵の合算値が、2つのインプットの段階で一旦ゼロになるものの、全インプットを合算するとゼロにはならない
  というエッジケースに対する送受信のテストベクトルを追加します。これによりすべてのインプットをまず合算するのではなく、
  インクリメンタルな合算の途中で早期に拒否してしまう実装を検出できます。

- [LDK #4555][]は、転送ノードが[ブラインドされた支払い経路][topic rv routing]に対して
  [`max_cltv_expiry`][topic cltv expiry delta]を適用する方法を修正します。このフィールドは、
  期限切れのブラインドルートがブラインドセグメントを通じて転送されて受信者に近い場所で失敗するのではなく、
  導入ホップで拒否されることを保証することを意図しています。これまでは、LDKはこの制約をホップの送信CLTV値と比較していましたが、
  現在は意図どおり受信CLTVの有効期限をチェックするようになっています。

- [LND #10713][]は、受信する[オニオンメッセージ][topic onion messages]に対して
  ピアごとおよびグローバルなトークンバケットレート制限を追加し、オニオンハンドラーに到達する前に
  入口で過剰なトラフィックをドロップします。これにより、LNDに最近追加されたオニオンメッセージの転送サポート（
  [ニュースレター #396][news396 lnd onion]参照）が、高速ピアからの大量の悪用に対して強化されます。
  ピアごととグローバルの分割は、LNDの以前のゴシップ帯域幅制限（[ニュースレター #370][news370 lnd gossip]参照）を踏襲しています。

- [LND #10754][]は、選択された次のホップがメッセージを届けたピアと同じピアである場合、
  [オニオンメッセージ][topic onion messages]の転送を停止し、同じ接続での即時バウンスを回避します。

{% include snippets/recap-ad.md when="2026-04-28 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1052,33477,35006,4555,10713,10754,1895,2142" %}
[news46 batch]: /en/newsletters/2019/05/14/#new-script-based-multisig-semantics
[topic hornet update]: https://delvingbitcoin.org/t/hornet-update-a-declarative-executable-specification-of-consensus-rules/2420
[hornet ml post]: https://groups.google.com/g/bitcoindev/c/M7jyQzHr2g4
[topic hornet]: /ja/newsletters/2026/02/06/#utxo
[onion del]: https://delvingbitcoin.org/t/onion-message-jamming-in-the-lightning-network/2414
[mitig2 onion]: https://ualberta.scholaris.ca/items/245a6a68-e1a6-481d-b219-ba8d0e640b5d
[mitig3 onion]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2022-February/003498.txt
[mitig4 onion]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2022-June/003623.txt
[tor issue]: https://blog.torproject.org/tor-network-ddos-attack/
[Bitcoin Core 31.0]: https://bitcoincore.org/bin/bitcoin-core-31.0/
[notes31]: https://bitcoincore.org/ja/releases/31.0/
[news388 private]: /ja/newsletters/2026/01/16/#bitcoin-core-29415
[Core Lightning 26.04]: https://github.com/ElementsProject/lightning/releases/tag/v26.04
[notes cln]: https://github.com/ElementsProject/lightning/releases/tag/v26.04
[LND 0.21.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.0-beta.rc1
[notes lnd]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.21.0.md
[news72 dump]: /ja/newsletters/2019/11/13/#bitcoin-core-16899
[news396 lnd onion]: /ja/newsletters/2026/03/13/#lnd-10089
[news370 lnd gossip]: /ja/newsletters/2025/09/05/#lnd-10103
