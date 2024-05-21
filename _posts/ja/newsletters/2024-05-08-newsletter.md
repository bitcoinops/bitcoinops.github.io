---
title: 'Bitcoin Optech Newsletter #301'
permalink: /ja/newsletters/2024/05/08/
name: 2024-05-08-newsletter-ja
slug: 2024-05-08-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、コンセンサスの変更なくランポート署名でトランザクションを保護するアイディアを掲載しています。
また、Bitcoin Core PR Review Clubの概要や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの変更点など恒例のセクションも含まれています。

## ニュース

- **ECDSA署名に加えてコンセンサスが適用されるランポート署名:**
  Ethan Heilmanは、トランザクションを有効なものにするために
  [ランポート署名][lamport signature]による署名を要求する方法をBitcoin-Devメーリングリストに[投稿しました][heilman lamport]。
  これにより、P2SHおよびP2WSHアウトプットを使用する際に[量子耐性][topic quantum resistance]を持つようにでき、
  [Andrew Poelstraによると][poelstra lamport1]「サイズ制限がBitcoinにコベナンツがない唯一の理由」となります。
  以下にプロトコルを要約しますが、説明を簡潔かつ明確にするために、いくつかのセキュリティ上の警告を省略しています。
  そのため、この要約に基づいて実装はしないでください。

  ランポート公開鍵は、ハッシュダイジェストの2つのリストで構成されます。
  ランポート署名は、選択された2つのハッシュのプリイメージで構成されます。
  署名者と検証者の間で共有されるプログラムは、どのプリイメージが命令として公開されるかを解釈します。
  たとえば、ボブはアリスが0〜31（バイナリで0000〜1111）の数字に署名したことを検証したいとします。
  アリスは2つの乱数のリストからランポート秘密鍵を作成します:

  ```text
  private_zeroes = [random(), random(), random(), random(), random()]
  private_ones   = [random(), random(), random(), random(), random()]
  ```

  アリスは、これらの秘密の数値をそれぞれハッシュして、ランポート公開鍵を作成します:

  ```text
  public_zeroes = [hash(private_zeroes[0]), ..., hash(private_zeroes[4])]
  public_ones   = [hash(private_ones[0]), ..., hash(private_ones[4])]
  ```

  アリスはボブに公開鍵を渡します。その後アリスは21という数値を検証可能な形でボブに伝えたいと考えています。
  アリスは以下のプリイメージを送信します:

  ```text
  private_ones[0]
  private_zeroes[1]
  private_ones[2]
  private_zeroes[3]
  private_ones[4]
  ```

  21はバイナリでは10101です。ボブは、各プリイメージが以前受け取った公開鍵と一致することを検証し、
  プリイメージの知識を持つアリスだけがメッセージ「21」を生成できたことを保証します。

  ECDSA署名の場合、Bitcoinは[DERエンコーディング][der encoding]を使用し、
  署名の2つのコンポーネントから先頭のゼロ（0x00）バイトを省略します。
  ランダムな値の場合、この0x00バイトは1/256の確率で発生するため、Bitcoinの署名は当然サイズにばらつきがあります。
  このばらつきは、R値の先頭バイトが半分の確率で0x00になることで（[LOW-R grinding][topic low-r grinding]参照）悪化しますが、
  理論的には、トランザクションが1/256の確率で1バイト小さくなるようにばらつきを減らすことができます。

  高速な量子コンピューターにより、攻撃者が秘密鍵の事前知識なしに署名を作成できるようになったとしても、
  DERエンコードされたECDSA署名の長さは変化し、その署名を含むトランザクションにコミットする必要があり、
  そのトランザクションには署名を有効にするために必要な、ハッシュのプリイメージのような、追加データが含まれている必要があります。

  これにより、P2SHのredeem scriptに、トランザクションにコミットするECDSA署名のチェックと、
  ECDSA署名の実際のサイズにコミットするランポート署名を含めることができます。たとえば:

  ```text
  OP_DUP <公開鍵> OP_CHECKSIGVERIFY OP_SIZE <サイズ> OP_EQUAL
  OP_IF
    # サイズが<サイズ>バイトと等しい場合
    OP_SHA256 <ダイジェストx> OP_CHECKEQUALVERIFY
  OP_ELSE
    # サイズが<size>バイトより大きいか小さい場合
    OP_SHA256 <ダイジェストy> OP_CHECKEQUALVERIFY
  OP_ENDIF
  ```

  このスクリプトの断片を満たすために、支払人はECDSA署名を提供します。
  この署名は複製され検証されます。有効な署名でない場合、スクリプトは失敗します。
  ポスト量子の世界では、攻撃者がこのテストをパスし、検証を続行できる可能性があります。
  そして、複製された署名のサイズが測定されます。それが`<size>`バイトと等しい場合、
  支払人は`<ダイジェストx>`のプリイメージを公開する必要があります。
  この`<size>`は、一般的なケースより1バイト小さく設定でき、これは256個の署名につき1回発生します。
  それ以外の場合（一般的なケースかサイズが拡大された署名の場合）、
  支払人は`<ダイジェストy>`のプリイメージを公開する必要があります。
  実際の署名のサイズに対して有効なプリイメージが公開されない場合、スクリプトは失敗します。

  たとえECDSA署名が完全に破られたとしても、攻撃者はランポート秘密鍵を知らない限りビットコインを使用することはできません。
  これ自体は、そんなにエキサイティングなことではありません。
  P2SHとP2WSHは、スクリプトのプリイメージが秘密にされている場合、既にこの基本的な特性を[持っています][news141 key hiding]。
  しかし、ランポート署名が公開された後で、偽造したECDSA署名とランポート署名を再利用しようとする攻撃者は、
  偽造したECDSA署名が元のECDSA署名が署名と同じ長さであることを保証しなければなりません。
  このため、攻撃者は署名の長さを調整するために、正直なユーザーは実行する必要のない、
  余分な演算を実行する必要があります。

  攻撃者が実行する必要のある調整の量は、ECDSAとランポート署名の追加のペアを含めることで指数関数的に増加します。
  残念ながらECDSA署名は256回に1回しかバイトサイズが変化しないため、これを簡単に行う方法は、
  実用的なセキュリティを得るために非常に多くの署名を含める必要があります。
  Heilmanは、より効率的な仕組みを[説明しています][heilman lamport2]。
  この仕組みは依然としてP2SHのコンセンサス制限を超過していますが、
  P2WSHのより高い制限ではかろうじて機能する可能性があると考えられます。

  さらに、高速な量子コンピューターや十分に強力な古典的コンピューターを持つ攻撃者は、
  短いECDSA nonceを発見し、そのような短いnonceを予期していなかった人から簡単に盗むことができる可能性があります。
  nonceの最小サイズは既知であるため、この攻撃は回避可能ですが、そのnonceのプライベートな形式は知られていないので、
  この攻撃を回避しようとする人は、高速な量子コンピューターが発明されるまで自分のビットコインを使用できなくなります。

  このランポート署名の検証は、提案中の[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]と実質的に似ています。
  どちらの場合も、検証対象のデータ、公開鍵、署名がスタックに配置され、
  署名が公開鍵に対応しスタック上のデータにコミットした場合にのみ操作は成功します。
  Andrew Poelstraは、これを[BitVM][topic acc]スタイルの操作と組み合わせて
  [コベナンツ][topic covenants]を作成する方法を[説明しました][poelstra lamport2]が、
  それはほぼ確実に少なくとも１つのコンセンサスサイズ制限に違反することになると警告しています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Index TxOrphanage by wtxid, allow entries with same txid][review club
30000]は、Gloria Zhao (GitHub glozow)によるPRで、`txid`ではなく`wtxid`でインデックスを作成することで、
`txid`が同じ複数のトランザクションが`TxOrphanage`に同時に存在できるようにします。

このPRにより、[Bitcoin Core #28970][]で導入された臨機応変な
1-parent-1-child (1p1c) [パッケージ受け入れ][topic package relay]がより堅牢になります。

{% include functions/details-list.md
  q0="なぜtxidが同じ複数のトランザクションが同時にTxOrphanageに存在するのを許可したいのでしょうか？
      これはどのような状況を防止するのでしょう？"
  a0="定義上、オーファントランザクションのwitnessデータは、親トランザクションが未知のため検証できません。
      txidが同じ複数のトランザクション（wtxidは異なる）を受信した場合、
      どのバージョンが正しいものかを知ることは不可能です。
      TxOrphanage内に複数のトランザクションが同時に存在できるようにすることで、
      攻撃者が正しいバージョンのさらなる受け入れを妨げる不正な細工をしたバージョンを送信することを防止します。"
  a0link="https://bitcoincore.reviews/30000#l-11"

  q1="txidが同じでwitnessが異なるオーファンにはどのようなものがありますか？"
  a1="txidが同じでwitnessが異なるトランザクションは、無効な署名（したがって無効なトランザクション）や、
      より大きなwitness（ただし手数料は同じなため手数料率は下がる）などが考えられます。"
  a1link="https://bitcoincore.reviews/30000#l-67"

  q2="txid毎に1つのエントリーのみを許可する場合の影響を考えてみましょう。
      悪意あるピアが、親の手数料率は低くない、オーファントランザクションの細工したバージョンを送信した場合どうなりますか？
      最終的にこの子をmempoolに受け入れるには、何が必要でしょうか？（回答は複数あります）"
  a2="細工した子がオーファンにあり、有効な手数料率が低くない親を受け取った場合、その親はmempoolに受け入れられ、
      細工した子は無効化されオーファンから削除されます。"
  a2link="https://bitcoincore.reviews/30000#l-52"

  q3="（親は低手数料率で、子と一緒に送信する必要がある）1-parent-1-child (1p1c)パッケージがある場合の影響を考えてみましょう。
      正しい親と子のパッケージをmempoolに受け入れるためには何が必要でしょうか？"
  a3="親は低手数料率なので、単独ではmempoolに受け入れられません。
      ただし、[Bitcoin Core #28970][]以降、子がオーファンにいる場合は、
      便宜的に1p1cパッケージとして受け入れられる可能性があります。オーファンの子が細工されていた場合、
      その親はmempoolから拒否され、子もオーファンから削除されます。"
  a3link="https://bitcoincore.reviews/30000#l-60"

  q4="<!--instead-of-allowing-multiple-transactions-with-the-same-txid-where-we-are-obviously-wasting-some-space-on-a-version-we-will-not-accept-should-we-allow-a-transaction-to-replace-an-existing-entry-in-the-txorphanage-what-would-be-the-requirements-for-replacement-->txidが同じ複数のトランザクションを許可する代わりに（受け入れられないバージョンで明らかにスペースを無駄にしている場合）、
      トランザクションがTxOrphanage内の既存のエントリーを置き換えられるようにする必要がありますか？
      この置換の要件はなんでしょう？"
  a4="トランザクションを既存のトランザクションと置き換えることを許可するかどうかを判断するための適切な指標はないようです。
      検討できる可能性のある手段の1つは、同じピアから重複トランザクションのみを置き換えることです。"
  a4link="https://bitcoincore.reviews/30000#l-80"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Libsecp256k1 v0.5.0][]は、Bitcoin関連の暗号操作を実行するためのこのライブラリのリリースです。
  鍵生成と署名を高速化し（[先週のニュースレター][news300 secp]参照）、
  コンパイル後のサイズが削減され「特に組み込みユーザーの利益になることが期待されます」。
  また、公開鍵をソートする関数も追加されています。

- [LND v0.18.0-beta.rc1][]は、この人気のLNノードの次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [Bitcoin Core #28970][]および[#30012][bitcoin core #30012]は、
  P2Pプロトコルへの変更を必要としない限定された形式のone-parent-one-child (1p1c)
  [パッケージリレー][topic package relay]のサポートを追加します。
  アリスが彼女のピアの[BIP133][]feefilter設定を下回る親トランザクションを持っており、
  ピアの誰もそれを受け入れないと知っているため、それをリレーすることを思いとどまっている状況を想像してください。
  アリスはまた上記のfeefilterに対して、親と一緒に十分な手数料率を支払う子トランザクションも持っています。
  アリスと彼女のピアは以下のプロセスを実行します。

  - アリスは子トランザクションをピアにリレーします。

  - ピアはそのトランザクションの親を持っていないことに気付き、そのトランザクションをオーファンプールに入れます。
    10年以上の間、Bitcoin Coreのすべてのバージョンは、
    親より前に受信した限られた数のトランザクションを一時的に保存するオーファンプールを持っています。
    これは、P2Pネットワーク上で、トランザクションが時に順番どおりに受信されないことがあるという事実を補うものです。

  - 数分後、アリスは親トランザクションをピアにリレーします。

  - このPRがマージされる前は、ピアは親の手数料率が低すぎることに気付き、その受け入れを拒否していました。
    親トランザクションを評価したので、子トランザクションもオーファンプールから削除されます。
    このPRのマージにより、ピアはオーファンプールに親の子があることに気付き、
    両方のトランザクションの合計手数料率を一緒に評価し、その手数料率が下限を上回っている場合（
    そしてノードのローカルポリシーに従って両方とも許容される場合）、両方をmempoolに入れることを許可します。

  この仕組みは攻撃者によって破られる可能性があることが知られています。
  Bitcoin Coreのオーファンプールは、すべてのピアによって追加できる循環バッファであるため、
  この種のパッケージリレーを阻止したい攻撃者は、多数のオーファントランザクションをピアにスパム送信し、
  親が受信される前に手数料を支払う子トランザクションが強制排除される可能性があります。
  [後続のPR][bitcoin core #27742]では、この懸念を解消するために、
  各ピアにオーファンプールの一部への排他的アクセスを与えることができます。
  別の関連するPRについては、このニュースレターの _Bitcoin PR Review Club_ セクションもご覧ください。
  P2Pプロトコルの変更を必要とする追加の改善については、[BIP331][]で説明されています。

- [Bitcoin Core #28016][]は、DNSシードをポーリングする前に、
  すべてのシードノードがポーリングされるのを待つようになりました。
  ユーザーはシードノードとDNSシードの両方を設定できます。
  シードノードは通常のBitcoinフルノードで、Bitcoin CoreはノードへのTCP接続を開き、
  潜在的なピアのアドレスのリストを要求し、接続を閉じることができます。
  DNSシードはDNS経由で潜在的なピアのIPアドレスのリストを返します。
  これによりその情報がDNSネットワーク全体に送信されキャッシュされるため、
  DNSシードサーバーの所有者は、情報を要求しているクライアントのIPアドレスを知ることができません。
  デフォルトでは、Bitcoin Coreは既にIPアドレスを知っているピアに接続しようとします。
  その接続がいずれも成功しない場合は、DNSシードをポーリングします。どのDNSシードにも到達できない場合は、
  ハードコードされたシードノードのセットに接続します。ユーザーはオプションで、
  接続するシードノードの独自のリストを提供できます。

  このPRがマージされる前は、ユーザーがシードノードのポーリングを設定し、
  DNSシードも使用するデフォルト設定を維持している場合、両方に並行して接続され、
  どちらか速い方がノードが試行するするピアのアドレスを支配していました。
  DNSのオーバーヘッドが低いこと、
  ユーザーに物理的に近いサーバーによって結果が既にキャッシュされている可能性があるという事実を考慮すると、
  通常はDNSが勝つでしょう。このPRがマージされた後は、デフォルト以外の`seednode`オプションを設定するユーザーは、
  デフォルトの結果よりもそのオプションの結果を好むと考えられるため、シードノードが優先されます。

- [Bitcoin Core #29623][]では、接続されているピアとローカル時刻が10分以上ずれているような場合に、
  ユーザーに警告するためのさまざまな改善が行われています。時計が狂っているノードは、
  有効なブロックを一時的に拒否する可能性があり、いくつかの深刻なセキュリティ問題につながる可能性があります。
  これは、コンセンサスコードからネットワーク調整時刻を削除したことに続くものです（[ニュースレター #288][news288 time]参照）。

## 訂正

ECDSA署名とランポート署名のサンプルスクリプトは、元々`OP_CHECKSIG`を使用していましたが、
公開後に`OP_CHECKSIGVERIFY`を使用するように更新されました。間違いを報告してくれたAntoine Poinsotに感謝します。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30012,28016,29623,27742,28970" %}
[lnd v0.18.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc1
[libsecp256k1 v0.5.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.5.0
[heilman lamport]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+XyW8wNOekw13C5jDMzQ-dOJpQrBC+qR8-uDot25tM=XA@mail.gmail.com/
[lamport signature]: https://en.wikipedia.org/wiki/Lamport_signature
[poelstra lamport1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZjD-dMMGxoGNgzIg@camus/
[der encoding]: https://en.wikipedia.org/wiki/X.690#DER_encoding
[heilman lamport2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+UnxB2vKQpJAa-z-qGZQfpR1ZeW3UyuFFZ6_WTWFYGfjw@mail.gmail.com/
[poelstra lamport2]: https://gnusha.org/pi/bitcoindev/Zjo72iTDYjwwsXW3@camus/T/#m9c4d5836e54ed241c887bcbf3892f800b9659ee2
[news300 secp]: /ja/newsletters/2024/05/01/#libsecp256k1-1058
[news288 time]: /ja/newsletters/2024/02/07/#bitcoin-core-28956
[news141 key hiding]: /ja/newsletters/2021/03/24/#p2pkh-hides-keys
[review club 30000]: https://bitcoincore.reviews/30000
