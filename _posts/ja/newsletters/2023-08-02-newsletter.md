---
title: 'Bitcoin Optech Newsletter #262'
permalink: /ja/newsletters/2023/08/02/
name: 2023-08-02-newsletter-ja
slug: 2023-08-02-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、最近のLN仕様ミーティングの議事録のリンクと、
ブラインドMuSig2署名の安全性に関するスレッドの要約を掲載しています。
また、新しいリリースやリリース候補、人気のあるBitcoinインフラストラクチャソフトウェアの
注目すべきコードの変更など、恒例のセクションも含まれています。

## ニュース

- **定期的なLN仕様ミーティングの議事録:** Carla Kirk-Cohenは、
  LNの仕様の変更を議論するための最近のビデオ会議の議事録が作成されたことを
  Lightning-Devメーリングリストに[投稿しました][kc scripts]。
  議事録は、Bitcoin Transcriptsで[公開されています][btcscripts spec]。
  関連するニュースとして、数週間前のLN開発者会議でも議論されたように、
  [Libera.chat][]のIRCチャットルーム`#lightning-dev`では、
  LN関連の議論が再び活発になっています。

- **ブラインドMuSig2署名の安全性:** Tom Trevethanは、
  [Statechains][topic statechains]の展開の一部として計画されている暗号プロトコルのレビュー依頼を
  Bitcoin-Devメーリングリストに[投稿しました][trevethan blind]。
  目的は、署名内容や部分署名がどのように使用されるのかについて何も知ることなく
  秘密鍵を使用して[MuSig2][topic musig]の部分署名を作成するサービスを展開することでした。
  ブラインド署名者は、特定の鍵を使って作成した署名の数を報告するだけです。

    メーリングリストでの議論では、この特定の問題に関連するさまざまな構成の落とし穴と、
    [さらに一般化されたブラインドSchnorr署名][generalized blind schnorr]の落とし穴について検討されました。
    また、ブラインドecashに使用できるブラインド[ディフィー・ヘルマン(DH)鍵交換][dhke]の1996年のプロトコルに関する
    Ruben Somsenの1年前の[gist][somsen gist]についても言及されました。
    [Lucre][]や[Minicash][]はBitcoinとは関係のないこの方式の以前の実装で、
    [Cashu][]はBitcoinとLNのサポートを統合したMinicashに関連する実装です。
    暗号技術に興味のある人なら、暗号技術に関して議論しているこのスレッドを興味深く読むことができるでしょう。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BTCPay Server 1.11.1][]は、このセルフホスト型のペイメントプロセッサの最新リリースです。
  1.11.xのリリースシリーズには、インボイスレポートの改善や、チェックアウトプロセスの追加のアップグレードおよび、
  POS端末の新機能が含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #26467][]では、ユーザーが`bumpfee`でトランザクションのどのアウトプットがお釣りか指定できるようになりました。
  ウォレットは、このアウトプットから金額を差し引いて[置換トランザクション][topic rbf]を作成する際の手数料を追加します。
  デフォルトでは、ウォレットは自動的にお釣りのアウトプットを検出し、
  検出できない場合は新しいアウトプットを作成します。

- [Core Lightning #6378][]と[#6449][core lightning #6449]では、
  ノードが対応するオンチェーンHTLCをタイムアウトできない場合（もしくは、手数料コストのためしたくない場合）、
  オンチェーンの受信[HTLC][topic htlc]を失敗としてマークします。
  たとえば、アリスのノードが20ブロックの有効期限でボブのノードにHTLCを転送し、
  ボブのノードは同じペイメントハッシュを持つHTLCを10ブロックの有効期限でキャロルのノードに転送します。
  その後、ボブとキャロルのチャネルがオンチェーンで強制クローズされます。

    10ブロックの有効期限が切れると、通常はあまり起こりにくい状況が発生します：
    ボブのノードは、払い戻しの条件を使用して資金を回収しようとするがトランザクションが承認されないか、
    払い戻しの回収をするための手数料が金額よりも高いと判断し回収しない判断をします。
    このPR以前は、ボブのノードは、アリスから受け取ったHTLCのオフチェーンキャンセルを作成しませんでした。
    なぜなら、そうすると、アリスはボブに転送した資金を保持し、キャロルはボブが彼女に転送した資金を請求することができ、
    ボブにHTLCの金額を負担させることになるからです。

    しかし、アリスがボブに提供したHTLCの20ブロックの有効期限が切れた後、
    アリスはボブに転送した金額の払い戻しを受け取るためにチャネルを強制クローズすることができます。
    アリスのソフトウェアは、上流のノードに対して資金を失う可能性があるため、
    これを自動的に行う可能性があります。しかし、彼女がチャネルを強制クローズすると、
    ボブと同じ状況になる可能性があります。つまり、払い戻しを請求できないか、
    経済的に有利ではないため請求しないかのどちらかです。これは、
    アリスとボブの間の有用なチャネルが、どちらの利益にもならないまま閉じられることを意味します。
    この問題は、アリスの上流のホップで複数回繰り返される可能性があり、
    その結果、望ましくないチャネル閉鎖の連鎖が発生します。

    このPRで実装された解決策は、ボブが払い戻しを請求するのに妥当な時間だけ待機し、
    それが実行されない場合は、アリスから受け取ったHTLCのオフチェーンキャンセルを作成し、
    ボブがHTLCの資金を失う可能性があるとしても、彼らのチャネルを継続させることです。

- [Core Lightning #6399][]では、`pay`コマンドにローカルノードで作成されたインボイスへの支払いがサポートされました。
  これは、最近[メーリングリストのスレッド][fiatjaf custodial]で議論されたように、
  バックグラウンドでCLNを呼び出すソフトウェアのアカウント管理コードを簡素化することができます。

- [Core Lightning #6389][]は、オプションのCLNRestサービスを追加しました。
  「RPC呼び出しをRESTサービスに変換する軽量のPythonベースのCore Lightningプラグインです。
  REST APIエンドポイントを生成することで、Core LightningのRPCメソッドを裏で実行し、レスポンスをJSON形式で提供します。」
  詳細は、[ドキュメント][clnrest doc]をご覧ください。

- [Core Lightning #6403][]と[#6437][core lightning #6437]は、
  runesの認証と認可のメカニズムをCLNのcommandoプラグイン（[ニュースレター #210][news210 commando]参照）から
  コア機能に移動し、他のプラグインからも使用できるようにしました。
  runesの作成、破棄、名前変更に関するいくつかのコマンドも更新されています。

- [Core Lightning #6398][]では、`setchannel` RPCを拡張し、
  新しい`ignorefeelimits`オプションにより、チャネルの最小オンチェーン手数料制限を無視し、
  リモートチャネルの取引相手がローカルノードが許可する最小額を下回る手数料率を設定できるようにしました。
  これは、他のLNノード実装の潜在的なバグを回避したり、
  部分的に信頼されたチャネルでの問題の原因である手数料の競合を排除するために使用できます。

- [Core Lightning #5492][]は、USDT（User-level Statically Defined Tracepoints）と
  その使用方法を追加しました。これにより、ユーザーは、トレスポイントが使用されていないときには、
  大きなオーバーヘッドを発生させることなく、デバッグのためにノードの内部動作を調査することができます。
  以前のBitcoin CoreへのUSDTサポートの組み込みについては、[ニュースレター #133][news133 usdt]をご覧ください。

- [Eclair #2680][]は、[BOLTs #863][]で提案された[スプライシングプロトコル][topic splicing]が必要とする
  静止ネゴシエーションプロトコルのサポートを追加しました。静止プロトコルは、スプライスのパラメーターに同意し、
  オンチェーンのスプライス・インまたはスプライス・アウトのトランザクションに協力して署名するなど、
  特定の操作が完了するまで、チャネルを共有する2つのノードがお互いに新しい[HTLC][topic htlc]を送信しないようにします。
  スプライスのネゴシエーションおよび署名中に受信したHTLCは、以前のネゴシエーションと署名を無効にする可能性があるため、
  スプライストランザクションの相互署名を入手するために必要な数回のネットワークラウンドトリップの間、
  HTLCリレーを一時停止する方が簡単です。Eclairはすでにスプライシングをサポートしていますが、
  この変更により、他のノードソフトウェアが使用するであろう同じスプライシングプロトコルのサポートに近づきました。

- [LND #7820][]は、`BatchOpenChannel` RPCに、
  `funding_shim`（バッチオープンには不要）と
  `fundmax`（複数のチャネルを開く際に１つのチャネルにすべての残高を与えられないため）を除く
  非バッチの`OpenChannel` RPCで利用可能なすべてのフィールドを追加しました。

- [LND #7516][]は、`OpenChannel` RPCに新しい`utxo`パラメーターを追加し、
  新しいチャネルの資金となるウォレットのUTXOを1つ以上指定できるようにしました。

- [BTCPay Server #5155][]は、支払いおよびオンチェーンウォレットのレポート、CSVへのエクスポート機能を提供する
  レポートページをバックオフィスに追加し、プラグインによって拡張できるようにしました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="863,26467,6378,6449,6399,6389,6403,6437,6398,5492,2680,7820,7516,5155" %}
[clnrest doc]: https://github.com/rustyrussell/lightning/blob/02c2d8a9e3b450ce172e8bc50c855ac2a16f5cac/plugins/clnrest/README.md
[news133 usdt]: /ja/newsletters/2021/01/27/#bitcoin-core-19866
[kc scripts]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004025.html
[btcscripts spec]: https://btctranscripts.com/lightning-specification/
[libera.chat]: https://libera.chat/
[trevethan blind]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-July/021792.html
[generalized blind schnorr]: https://gist.github.com/moonsettler/05f5948291ba8dba63a3985b786233bb
[somsen gist]: https://gist.github.com/RubenSomsen/be7a4760dd4596d06963d67baf140406
[lucre]: https://github.com/benlaurie/lucre
[minicash]: https://github.com/phyro/minicash
[cashu]: https://github.com/cashubtc/cashu
[fiatjaf custodial]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004008.html
[news210 commando]: /ja/newsletters/2022/07/27/#core-lightning-5370
[dhke]: https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange
[btcpay server 1.11.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.11.1
