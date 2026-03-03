---
title: 'Bitcoin Optech Newsletter #358'
permalink: /ja/newsletters/2025/06/13/
name: 2025-06-13-newsletter-ja
slug: 2025-06-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、セルフィッシュマイニングの危険閾値の計算方法や、
高手数料率のトランザクションのフィルタリングの防止に関するアイディアのまとめ、
BIP390`musig()`ディスクリプターの変更案に関するフィードバックの募集、
ディスクリプター暗号化用の新しいライブラリの発表を掲載しています。また、
Bitcoin Core PR Review Clubの概要や、新しいリリースとリリース候補の発表、
そして人気のBitcoinインフラストラクチャプロジェクトの最近の更新など、恒例のセクションも含まれています。

## ニュース

- **<!--calculating-the-selfish-mining-danger-threshold-->セルフィッシュマイニングの危険閾値の計算:**
  Antoine Poinsotは、[セルフィッシュマイニング攻撃][topic selfish mining]の名称の由来となった
  2013年の[論文][es selfish]の数式（ただし、この攻撃自体は2010年に[既に説明されていました][bytecoin selfish]）を
  拡張した記事をDelving Bitcoinに[投稿しました][poinsot selfish]。
  彼はまた、この攻撃を実験するための簡略化された
  マイニングおよびブロックリレー[シミュレーター][darosior/miningsimulation]も提供しています。
  彼は、2013年の論文の結論の1つを再現することに焦点を当てています。
  それは、ネットワーク全体のハッシュレートの33%を制御する不正なマイナー（または強力な繋がりがあるマイナーのカルテル）は、
  その他の追加の優位性がなくても、ハッシュレートの67%を制御するマイナーよりも、
  長期的にわずかながら利益を上げることができるというものです。
  これは33%のマイナーが、発見した新しいブロックの一部のアナウンスを選択的に遅らせることで実現されます。
  不正なマイナーのハッシュレートが33%を超えると、その収益性はさらに高まり、
  最終的には50%のハッシュレートを超えて、競合他社がベストブロックチェーン上に新しいブロックを保持できないようにすることができます。

  Poinsotの投稿を詳しくレビューしたわけではありませんが、彼のアプローチは妥当であるように思われ、
  数学的な検証や理解を深めたいと考えている方には、ぜひお勧めします。

- **上位のmempoolのセット調整によるリレーの検閲耐性:**
  Peter Toddは、高手数料率のトランザクションをフィルタリングしているピアを
  ノードが切断できるようにするメカニズムについてBitcoin-Devメーリングリストに[投稿しました][todd feerec]。
  このメカニズムは、[クラスターmempool][topic cluster mempool]と、
  [erlay][topic erlay]で使用されているようなセット調整メカニズムに依存します。
  ノードは、クラスターmempoolを使って、（たとえば）8,000,000 weight単位（最大8MB）に収まる、
  最も収益性の高い未承認トランザクションのセットを計算します。
  ノードの各ピアも、未承認トランザクションの上位8 MWUを計算します。
  [minisketch][topic minisketch]などの効率的なアルゴリズムを使って、
  ノードはピアとトランザクションのセットを調整します。これにより、
  各ピアのmempoolの上位にどのようなトランザクションがあるかを正確に学習します。
  その後、ノードは平均して収益性の低いmempoolを持つピアとの接続を定期的に切断します。

  収益性の低い接続を切断することで、ノードは最終的に、
  高手数料率のトランザクションをフィルタリングする可能性が最も低いピアを見つけることができるでしょう。
  Toddは、クラスターmempoolのサポートがBitcoin Coreにマージされた後で実装に取り組みたいと述べました。
  彼はこのアイディアはGregory Maxwellらの功績だと述べており、
  Optechは基本的なアイディアについて[ニュースレター #9][news9 reconcile]で初めて言及しました。

- **`musig()`式で参加者の鍵の重複を許可するようBIP390を更新:**
  Ava Chowは、[アウトプットスクリプトディスクリプター][topic descriptors]内の
  `musig()`式で同じ参加者の公開鍵を複数使用できるように[BIP390][]を更新することに反対する人がいるかどうかを
  Bitcoin-Devメーリングリストで[尋ねました][chow dupsig]。
  これは、実装を簡素化し、[MuSig2][topic musig]の仕様である[BIP327][]では明示的に許可されています。
  この記事の執筆時点では反対意見はなく、ChowはBIP390の仕様を変更する[プルリクエスト][bips #1867]を公開しました。

- **<!--descriptor-encryption-library-->ディスクリプター暗号化ライブラリ:**
  Josh Domanは、[アウトプットスクリプトディスクリプター][topic descriptors]または
  [miniscript][topic miniscript]の機密部分を、そこに含まれる公開鍵で暗号化するライブラリを作成したことを
  Delving Bitcoinで[発表しました][doman descrypt]。
  彼は、復号に必要な情報について説明しています:

  > - 使用する際にウォレットが2-of-3の鍵を求める場合、復号にも正確に2-of-3の鍵が必要になります。
  >
  > - ウォレットが「2つの鍵 OR タイムロックと別の鍵」のような複雑なminiscriptポリシーを使用している場合は、
  >   すべてのタイムロックやハッシュロックが満たされているかのように、暗号化も同じ構造に従います。

  これは、[ニュースレター #351][news351 salvacrypt]で説明した暗号化ディスクリプターバックアップ方式とは異なります。
  その方式では、ディスクリプター内に含まれる任意の公開鍵の知識があれば、ディスクリプターを復号できます。
  Domanは、この方式は、暗号化ディスクリプターがブロックチェーンなどの公開または半公開のソースにバックアップされている場合に、
  より優れたプライバシーを提供すると主張しています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Separate UTXO set access from validation functions][review club 32317]は、
[TheCharlatan][gh thecharlatan]によるPRで、UTXOセット全体を要求するのではなく、
必要なUTXOのみを渡すことで検証関数を呼び出せるようにします。
これは、[`bitcoinkernel`プロジェクト][Bitcoin Core #27587]の一部で、
[Utreexo][topic utreexo]ノードや
[SwiftSync][somsen swiftsync]ノード（[ニュースレター #349][news349 swiftsync]参照）など、
UTXOセットを実装していないフルノード実装において、ライブラリをより使いやすくするための重要なステップです。

最初の4つのコミットでは、このPRにより、検証関数がUTXOセットに直接アクセスするのではなく、
呼び出し側が必要な`Coin`または`CTxOut`をまず取得し、それらを検証関数に渡すことで、
トランザクション検証関数とUTXOセット間の結合を低減します。

それ以降のコミットでは、UTXOセットとのやりとりを必要とする残りのロジックを
別の`SpendBlock()`メソッドに分離することで、`ConnectBlock()`のUTXOセットへの依存を完全に解消します。

{% include functions/details-list.md
q0="このPRで、`ConnectBlock()`関数から新しい`SpendBlock()`関数を切り離すことがなぜ役立つのですか？
2つの関数の目的をどのように比較しますか？"
a0="`ConnectBlock()`関数は、もともとブロックの検証とUTXOセットの変更の両方を実行していました。
このリファクタリングにより、これらの役割が分割されます。`ConnectBlock()`関数は、
UTXOセットを必要としない検証ロジックのみを担当し、新しい`SpendBlock()`関数は
UTXOセットとのすべてのやりとりを処理します。これにより、呼び出し元は、
`ConnectBlock()`を使ってUTXOセットなしでブロックの検証を行えます。"
a0link="https://bitcoincore.reviews/32317#l-37"

q1="UTXOセットなしでカーネルを使用できるようになること以外に、この分離に別の利点はありますか？"
a1="UTXOセットの無いプロジェクトでカーネルを使用できるようになることに加えて、
この分離により、コードを個別にテストしやすくなり、保守も容易になります。
あるレビュアーは、UTXOセットへのアクセスが不要になることで、
SwiftSyncの重要な機能であるブロックの並列検証が可能になると指摘しています。"
a1link="https://bitcoincore.reviews/32317#l-64"

q2="`SpendBlock()`は、`CBlock block`および`CBlockIndex pindex`、
`uint256 block_hash`パラメーターを受け取ります。これらはすべて使用されるブロックを参照します。
なぜ3つのパラメーターが必要なのでしょうか？"
a2="検証コードはパフォーマンスが重要であり、ブロックの伝播速度などの重要なパラメーターに影響します。
`CBlock`や`CBlockIndex`からブロックハッシュを計算すると、値がキャッシュされないためコストがかかります。
そのため、作者はパフォーマンスを優先し、計算済みの`block_hash`を別のパラメーターとして渡すことにしました。
同様に、`pindex`をブロックインデックスから取得することもできますが、
これは厳密には必要のない追加のマップ検索を必要とします。
<br>_注: 作者は後にアプローチを[変更し][32317 updated approach]、
`block_hash`のパフォーマンス最適化を削除しました。_"
a2link="https://bitcoincore.reviews/32317#l-97"

q3="このPRの最初のコミットでは、`CCoinsViewCache`をいくつかの検証関数の関数シグネチャからリファクタリングしています。
`CCoinsViewCache`はUTXOセット全体を保持しているのでしょうか？なぜそれが問題になるのか（あるいは問題にならないのか）？
このPRは、その動作を変更しますか？"
a3="`CCoinsViewCache`はUTXOセット全体を保持するわけではありません。
これは、UTXOセット全体をディスクに保存する`CCoinsViewDB`の前に位置するメモリ内のキャッシュです。
要求されたコインがキャッシュにない場合は、ディスクから取得する必要があります。
このPRは、キャッシュの動作自体を変更するものではありません。関数シグネチャから
`CCoinsViewCache`を削除することで、UTXOセットへの依存関係を明示し、
呼び出し元は検証関数を呼び出す前にコインを取得する必要があります。"
a3link="https://bitcoincore.reviews/32317#l-116"
%}

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 25.05rc1][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。

- [LND 0.19.1-beta][]は、この人気のLNノード実装のメンテナンスバージョンのリリースです。
  複数のバグ修正が[含まれています][lnd rn]。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32406][]は、デフォルトの`-datacarriersize`の設定を83から
  100,000 byte（トランザクションの最大サイズ制限）に引き上げることで、
  `OP_RETURN`アウトプットのサイズ制限（標準ルール）の上限を解除します。
  `-datacarrier`および`-datacarriersize`オプションは引き続き使用できますが、
  非推奨としてマークされており、将来のリリース（未定）で削除される可能性があります。
  さらに、このPRにより、OP_RETURNアウトプットはトランザクションに付き1つというポリシー制限も解除され、
  サイズ制限はトランザクション内のすべてのアウトプットに割り当てられるようになりました。
  この変更に関する詳細は、[ニュースレター #352][news352 opreturn]をご覧ください。

- [LDK #3793][]は、ピアに次の`n`個(`batch_size`)のメッセージを単一の論理単位として扱うように指示する
  新しい`start_batch`メッセージを追加します。また、`PeerManager`を更新し、
  [スプライシング][topic splicing]中の`commitment_signed`メッセージについて、
  バッチ内の各メッセージにTLVと`batch_size`フィールドを追加するのではなく、このメッセージに依存するようにしています。
  これは、LN仕様で定義されている唯一のバッチ処理である`commitment_signed`メッセージだけでなく、
  追加のLNプロトコルメッセージのバッチ処理を可能にする試みです。

- [LDK #3792][]は、[TRUCトランザクション][topic v3 transaction relay]と
  [エフェメラルアンカー][topic ephemeral anchors]に依存する
  [v3コミットメント トランザクション][topic v3 commitments]（[ニュースレター #325][news325 v3]参照）の初期サポートを、
  テストフラグの下、導入します。ノードは、ゼロ以外の手数料率を設定する`open_channel`提案を拒否し、
  そのようなチャネルを自分から開始しないことを保証し、
  後の手数料引き上げのためにまずUTXOを確保するためにv3チャネルを自動的に受け入れるのを停止します。
  このPRではまた、TRUCトランザクションは10 kvB未満でなければならないため、
  チャネルあたりの[HTLC][topic htlc]数の制限が483から114に引き下げられました。

- [LND #9127][]では、`lncli addinvoice`コマンドに`--blinded_path_incoming_channel_list`オプションが追加されました。
  これにより、受取人は、支払人が[ブラインドパス][topic rv routing]で転送を試みるための
  1つ以上（複数のホップの場合）の優先チャネルIDを埋め込むことができます。

- [LND #9858][]は、[RBF][topic rbf]による協調クローズフロー（[ニュースレター #347][news347 rbf]参照）の
  プロダクション機能ビット61のシグナリングを開始し、Eclairとの相互運用性を適切に実現します。
  この機能をテストするノードとの相互運用性を維持するため、ステージングビット161は保持されます。

- [BOLTs #1243][]は、[BOLT11][]仕様を更新し、p（ペイメントハッシュ）、
  h（説明のハッシュ）、s（シークレット）などの必須フィールドの長さが正しくない場合、
  読み取り人（支払人）はインボイスの支払いを行ってはならないことを示しました。
  これまでは、ノードはこの問題を無視できました。このPRではまた、
  [Low R署名][topic low-r grinding]は1 byteのスペースを節約できるが、
  仕様では強制されないことを説明する注記をサンプルセクションに追加しています。

{% include snippets/recap-ad.md when="2025-06-17 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32406,3793,3792,9127,1867,9858,1243,27587" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[lnd 0.19.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.1-beta
[poinsot selfish]: https://delvingbitcoin.org/t/where-does-the-33-33-threshold-for-selfish-mining-come-from/1757
[bytecoin selfish]: https://bitcointalk.org/index.php?topic=2227.msg30083#msg30083
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/v0.19.1-beta/docs/release-notes/release-notes-0.19.1.md
[darosior/miningsimulation]: https://github.com/darosior/miningsimulation
[todd feerec]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aDWfDI03I-Rakopb@petertodd.org/
[news9 reconcile]: /en/newsletters/2018/08/21/#bandwidth-efficient-set-reconciliation-protocol-for-transactions
[chow dupsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/08dbeffd-64ec-4ade-b297-6d2cbeb5401c@achow101.com/
[doman descrypt]: https://delvingbitcoin.org/t/rust-descriptor-encrypt-encrypt-any-descriptor-such-that-only-authorized-spenders-can-decrypt/1750/
[news351 salvacrypt]: /ja/newsletters/2025/04/25/#standardized-backup-for-wallet-descriptors
[es selfish]: https://arxiv.org/pdf/1311.0243
[news352 opreturn]: /ja/newsletters/2025/05/02/#bitcoin-core-op-return
[news325 v3]: /ja/newsletters/2024/10/18/#version-3-commitment-transactions-3
[news347 rbf]: /ja/newsletters/2025/03/28/#lnd-8453
[review club 32317]: https://bitcoincore.reviews/32317
[gh thecharlatan]: https://github.com/TheCharlatan
[somsen swiftsync]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[32317 updated approach]: https://github.com/bitcoin/bitcoin/pull/32317#issuecomment-2883841466
[news349 swiftsync]: /ja/newsletters/2025/04/11/#swiftsync
