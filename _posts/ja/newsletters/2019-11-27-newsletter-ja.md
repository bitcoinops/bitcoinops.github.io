---
title: 'Bitcoin Optech Newsletter #74'
permalink: /ja/newsletters/2019/11/27/
name: 2019-11-27-newsletter-ja
slug: 2019-11-27-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---

今週のニュースレターでは、Bitcoin Coreの新しいメジャーバージョンの発表、BitcoinとLNの開発メーリングリストについてのアップデート、開発が進むSchnorr / Taprootのレビューにおける進展内容、Bitcoin StackExchangeで最も投票が多かった質疑応答、Bitcoinインフラストラクチャプロジェクトの主な変更点をお送りします。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Bitcoin Core 0.19.0.1へのアップグレード**：Bitcoinユーザーは、新機能と複数のバグ修正を含む、最新[リリース][bitcoin core 0.19.0.1]にアップグレードすることをお勧めします。これは、0.19.0で[バグ][Bitcoin Core #17449]が見つかった後に修正された、0.19シリーズの最初のリリースバージョンです。

## News

- **Bitcoin Core 0.19リリース**：100人以上のコントリビュータによる1,000回以上のコミットを含む[最新のBitcoin Coreリリース][bitcoin core 0.19.0.1]は、いくつかの目に見える新機能、多数のバグ修正、P2Pネットワーク処理といった内部システムに関する複数の改善などを提供します。このニュースレター読者にとって、特に興味深い変更は、以下のものがあります。

    - *CPFPカーブアウト* ：この新しい[mempoolポリシー][topic cpfp carve out]は、2者契約プロトコル（現在のLNなど）で、両者がChild-Pays-For-Parent（CPFP）フィーバンピングを使用できるようにするのに役立ちます（[Newsletter＃63][news63 carve-out]参照）。 LN開発者は、コミットメントトランザクションのフィー管理を簡素化するために、この機能をどのように使用するかについての提案をすでに議論中です（Newsletter [#70][news70 simple commits]および[#71][news71 ln carve-out]＃71参照）。

    - *BIP158ブロックフィルター（RPCオンリー）*：[BIP158][]で規定される[コンパクトブロックフィルター][topic compact block filters]をBitcoin Coreで生成したい場合、ユーザーは新しいオプション`blockfilterindex`を設定できるようになりました。その後、新しいRPC `getblockfilter`を使用して、各ブロックのフィルターを取得できます。互換性のある軽量クライアントにフィルターを提供して、その軽量クライアントが持つキーに関係するトランザクションがブロックに含まれるかどうかを判断できるようにすることができます（[Newsletter#43][news43 core bip158]参照）。[PR#16442][Bitcoin Core #16442]は現在、P2Pネットワークを介してこれらのフィルターをクライアントと共有できるようにする[BIP157][]プロトコルのサポートを追加するために、オープンされています。

    - *<!--deprecated-or-removed-features-->非推奨となった、または削除された機能*：[BIP70][]ペイメントプロトコル、[BIP37][] P2Pプロトコルブルームフィルター、および[BIP61][] P2Pプロトコル拒否メッセージのサポートはデフォルトで無効になっており、さまざまな問題の原因を取り除いています（Newslette [#19][news19 bip70]、[#57][news57 bip37]、[#37][news37 bip61]参照） ）。ペイメントプロトコルと拒否メッセージは、約6か月後の次のメジャーBitcoin Coreバージョンで完全に削除される予定です。

    - *<!--customizable-permissions-for-whitelisted-peers-->ホワイトリスト化されたピアのカスタマイズ可能な権限*：どのピアまたはインターフェイスをホワイトリスト化するかを指定した場合、ホワイトリスト化されたピアがアクセスできる特別な機能を指定できるようになりました。以前までは、ホワイトリスト化されたピアは締め出されず、リレーされたトランザクションをより速く受け取れていました。これらのデフォルトは変更されていませんが、ピアごとに設定を切り替えたり、デフォルトではホワイトリスト化されていないピアでは無効になっている場合でも、指定したホワイトリスト化されたピアがBIP37ブルームフィルターをリクエストできるようになりました。詳細については、[Newsletter #60][news60 16248]を参照ください。

    - *GUIの改善*：グラフィカルユーザーは、GUIの*file*メニューからマルチウォレットモードで新しいウォレットを作成できるようになりました（[Newsletter #63][news63 new wallet]参照）。また、今回のGUIはデフォルトで[bech32][topic bech32]ビットコインアドレスをユーザーに提供しますが、ユーザーはボタンの横にあるチェックボックスを切り替えて、次からは下位互換性のあるP2SH-P2WPKHアドレスを生成するよう簡単にリクエストできます（[Newsletter #42][news42 core gui bech32]参照）。

    - *<!--optional-privacy-preserving-address-management-->選択可能なプライバシー保護アドレス管理*：`setwalletflag` RPCを使用して切り替えることができる`avoid_reuse`ウォレットフラグを有効にすると、以前に使用したアドレスに受信したビットコインをウォレットが使用することを防ぐことができます（[Newsletter #52][news52 avoid_reuse]参照）。これにより、[dust
      flooding][]などのブロックチェーン分析に基づいた特定のプライバシー漏洩が防止されます。

   重要な変更リスト、それらの変更が行われたPRへのリンク、およびノードオペレーターに役立つ追加情報については、Bitcoin Coreプロジェクトの[リリースノート][notes 0.19.0]を参照してください。

- **新しいLNDメーリングリストと既存のメーリングリストの新しいホスト**：Googleグループ上でホストされる[新しいメーリングリスト][lnd engineering]がLNDアプリケーション開発者向けに発表され、Olaoluwa Osuntokunによる[最初の投稿][osuntokun lnd plans]では、LNDの次のリリースの短期目標が説明されました。これとは別に、[Bitcoin-Dev][]と [Lightning-Dev][]の既存のメーリングリストのホスティングは、さまざまなオープンソースプロジェクトホスティングの提供で評判の高いオレゴン州立大学の[Open Source Lab][osl] (OSL)に[移行][togami ml update]されました。 Optechは、Bitcoinのオープンなコミュニケーションチャネルの維持に貢献するWarren Togami、Bryan Bishop、および他多くのすべての人々に感謝いたします。彼らなくしては、このニュースレターも存在しえません。

- **Schnorr / Taprootの更新**：[taproot review group][]の参加者は、提案されたビットコインへのソフトフォーク変更のレビューを継続しており、[記録されている][tbr log]Freenodeネットワーク上の##taproot-bip-review IRCチャットルームで、多くの興味深い質問が行われています。さらに、一部の参加者は、libbitcoinやbcoin完全検証ノードを含む、BIPの一部の独自実装を作成しています。

    今週、マルチパーティSchorr署名のセキュリティに関連する2つのブログ記事も投稿されました。BlockstreamのエンジニアJonas Nickは、[bip-schnorr][]のユーザーが複数の公開鍵を単一の公開鍵に集約できるように設計された[MuSig][]マルチパーティ署名方式について[説明しました][nick musig]。ユーザーはその後、その鍵に署名して、ユーザー間で共同で生成された単一の署名を使用できます。Nickは、MuSigの署名プロトコルの3つのステップについて説明しています - ナンスコミットメントの交換、ナンスの交換、部分署名の交換（ナンスと部分署名を集約して最終署名を生成）です。速度が重要な場合（LNチャネルコミットメントトランザクションの作成など）、時間を節約するために、署名でコミットするトランザクションを知る前にナンスコミットメントとナンスを交換したい人がいるかもしれませんが、これはNickが説明しているようにWagnerのアルゴリズムにより安全ではありません。参加者が署名するトランザクションを認識する前に安全に共有できる唯一の情報は、ナンスコミットメントです。（これはブログ記事では言及されておらずIRCで議論されましたが、Pieter Wuilleと他の人々は、インタラクティビティ減少を可能にするZero Knowledge Proof（ZKP）に基づいた構造を調査しています。）ブログの投稿は、開発者がプロトコルを安全に使用できるように設計された[libsecp256k1-zkp][]のMuSig実装を、興味ある場合レビューするよう提案する形で結論づけられました。

    ベルリンライトニングカンファレンスでのこのトピックに関するJonas Nickのプレゼンテーションの影響を受けて、Adam Gibsonは、Wagnerのアルゴリズムを数学、直感的な分析、そしてBitcoinerが興味をそそるトピック情報を交えて[ブログ記事][gibson wagners]を投稿しました。（例えばSatoshi NakamotoがAdam BackとWeiDaiを[引用する][bitcoin.pdf]数年前に同内容を引用していた[Wagner's paper][]についてのトリビアなど）独自の暗号化プロトコルの開発に関心のある方は、両投稿を読むことをお勧めします。それぞれの投稿は内容を繰り返すものではなく、各自の投稿を補完しています。

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・答えについて共有しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [P2WPKHとP2WSHとで長さが異なるように、schnorr pubkeyはtaproot pubkeyとは異なる長さになりますか？]({{bse}}91531) P2WPKHおよびP2WSHの出力タイプと長さが異なるsegwit v0とは異なり、すべてのsegwit v1 Pay-to-Taproot（P2TR）出力は常に同じ長さであるとMurchは説明しています。

- [MuSig署名のインタラクティビティ]({{bse}}91534) Justinmoonはなぜ[MuSig][]署名が常に対話型なのか、オフラインでの対話型の署名で安全な方法はあるか、という質問を投稿しました。Nicklerは、MuSig署名に関連する各プロセスと、署名中に避けるべきいくつかの落とし穴について説明しました。

- [bech32アドレスが可変長となる場合の問題とは何ですか？]({{bse}}91602) Jnewberyは、アドレスの最後の文字「p」の直前に文字「q」を追加または削除すると、有効な新しいbech32アドレスが生成されることがある詳細な理由について質問しています。 Pieter Wuilleは、この問題は、ランダムな長さ変更によるエラーを見逃してしまう確率（10億分の1）よりも発生する可能性が高い理由について、いくつかの代数的説明を提供しました。 加えてMCCCSは、Bitcoin Coreコードの一部を使用した説明を提供しました。

- [Bitcoinポリシー言語とMiniscriptの違いは何ですか？]({{bse}}91565) Pieter Wuille、James C.、およびsanket1729は、Bitcoin Script、ポリシー言語（人間が支出条件を設計するためのツール）、およびminiscript（コミュニケーションや分析用のより構造化されたBitcoin Script表現）の関係を説明しています。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], および [Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #17265][]および[#17515][Bitcoin Core #17515]は、Bitcoin 0.1リリース以来使用されていたOpenSSLへの依存を取り除きます。 この依存性は[コンセンサス脆弱性][non-strict der]、[リモートメモリ漏洩][heartbleed]（秘密鍵の漏洩の可能性）、 [その他のバグ][cve-2014-3570]、そして [パフォーマンス低下][libsecp256k1 sig speedup]を招いていました。

- [Bitcoin Core #16944][]は、GUIを更新して、ユーザーが秘密鍵が無効になっているウォッチ専用ウォレットでトランザクションを作成しようとすると、[BIP174][]部分的署名ビットコイントランザクション（PSBT）を生成し自動的にクリップボードにコピーします。そのPSBTは別の署名用アプリケーション（[HWI][topic hwi]など）にコピーすることもできます。 GUIは、署名されたPSBTをコピーし戻してブロードキャストするための特別なダイアログボックスをまだ提供していません。

- [Bitcoin Core #17290][]は、ユーザーが特定の入力の使用を求めたり、支払い額からフィーを選択するように要求したりする場合に使用するコイン選択アルゴリズムを変更します。これらは今後のBitcoin Coreの通常のデフォルトのアルゴリズムとなるBranch and Bound（BnB）を使用します。 BnBは、お釣りの発生しないトランザクションの作成を最適化することにより、フィーを最小化し、プライバシーを最大化するように設計されました。

- [C-Lightning #3264][]には、ゴシップクエリ実装のバグである[LND #3728][]に関するいくつかの緩和策が含まれています。この変更により、テストとデバッグに役立つ2つの新しいコマンドラインパラメーター、`--hex`と`--features`も追加されます。

- [C-Lightning #3274][]は、`lightningd`が最後に実行されたときよりも低いブロックの高さで`bitcoind`が現在検出されている場合、`lightningd`の起動を拒否します。`lightningd`の実行中に低いブロックの高さが見られる場合は、より高いブロックの高さが見られるまで、単純に待機します。ブロックの高さは、ブロックチェーンの再編成中、ブロックチェーンの再インデックス中、またはユーザーが開発者テスト用の特定のコマンドを実行した場合に減少する可能性があります。この場合、`lightningd`側で問題を解決しようとするよりも、これらの状況が`bitcoind`によって解決されるのを待つことは、簡単で安全です。ただし、LNユーザーが切り捨てられたチェーンを本当に使用したい場合は、`--rescan`パラメーターを使用して`lightningd`を開始し、ブロックチェーンを再処理できます。

- [Eclair #1221][]は、既知のチャネルの数、既知のLNノードの数、LNノードのキャパシティ（パーセントでグループ化）、およびノードが課金するフィー（同様にパーセントでグループ化）など、ローカルノードから観測出来るLNネットワークに関するさまざまな情報を返す`networkstats` APIを追加します。

- [LND #3739][]を使用すると、支払いが受信者に配信される前に、ルート上の最後のホップとなるノードを指定できます。 [LND #3736][]などの他の保留中のPRとあわせることで、ユーザーはLND機能だけで（現在のように外部ツールに頼らずとも）チャネルのバランスを再調整できます。

- [LND #3729][]を使用することで、ミリサトシ（1/1000サトシ）の精度で請求書を生成できます。以前までは、LNDではサトシ以下のインボイスを生成できませんでした。

- [LND #3499][]は、`listpayments`や`trackpayment`などの複数のRPCを拡張して、[マルチパスペイメント][topic multipath payments]（異なるルートを介して送信された複数部分を持つ支払い）に関する情報を提供します。これらはまだLNDで完全にはサポートされていませんが、このマージされたPRにより、後の実施を簡単に追加できます。さらに、以前に送信されたシングルパートのみの支払いは、マルチパスに使用されるものと同じ構造に変換されますが、シングルパートのみに表示されます。

{% include linkers/issues.md issues="17449,3499,3729,3739,1221,16442,17265,17515,16944,3264,3728,3274,17290,3736" %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bitcoin core 0.19.0.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.0.1/
[notes 0.19.0]: https://bitcoincore.org/ja/releases/0.19.0.1/
[news63 carve-out]: /en/newsletters/2019/09/11/#bitcoin-core-16421
[news70 simple commits]: /ja/newsletters/2019/10/30
[news71 ln carve-out]: /ja/newsletters/2019/11/06
[news43 core bip158]: /en/newsletters/2019/04/23/#basic-bip158-support-merged-in-bitcoin-core
[news19 bip70]: /en/newsletters/2018/10/30/#bitcoin-core-14451
[news57 bip37]: /en/newsletters/2019/07/31/#bloom-filter-discussion
[news37 bip61]: /en/newsletters/2019/03/12/#removal-of-bip61-p2p-reject-messages
[news63 new wallet]: /en/newsletters/2019/09/11/#bitcoin-core-15450
[news42 core gui bech32]: /en/newsletters/2019/04/16/#bitcoin-core-15711
[news52 avoid_reuse]: /en/newsletters/2019/06/26/#bitcoin-core-13756
[dust flooding]: {{bse}}81509
[news60 16248]: /en/newsletters/2019/08/21/#bitcoin-core-16248
[togami ml update]: http://www.erisian.com.au/bitcoin-core-dev/log-2019-11-21.html#l-23
[nick musig]: https://medium.com/blockstream/insecure-shortcuts-in-musig-2ad0d38a97da
[gibson wagners]: https://joinmarket.me/blog/blog/avoiding-wagnerian-tragedies/
[news55 tlv]: /en/newsletters/2019/07/17/#bolts-607
[lnd engineering]: https://groups.google.com/a/lightning.engineering/forum/#!forum/lnd
[osuntokun lnd plans]: https://groups.google.com/a/lightning.engineering/forum/#!topic/lnd/GtcrXNhTLqQ
[bitcoin-dev]: https://lists.linuxfoundation.org/mailman/listinfo/bitcoin-dev
[lightning-dev]: https://lists.linuxfoundation.org/mailman/listinfo/lightning-dev
[osl]: https://osuosl.org/
[taproot review group]: https://github.com/ajtowns/taproot-review
[tbr log]: http://www.erisian.com.au/taproot-bip-review/
[libsecp256k1-zkp]: https://github.com/ElementsProject/secp256k1-zkp
[wagner's paper]: https://people.eecs.berkeley.edu/~daw/papers/genbday-long.ps
[non-strict der]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[cve-2014-3570]: https://www.reddit.com/r/Bitcoin/comments/2rrxq7/on_why_010s_release_notes_say_we_have_reason_to/
[libsecp256k1 sig speedup]: https://bitcoincore.org/en/2016/02/23/release-0.12.0/#x-faster-signature-validation

