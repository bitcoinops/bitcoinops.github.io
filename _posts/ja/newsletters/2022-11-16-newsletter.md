---
title: 'Bitcoin Optech Newsletter #226'
permalink: /ja/newsletters/2022/11/16/
name: 2022-11-16-newsletter-ja
slug: 2022-11-16-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinで汎用的なスマートコントラクトを可能にする提案と、
LNのチャネルジャミング攻撃への対処に関する論文を掲載しています。
また、サービスやクライアントソフトウェアの変更や、新しいリリースおよびリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更を含む
恒例のセクションも含まれています。

## ニュース

- **CovenantによるBitcoinの汎用的なスマートコントラクト:** Salvatore Ingalaは、
  [マークルツリー][merkle trees]を使用して、
  あるオンチェーントランザクションから別のトランザクションに状態を遷移させることができる
  スマートコントラクトの作成を可能にする新しいタイプの[Covenant][topic covenants]の提案（ソフトフォークを必要とする）を
  Bitcoin-Devメーリングリストに[投稿しました][ingala matt]。
  Ingalaの投稿の例では、2人のユーザーがチェスのゲームで賭けをし、
  コントラクトにゲームのルールを保持し、ボード上のすべての駒の位置を状態として保持し、
  各オンチェーントランザクションでその状態を更新することができるようになります。
  もちろん、よく設計されたコントラクトであれば、ゲーム終了時の決済トランザクションのみをオンチェーンにし、
  オフチェーンでゲームを行うことができます（ペイメントチャネルなど、別のオフチェーン構成でゲームが行われた場合、
  オフチェーンのままでも可能）。

  Ingalaは、この研究が[Joinpool][topic joinpools]やOptimistic rollup（[ニュースレター #222][news222 rollup]参照）、
  その他のステートフルな構成の設計にどのように役立つか説明しています。

- **<!--paper-about-channel-jamming-attacks-->チャネルジャミング攻撃に関する論文:**
  Clara ShikhelmanとSergei Tikhomirovは、
  [チャネルジャミング攻撃][topic channel jamming attacks]の解決策について書いた[論文][st unjam paper]を
  Lightning-Devメーリングリストに[投稿しました][st unjam post]。
  2015年に初めて報告されたこの攻撃は、攻撃者にとってごくわずかなコストで、
  大量のチャネルを長期間使用不能にすることができます。

  著者らは、ジャミング攻撃を2つのタイプに分類しています。
  1つは、チャネルの限られたスロットや支払い転送用の資金を長期間使用できなくする*スロー・ジャミング*で、
  正当な支払いではほとんど発生しません。もう1つは、スロットや資金が短時間だけブロックされる*ファスト・ジャミング*で、
  これは通常の支払いで頻繁に発生し、ファスト・ジャミングを緩和するのは難しいかもしれません。

  彼らは2つの解決策を提案しています:

    - *<!--unconditional-fees-->無条件の手数料：* （以前のニュースレターに掲載した*前払い手数料*と同じで）
      支払いが受信者まで届かなかった場合でも、転送ノードにいくらかの手数料が支払われるというものです。
      著者らは、支払額に依存しない*基本*前払い手数料と、支払額に応じて増加する*比例*前払い手数料の両方を提案しています。
      2つの別々の手数料は、HTLCスロットへの妨害と流動性への妨害に対処するものです。
      手数料はファスト・ジャミングを防止するためのものなので、非常に少額にすることができます。
      ファストジャミングでは、偽の支払いを頻繁に再送信する必要があり、
      その際に毎回前払い手数料を支払う必要がでてくるため、攻撃者のコストが上昇します。

    - *<!--local-reputation-with-forwarding-->転送を伴うローカルのレピュテーション：*
      各ノードは、転送された支払いが保留されている期間と、徴収した転送手数料に関するピアの統計情報を保持します。
      手数料あたりの保留時間が高い場合、そのピアを高リスクとみなし、
      ローカルノードのスロットと資金を限定します。それ以外の場合は、ピアを低リスクとみなします。

      ノードが低リスクとみなすピアから転送された支払いを受け取ると、
      そのピアが支払いを低リスクとしてタグ付けしているかどうかを確認します。
      上流の転送ノードと、支払いの両方が低リスクである場合、その支払いは利用可能なスロットと資金を使用することができます。

  この論文は、メーリングリスト上でいくつかの議論を呼び、特にローカルレピュテーション方式が賞賛されました。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Sparrow 1.7.0リリース:**
  [Sparrow 1.7.0][sparrow 1.7.0]では、[RBF(Replace-By-Fee)][topic rbf]対応による
  トランザクションキャンセル機能のサポートやその他のアップデートが行われました。

- **Blixt WalletがTaprootをサポート:**
  [Blixt Wallet v0.6.0][blixt v0.6.0]は、[Taproot][topic taproot]アドレスへの送受信をサポートしました。

- **Specter-DIY v1.8.0リリース:**
  [Specter-DIY v1.8.0][]は、[再現可能なビルド][topic reproducible builds]と
  [Taproot][topic taproot]のkeypathによる支払いをサポートしました。

- **Trezor Suiteがコインコントロール機能を追加:**
  Trezorは[最近のブログ記事][trezor coin control]で、Trezor
  Suiteが[コインコントロール][topic coin selection]機能をサポートしたことを発表しました。

- **StrikeがTaprootへの送金をサポート:**
  Strikeのウォレットで、[bech32m][topic bech32]アドレスへの送金ができるようになりました。

- **取引所KolliderがLightningのサポートを開始:**
  Kolliderは、LNの入出金機能を備えた取引所とブラウザベースのLightningウォレットを[発表しました][kollider launch]。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 24.0 RC4][]は、ネットワークで最も広く使われているフルノード実装の次期バージョンのリリース候補です。
  [テストのガイド][bcc testing]が利用できるようになっています。

  **警告:** このリリース候補には、`mempoolfullrbf`設定オプションが含まれており、
  以前のニュースレター[#222][news222 rbf]と[#223][news223 rbf]で説明したように、
  一部のプロトコルおよびアプリケーション開発者は、マーチャントサービスに対して問題を引き起こす可能性があると考えています。
  また、[ニュースレター #224][news224 rbf]に掲載しているように、トランザクションリレーにも問題が発生する可能性があります。

- [LND 0.15.5-beta.rc1][]は、LNDのメンテナンスリリースのリリース候補です。
  予定されているリリースノートによると、小さなバグ修正のみが含まれているます。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。

- [Core Lightning #5681][]は、RPCのJSON出力をサーバー側でフィルタリングする機能を追加しました。
  サーバー側でのフィルタリングにより、帯域幅の制限されたリモート接続使用時に、
  不要なデータの送信を回避することができます。将来的には、
  いくつかのRPCはフィルタリングされたデータの計算を回避できるようになり、
  より速く結果を返せるようになる可能性があります。
  フィルタリングはすべてのRPC、特にプラグインによって提供されるRPCについて、
  保証されているわけではありません。フィルタリングが利用できない場合、
  フィルタリングされていない完全な出力が返されます。
  詳細は、追加された[ドキュメント][cln filter doc]をご覧ください。

- [Core Lightning #5698][]は、実験的な開発者モードを更新し、
  任意のサイズのonionでラップされたエラーメッセージを受信できるようになりました。
  BOLT2は、現在256バイトのエラーを推奨していますが、それ以上のエラーメッセージを禁止しておらず、
  LNの最新のTLV（Type-Length-Value）セマンティクスを使用してエンコードされた
  1024バイトのエラーメッセージの使用を推奨する[BOLTs #1021][]が公開されています。

- [Core Lightning #5647][]は、recklessプラグインマネージャーを追加しました。
  このプラグインマネージャーは、`lightningd/plugins`リポジトリからCLNのプラグインを名前でインストールするために使用されます。
  プラグインマネージャーは、依存関係を自動的にインストールし、インストールの検証をします。
  また、プラグインの有効化や無効化およびプラグインの状態を設定ファイルに保存することができます。

- [LDK #1796][]は、`Confirm::get_relevant_txids()`を更新し、
  txidだけでなく参照されたトランザクションを含むブロックのハッシュも返すようにしました。
  これは、ブロックチェーンの再編成がいつトランザクションの承認数を変更したかを、
  より上位のアプリケーションが判断しやくします。もし、あるtxidのブロックハッシュが変わったとしたら、
  それは再編成が発生したということになります。

- [BOLTs #1031][]は、[簡略化されたマルチパスペイメント][topic multipath payments]を使用する際、
  支払人が受取人に要求された金額より少し多めに支払うことを許可します。
  これは、選択された支払い経路がルーティング可能な最小額のチャネルを使用する場合に必要になることがあります。
  たとえば、アリスが合計900 satを2つに分けたいものの、
  選択した経路が両方とも最低500 satを必要とする場合です。この仕様変更により、
  アリスは2つの500 satの支払いの送信ができるようになり、自分の好きな経路を使用するために合計100 satの過払いを選択することができます。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5681,5698,5647,1796,1031,1021" %}
[bitcoin core 24.0 rc4]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[lnd 0.15.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc1
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /ja/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /ja/newsletters/2022/10/26/#rbf
[news224 rbf]: /ja/newsletters/2022/11/02/#mempool
[cln filter doc]: https://github.com/rustyrussell/lightning/blob/a6f38a2c1a47c5497178c199691047320f2c55bc/doc/lightningd-rpc.7.md#field-filtering
[ingala matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-November/021182.html
[merkle trees]: https://en.wikipedia.org/wiki/Merkle_tree
[news222 rollup]: /ja/newsletters/2022/10/19/#validity-rollups
[st unjam post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-November/003740.html
[st unjam paper]: https://raw.githubusercontent.com/s-tikhomirov/ln-jamming-simulator/master/unjamming-lightning.pdf
[sparrow 1.7.0]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.0
[blixt v0.6.0]: https://github.com/hsjoberg/blixt-wallet/releases/tag/v0.6.0
[Specter-DIY v1.8.0]: https://github.com/cryptoadvance/specter-diy/releases/tag/v1.8.0
[trezor coin control]: https://blog.trezor.io/coin-control-in-trezor-suite-92f3455fd706
[kollider launch]: https://blog.kollider.xyz/announcing-kolliders-launch/
