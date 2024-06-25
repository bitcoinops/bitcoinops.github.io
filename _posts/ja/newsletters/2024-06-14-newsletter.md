---
title: 'Bitcoin Optech Newsletter #307'
permalink: /ja/newsletters/2024/06/14/
name: 2024-06-14-newsletter-ja
slug: 2024-06-14-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、量子安全なBitcoinアドレスフォーマットのBIPドラフトの発表と、
Bitcoin Core PR Review Clubの要約、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など、
恒例のセクションが含まれています。

## ニュース

- **量子安全なアドレスフォーマットのBIPドラフト:** 開発者のHunter Beastは、
  バージョン3のsegwitアドレスを[量子耐性][topic quantum resistance]のある署名アルゴリズムに割り当てるための
  [BIPのラフなドラフト][quantum draft]をDelving Bitcoinとメーリングリストの両方に[投稿しました][beast post]。
  BIPドラフトには、問題と予想されるオンチェーンサイズと共にいくつかの可能性のあるアルゴリズムのリンクが掲載されています。
  アルゴリズムの選択と実装の具体的な詳細は、Bitcoinに完全な量子耐性を追加するというビジョンを完全に実現するために必要な追加のBIPと同様に、
  今後の議論に委ねられています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Don't wipe indexes again when continuing a prior reindex][review club
30132]は、[TheCharlatan][gh thecharlatan]によるPRで、
進行中のインデクスの再作成が完了する前にユーザーがノードを再起動した際の起動時間を改善できます。

Bitcoin Coreは5つのインデックスを実装しています。UTXOセットとブロックインデックスは必須ですが、
トランザクションインデックスと[コンパクトブロックフィルター][topic compact block filters]インデックスおよび
coinstatsインデックスはオプションです。`-reindex`を指定して実行すると、すべてのインデックスが消去され、再構築されます。
このプロセスにはかなり時間がかかる可能性があるため、何らかの理由でノードが停止する前に完了する保証はありません。

ノードには最新のUTXOセットとブロックインデックスが必要であるため、
インデックスの再作成のステータスはディスク上に永続化されます。インデックスの再作成を開始した際に、
フラグが[セットされ][reindex flag set]、終了した際にのみフラグは解除されます。
こうすることで、ノードの起動時に、ユーザーが起動オプションとしてフラグを指定しなかった場合でも、
インデックスの再作成の継続を検出することができます。

インデックスの再作成が未完了な状態で（`-reindex`なしで）再起動した場合、
必要なインデックスは保持され、再構築が継続されます。
[Bitcoin Core #30132][]以前では、オプションのインデックスは再度消去されていました。
[Bitcoin Core #30132][]は、必要のないオプションインデックスの消去を回避することで、
ノードの起動をより効率的にすることができます。

{% include functions/details-list.md
  q0="このPRの導入によって動作はどう変わりますか？"
  a0="動作は3つ変わります。まず、このPRの目的どおり、
  インデックスの再作成が完了する前にノードが再起動された場合、オプションのインデックスは再度消去されなくなりました。
  これは、オプションのインデックスの消去動作を必須インデックスに合わせるものです。
  2つめは、ユーザーがGUIからインデックスの再作成を要求した場合、この要求は無視されなくなります。
  [b47bd95][gh b47bd95]で導入された軽微なバグが修正されています。
  3つめは、ログの\"Initializing databases...\\n\"行が削除されています。"
  a0link="https://bitcoincore.reviews/30132#l-19"

  q1="<!--what-are-the-two-ways-an-optional-index-can-process-new-blocks-->オプションのインデックスが新しいブロックを処理する2つの方法とは何ですか？"
  a1="オプションのインデックスが初期化されると、その最も高いブロックが現在のチェーンの先頭と同じかどうかをチェックします。
  同じでない場合は、まず`BaseIndex::StartBackgroundSync()`を使用して、
  欠落しているすべてのブロックをバックグランドで同期します。インデックスがチェーンの先頭に追いついたら、
  `ValidationSignals::BlockConnected`を使用して検証インターフェースを通してそれ以降のすべてのブロックを処理します。"
  a1link="https://bitcoincore.reviews/30132#l-52"

  q2="<!--how-does-this-pr-affect-the-logic-of-optional-indexes-processing-new-blocks-->このPRは、新しいブロックを処理するオプションインデックスのロジックにどう影響しますか？"
  a2="このPR以前は、chainstateを消去せずにオプションインデックスを消去すると、
  これらのインデックスは同期されていないとみなされます。前の質問のとおり、
  これは検証インターフェースに切り替える前に、最初のバックグランド同期を実行することを意味します。
  このPRでは、オプションインデックスは、chainstateと同期されたままであるため、バックグラウンド同期は必要ありません。
  注：バックグラウンド同期はインデックスの再作成が完了した後にのみ開始されますが、
  検証イベントの処理は並行して行われます。"
  a2link="https://bitcoincore.reviews/30132#l-70"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 24.05][]は、この人気のLNノード実装の次期メジャーバージョンのリリースです。
  このリリースには、プルーニングされたフルノードでより良く動作するための改良（[ニュースレター #300][news300 cln prune]参照）、
  プラグインで動作するための`check` RPC（[ニュースレター #302][news302 cln check]参照）、
  安定性の改善（ニュースレター[#303][news303 cln chainlag]や[#304][news304 cln feemultiplier]に掲載されているものなど）、
  [オファー][topic offers]インボイスのより堅牢な配信（[ニュースレター #304][news304 cln offers]参照）、
  `ignore_fee_limits`設定オプションが使用されている場合の
  手数料の過払い問題の修正（[ニュースレター #306][news306 cln overpay]参照）などが含まれています。

- [Bitcoin Core 27.1][]は、この主要なフルノード実装のメンテナンスリリースです。
  複数のバグ修正が含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #29496][]は、`TX_MAX_STANDARD_VERSION`を3に引き上げ、
  [TRUC][topic v3 transaction relay]（Topologically Restricted Until Confirmation）トランザクションを標準にしました。
  トランザクションのバージョンが3の場合、[BIP431][]仕様で定義されているTRUCトランザクションとして扱われます。
  `CURRENT_VERSION`は2のままで、これはウォレットがまだTRUCトランザクションを作成しないことを意味します。

- [Bitcoin Core #28307][]は、P2SH-segwitとbech32の両方でSegwitのredeem scriptに
  520バイトのP2SHの最大スクリプトサイズ制限を課していたバグを修正しました。
  この修正により15個より多くの鍵を含むマルチシグ[アウトプットディスクリプター][topic descriptors]の作成が可能になり（
  `OP_CHECKMULTISIG`のコンセンサスの上限である20個まで可能）、これらのスクリプトの署名や、
  P2SHの制限を超える他のSegwit後のredeem scriptも作成できるようになります。

- [Bitcoin Core #30047][]は、[bech32][topic bech32]エンコーディング方式の`charlimit`のモデルを
  定数90から`Enum`にリファクタリングしました。この変更により、bech32エンコーディング方式を使用するものの、
  [BIP173][]の設計と同じ文字数制限を持たない新しいアドレスタイプを簡単にサポートできます。
  たとえば、118文字を必要とする[サイレントペイメント][topic silent payments]アドレスの解析を有効にすることができます。

- [Bitcoin Core #28979][]は、`sendall` RPCコマンド（[ニュースレター #194][news194 sendall]参照）のドキュメントを更新し、
  承認済みのアウトプットに加えて未承認のお釣りも使用すると記載しています。
  未承認のアウトプットが使用される場合、手数料の不足分が補填されます（[ニュースレター #269][news269 deficit]参照）。
  この項目は、公開後に修正されました。[^correction-28979]

- [Eclair #2854][]と[LDK #3083][]は、[BOLTs #1163][]を実装し、
  [Onionメッセージ][topic onion messages]の配送に失敗した場合の`channel_update`の要件を削除しました。
  この要件により、配送失敗のエラーステータスを生成した中継ノードが`channel_update`フィールドを介して
  [HTLC][topic htlc]の送信者を特定できる攻撃が容易になり、送信者のプライバシーが侵害されます。

- [LND #8491][]は、`lncli` RPCコマンド`addinvoice`と`addholdinvoice`に`cltv_expiry`フラグを追加し、
  ユーザーが`min_final_cltv_expiry_delta`（最終ホップの[CLTV expiry delta][topic cltv expiry delta]）を設定できるようにしました。
  この変更の動機はプルリクエストには記載されていませんが、LNDが最近[BOLT2][]仕様に従うために
  デフォルトを9ブロックから18ブロックに引き上げたことに対応したものと思われます（[ニュースレター #284][news284 lnd final delta]参照）。

- [LDK #3080][]は、`MessagerRouter`の`create_blinded_path`コマンドを2つのメソッドにリファクタリングしました。
  1つはコンパクトな[ブラインドパス][topic rv routing]の作成用で、もう1つは通常のブラインドパスの作成用です。
  これにより、呼び出し元の文脈に応じた選択が可能になります。コンパクトなブラインドパスは、
  ファンディングトランザクション（またはチャネルエイリアス）を参照する通常8バイトのショートチャネルID（SCID）を使用します。
  通常のブラインドパスは、33バイトの公開鍵でLNノードを参照します。コンパクトパスは、
  チャネルが閉じられたり[スプライス][topic splicing]されたりすると古くなってしまう可能性があるため、
  バイトスペースが重視される短期間のQRコードや支払いリンクに使用するのが最適です。
  通常のパスは、長期的な使用に適しています。これは、
  ノード識別子を使用することでノードとピアがチャネルを共有していない場合でもピアにメッセージを転送することができる
  [Onionメッセージ][topic onion messages]ベースの[オファー][topic offers]などを含みます（Onionメッセージはチャネルを必要としないため）。
  `ChannelManager`は、短期の[オファー][topic offers]や返金にコンパクトなブラインドパスを使用し、
  リプライパスには通常の（コンパクトでない）ブラインドパスを使用するようリファクタリングされました。

- [BIPs #1551][]は、DNS Payment Instructionの仕様である[BIP353][]を追加しました。
  これは、DNSのTXTレコード内に[BIP21][] URIをエンコードするプロトコルで、
  人が読みやすくそのような解決を非公開でクエリできるようになります。
  たとえば、`example@example.com`は`example.user._bitcoin-payment.example.com`のようなDNSで解決することができ、
  `bitcoin:bc1qexampleaddress0123456`のようなBIP21 URIを含むDNSSEC署名されたTXTレコードを返します。
  以前の説明については[ニュースレター #290][news290 bip353]を、
  関連するBLIPのマージについては[先週のニュースレター][news306 dns]をご覧ください。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}

## 脚注

[^correction-28979]:
    Bitcoin Core #28979について最初に公開した説明では、`sendall`が未承認のお釣りを使用する変更は、
    動作の変更であると記載していました。（誤りはニュースレターの編集者によるもので）
    Gustavo Floresの元の正しい記述と、誤りを報告してくれたMark "Murch" Erhardtに感謝します。

{% include references.md %}
{% include linkers/issues.md v=2 issues="29496,28307,30047,28979,2854,3083,1163,8491,3080,3072,1551,30132" %}
[beast post]: https://delvingbitcoin.org/t/proposing-a-p2qrh-bip-towards-a-quantum-resistant-soft-fork/956
[quantum draft]: https://github.com/cryptoquick/bips/blob/p2qrh/bip-p2qrh.mediawiki
[core lightning 24.05]: https://github.com/ElementsProject/lightning/releases/tag/v24.05
[Bitcoin Core 27.1]: https://bitcoincore.org/bin/bitcoin-core-27.1/
[news306 cln overpay]: /ja/newsletters/2024/06/07/#core-lightning-7252
[news304 cln feemultiplier]: /ja/newsletters/2024/05/24/#core-lightning-7063
[news304 cln offers]: /ja/newsletters/2024/05/24/#core-lightning-7304
[news303 cln chainlag]: /ja/newsletters/2024/05/17/#core-lightning-7190
[news302 cln check]: /ja/newsletters/2024/05/15/#core-lightning-7111
[news300 cln prune]: /ja/newsletters/2024/05/01/#core-lightning-7240
[review club 30132]: https://bitcoincore.reviews/30132
[gh thecharlatan]: https://github.com/TheCharlatan
[gh b47bd95]: https://github.com/bitcoin/bitcoin/commit/b47bd959207e82555f07e028cc2246943d32d4c3
[reindex flag set]: https://github.com/bitcoin/bitcoin/blob/457e1846d2bf6ef9d54b9ba1a330ba8bbff13091/src/node/blockstorage.cpp#L58
[news198 sendall]: /ja/newsletters/2022/04/06/#bitcoin-core-24118
[news290 bip353]: /ja/newsletters/2024/02/21/#dns-bitcoin
[news194 sendall]: /ja/newsletters/2022/04/06/#bitcoin-core-24118
[news269 deficit]: /ja/newsletters/2023/09/20/#bitcoin-core-26152
[news284 lnd final delta]: /ja/newsletters/2024/01/10/#lnd-8308
[news306 dns]: /ja/newsletters/2024/06/07/#blips-32
