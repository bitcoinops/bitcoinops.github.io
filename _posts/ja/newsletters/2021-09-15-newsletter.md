---
title: 'Bitcoin Optech Newsletter #166'
permalink: /ja/newsletters/2021/09/15/
name: 2021-09-15-newsletter-ja
slug: 2021-09-15-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Covenant opcodeの新しい提案と、
signetでの定期的なreorgの実装に関するフィードバックの要求について掲載しています。
また、Taprootの準備や、新しいリリースおよびリリース候補のリスト、
人気のあるBitcoinインフラストラクチャソフトウェアの説明など、恒例のセクションも含まれています。

## ニュース

- **<!--covenant-opcode-proposal-->Covenant opcodeの提案:** Anthony Townsは、Bitcoin-Devメーリングリストに、
  Covenant opcodeのアイディアの[概要][towns overview]と、
  そのopcode（および他のいくつかのtapscriptの変更）がどのように機能するかを説明する、
  より[技術的に詳細な][towns detailed]メッセージを投稿しました。

  要約すると、新しい`OP_TAPLEAF_UPDATE_VERIFY` opcode (TLUV)は、
  使用されるTaprootのインプットに関する情報を受け取り、Tapscriptの記述を変更し、
  その結果がインプットと同じ位置にあるアウトプットのscriptPubKeyと同じであることを要求します。
  これにより、TLUVは、[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS)や
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)などの他の提案されているopcodeと同様に、
  ビットコインの使用先（[Covenant][topic covenants]の定義）を制限できます。
  これまでの提案と異なるのは、Tapscriptの作成者に許可されている以下の変更点です:

  - **<!--internal-key-tweak-->内部キーの調整:** すべてのTaprootアドレスは、署名のみで使用できる内部キーにコミットします。
    （TLUVを含む）Tapscriptを使用するためには、現在の内部キーを明らかにする必要があります。
    TLUVでは、その鍵に加算する調整値を指定する必要があります。例えば、
    内部キーが鍵`A+B+C`の集約鍵である場合、鍵`C`を`-C`の調整値を指定することで削除できたり、
    調整値`X`を指定することで鍵`X`を追加できます。TLUVは、変更された内部キーを計算し、
    それが同じ位置のアウトプットが支払うものであることを保証します。

    Townsのメールに記載されているこの機能の強力な使用法の１つは、
    [Joinpool][joinpool]をより効率的に作成する機能です。
    Joinpoolは、それぞれがUTXOの資金の一部を管理しているものの、
    その所有権をオンチェーンで公に公開する必要がない（また、UTXOの所有者の数を公開する必要もない）
    複数のユーザーが共有する１つのUTXOのことです。
    すべてのプール参加者が一緒に署名すれば、彼らは資金を非常にファンジブルなトランザクションで使用できます。
    もし合意に至らない場合は、各プール参加者は、
    （オンチェーン手数料を差し引いた）すべての資金を持ってプールを抜けるためのトランザクションを使用できます。

    現在、署名済みのトランザクションのみを使用してJoinpoolを作るのは可能ですが、
    プールの各参加者が他の参加者の協力を得ずに個別に抜けれるようにするためには、
    指数関数的に増加する署名を作成する必要があります。CTVにも同様の問題があり、
    プールから抜けるためには、他の複数の参加者に影響を与える複数のトランザクションの作成が必要になる場合があります。
    TLUVでは、１人の参加者がJoinpoolから抜けたことを明らかにするだけで、
    何かに事前に署名する必要もなく、他の参加者に影響を与えることもなく、１人でいつでも抜けることができます。

  - **<!--merkle-tree-tweak-->マークルツリーの調整:** Taprootアドレスは、Tapscriptのツリーのマークルルートにコミットすることができ、
    TLUV opcodeを実行するのは、トランザクションインプット内のこれらのTapscriptの１つになります。
    TLUVにより、そのScriptは、マークルツリーのその部分がどう変更されるべきかを指定することができます。
    例えば、現在実行されているノード（Tapleaf）をツリーから削除したり（例えばJoinpoolを抜ける人）、
    別のTapscriptへ支払うTapleafに置き換えたりすることができます。
    TLUVは、変更されたマークルルートを計算し、それを同じ位置のアウトプットへ支払うことを保証します。

    Townsのメールでは、2019年のBryan Bishopの[Vault][topic vaults]の設計（[ニュースレター #59][news59 vaults]参照）を実装するために、
    これがどう利用できるか説明されています。アリスは、安全性の低いホットウォレット用と、
    安全性の高いコールドウォレット用の２つの鍵ペアを作成します。
    コールドウォレットの鍵はTaprootの内部キーになり、いつでも資金を使用できます。
    ホットウォレットの鍵はTLUVと一緒に使用され、ホットウォレットの鍵から2回めの支払いが送信されるまでの遅延時間を含む、
    マークルツリーの変更へのみ支払いを許可します。

    つまり、アリスはホットキーで全資金の支払いを開始できますが、
    そのためにオンチェーントランザクションを作成し、任意のアドレスで資金を本当に使用できるようになるまで、
    遅延時間（例えば1日）が経過するのを待たなければなりません。
    他の誰かがアリスのホットキーを使って支払いプロセスを開始した場合、
    アリスはコールドキーを使って資金を安全なアドレスに移動させることができます。

  - **<!--amount-introspection-->量のイントロスペクション:** TLUVに加えて、インプットのビットコインの量と対応するアウトプットを
    スクリプトの実行スタックにプッシュする2つめのopcodeが追加されます。
    これにより、計算や比較用のopcodeを使って使用される量を制限することができます。

    Joinpoolの場合、抜ける参加者が自分の資金のみを引き出せるようにするのに使用されます。
    Vaultでは、1日につき1BTCなど、定期的な引き出し制限を設定するのに利用できます。

  この記事を書いている時点では、この提案はまだメーリングリストで初期のフィードバックを受けています。
  注目すべきコメントがあれば、今後のニュースレターでまとめてご紹介します。

- **<!--signet-reorg-discussion-->signetのreorgに関する議論:** 開発者の0xB10Cは、
  [signet][topic signet]で定期的にブロックチェーンの再編成（reorg）を行うための提案をBitcoin-Devメーリングリストに[投稿しました][b10c post]。
  最終的にreorgされるブロックは、versionフィールドの１つにシグナルをセットし、
  reorgを追跡したくない人はそれらのブロックを無視できるようにします。
  reorgは定期的に、おそらく1日に3回発生し、mainnetで起こりうるreorgを再現した２つの異なるパターンに従います。

  0xB10Cはフィードバックを求め、この記事を書いている時点でいくつかのコメントを受け取っています。
  signetでのreorgのテストに興味のある方（またはそれを回避したい方）は、
  議論を読んで参加を検討してみてください。

## Taprootの準備 #13: バックアップとセキュリティのスキーム

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/12-backups.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 22.0][bitcoin core 22.0]は、このフルノード実装と、
  それに付随するウォレットなどのソフトウェアの次のメジャーバージョンのリリースです。
  この新バージョンの主な変更点は、[I2P][topic anonymity networks]接続のサポート、
  [version 2 Tor][topic anonymity networks]接続のサポートの削除、
  ハードウェアウォレットのサポートの強化などです。
  なお、[ニュースレター #162][news162 core verification]に掲載しているように、
  このリリースではリリース検証手順が変更されていることに注意してください。

- [BTCPay Server 1.2.3][]は、責任をもって報告された３つのクロスサイトスクリプティング（XSS）の脆弱性を修正するリリースです。

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2]は、
  Bitcoin Coreのメンテナンスバージョンのリリース候補です。
  いくつかのバグ修正と小さな改善が含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #22079][]は、[ZMQインターフェース][ZMQ interface]にIPv6のサポートを追加しました。

- [C-Lightning #4599][]は、[BOLTs #843][]で説明されている迅速なクローズのための手数料調整プロトコルを実装しています。
  先週のニュースレーターでこのプロトコルについて[説明しました][news165 bolts847]が、
  このプロトコルで置き換えられる既存のプロトコルについての説明は[不正確][russell tweet]でした。
  従来のプロトコルでは、協調クローズトランザクションに使用する手数料率をトライ＆エラーで調整する必要があり、
  現在のコミットメント・トランザクションよりも高い手数料率を設定することはできませんでした。
  これは低手数料率のコミットメント・トランザクションが使用された際に手数料を引き上げるために設計された
  [anchor output][topic anchor outputs]では意味をなしません。
  新しいプロトコルでは、より高い手数料を支払うことができ、可能な場合は、より効率的な範囲ベースの調整を使用します。
  今週マージされた[Eclair #1768][]も、このプロトコルを実装しています。

- [Eclair #1930][]は、非デフォルトの実験的なパラメーターセットで経路探索アルゴリズムを実行できるようになりました。
  これは一定の割合のトラフィックに対して自動的に行うことも、APIを通じて手動で行うこともできます。
  実験的なパラメーターセット毎にメトリクスが記録され、最適な経路探索パラメーターの最適化に利用できます。

- [Eclair #1936][]は、ノードのTorオニオンサービスのアドレスを非公開にしたい場合に、
  そのアドレスの公開を無効にすることができるようになりました。

- [LND #5356][]は、`BatchChannelOpen`RPCを追加し、
  同じ[バッチ][topic payment batching]オンチェーントランザクションで、異なるノードと複数のチャネルを開くことができるようになりました。

- [BTCPay server #2830][]では、シングルシグのP2TR支払いの受信と送信の両方が可能な[Taproot][topic taproot]対応ウォレットの作成をサポートしました。
  [signet][topic signet]でテストされています。追加のマージ済みのPR [#2837][btcpay server #2837]は、
  ウォレットの設定でP2TRアドレスのサポートがリストされていますが、ブロック{{site.trb}}までは選択できないようになっています。

{% include references.md %}
{% include linkers/issues.md issues="22079,4599,1930,1936,5356,2830,843,1768,2837" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[btcpay server 1.2.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.2.3
[towns overview]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019419.html
[towns detailed]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019420.html
[joinpool]: https://gist.github.com/harding/a30864d0315a0cebd7de3732f5bd88f0
[news59 vaults]: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[b10c post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019413.html
[news165 bolts847]: /ja/newsletters/2021/09/08/#bolts-847
[russell tweet]: https://twitter.com/rusty_twit/status/1435758634995105792
[news162 core verification]: /ja/newsletters/2021/08/18/#bitcoin-core-22642
[zmq interface]: https://github.com/bitcoin/bitcoin/blob/40a9037a1b5d990637d7f5009fc0c39628ed2c05/doc/zmq.md
[series preparing for taproot]: /ja/preparing-for-taproot/
