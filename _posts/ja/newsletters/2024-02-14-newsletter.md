---
title: 'Bitcoin Optech Newsletter #289'
permalink: /ja/newsletters/2024/02/14/
name: 2024-02-14-newsletter-ja
slug: 2024-02-14-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、クラスターmempool展開後のリレーの拡張のアイディアと、
2023年のLNスタイルのアンカーアウトプットのトポロジーと研究結果、
Bitcoin-Devメーリングリストの新しいホストの発表および、
フリーソフトウェアの貢献者に感謝するI Love Free Software Dayのお祝いについて掲載しています。
また、Bitcoin Core PR Review Clubミーティングの要約や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、恒例のセクションも含まれています。

## ニュース

- **クラスターmempool展開後のリレーの拡張に関するアイディア:**
  Gregory Sandersは、[クラスターmempool][topic cluster mempool]のサポートが完全に実装、テストされ、
  展開された後で、個々のトランザクションが特定のmempoolポリシーにオプトインできるようにするためのいくつかのアイディアを
  Delving Bitcoinに[投稿しました][sanders future]。この改良は、
  [v3トランザクションリレー][topic v3 transaction relay]の機能に基づいており、
  もう必要ないと思われるルールを緩和し、トランザクション（またはトランザクションの[パッケージ][topic package relay]）が
  次のブロックまたは2ブロック以内にマイニングされる可能性が高い手数料率を支払うという要件を追加します。

- **<!--what-would-have-happened-if-v3-semantics-had-been-applied-to-anchor-outputs-a-year-ago-->1年前にv3セマンティクスがアンカーアウトプットに適用されていたらどうなっていただろう？**
  Suhas Daftuarは、[アンカースタイル][topic anchor outputs]のLNコミットメントと
  手数料引き上げのトランザクションに[v3トランザクションリレーポリシー][topic v3 transaction relay]を自動的に適用するアイディア（
  基礎となるv3の埋め込みの提案については[ニュースレター #286][news286 imbued]参照）に関する研究結果を
  Delving Bitcoinに[投稿しました][daftuar retrospective]。
  つまり彼は、2023年にアンカーの支払いのように見える14,124個のトランザクションを記録しました。そのうち、

  - 約94%<!-- (14124 - 856) / 14124 -->は、v3ルールの下で成功するでしょう。

  - 約2.1%<!-- 302/14124 -->は、複数の親を持っていました（たとえば、
    [CPFP][topic cpfp]のバッチ支払いの試行など）。一部のLNウォレットは、
    短時間に複数のチャネルを閉じる際に、効率化のためにこのような動作をするものがあります。
    アンカースタイルのアウトプットにv3の特性を組み込む場合は、この動作を無効にする必要があります。

  - 約1.8%<!-- 251/14124 -->は、親の最初の子ではありませんでした。v3が組み込まれた場合、
    2つめの子は[パッケージ][topic package relay]内の最初の子を置き換えることができます（[ニュースレター #287][news287 kindred]参照）。

  - 約1.2%<!-- 175/14124 -->は、明らかにコミットメントトランザクションの孫であり、
    つまり、アンカーアウトプットの支払いのさらに支払いでした。
    LNウォレットは、複数のアンカーチャネルを順番に閉鎖したり、
    アンカーチャネル閉鎖のお釣りから新しいチャネルを開設したりと、さまざまな理由でこれを行う可能性があります。
    アンカースタイルのアウトプットにv3の特性が組み込まれた場合、LNウォレットはこの動作を使用できなくなります。

  - 約1.2%<!-- 173 / 14124 -->は、マイニングされず、それ以上分析されませんでした。

  - 約0.1%<!-- 19/14124 -->は、無関係な未承認のアウトプットを使用しており、
    その結果、アンカーの支払いは許容される1つ以上の親を持つようになりました。
    開発者のBastien Teinturierは、これはEclairの動作かもしれないと考えており、
    Eclairは現在のコードでもこの状況を自動的に解決すると指摘しています。

  - 1,000 vbyteを超えるものは0.1%<!-- 10/14124 -->未満でした。
    これは、LNウォレットが変更すべき動作でもあります。
    Daftuarのさらなる調査によると、ほぼすべてのアンカーの支払いは500 vbyte未満であり、
    v3のサイズ制限が縮小される可能性が示唆されました。そうすると、
    アンカーの支払いに対する[Pinning攻撃][topic transaction pinning]の試行を防ぐためのコストが低くなりますが、
    LNウォレットが数個よりも多くのUTXOから手数料を拠出することができなくなります。
    Teinturierは、「1,000 vbyteの値を下げることは非常に魅力的ですが、
    過去のデータでは（保留中のHTLCがとても少ない）誠実な試みしか示されておらず、
    ネットワーク上での広範な攻撃はまだ確認されていないため、
    どのような値がより良い値になるかを把握するのは困難です」と述べています。

  このトピックに関する追加の議論や研究が期待されますが、
  Bitcoin Coreがアンカーの支払いをv3トランザクションとして安全に扱い始める前に、
  LNウォレットはv3セマンティクスによりよく適合するために、
  いくつかの小さな変更を加える必要があるかもしれないというのが、今回の結果からの私たちの印象です。

- **Bitcoin-Devメーリングリストに移動:** プロトコル開発を議論するメーリングリストは、
  新しいメールアドレスと新しいサーバーでホストされるようになりました。
  引き続き投稿を受け取りたい人は、再登録が必要です。
  詳細は、Bryan Bishopの[移行メール][migration email]をご覧ください。
  移行に関する過去の議論については、ニュースレター[#276][news276 ml]と[#288][news288 ml]をご覧ください。

- **I Love Free Software Day:** 毎年2月14日、[FSF][]や[FSFE][]などの組織は、
  FOSS（Free and Open Source Software）のユーザーに向けて、
  「フリーソフトウェアを保守し貢献しているすべての人々に「ありがとう！」を言おう」と奨励しています。
  2月14日以降にこのニュースレターを読んでいる場合でも、BitcoinのFOSSプロジェクトに貢献してくれている
  お気に入りの人たちに感謝の気持ちを伝えることをお勧めします。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Add `maxfeerate` and `maxburnamount` args to `submitpackage`][review club 28950]は、
Greg Sanders（GitHubではinstagibbs）によるPRで、単一トランザクションのRPC
`sendrawtransaction`と`testmempoolaccept`には既に存在する機能を`submitpackage` RPCに追加するものです。
このPRは、より大きな[パッケージリレー][topic package relay]プロジェクトの一部です。
具体的には、このPRはパッケージの送信者が（PRのタイトルにある）引数を指定できるようにするもので、
これにより要求されたパッケージ内のトランザクションのサニティチェックを可能にし、
偶発的な資金の損失を防ぐことができます。Review Clubミーティングは、
Abubakar Sadiq Ismail（GitHubではismaelsadeeq）が主催しました。

{% include functions/details-list.md
  q0="<!--why-is-it-important-to-perform-these-checks-on-submitted-packages-->なぜ送信されたパッケージに対してこれらのチェックを行うことが重要なのですか？"
  a0="パッケージ内のトランザクションに、個々のトランザクションの送信と同じセーフガードが適用されることは、ユーザーにとって有益です。"
  a0link="https://bitcoincore.reviews/28950#l-27"

  q1="<!--are-there-other-important-checks-apart-from-maxburnamount-and-maxfeerate-that-should-be-performed-on-packages-before-they-are-accepted-to-the-mempool-->`maxburnamount`と`maxfeerate`以外に、mempoolに受け入れられる前にパッケージに対して実行されるべき他の重要なチェックはありますか？"
  a1="はい。2つの例が、基本手数料のチェックと最大標準トランザクションサイズです。
      これらは低コストのチェックであるため、早期にチェックすることができ、パッケージを迅速に失敗させることができます。"
  a1link="https://bitcoincore.reviews/28950#l-33"

  q2="<!--the-options-maxburnamount-and-maxfeerate-can-prevent-a-transaction-from-entering-the-mempool-and-being-relayed-can-we-consider-these-options-as-policy-rules-why-or-why-not-->`maxburnamount`と`maxfeerate`のオプションは、トランザクションがmempoolに入ってリレーされるのを防ぐことができます。
      これらのオプションはポリシールールとみなすことができますか？それは何故で、あるいはそうでない場合は何故ですか？"
  a2="これはポリシーです。これらのチェックはマイニングされたブロックのトランザクションには適用されません（つまり、これはコンセンサスではありません）。
      これらはピアからのトランザクションリレーにも影響せず、RPCを使用してローカルで送信されたトランザクションにのみ影響します。"
  a2link="https://bitcoincore.reviews/28950#l-47"

  q3="<!--why-do-we-validate-maxfeerate-against-the-modified-feerate-instead-of-the-base-fee-rate-->なぜ基本手数料率ではなく、変更された手数料率に対してmaxfeerateを検証するのですか？"
  a3="（以前のReview Club[24152][review club 24152]、[24538][review club 24538]および
      [27501][review club 27501]で、変更版と基本手数料の概念を取り上げました）
      ほとんどの参加者は、`sendrawtransaction`と`testmempoolaccept`がそのチェックで基本手数料を使用しているため、
      変更された手数料ではなく基本手数料を使用する必要があると考えていました。その方が一貫性があるように思えるからです。
      （修正版と基本手数料を異なるものとする）`prioritisetransaction`は、通常マイナーのみが使用するため、
      実用的な違いは生じない可能性があります。"
  a3link="https://bitcoincore.reviews/28950#l-69"

  q4="<!--we-validate-maxfeerate-against-the-modified-feerate-of-individual-package-transactions-not-package-feerate-when-can-this-be-inaccurate-->パッケージの手数料率ではなく、パッケージの個々のトランザクションの変更された手数料率に対してmaxfeerateを検証します。
      これが不正確になるのはどのような場合ですか？"
  a4="パッケージの子トランザクションが、その変更された手数料率が個々に`maxfeerate`を超える場合、拒否されますが、
      パッケージとしてチェックされている場合は拒否されません。"
  a4link="https://bitcoincore.reviews/28950#l-84"

  q5="<!--given-that-possible-inaccuracy-why-not-check-maxfeerate-against-package-feerate-instead-->その不正確さの可能性を考えると、なぜ代わりに`maxfeerate`をパッケージの手数料率に対してチェックしないのですか？"
  a5="それは別の不正確さを引き起こす可能性があるためです。トランザクションAの手数料がゼロで、
      BがCPFPによりAの手数料を引き上げると仮定します。AとBは両方とも物理的に大きいので、
      どちらも`maxfeerate`を超過しません。しかし、今、AとBの両方を使用する高手数料率のCが追加されました。
      （これは2つの階層しかないため許可されるトポロジーですが、`submitpackage` RPCではこのトポロジーが許可されないことが指摘されました）
      この場合、Cは手数料の多くがAとBに吸収されるため受け入れられますが、Cは拒否されるべきです。"
  a5link="https://bitcoincore.reviews/28950#l-108"

  q6="<!--why-can-t-maxfeerate-be-checked-immediately-after-decoding-like-maxburnamount-is-->なぜ`maxfeerate`は、`maxburnamount`のようにデコード後すぐにチェックされないのですか？"
  a6="トランザクションインプットにはインプットの金額が明示的に記載されていないことはよく知られています。
      これは親のアウトプットを探した後でのみ知ることができます。手数料率には手数料が必要であるため、
      インプットの金額が必要です。"
  a6link="https://bitcoincore.reviews/28950#l-141"

  q7="<!--how-does-the-maxfeerate-check-in-testmempoolaccept-rpc-differ-from-submitpackage-rpc-why-can-t-they-be-the-same-->`testmempoolaccept` RPCの`maxfeerate`チェックは、`submitpackage` RPCとどう異なりますか？
      なぜ同じにはならないのでしょうか？"
  a7="先ほどに説明したように、`submitpackage`は変更された手数料を使用しますが、
      `testmempoolaccept`は基本手数料を使用します。また、
      トランザクションはmempoolに追加されず、処理後にブロードキャストされるため、
      手数料率のチェックは`testaccept`パッケージの処理後に行われます。
      そのため、安全に`maxfeerate`のチェックを行い、適切なエラーメッセージを返すことができます。
      同じことを`submitpackage`で行うことはできません。パッケージのトランザクションが既にmempoolに受け入れられ、
      ピアにブロードキャストされている可能性があり、チェックが冗長になるからです。"
  a7link="https://bitcoincore.reviews/28950#l-153"
%}

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [Bitcoin Core #28948][]は、
  [バージョン3トランザクションリレー][topic v3 transaction relay]のサポートを追加し（ただし、有効にはなっていません）、
  未承認の親を持たないv3トランザクションが、通常のトランザクションの受け入れルールに従ってmempoolに入ることが可能になりました。
  v3トランザクションは、[CPFPによる手数料の引き上げ][topic cpfp]をすることができますが、
  子トランザクションは1,000 vbyte以下の場合に限定されます。
  各親のv3は、未承認の子トランザクションを1つだけmempoolに持つことができ、
  各子は未承認の親を1つだけ持つことができます。親トランザクションか子トランザクションのどちらかは、
  常に[手数料による置換][topic rbf]が可能です。このルールは、Bitcoin Coreのリレーポリシーにのみ適用されます。
  コンセンサスレイヤーでは、v3トランザクションは[BIP68][]で定義されたバージョン2トランザクションと同じように検証されます。
  この新しいルールは、LNのようなコントラクトプロトコルが、
  [トランザクションのPinning攻撃][topic transaction pinning]から逃れるために必要な手数料を最小限に抑えながら、
  事前コミットしたトランザクションを常に迅速に承認できるようにすることを目的としています。

- [Core Lightning #6785][]では、Bitcoin上で[アンカースタイル][topic anchor outputs]のチャネルがデフォルトになりました。
  Elements互換の[サイドチェーン][topic sidechains]上のチャネルでは、非アンカーチャネルが引き続き使用されます。

- [Eclair #2818][]は、既存の未承認トランザクションが承認される可能性が非常に低いケースを検出することで、
  Eclairウォレットが安全に使用できると考えるインプットの数を最大化します。
  Eclairは、Bitcoin Coreのウォレットを使用して、手数料引き上げトランザクションを含む
  オンチェーン支払いのUTXOを管理します。ウォレットによって制御されるUTXOが、
  トランザクションのインプットとして使用される場合、Bitcoin Coreのウォレットは、
  そのインプットを使用して他の無関係なトランザクションを自動的に作成することはありません。
  しかし、そのトランザクションの別のインプットが二重使用され、そのトランザクションが承認できなくなった場合、
  Bitcoin CoreのウォレットはUTXOが別のトランザクションで再び使用されることを自動的に許可します。
  残念ながら、異なるバージョンが承認され、トランザクションの親が承認不可能になった場合、
  Bitcoin Coreのウォレットは現在のところ自動的にUTXOの使用を許可しません。
  Eclairは、親トランザクションの二重使用を独自に検出でき、
  Eclairの以前のUTXOのアンロックの試みを[放棄][rpc abandontransaction]し、
  再度使用可能にするようBitcoin Coreのウォレットに指示します。

- [Eclair #2816][]により、ノードオペレーターはコミットメントトランザクションを承認するために、
  [アンカーアウトプット][topic anchor outputs]に使用する最大額を選択できるようになりました。
  これまでEclairは、チャネルの金額の5%までを使用していましたが、
  金額が多いチャネルにとっては高すぎる可能性があります。
  Eclairの新しいデフォルトは、その手数料率の推定器が提案する最大手数料率で、
  絶対的な合計額は10,000 satまでです。Eclairはまた、
  まもなく期限切れになる[HTLC][topic htlc]のリスクにさらされる金額まで引き続き支払い、
  10,000 satよりも高くなる可能性があります。

- [LND #8338][]は、チャネルを共同で閉鎖する新しいプロトコルの初期機能を追加しました（
  [ニュースレター #261][news261 close]および[BOLTs #1096][]参照）。

- [LDK #2856][]は、受信者が支払いを請求するのに十分なブロックを確保するため、
  LDKの[ルートブラインド][topic rv routing]の実装を更新しました。
  これは、[BOLTs #1131][]のルートブラインドの仕様の更新に基づくものです。

- [LDK #2442][]では、保留中の各[HTLC][topic htlc]の詳細が`ChannelDetails`に含まれるようになりました。
  これによりAPIの利用者は、HTLCを受け入れるか拒否するために、次に何が必要かを知ることができます。

- [Rust Bitcoin #2451][]は、HD導出パスが`m`で始まるという要件が削除されました。
  [BIP32][]では、文字列`m`はマスター秘密鍵を表す変数です。パスのみを参照する場合、
  `m`は不要で、文脈によっては誤っている可能性があります。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28948,6785,2818,2816,8338,2856,2442,2451,1131,1096" %}
[fsfe]: https://fsfe.org/activities/ilovefs/index.en.html
[fsf]: https://www.fsf.org/blogs/community/i-love-free-software-day-is-here-share-your-love-software-and-a-video
[sanders future]: https://delvingbitcoin.org/t/v3-and-some-possible-futures/523
[news261 close]: /ja/newsletters/2023/07/26/#ln
[teinturier better]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/37
[daftuar retrospective]: https://delvingbitcoin.org/t/analysis-of-attempting-to-imbue-ln-commitment-transaction-spends-with-v3-semantics/527/
[news286 imbued]: /ja/newsletters/2024/01/24/#v3
[news287 kindred]: /ja/newsletters/2024/01/31/#kindred-replace-by-fee
[migration email]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-February/022327.html
[news276 ml]: /ja/newsletters/2023/11/08/#mailing-list-hosting
[news288 ml]: /ja/newsletters/2024/02/07/#bitcoin-dev
[review club 28950]: https://bitcoincore.reviews/28950
[review club 24152]: https://bitcoincore.reviews/24152
[review club 24538]: https://bitcoincore.reviews/24538
[review club 27501]: https://bitcoincore.reviews/27501