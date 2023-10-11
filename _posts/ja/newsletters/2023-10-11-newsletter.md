---
title: 'Bitcoin Optech Newsletter #272'
permalink: /ja/newsletters/2023/10/11/
name: 2023-10-11-newsletter-ja
slug: 2023-10-11-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、提案されている`OP_TXHASH` opcodeの仕様のリンクに加えて、
Bitcoin Core PR Review Clubミーティングの概要、新しいリリースとリリース候補のリンクおよび、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など、恒例のセクションが掲載されています。

## ニュース

- **`OP_TXHASH`の仕様の提案:** Steven Rooseは、
  新しい`OP_TXHASH` opcodeの[BIPドラフト][bips #1500]をBitcoin-Devメーリングリストに[投稿しました][roose txhash]。
  このopcodeの背後にあるアイディアは以前も議論されましたが（[ニュースレター #185][news185 txhash]参照）、
  これはアイディアの最初の仕様です。このopcodeがどのように機能するかを正確に記述するだけでなく、
  このopcodeが呼び出されるたびにフルノードが最大数MBのデータをハッシュする必要がある可能性など、
  いくつかの潜在的な欠点を軽減することも検討されています。Rooseのドラフトには、
  opcodeのサンプル実装が含まれています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*


[util: Type-safe transaction identifiers][review club 28107]は、
Niklas Gögge (dergoegge)によるPRで、
`txid`（トランザクション識別子またはsegwitのwitnessデータを含まないハッシュ）と
`wtxid`（同じだがwitnessデータを含む）に別々の型を導入することで、
両方とも`uint256`（SHA256ハッシュを含むことができる256ビットの整数）で表現されるのに比べて型の安全性を向上させるものです。
このPRは、運用上何の影響もないはずです。このPRの目的は、もう一方のトランザクションIDが意図されていたのに、
別のトランザクションIDが使用されるという将来のプログラミングのミスを防止することです。
このようなエラーは、コンパイル時に検出されるようになります。

混乱を最小限に抑え、レビューを容易にするため、これらの新しい型は、
初期はコードは1つの領域（トランザクションの「オーファン」）のみで使用されます。
将来のPRで、コードベースの他の領域でも新しい型を使用する予定です。

{% include functions/details-list.md
  q0="トランザクション識別子が型安全であるとはどういうことですか？
      なぜそれが重要で役に立つのですか？デメリットはありますか？"
  a0="トランザクション識別子には2つの意味（`txid`か`wtxid`）のいずれかがあるため、
      型安全とは、識別子が間違った意味で使用されることがないという特性です。
      つまり、`wtxid`が期待される場面で`txid`を使用することはできず、その逆も同様で、
      これはコンパイラの標準型チェックによって強制されます。"
  a0link="https://bitcoincore.reviews/28107#l-38"

  q1="`uint256`を _継承する_ 新しい型クラス`Txid`および`Wtxid`ではなく、
      `uint256`を _含める_ （ラップする）べきですか？そのトレードオフは何ですか？"
  a1="これらのクラスをそうすることも可能ですが、コードチャーン（Code Churn）がさらに多くなります（
      さらに多くの行のソースを触る必要があります）。"
  a1link="https://bitcoincore.reviews/28107#l-39"

  q2="なぜ実行時ではなくコンパイル時に型を強制する方が良いのですか？"
  a2="開発者は、実行時にバグを発見するために大規模なテスト・スイートを書くことに依存するよりも
      （そしてこれらのテストはまだいくつかのエラーを見落としているかもしれません）、
      コーディングしている時に素早くエラーを発見することができます。
      しかし、そもそも型安全性では誤った型のトランザクションIDの一貫した使用は防止されないので、テストは依然として有用です。"
  a2link="https://bitcoincore.reviews/28107#l-67"

  q3="概念的に、トランザクションを参照する新しいコードを書いている時、
      いつ`txid`を使用して、いつ`wtxid`を使用する必要がありますか？
      コード内で一方を他方の代わりに使用すると非常にまずい例があれば教えてください。"
  a3="一般的には、トランザクション全体にコミットするため、`wtxid`の使用が望ましいです。
      重要な例外は、使用する各インプットからアウトプット（UTXO）への`prevout`による参照で、
      これは`txid`でトランザクションを指定する必要があります。
      一方を使用し、他方を使用しないことが重要な例を[ここに][wtxid example]示します（詳細については、
      [ニュースレター #104][news104 wtxid]参照ください）。"
  a3link="https://bitcoincore.reviews/28107#l-85"

  q4="`uint256`の代わりに`transaction_identifier`を使用することで、どのような具体的な方法で既存のバグを発見したり、
      新しいバグの発生を防ぐことができますか？逆にこの変更によって新たなバグが発生する可能性はありますか？"
  a4="このPRがなければ、`uint256`引数を取る関数（ブロックIDのハッシュなど）に`txid`が渡される可能性があります。
      このPRがあれば、これはコンパイル時にエラーになります。"
  a4link="https://bitcoincore.reviews/28107#l-128"

  q5="[`GenTxid`][GenTxid]クラスは既に存在します。これはどう型の正確性を強制しているのでしょうか？
      また、このPRのアプローチとの違いは何ですか？"
  a5="このクラスは、ハッシュとそのハッシュが`wtxid`なのか`txid`なのかを示すフラグを含むので、
      2つの異なる型ではなく1つの型です。これにより型チェックが可能になりますが、明示的にプログラムする必要があり、
      さらに重要なことに、型チェックはコンパイル時ではなく実行時にのみ行われます。
      これは、どちらの種類の識別子であってもいい入力を受け取りたいというよくあるユースケースを満たします。
      そのため、このPRでは`GenTxid`は削除されません。
      将来的には、`std::variant<Txid, Wtxid>`が良い選択肢になるかもしれません。"
  a5link="https://bitcoincore.reviews/28107#l-161"

  q6="C++では整数は型でありクラスではないとすると、`transaction_identifier`はどのようにして`uint256`をサブクラス化できるのでしょうか？"
  a6="`uint256`は組み込み型ではなく、クラスだからです。（C++の最大の組み込み整数型は64ビットです。）"
  a6link="https://bitcoincore.reviews/28107#l-194"

  q7="`uint256`は、その他の点では、たとえば`uint64_t`と同じように動作しますか？"
  a7="いいえ。（`uint256`の主な用途である）ハッシュでは意味をなさないため、
      算術演算は`uint256`では許可されていません。この名前は誤解を招きます。
      これは実際には単なる256ビットの塊です。別の`arith_uint256`では算術演算が可能です（たとえば、PoWの計算で使われます）。"
  a7link="https://bitcoincore.reviews/28107#l-203"

  q8="なぜ`transaction_identifier`は完全に新しい型ではなく、`uint256`をサブクラスにしているのですか？"
  a8="これにより、明示的および暗黙的な変換を使用して、
     新しいより厳密な`Txid`型または`Wtxid`型を使用するようにリファクタリングをする適切な時期が来るまで、
     `uint256`形式のトランザクションIDを期待しているコードを変更しないままにすることができます。"
  a8link="https://bitcoincore.reviews/28107#l-219"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LDK 0.0.117][]は、LN対応アプリケーションを構築するためのこのライブラリのリリースです。
  このリリースには、直近のリリースに含まれていた[アンカー・アウトプット][topic anchor outputs]に関する
  セキュリティバグ修正が含まれています。また、経路探索の改善や、
  [ウォッチタワー][topic watchtowers]のサポートの改善、
  新規チャネルの[バッチ][topic payment batching]ファンディングを可能にするなど、
  いくつかの機能とバグ修正が含まれています。

- [BDK 0.29.0][]は、ウォレットアプリケーションを構築するためのこのライブラリのリリースです。
  このリリースでは、依存関係を更新し、
  ウォレットがマイナーのコインベーストランザクションから複数のアウトプットを受け取った場合に影響がある（おそらく稀な）バグを修正しています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #27596][bitcoin core #27596]は、
  [assumeutxo][topic assumeutxo]プロジェクトの最初のフェーズを終了します。
  これには、assumedvalidなスナップショットのチェーンステートの使用と、
  バックグラウンドでの完全な検証同期の両方に必要な残りの変更が含まれています。
  UTXOスナップショットをRPC（`loadtxoutset`）を介してロードできるようにし、
  `assumeutxo`パラメーターをchainparamsに追加します。

    この機能セットは[アクティベート][bitcoin core #28553]されるまでmainnetで利用できませんが、
    このマージは複数年にわたる取り組みの集大成となります。[2018年に提案され][assumeutxo core dev]、
    [2019年に正式化された][assumeutxo 2019 mailing list]このプロジェクトは、
    ネットワークに初めて参加する新しいフルノードのユーザーエクスペリエンスを大幅に改善します。
    このマージに、[Bitcoin Core #28590][bitcoin core #28590]、[#28562][bitcoin core #28562]、
    [#28589][bitcoin core #28589]が続きます。

- [Bitcoin Core #28331][]、[#28588][bitcoin core #28588]、
  [#28577][bitcoin core #28577]および[GUI #754][bitcoin core gui #754]は、
  [BIP324][]で定義されている[バージョン2暗号化P2Pトランスポート][topic v2 p2p transport]のサポートを追加します。
  この機能は、現在デフォルトで無効になっていますが、`-v2transport`オプションを使用して有効にできます。

    暗号化トランスポートは、（ISPなどの）受動的な監視者が、
    ノードがどのトランザクションをピアに中継するかを直接判断するのを防止することで、
    Bitcoinユーザーのプライバシーを向上させるのに役立ちます。
    また、暗号化トランスポートを使用して、セッションIDを比較することで中間者の監視を阻止することもできます。
    将来的には、他の[機能][topic countersign]の追加により、
    軽量クライアントがP2P暗号化接続を介して信頼できるノードに安全に接続できるようになる可能性があります。

- [Bitcoin Core #27609][]により、`submitpackage` RPCが非regtestネットワークで利用可能になりました。
  ユーザーは、このRPCを使用して、未承認の親を持つ単一のトランザクションのパッケージを送信することができます。
  この時、どの親も別の親のアウトプットを使用しません。子トランザクションは、
  ノードの動的なmempoolの最小手数料率を下回る親のCPFPに使用できます。ただし、
  [パッケージリレー][topic package relay]はまだサポートされていないため、
  これらのトランザクションがネットワーク上の他のノードに伝播するとは限りません。

- [Bitcoin Core GUI #764][]は、GUIでレガシーウォレットを作成する機能が削除されました。
  レガシーウォレットを削除する機能は削除されます。Bitcoin Coreの将来のバージョンでは、
  新しく作成されるウォレットはすべて[ディスクリプター][topic descriptors]ベースになります。

- [Core Lightning #6676][]は、ノードのウォレットにオンチェーンで資金を受け取るためのアウトプットを[PSBT][topic psbt]に追加する
  新しい`addpsbtoutput` RPCを追加しました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27596,28590,28562,28589,28331,28588,28577,28553,754,27609,764,6676,1500" %}
[roose txhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021975.html
[news185 txhash]: /ja/newsletters/2022/02/02/#ctv-apo
[ldk 0.0.117]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.117
[bdk 0.29.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.29.0
[review club 28107]: https://bitcoincore.reviews/28107
[wtxid example]: https://github.com/bitcoin/bitcoin/blob/3cd02806ecd2edd08236ede554f1685866625757/src/net_processing.cpp#L4334
[GenTxid]: https://github.com/bitcoin/bitcoin/blob/dcfbf3c2107c3cb9d343ebfa0eee78278dea8d66/src/primitives/transaction.h#L425
[news104 wtxid]: /en/newsletters/2020/07/01/#bips-933
[assumeutxo core dev]: https://btctranscripts.com/bitcoin-core-dev-tech/2018-03/2018-03-07-priorities/#:~:text=“Assume%20UTXO”
[assumeutxo 2019 mailing list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016825.html
