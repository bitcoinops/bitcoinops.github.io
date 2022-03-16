---
title: 'Bitcoin Optech Newsletter #191'
permalink: /ja/newsletters/2022/03/16/
name: 2022-03-16-newsletter-ja
slug: 2022-03-16-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Scriptを新しいopcodeで拡張または置換する提案と、
RBFポリシーの改善に関する最近の議論のまとめ、
`OP_CHECKTEMPLATEVERIFY` opcodeの継続的な作業のリンクを掲載しています。
また、人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更について解説する恒例のセクションも含まれています。

## ニュース

- **Bitcoin Scriptの拡張と代替** 複数の開発者がBitcoin-Devメーリングリストで、
  ビットコインを受けとった人が後でそれらのビットコインの使用を承認したことを証明する方法を指定するために使用する
  BitcoinのScriptと[Tapscript][topic tapscript]言語を改善するためのアイディアについて議論しました。

    - *<!--looping-folding-->ループ (たたみ込み):* 開発者のZmnSCPxjは、
      Bitcoin Scriptでループのような動作を可能にする方法として`OP_FOLD`の提案について[説明しました][zmnscpxj fold]。
      彼は、Bitcoin ScriptとTapscriptが現在使用可能なCPUおよびメモリよりも多くのリソースを使用しないことを保証する
      ループに課す一連の制約について説明しました。
      また、Script内に繰り返しコードを含める必要がなくなるため帯域幅を削減できます。

    - *Chia Lispの使用:* Anthony Townsは、
      アルトコインChia用に設計された[Lisp][]の方言である[Chia Lisp][]のバリエーションを
      Bitcoinに追加することについて[投稿しました][towns btc-lisp]。
      これは従来のBitcoin ScriptやTapscriptとは全く異なる代替手段で、
      以前提案された[Simplicity][topic simplicity]言語と同じように新たなメリットを提供します。
      Townsは、代替案の「Binary Tree Coded Script」または「btc-script」は、
      Simplicityよりも理解しやすく、使いやすいとしていますが、
      おそらく正式に検証するのは難しいでしょう。

- **RBFポリシーの改善に向けたアイディア:** Gloria Zhaoは、
  最近ロンドンで開催された[CoreDev.Tech][]ミーティングで行われた
  Replace-by-Fee ([RBF][topic rbf])ポリシーに関する議論の要約と、それに関連するいくつかの最新情報を[投稿しました][zhao rbf]。
  彼女によると、議論された主なコンセプトは、特定の時間内に中継される関連トランザクションの数を制限するなどして、
  トランザクションとその置換トランザクションを中継するために使用されるリソースの最大量を制限することであったようです。

    Zhaoはまた、トランザクションを使用する子孫の制限を提案できるようにすることを検討した要点に関する
    別の[議論][daftuar limits]もまとめています。例えば、
    トランザクションとその子孫が消費可能なmempoolのスペースの最大値を
    デフォルトの100,000 vbyteではなく1,000 vbyteにすることを提案できます。
    そうすれば、最悪の場合[Pinning攻撃][topic transaction pinning]を受けても、
    正直なユーザーがそれに対処するためのコストを低く抑えることができます。

    さらにZhaoは、現在のmempoolが与えられた場合の
    トランザクションのマイナーへの価値を計算するアルゴリズムについてのフィードバックを求めています。
    こにより置換トランザクションを受け入れるかどうかについて、ノードソフトウェアでより柔軟な意思決定ができるかもしれません。

- **CTVの議論の続き:** [ニュースレター #183][news183 ctv meeting]で言及したように、
  提案中の[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) opcodeを議論するミーティングは継続中で、
  Jeremy Rubinによって要約されています： [1][news183 ctv meeting]、[2][ctv2]、[3][ctv3]、[4][ctv4]、[5][ctv5]。
  さらに先週は、James O'BeirneがCTVベースの[Vault][topic vaults]のコードと設計ドキュメントを[投稿しました][obeirne vault]。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #24198][]は、`listsinceblock`および`listtransactions`、`gettransaction` RPCを拡張し、
  [BIP141][]で定義された各トランザクションのWitness Transaction Identifierを含む新しい`wtxid`フィールドを追加しました。

- [Bitcoin Core #24043][]は、旧Scriptの`OP_CHECKMULTISIG`opcodeおよび`OP_CHECKMULTISIGVERIFY`opcodeに代わって、
  [Tapscriptの][topic tapscript]`OP_CHECKSIGADD`opcodeで動作する支払い承認ポリシーを作成するための
  新しい`multi_a` [descriptor][topic descriptors]および`sortedmulti_a` descriptorを追加しました。
  Tapscriptのこの機能についての詳細は[ニュースレター #46][news46 csa]をご覧ください。

- [Bitcoin Core #24304][]は、Bitcoin Coreのデータディレクトリと、
  検証してデータディレクトリに追加することが可能なブロックを渡すことができる新しい試験用の`bitcoin-chainstate`実行可能ファイルを追加しました。
  これは直接的に役立つとは期待されていませんが、
  他のプロジェクトがBitcoin Coreが使用するコードと全く同じコードを使ってブロックやトランザクションを検証するために使用できるライブラリを生成するために
  [libbitcoinkernel][bitcoin core #24303]プロジェクトが活用するツールを作成できます。

- [C-Lightning #5068][]は、C-Lightningが1日にノードあたり中継する[BOLT7][]の`node_announcement`メッセージの最少数を1から2に増やしました。
  これは、ノードがIPアドレスを変更したり、メンテナンスのために一時的にオフラインになることに関連するいくつかの問題を軽減するでしょう。

- [BIPs #1269][]は、[BIP68][]のコンセンサスで適用されるnSequenceの値が必要な場合のプライバシーを改善するために、
  コントラクトプロトコルで必要がない場合でも、
  [Taproot][topic taproot]トランザクションがnSequenceの値をセットするという推奨事項を[BIP326][]に割り当てました。
  BIP326では、nSequenceを使用することで、現在トランザクションのlocktimeフィールドを通じて有効になっている
  [アンチ・フィー・スナイピング][topic fee sniping]保護に代わる方法を提供できることについても説明しています。
  メーリングリストでの提案の概要については[ニュースレター #153][news153 nseq]を参照ください。

{% include references.md %}
{% include linkers/issues.md v=1 issues="24198,24043,24304,24303,5068,1269" %}
[news46 csa]: /en/newsletters/2019/05/14/#new-script-based-multisig-semantics
[zmnscpxj fold]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/020021.html
[towns btc-lisp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020036.html
[lisp]: https://ja.wikipedia.org/wiki/LISP
[chia lisp]: https://chialisp.com/
[zhao rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020095.html
[daftuar limits]: https://gist.github.com/glozow/25d9662c52453bd08b4b4b1d3783b9ff?permalink_comment_id=4058140#gistcomment-4058140
[news183 ctv meeting]: /ja/newsletters/2022/01/19/#irc
[ctv2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019855.html
[ctv3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019874.html
[ctv4]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019974.html
[ctv5]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020086.html
[obeirne vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020067.html
[coredev.tech]: https://coredev.tech/
[news153 nseq]: /ja/newsletters/2021/06/16/#taproot-nsequence-bip
