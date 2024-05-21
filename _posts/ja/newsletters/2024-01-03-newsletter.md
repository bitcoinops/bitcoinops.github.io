---
title: 'Bitcoin Optech Newsletter #283'
permalink: /ja/newsletters/2024/01/03/
name: 2024-01-03-newsletter-ja
slug: 2024-01-03-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNDの過去の脆弱性の開示の共有や、手数料依存のタイムロックの提案の概要、
トランザクションクラスターを使用して手数料の推定を改善するためのアイディアの説明、
ディスクリプターで使用不可能な鍵を指定する方法についての説明、
v3トランザクションリレーの提案におけるPinningのコスト調査、
ディスクリプターをPSBTに含められるようにするBIP提案の言及、
プログラムが正しく実行されたことを証明するためにMATT提案とともに使用できるツールの発表、
プールされたUTXOから高効率なグループの退出を可能にする提案の検討および、
Bitcoin Core向けに提案されている新しいコイン選択戦略について掲載しています。
また、新しいソフトウェアリリースの発表や、人気のあるBitcoinインフラストラクチャの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **過去のLNDの脆弱性の開示:** Niklas Göggeは、以前[責任を持って開示した][topic responsible disclosures]
  2つの脆弱性についてDelving Bitcoinに[投稿し][gogge lndvuln]、
  実際にそれはLNDの修正バージョンのリリースにつながりました。
  LND 0.15.0以降を使用しているユーザーは脆弱ではありません。
  それより前のバージョンのLNDを使用している人は、
  これらの脆弱性や古いリリースに影響する他の既知の脆弱性のため、
  すぐにアップグレードを検討する必要があります。簡単に説明すると、
  公開された2つの脆弱性は、次のとおりです:

  - DoSの脆弱性により、LNDがメモリ不足によりクラッシュする可能性があります。
    LNDが実行されていない場合、時間に敏感なトランザクションがブロードキャストできず、
    資金の損失につながる可能性があります。

  - 検閲の脆弱性により、攻撃者が、LNDノードがネットワーク上の対象チャネルの更新を学習するのを阻止できる可能性があります。
    攻撃者はこれを利用してノードが送信する支払いに対して特定のルートを選択するようバイアスし、
    より多くの転送手数料とノードが送信した支払いに関するより多くの情報を攻撃者に与える可能性があります。

  Göggeは、2年以上前にLND開発者に最初の情報を開示し、両方の脆弱性の修正を含むLNDのバージョンは18ヶ月以上前から入手可能でした。
  Optechは、どちらの脆弱性の影響を受けたユーザーも確認していません。

- **<!--fee-dependent-timelocks-->手数料依存のタイムロック:** John Lawは、
  ブロックの手数料率の中央値がユーザーが選択したレベルを下回った場合にのみ
  トランザクションの[タイムロック][topic timelocks]をアンロック（期限切れに）できるようにするソフトフォークの
  大まかな提案をBitcoin-DevメーリングリストおよびLightning-Devメーリングリストに[投稿しました][law fdt]。
  たとえば、アリスはボブとのペイメントチャネルに資金をデポジットしたいものの、
  ボブが利用不能な場合に払い戻しを受けられるようにもしたいため、
  アリスはボブに、自分が支払った資金をいつでも請求できるオプションを与えるのと同時に、
  アリス自身はタイムロックの期限が切れた後にデポジットの返金を請求できるオプションを持ちます。
  タイムロックの期限が近づくにつれて、ボブは自分の資金を請求しようとしますが、
  現在の手数料率は両者がコントラクトを使い始めた時に予想していたよりもはるかに高くなっています。
  ボブは、手数料に必要な十分なビットコインを持っていないか、
  手数料の高さを考えると請求トランザクションを作成するのに法外なコストがかかるため、
  自分の資金を承認するためのトランザクションを得ることができません。
  現在のBitcoinプロトコルでは、ボブが行動できない場合、アリスは返金の請求が可能です。
  Lawの提案では、アリスとボブがコントラクトの交渉時に指定した金額を下回る手数料率の中央値を持つブロックが発生するまで、
  アリスが返金を請求できないタイムロックの期限が延期されることになります。
  これにより、ボブは許容可能な手数料率でトランザクションを承認する機会を確実に得ることができます。

  Lawは、これにより[元のライトニングネットワークの論文][original Lightning Network paper]で指摘されていた、
  _Forced Expiration Flood_ の長年の懸念の1つが解消されると指摘しています。
  これは、同時に閉じられるチャネルの数が多すぎると
  タイムロックが期限切れになる前にすべてのチャネルを承認するのに必要なブロックスペースが不足し、
  一部のユーザーが損失を被る可能性があるという問題です。
  手数料依存のタイムロックが設定されている場合、閉じられるチャネルのユーザーは、
  手数料依存のロックを超えるまで手数料率を競り上げ、その後は手数料が十分低くなり、
  すべてのユーザーが利用できる金額になるまでタイムロックの期限が延期されます。
  LNチャネルには、現在2人のユーザーのみが関与していますが、3人以上のユーザーがUTXOを共有する
  [チャネルファクトリー][topic channel factories]や[Joinpool][topic joinpools]は、
  Forced Expiration Floodに対してさらに脆弱であるため、このソリューションはセキュリティを大幅に強化します。
  Lawはまた、これらの構成の少なくとも一部では、手数料が下がるまで資本がコントラクトにロックされるため、
  返金条件を持つ参加者（先程の例ではアリス）が手数料の増加によって最も不利益を被る当事者であると指摘しています。
  手数料依存のロックは、その当事者に（短期間で多数のチャネルを閉じないなど）手数料率を低く抑える行動をする追加のインセンティブを与えます。

  手数料依存のタイムロックの実装の詳細は、コントラクト参加者が簡単に使用でき、
  タイムロックを検証するためにフルノードが保存する必要がある追加情報の量を最小限に抑えるよう選択されています。

  この提案は、適度な議論が行われ、
  手数料依存のタイムロックパラメーターを[Taproot][topic taproot]のannexに[保存する][riard fdt]ことや、
  軽量クライアントをサポートするためにブロックに手数料の中央値を[コミット][boris fdt]させること、
  アップグレードされたプルーニングノードがフォークをどのようにサポートできるかについての[詳細][harding pruned]などが提案されました。
  マイナーが帯域外の手数料、つまり通常のトランザクション手数料の仕組みとは別に支払われる
  トランザクションを承認するための手数料（特定のマイナーに直接支払うなど）を受け入れることの影響について、
  Lawと[他のメンバー][evo fdt]との間で追加の議論がありました。

- **<!--cluster-fee-estimation-->クラスター手数料推定:**
  Abubakar Sadiq Ismailは、Bitcoin Coreでの手数料推定を改善するために、
  [クラスターmempool][topic cluster mempool]の設計から得られたいくつかのツールと洞察を使用することについて、
  Delving Bitcoinに[投稿しました][ismail cluster]。
  Bitcoin Coreの現在の手数料推定アルゴリズムは、
  ローカルノードのmempoolに入るトランザクションが承認されるまでにかかるブロック数を追跡します。
  承認が行われると、トランザクションの手数料率を使用して、
  同様の手数料率のトランザクションが承認されるまでにかかる時間の予測が更新されます。

  このアプローチでは、一部のトランザクションはBitcoin Coreによって手数料率目的で無視され、
  他のトランザクションが誤ってカウントされる可能性があります。これは、
  子トランザクション（および他の子孫）がマイナーに親（および他の祖先）を承認するように促す[CPFP][topic cpfp]の結果です。
  子トランザクション自体は手数料率が高いかもしれませんが、その手数料と祖先の手数料を合わせて考慮すると、
  手数料率は大幅に低くなり、承認に予想よりも時間がかかる可能性があります。
  それが合理的な手数料の過大評価を引き起こすのを防ぐため、Bitcoin Coreは
  親が承認されていない時にmempoolに入るトランザクションを使用して手数料の推定を更新しません。
  同様に、親トランザクション自体の手数料は低い場合がありますが、
  子孫の手数料も考慮すると手数料率が大幅に高くなり、予想より早く承認が行われる可能性があります。
  Bitcoin Coreの手数料推定は、この状況を補うものではありません。

  クラスターmempoolは、関連するトランザクションをまとめ、一緒にマイニングすると利益が得られるチャンクへの分割をサポートします。
  Ismailは、個々のトランザクション（チャンクが単一のトランザクションであることもありますが）ではなく、
  チャンクの手数料率を追跡し、ブロック内で同じチャンクを見つけようとすることを提案しています。
  チャンクが承認されると、個々のトランザクションの手数料率ではなく、
  そのチャンクを使用して手数料の推定が更新されます。

  この提案は好評で、開発者たちは更新されたアルゴリズムで考慮する必要がある詳細について議論しました。

- **<!--how-to-specify-unspendable-keys-in-descriptors-->ディスクリプター内で使用不可能な鍵を指定する方法:**
  Salvatore Ingalaは、[ディスクリプター][topic descriptors]、
  特に[Taproot][topic taproot]のディスクリプターで秘密鍵が知られていない鍵を指定できるようにする（その鍵の使用を防ぐ）方法について、
  Delving Bitcoinで[議論][ingala undesc]を開始しました。
  このための重要なコンテキストの1つは、scriptpathでのみ支払いが可能なTaprootアウトプットに送金することです。
  これを行うには、keypathに使用不可能な鍵をセットする必要があります。

  Ingalaは、ディスクリプター内で使用不可能な鍵を使用する際のいくつかの課題と、
  さまざまなトレードオフがあるいくつかの提案されたソリューションについて説明しました。
  Pieter Wuilleは、使用不可能な鍵に関する[特定の][wuille undesc2]アイディアを含む、
  ディスクリプターに関する最近の議論を要約しました。Josie Bakerは、
  使用不可能な鍵が定数値（BIP341のNUMS（nothing-up-my-sleeve）など）にできない理由について詳しく訪ねました。
  これを使うと、使用不可能な鍵が使用されていることを誰もがすぐ知ることができます。これは、
  [サイレントペイメント][topic silent payments]などの一部のプロトコルにとって利点となる可能性があります。
  Ingalaは、Bakerに次のように回答しました。「これはフィンガープリントの一種です。
  必要に応じていつでもこの情報を自分で公開できますが、標準によって強制されない方が素晴らしいでしょう。」
  Wuilleはさらに、証明を生成するためのアルゴリズムについて回答しました。
  この記事の執筆時点でのスレッドの最後の投稿でIngalaは、
  使用不可能な鍵に関連するポリシーを定義する作業の一部が、
  ディスクリプターと[BIP388][]ウォレットポリシーに分割できることを指摘しました。

- **v3トランザクションのPinningコスト:** Peter Toddは、
  LNなどのコントラクトプロトコルに対する[トランザクションPinning][topic transaction pinning]に関する
  [v3トランザクションリレー][topic v3 transaction relay]ポリシー案の分析をBitcoin-Devメーリングリストに[投稿しました][todd v3]。
  たとえば、ボブとマロリーがLNチャネルを共有している場合、ボブはチャネルを閉じたいと思い、
  自分の現在のコミットメントトランザクションと[CPFP][topic cpfp]を通じて手数料を提供する小さな子トランザクション
  （合計500 vbyte）をブロードキャストします。マロリーは、マイナーに到達する前にP2Pネットワーク上でボブのトランザクションを検出し、
  自分のコミットメントトランザクションと非常に大きな子トランザクションを送信します。
  マロリーの2つのトランザクションの合計サイズは100,000 vbyteで、
  合計の手数料率はボブのものよりも低いものです。
  Bitcoin Coreの現在のデフォルトリレーポリシーと[パッケージリレー][topic package relay]の現在の提案を使用して、
  ボブはマロリーの2つのトランザクションを[置き換える][topic rbf]ことを試みることができますが、
  [BIP125][]のルール#3に従って、マロリーのトランザクションで使用される帯域幅の手数料を支払う必要があります。
  ボブが最初に10 sat/vbyte（合計5,000 sats）の手数料率を使用し、
  マロリーが5 sat/vbyte (合計500,000 sats)の手数料率を使用していた場合、
  ボブは置換にあたって最初に支払った金額の100倍を支払う必要があります。
  それがボブの許容額を超えている場合、マロリーの巨大な低手数料率のトランザクションは、
  重要なタイムロックの期限切れになる前に承認されず、マロリーがボブから資金を盗むことが可能になる可能性があります。

  v3トランザクションリレーの提案では、ルールにより、v3トランザクションにオプトインしているトランザクションは、
  最大1つの未承認の子トランザクションのみを持つことができ、その子トランザクションはリレーされ、
  mempoolに保存され、v3ポリシーに従うことに同意したノードによってマイニングされます。
  Peter Toddが彼の記事で示しているように、それでもマロリーはボブの費用をボブが支払いたい金額の約1.5倍に増やすことができます。
  回答者らは、悪意ある取引相手の場合、ボブはより多くの金額を支払わなければならないリスクがあることにほぼ同意しましたが、
  現在のリレーポリシーの下でボブが支払う必要があるかもしれない100倍以上よりは、僅かな倍率の方がはるかに良いと指摘しました。

  会話ではさらに、v3リレールールと[エフェメラルアンカー][topic ephemeral anchors]の具体的な内容、
  現在利用可能な[CPFP carve-out][topic cpfp carve out]と
  [アンカーアウトプット][topic anchor outputs]との比較について議論されました。

- **PSBTのドラフトBIPのディスクリプター:** SeedHammerチームは、
  [PSBT][topic psbt]に[ディスクリプター][topic descriptors]を含めるためのBIPのドラフトを
  Bitcoin-Devメーリングリストに[投稿しました][seedhammer descpsbt]。
  提案されている規格では、ディスクリプターが含まれている場合にPSBTがトランザクションデータを省略できるため、
  主な使用目的はウォレット間での転送のためにディスクリプターをPSBT形式でカプセル化することだと思われます。
  これは、ソフトウェアウォレットがアウトプットの情報をハードウェア署名デバイスに転送する場合や、
  マルチシグのフェデレーション内の複数のウォレットが作成したいアウトプットに関する情報を転送する場合に便利です。
  この記事の執筆時点で、メーリングリスト上でBIPのドラフトへの返信はありませんが、
  11月の初期提案に関する[投稿][seedhammer descpsbt2]には[フィードバック][black descpsbt]が寄せられました。

- **MATTで提案されたopcodeを使用した任意のプログラムの検証:**
  Johan Torås Halsethは[elftrace][]についてDelving Bitcoinに[投稿しました][halseth ccv]。
  elftraceは、[MATT][]のソフトフォーク提案の`OP_CHECKCONTRACTVERIFY` opcodeを使用して、
  任意のプログラムが正常に実行された場合にコントラクトプロトコルの参加者が資金を請求できるようにする概念実証プログラムです。
  コンセプトはBitVM（[ニュースレター #273][news273 bitvm]参照）に似ていますが、
  プログラムの実行検証用に特別に設計されたopcodeを使用するため、Bitcoinの実装はよりシンプルです。
  elftraceは、Linuxの[ELF][]形式を使用して、RISC-Vアーキテクチャ用にコンパイルされたプログラムで動作します。
  ほとんどすべてのプログラマーがそのターゲット用のプログラムを簡単に作成できるため、elftraceの使用がとても簡単になります。
  この記事の執筆時点では、フォーラムの投稿には返答はありません。

- **Fraud Proofを使用した委任によるPool退出時の支払いのバッチ処理:**
  Salvatore Ingalaは、複数のユーザーがUTXOを共有する[Joinpool][topic joinpools]や
  [チャネルファクトリー][topic channel factories]などのマルチパーティコントラクトにおいて、
  一部のユーザーがコントラクトから退出したいものの他のユーザーの（意図的であるにせよないにせよ）応答がない場合の改善案を
  Delving Bitcoinに[投稿しました][ingala exit]。
  このようなプロトコルを構築する一般的な方法は、
  ユーザーが退出したい場合にブロードキャストできるオフチェーントランザクションを各ユーザーに与えることです。
  つまり、最良のケースでも、5人のユーザーが退出したい場合、各ユーザは個別のトランザクションをブロードキャストする必要があり、
  それらのトランザクションには少なくとも1つのインプットと1つのアウトプットがあり、
  合計5つのインプットと5つのアウトプットができます。
  Ingalaは、これらのユーザーが協力して1つのインプットと5つのアウトプットを持つ単一のトランザクションで退出する方法を提案しています。
  これにより、典型的な[支払いのバッチ処理][topic payment batching]でトランザクションサイズが約50%削減されます。

  非常に多数のユーザーがいる複雑なマルチパーティコントラクトでは、
  オンチェーンサイズの削減は簡単に50%を大幅に超える可能性があります。
  さらに良いことに、5人のアクティブユーザーが単に自分たちだけが関与する新しい共有UTXOに資金を移動したい場合は、
  単一インプット、単一アウトプットのトランザクションを使用でき、5人の場合は約80%の節約、
  100人の場合は99%の節約になります。トランザクションの手数料率が高く、
  多くのユーザーのコントラクト内の残高が比較的少ない場合、
  大規模なユーザーグループが資金をあるコントラクトから別のコントラクトに移動するのにこの大幅な節約が重要になる可能性があります。
  たとえば、100人のユーザーがそれぞれ10,000 sats（執筆時点で$4 USD）の残高を持っており、
  コントラクトから退出して新しいコントラクトに参加するために各ユーザーが個別にトランザクション手数料を支払わなければならない場合、
  100 vbyteというありえないほど小さなトランザクションサイズであっても、
  100 sats/vbyteのトランザクション手数料が彼らの残高全体を消費することになります。
  もし、100万satsの資金を1回の200 vbyteのトランザクションで100 sats/vbyteで移動できる場合、
  各ユーザーが支払うのは200 satsのみ（彼らの残高の2%）です。

  支払いのバッチ処理は、マルチパーティコントラクトプロトコルの参加者の1人に、
  他のアクティブな参加者が合意したアウトプットに対する共有資金の支払いを構築させることで実現されます。
  コントラクトではこれを許可していますが、トランザクションを構築した当事者が債権に資金を提供した場合のみで、
  コントラクトプロトコルの資金が不正に使用されたことを証明できるメンバーいた場合、その保証金を失います。
  保証金の額は、構築当事者が不正な資金の送金を試みて得られる金額よりもかなり多くなければなりません。
  一定期間内に構築当事者が不適切な行為を行ったことを示すFraud Proofを誰も提出しなかった場合、
  保証金は当事者に返還されます。Ingalaは、[OP_CAT][]、`OP_CHECKCONTRACTVERIFY`および
  提案中の[MATT][]ソフトフォークの金額のイントロスペクションを使用して、
  この機能をマルチパーティコントラクトプロトコルにどのように追加できるかの概要を説明し、
  [OP_CSFS][topic op_checksigfromstack]と
  [Tapscript][topic tapscript]内で64 bitの算術演算子も追加すると簡単になると述べています。

- **<!--new-coin-selection-strategies-->新しいコイン選択戦略:**
  Mark Erhardtは、Bitcoin Coreの[コイン選択][topic coin selection]戦略でユーザーが経験した可能性のあるエッジケースについて
  Delving Bitcoinに[投稿し][erhardt coin]、高手数料率でのウォレットトランザクションで使用されるインプットの数を減らすことで、
  このエッジケースに対処する2つの新しい戦略を提案しています。
  彼はまた、Bitcoin Coreのすべての戦略（実装済みのものと彼が提案したものの両方）の長所と短所を要約し、
  さまざまなアルゴリズムを使用して実行したシミュレーションから複数の結果を提供しています。
  最終的な目標は、Bitcoin Coreが一般に、長期にわたって手数料に使用されるUTXOの値の割合を最小限に抑える
  インプットのセットを選択すると同時に、手数料率が高い場合に不必要に大きなトランザクションを作成しないようにすることです。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 23.11.2][]は、Core Lightningのユーザーが作成したインボイスを
  LNDノードが確実に支払うことができるようにするバグ修正のリリースです。
  詳細については、以下の「注目すべき変更」セクションのCore Lightning #6957をご覧ください。

- [Libsecp256k1 0.4.1][]は、「x86_64のデフォルト設定を使用する場合に、
  ECDH演算の速度を僅かに向上させ、多くのライブラリ関数のパフォーマンスを大幅に向上させる」マイナーリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #28349][]では、C++20互換のコンパイラの使用が必要になり、
  将来のPRでC++20の機能が使用できるようになります。PRの説明にあるように、
  「C++20は、コンパイル時により多くのものを強制できるため、より安全なコードを書くことができます」。

- [Core Lightning #6957][]は、デフォルト設定でCore Lightningによって生成されたインボイスに対して
  LNDユーザーの支払いを妨げていた、意図しない非互換性を修正しています。
  問題は、受信者が支払いを請求するために必要な最大ブロック数を指定する`min_final_cltv_expiry`です。
  [BOLT2][]では、この値をデフォルトで18に設定することを提案していますが、
  LNDはCore Lightningがデフォルトで受け入れる値よりも低い9を使用しています。
  この問題は、Core Lightningのインボイスに値18を要求するフィールドを含めることで対処されました。

- [Core Lightning #6869][]は、`listchannels` RPCを更新し、
  [非公表チャネル][topic unannounced channels]をリストしなくなりました。
  この情報が必要なユーザーは、`listpeerchannels` RPCを使用できます。

- [Eclair #2796][]は、脆弱性を修正するため[logback-classic][]への依存関係を更新しました。
  Eclairは脆弱性の影響を受ける機能を直接使用していませんが、アップグレードにより、
  その機能を使用するプラグインや関連ソフトウェアが脆弱になることがありません。

- [Eclair #2787][]は、BitcoinHeaders.netからヘッダー取得のサポートを最新のAPIにアップグレードしました。
  DNS経由のヘッダー取得は、ノードを[エクリプス攻撃][topic eclipse attacks]から保護するのに役立ちます。
  DNSベースのヘッダー取得を当初サポートしていたEclairの説明については、
  [ニュースレター #123][news123 headers]をご覧ください。BitcoinHeaders.netを使用する他のソフトウェアは、
  すぐに新しいAPIにアップグレードする必要があります。

- [LDK #2781][]および[#2688][ldk #2688]は、[ブラインドペイメント][topic rv routing]の送受信、
  特にマルチホップブラインドパスのサポートを更新し、[オファー][topic offers]に少なくとも1つのブラインドホップが常に含まれるという要件に準拠します。

- [LDK #2723][]は、直接接続を使用した[Onionメッセージ][topic onion messages]の送信のサポートを追加しています。
  送信者が受信者へのパスを見つけられないが、
  受信者のネットワークアドレス（たとえば、受信者はパブリックノードでIPアドレスをゴシップしている場合など）を知っている場合、
  送信者は受信者に直接ピア接続を開き、メッセージを送信し、必要に応じて接続を閉じます。
  これにより、ネットワーク上の少数のノードのみがOnionメッセージをサポートする場合でも（現在はそうなっています）、
  Onionメッセージは正常に機能します。

- [BIPs #1504][]は、BIP2を更新し、BIPをMarkdownで記述できるようになりました。
  これまでは、すべてのBIPをMediawikiマークアップで記述する必要がありました。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28349,6957,6869,2796,2787,2781,2723,1504,2688" %}
[gogge lndvuln]: https://delvingbitcoin.org/t/denial-of-service-bugs-in-lnds-channel-update-gossip-handling/314/1
[law fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004254.html
[original lightning network paper]: https://lightning.network/lightning-network-paper.pdf
[riard fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[boris fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[harding pruned]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004256.html
[evo fdt]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004260.html
[ismail cluster]: https://delvingbitcoin.org/t/package-aware-fee-estimator-post-cluster-mempool/312/1
[ingala undesc]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/1
[wuille undesc]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/2
[wuille undesc2]: https://gist.github.com/sipa/06c5c844df155d4e5044c2c8cac9c05e#unspendable-keys
[todd v3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-December/022211.html
[seedhammer descpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-December/022200.html
[seedhammer descpsbt2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022184.html
[black descpsbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-November/022186.html
[halseth ccv]: https://delvingbitcoin.org/t/verification-of-risc-v-execution-using-op-ccv/313
[elftrace]: https://github.com/halseth/elftrace
[matt]: /ja/newsletters/2022/11/16/#covenant-bitcoin
[news273 bitvm]: /ja/newsletters/2023/10/18/#payments-contingent-on-arbitrary-computation
[elf]: https://ja.wikipedia.org/wiki/Executable_and_Linkable_Format
[ingala exit]: https://delvingbitcoin.org/t/aggregate-delegated-exit-for-l2-pools/297
[erhardt coin]: https://delvingbitcoin.org/t/gutterguard-and-coingrinder-simulation-results/279/1
[logback-classic]: https://logback.qos.ch/
[news123 headers]: /en/newsletters/2020/11/11/#eclair-1545
[bip388]: https://github.com/bitcoin/bips/pull/1389
[core lightning 23.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.11.2
[libsecp256k1 0.4.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.4.1
