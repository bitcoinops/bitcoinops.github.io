---
title: 'Bitcoin Optech Newsletter #305'
permalink: /ja/newsletters/2024/05/31/
name: 2024-05-31-newsletter-ja
slug: 2024-05-31-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、サイレントペイメント用の軽量クライアントプロトコルの提案と、
Taproot用の2つの新しいディスクリプターの提案、
重複する機能を持つopcodeをソフトフォークで追加するかどうかについての議論のリンクを掲載しています。
また、Bitcoin Stack Exchangeから人気のある質問とその回答、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャの注目すべき変更を含む恒例のセクションも含まれています。

## ニュース

- **<!--light-client-protocol-for-silent-payments-->サイレントペイメント用の軽量クライアント:**
  Setor Blagogeeは、軽量クライアントが[サイレントペイメント][topic silent payments]（SP）を受け取るための
  プロトコルのドラフト仕様をDelving Bitcoinに[投稿しました][blagogee lcsp]。
  いくつかの暗号プリミティブを追加するだけで、どんなウォレットソフトウェアでもSPを送信できるようになりますが、
  サイレントペイメントを受信するためには、それらのプリミティブだけでなく、
  SPと互換性のあるすべてのオンチェーントランザクションに関する情報にアクセスする機能も必要です。
  これは、Bitcoin Coreなど、すでにすべてのオンチェーントランザクションを処理しているフルノードにとっては簡単ですが、
  通常、要求するトランザクションデータの量を最小限にしようとすると軽量クライアントには追加の機能が必要です。

  基本プロトコルでは、サービスプロバイダーがSPで使用できる公開鍵のブロックごとのインデックスを構築します。
  クライアントは、そのインデックスと、同じブロックの[コンパクトブロックフィルター][topic compact block filters]をダウンロードします。
  クライアントは各鍵（または鍵のセット）のローカルtweakを計算し、ブロックフィルターに対応する調整された鍵への支払いが含まれているかどうかを判断します。
  含まれている場合は、ブロックレベルのデータを追加でダウンロードして、受け取った金額と、
  後で支払いで使用する際の方法を知ることができます。

- **RAW Taprootディスクリプター:** Oghenovo Usiwomaは、
  [Taproot][topic taproot]の使用条件を構築するために提案された2つの新しい[ディスクリプター][topic descriptors]について
  Delving Bitcoinに[投稿しました][usiwoma descriptors]。

  - `rawnode(<hash>)`は、内部ノードまたはリーフノードのマークルツリーノードのハッシュを引数にとります。
    これにより、ウォレットや他のスキャンプログラムは、使用するTapscriptを正確に知らなくても、
    特定のアウトプットスクリプトを見つけることができます。これは、ほとんどの状況において、
    お金を受け取る上で安全ではありません。未知のスクリプトは、使用できなかったり、第三者が資金を使用できる可能性があります。
    しかし、安全なプロトコルもあります。

    Anthony Townsは、アリスがボブに自分の資金を相続できるようにしたいという[例][towns descriptors]を示しています。
    アリスの使用条件ではアリスはノードハッシュのみをボブに提供し、
    ボブの相続条件ではアリスは彼に（おそらく一定期間が経過するまで使用できないようにするタイムロックを含む）
    テンプレート化されたディスクリプターを提供します。
    これは、ボブにとっては資金は彼のものではないため安全です。
    ボブに他の使用条件を事前に明かす必要がないためアリスのプライバシーにも適しています（ただし、
    ボブはアリスのオンチェーントランザクションからそれらを知る可能性があります）。

  - `rawleaf(<script>,[version])`は、
    テンプレート化されたディスクリプターを使って表現できないスクリプトを含めるための既存の`raw`ディスクリプターに似ています。
    主な違いは、[BIP342][]で定義されている[Tapscript][topic tapscript]のデフォルトとは異なる
    Tapleafバージョンを示す機能が含まれている点です。

  Usiwomaの投稿には、以前の議論と彼が作成した[参照実装][usiwoma poc]への例とリンクが記載されています。

- **<!--should-overlapping-soft-fork-proposals-be-considered-mutually-exclusive-->重複するソフトフォークの提案は相互に排他的であるべきか？**
  Pierre Rochardは、同様のコストで同じ機能の多くを提供できるソフトフォークの提案は相互に排他的であると考えるべきなのか、
  それとも複数の提案を有効化して開発者が好きな方を使えるようにするのが理にかなっているのか、[質問しています][rochard exclusive]。

  Anthony Townsは、重複する機能それ自体は問題ではないが、
  誰もが代替案を好むことで使用されない機能は、いくつかの問題を引き起こす可能性があることを示唆するなど、
  複数のポイントに[回答しています][towns exclusive]。彼は、
  特定の提案に好意的な人は、試作段階のソフトウェアを使用してその機能をテストし、
  特にその機能をBitcoinに追加できる他の方法と比較して、その使い勝手を確かめることを提案しています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--what-s-the-smallest-possible-coinbase-transaction-block-size-->コインベーストランザクション/ブロックの最小サイズは？]({{bse}}122951)
  Antoine Poinsotは、コインベーストランザクションに関する最小限の制限について説明し、
  現在のブロック高で有効なBitcoinブロックの最小サイズは145バイトであると結論付けています。

- [スクリプトの数値エンコーディングCScriptNumを理解する]({{bse}}122939)
  Antoine Poinsotは、CScriptNumがBitcoinのスクリプト内で整数をどのように表現するか説明し、
  エンコーディング例をいくつか示し、2つのシリアライゼーション実装のリンクを掲載しています。

- [BTCのウォレットアドレスを公開し、それが何BTC持っているか隠す方法はありますか？]({{bse}}122786)
  Vojtěch Strnadは、[サイレントペイメント][topic silent payments]の再利用可能な支払いアドレスを使用すると、
  オブザーバーがそれに支払われるトランザクションを関連付けることなく、公開ペイメント識別子を提示できると指摘しています。

- [regtestにおける手数料率増加のテスト]({{bse}}122837)
  Ava Chowは、regtestにおいて、Bitcoin Coreのテストフレームワークを使用し、手数料率の高い環境をシミュレートするために、
  `-maxmempool`を低い値に、`-datacarriersize`を高い値に設定することを推奨しています。

- [なぜ私のP2P_V2ピアはv1で接続されているのでしょうか？]({{bse}}122774)
  Pieter Wuilleは、ユーザーがBIP324[暗号化トランスポート][topic v2 p2p transport]をサポートするピアが
  v1非暗号化接続で接続されているのを確認した原因は、古いピアaddr情報であったのではないかという仮設を立てています。

- [P2PKHトランスポートは非圧縮鍵のハッシュに送信しますか、それとも圧縮鍵のハッシュに送信しますか？]({{bse}}122875)
  Pieter Wuilleは、圧縮公開鍵と非圧縮公開鍵の両方を使用できるため、異なるアドレスが生成されると指摘し、
  P2WPKHはポリシーにより圧縮公開鍵のみをサポートし、P2TRは[x座標のみの公開鍵][topic X-only public keys]を使用すると付け加えています。

- [Bitcoinネットワークにブロックをブロードキャストするにはどのような方法がありますか？]({{bse}}122953)
  Pieter Wuilleは、P2Pネットワーク上でブロックを通知する4つの方法について説明しています：
  [BIP130][]を使用する方法、[BIP152][]を使用する方法、
  [未承諾で`block`メッセージ][unsolicited `block` messages]を送信する方法、
  および古い`inv` / `getdata` / `block`メッセージフローを使用する方法です。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND v0.18.0-beta][]は、この人気のLNノード実装の最新のメジャーリリースです。
  [リリースノート][lnd rn]によると、_インバウンドルーティング手数料_
  の実験的なサポートが追加され（[ニュースレター #297][news297 inbound]参照）、
  [ブラインドパス][topic rv routing]用の経路探索が利用可能になり、
  [ウォッチタワー][topic watchtowers]が[Simple Taproot Channel][topic simple taproot channels]をサポートし、
  暗号化されたデバッグ情報の送信が効率化されました（[ニュースレター #285][news285 encdebug]参照）。
  その他にも多くの機能が追加され、多くのバグが修正されています。

- [Core Lightning 24.05rc2][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [Bitcoin Core #29612][]は、`dumptxoutset` RPCを使用したUTXOセットのダンプ出力のシリアライゼーションフォーマットを更新しました。
  これにより、17.4%のスペースの最適化が実現します。`loadtxoutset` RPCは、
  UTXOセットのダンプファイルをロードする際にこの新しい形式を期待し、古い形式はサポートされなくなりました。
  以前の`dumptxoutset`に関してはニュースレター[#178][news178 txoutset]および[#72][news72 txoutset]をご覧ください。

- [Bitcoin Core #27064][]は、Windowsのデフォルトのデータディレクトリを、
  新規インストールの場合のみ、`C:\Users\Username\AppData\Roaming\Bitcoin`から
  `C:\Users\Username\AppData\Local\Bitcoin`に変更しました。

- [Bitcoin Core #29873][]は、[TRUC（Topologically Restricted Until Confirmation）][topic v3 transaction
  relay]トランザクション（v3トランザクション）に10kvBのデータweight制限を導入し、
  [トランザクションPinning][topic transaction pinning]攻撃の潜在的な緩和コストを削減し、
  ブロックテンプレート構築の効率を向上し、特定のデータ構造に厳しいメモリ制限を課します。
  v3トランザクションは、標準トランザクションのサブセットで、トランザクションPinning攻撃を克服するコストを最小限に抑えながら、
  トランザクションの置換を可能にするよう設計された追加ルールを備えています。
  v3トランザクションの詳細については、ニュースレター[#289][news289 v3]および[#296][news296 v3]をご覧ください。

- [Bitcoin Core #30062][]は、ピアノードのネットワークアドレスに関する情報を返すコマンドである
  `getrawaddrman` RPCに2つの新しいフィールド`mapped_as`と`source_mapped_as`を追加しました。
  新しいフィールドは、ピアとそのソースにマップされたASN（自律システム番号）を返します。
  これにより、どのISPがどのIPアドレスを管理しているかに関するおおよその情報が提供され、
  Bitcoin Coreの[エクリプス攻撃][topic eclipse attacks]に対する耐性が向上します。
  ニュースレター[#52][news52 asmap]、[#83][news83 asmap]、[#101][news101 asmap]、[#290][news290 asmap]もご覧ください。

- [Bitcoin Core #26606][]は、Berkeleyデータベース（BDB）ファイルパーサーの独立した実装である
  `BerkeleyRODatabase`を導入しました。これにより、BDBファイルへの読み取り専用アクセスが提供されます。
  重いBDBライブラリを必要とせずに、レガシーウォレットのデータを抽出できるようになり、
  [ディスクリプター][topic descriptors]ウォレットへの移行が容易になります。
  `wallettool`の`dump`コマンドは、`BerkeleyRODatabase`を使用するように変更されました。

- [BOLTs #1092][]は、使用されておらずサポートされなくなった機能`initial_routing_sync`と
  `option_anchor_outputs`を削除してライトニングネットワーク（LN）の仕様を整理しました。
  次の3つの機能は、現在すべてのノードに存在するものと想定されています：
  任意のデータを特定のホップにリレーする可変サイズの[Onionメッセージ][topic onion messages]のための`var_onion_optin`、
  ノードが再接続時に最新のチャネル状態に関する情報を要求するための`option_data_loss_protect`、
  ノードがチャネルの更新の度にノードの非[HTLC][topic htlc]資金を同じアドレスに送信するようコミットする`option_static_remotekey`。
  特定のゴシップ要求のための`gossip_queries`機能が変更され、
  これをサポートしていないノードは、他のノードから照会を受け付けないようになりました。
  ニュースレター[#259][news259 cleanup]参照。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-06-04 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29612,27064,29873,30062,26606,1092" %}
[lnd v0.18.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta
[blagogee lcsp]: https://delvingbitcoin.org/t/silent-payments-light-client-protocol/891/
[usiwoma descriptors]: https://delvingbitcoin.org/t/tr-rawnode-and-rawleaf-support/901/
[towns descriptors]: https://delvingbitcoin.org/t/tr-rawnode-and-rawleaf-support/901/6
[usiwoma poc]: https://github.com/Eunovo/bitcoin/tree/wip-tr-raw-nodes
[rochard exclusive]:  https://delvingbitcoin.org/t/mutual-exclusiveness-of-op-codes/890/3
[towns exclusive]: https://delvingbitcoin.org/t/mutual-exclusiveness-of-op-codes/890/3
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.18.0.md
[core lightning 24.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.05rc2
[news297 inbound]: /ja/newsletters/2024/04/10/#lnd-6703
[news285 encdebug]: /ja/newsletters/2024/01/17/#lnd-8188
[unsolicited `block` messages]: https://developer.bitcoin.org/devguide/p2p_network.html#block-broadcasting
[news72 txoutset]: /ja/newsletters/2019/11/13/#bitcoin-core-16899
[news178 txoutset]: /ja/newsletters/2021/12/08/#bitcoin-core-23155
[news289 v3]: /ja/newsletters/2024/02/14/#bitcoin-core-28948
[news296 v3]: /ja/newsletters/2024/04/03/#bitcoin-core-29242
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news83 asmap]: /ja/newsletters/2020/02/05/#bitcoin-core-16702
[news101 asmap]: /en/newsletters/2020/06/10/#bitcoin-core-0-20-0
[news290 asmap]: /ja/newsletters/2024/02/21/#asmap
[news259 cleanup]: /ja/newsletters/2023/07/12/#ln
