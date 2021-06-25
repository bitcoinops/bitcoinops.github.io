---
title: 'Bitcoin Optech Newsletter #154'
permalink: /ja/newsletters/2021/06/23/
name: 2021-06-23-newsletter-ja
slug: 2021-06-23-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、手数料による普遍的なトランザクションの置換を可能にする提案と、
Taprootの準備に関する新しい週刊シリーズの最初の記事を掲載しています。
また、クライアントやサービスの更新や、新しいリリースおよびリリース候補、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点などの恒例のセクションも含まれています。

## ニュース

- **<!--allowing-transaction-replacement-by-default-->デフォルトでトランザクションの置換を許可:**
  現在、ほぼすべてのBitcoinフルノードは、[BIP125][] opt-in Replace By Fee ([RBF][topic rbf])を実装していると考えられます。
  RBFは、トランザクションの作成者が元のトランザクションにシグナルを設定した場合に限り、
  ノードのmempool内の未承認トランザクションを、より高い手数料の代替バージョンに置き換えることができるようにするものです。
  このopt-inの動作は、手数料の引き上げや[加法的な支払いのバッチ処理][additive payment batching]などでトランザクションの置換を許可したい人々と、
  置換を許可すると未承認のトランザクションを最終的なものとして受け入れるマーチャントを欺くツールの構築が簡単になるという理由で反対する人々との間の妥協案として提案されました。

    ５年以上経過した現在、未承認トランザクションを最終的なものとして受け入れているマーチャントはほとんどいないようです。
    実際に、 BIP125 opt-inシグナルをチェックし、それらのトランザクションを異なる方法で処理しているマーチャントの数は明らかになっていません。
    誰もBIP125のシグナルに依存していないのであれば、すべてのトランザクションを置換可能にすることで、
    以下のような利点が得られます:

    - RBFによる手数料の引き上げのアイディアでは、悪意ある相手がBIP125シグナルの設定を防ぐの能力を考慮する必要があるが、
      （LNや[Vault][topic vaults]などの）事前署名されたトランザクションプロトコルの分析を**簡素化します**。

    - RBFを選択したトランザクションは、選択していないトランザクションとはチェーン上で異なって見えるため、
      **トランザクション分析の機会が減少します**。ほとんどのウォレットは一貫してオプトインするかしないかを選択するため、
      これは監視会社が誰がどのビットコインを所有しているかを特定するために使用できる証拠になります。
      すべてのトランザクションが置換可能であれば、BIP125シグナルを設定する必要はないでしょう。

    今週、Antoine Riardは、BIP125 opt-inシグナルを設定するかどうかに関わらず、
    最終的にBitcoin Coreのコードを変更して、
    すべてのトランザクションにRBFを許可するという提案をBitcoin-Devメーリングリストに[投稿しました][riard rbf]。
    このアイディアは、最初のトランザクションリレーワークショップの[ミーティング][trw meeting]でも議論されました。
    参加者の何人かは、別のアプローチとしてBitcoin Coreの[PR #10823][bitcoin core #10823]に言及していました。
    このPRでは、どのようなトランザクションでも置換可能ですが、
    そのトランザクションがノードのmempoolで一定時間（当初は6時間と提案されていましたが、その後72時間が提案されました）経過した後でのみ置換可能になります。

    Riardのメールとミーティング参加者ともに、BIP125 opt-inシグナルを含まないトランザクションを置き換える提案には、
    現在BIP125の動作に依存しているマーチャントからのフィードバックが必要であると述べています。
    Optechは、そのようなマーチャントがメーリングリストのスレッドに反応することを推奨します。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Trezor SuiteがRBFのサポートを追加:**
  Trezorのウォレットソフトウェア、
  Trezor Suiteがバージョン21.2.2で[Replace-by-Fee(RBF)のサポート][trezor rbf]を追加しました。
  RBFはデフォルトでオンになっており、Trezorのいくつかのハードウェアデバイスでもサポートされています。

- **Lightning LabsがTerminal Webを発表:**
  Lightning Labsは、最近の[ブログ記事][lightning labs terminal web blog]で、
  WebベースのLightningノードのスコアリングダッシュボードである[Terminal Web][terminal web]について説明しています。

- **Specter v1.4.0リリース:**
  [Specter v.1.4.0][specter v1.4.0]は、BIP125 opt-in [Replace-by-Fee (RBF)][topic rbf]を使用して
  [トランザクションを"キャンセル"する][specter 1197]機能を追加しています。

- **PhoenixがLNURL-payを追加:**
  ACINQのモバイルウォレット[Phoenix][phoenix wallet]は、[v1.4.12リリース][phoenix 1.4.12]で
  [LNURL-pay][lnurl-pay github]プロトコルのサポートを追加しました。

- **JoinMarket v0.8.3リリース:**
  [JoinMarket v0.8.3][joinmarket v0.8.3]では、カスタムのお釣り用アドレスを提供する機能と、
  Electrum互換のsegwitの`signmessage`実装が追加されました。

## Taprootの準備 #1: bech32m送信のサポート

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊シリーズの第１回めをお届けします。*

{% include specials/taproot/ja/00-bech32m.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.13.0-beta][]は、新しいメジャーリリースで、
  [anchor output][topic anchor outputs]をデフォルトのコミットメントトランザクションフォーマットにすることで手数料率の管理を改善し、
  プルーニングされたBitcoinフルノードの使用をサポートし、
  Atomic MultiPath（[AMP][topic multipath payments]）を使用した支払いの送受信を可能にし、
  LNDの[PSBT][topic psbt]の機能を向上させるなどの改良やバグ修正を行っています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #21365][]では、P2TR公開鍵のみを使用したkeypathによる使用と、
  [Tapscript][topic tapscript]使用したscriptpathによる使用の両方について、
  [Taproot][topic taproot]を使用する際の署名を作成する機能が追加されました。
  ウォレットはTaprootを使用する[PSBT][topic psbt]にも署名できますが、
  これはウォレットが必要なすべてのkeypathもしくはscriptpathの情報を既に持っている場合に限られます。
  多少関連するマージ済みのPR [#22156][bitcoin core #22156]では、
  Taprootが有効になった後で、そのkeypathやscriptpathの情報をインポートすることのみ可能です
  （mainnetではブロック{{site.trb}}ですが、Taprootが既に有効になっているテストネットワークでは、
  インポートは現在使用できます）。

- [Bitcoin Core #22144][]は、ピアからのP2Pメッセージの解析と処理および、
  それらのピアへメッセージを送信するメッセージ処理スレッドで、ピアが処理される順序をランダム化します。
  これまでは、メッセージ処理スレッドは、_それらのピアへの接続が最初に確立された順に_
  ラウンドロビンでサービスを提供していました。このPRではロジックを変更し、
  メッセージ処理ループの各反復において、ピアにサービスを提供する順番がランダムになるようにしました。
  ピアは同じ頻度でサービスされますが（ピアは各反復毎に１回サービスされます）、
  サービスされるピアの決定論的な順序に依存する弱点や悪用は回避されます。

- [Bitcoin Core #21261][]は、インバウンド接続保護をより多くのネットワークに拡張することを容易にし、
  そのフレームワークを使用して[I2P][]を保護されたネットワークのリストに追加できるようにしています。
  多様性保護（よく退避保護と呼ばれる）により、Bitcoin Coreが高レイテンシーの接続を切断する際に、
  望ましい特性を持つ少数のピアの接続が維持されるようになります。
  匿名ネットワーク上のピアへの少数の接続を維持することは、
  トランザクション作成者がネットワークの識別子を隠すためにそれらのネットワークを使用できるようにし、
  通常のインターネットプロトコルに加えてこれらのネットワークを介してブロックを受信する機能により、
  いくつかのタイプの[エクリプス攻撃][topic eclipse attacks]を防ぐことができるという理由から、
  非常に望ましいことです。

- [Rust Bitcoin #601][]は、[bech32m][topic bech32]アドレスの解析のサポートを追加し、
  v1以上のネイティブsegwitアドレスをbec32ではなくbech32mでエンコードするよう要求します。

- [BTCPay Server #2450][]は、ユーザーが支払いの受け取りにホットウォレットを選択した場合に、
  [Payjoin][topic payjoin]互換のインボイスの生成をデフォルトにしました。
  *ウォレット作成*画面にあるボタンで、このデフォルト設定を解除することができます。

- [BTCPay Server #2559][]では、
  ユーザーが自分のウォレットから使用するトランザクションに署名する方法の選択をユーザーに案内するための別画面が追加されました。
  ホットウォレットの場合はサーバーが署名するだけですが、鍵が別の場所に保存されているウォレットの場合、
  魅力的で情報量の多いGUIで、リカバリーニーモニックの入力やハードウェア署名デバイスの使用、
  署名ウォレットへ転送するPSBTの生成などの署名オプションをユーザーに案内するようになりました。

{% include references.md %}
{% include linkers/issues.md issues="10823,21365,22156,22144,21261,601,2450,2559" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc5
[trw meeting]: https://gist.githubusercontent.com/ariard/5f28dffe82ddad763b346a2344092ba4/raw/2a8e0d4ff431a225a970d0128aa78616df6b6382/meeting-logs
[additive payment batching]: /ja/cardcoins-rbf-batching/
[riard rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019074.html
[bech32#56]: https://github.com/sipa/bech32/pull/56
[i2p]: https://en.wikipedia.org/wiki/I2P
[phoenix wallet]: https://phoenix.acinq.co/
[phoenix 1.4.12]: https://github.com/ACINQ/phoenix/releases/tag/v1.4.12
[lnurl-pay github]: https://github.com/fiatjaf/lnurl-rfc/blob/master/lnurl-pay.md
[joinmarket v0.8.3]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.8.3
[specter v1.4.0]: https://github.com/cryptoadvance/specter-desktop/releases/tag/v1.4.0
[specter 1197]: https://github.com/cryptoadvance/specter-desktop/pull/1197
[terminal web]: https://terminal.lightning.engineering/
[lightning labs terminal web blog]: https://lightning.engineering/posts/2021-05-11-terminal-web/
[trezor rbf]: https://wiki.trezor.io/Replace-by-fee_(RBF)
