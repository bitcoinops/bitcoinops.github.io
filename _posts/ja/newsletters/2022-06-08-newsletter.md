---
title: 'Bitcoin Optech Newsletter #203'
permalink: /ja/newsletters/2022/06/08/
name: 2022-06-08-newsletter-ja
slug: 2022-06-08-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、Bitcoin Core PR Review Clubミーティングの概要や、
新しいソフトウェアリリースとリリース候補のリスト、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点など、
恒例のセクションを掲載しています。

## ニュース

*今週は重要なニュースはありませんでした。*

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Miniscript support in Output Descriptors][reviews 24148]は、
Antoine PoinsotとPieter WuilleによるPRで、
[ディスクリプター][topic descriptors]における監視専用の[Miniscript][topic miniscript]のサポートを導入するものです。
参加者は2回のミーティングでPRをレビューしました。
議論のトピックは、Miniscriptの用途と、細工（マリアビリティ）に関する考察および、ディスクリプターのパーサーの実装に関してでした。

{% include functions/details-list.md

  q0="<!--which-types-of-analysis-enabled-by-miniscript-would-be-helpful-for-which-use-cases-or-applications-->Miniscriptによって可能になるどんなタイプの分析が、どんなユースケースやアプリケーションの役に立ちますか？"
  a0="いくつかのユースケースと分析のタイプについて議論されました。
  Miniscriptは、最大witnessサイズの分析を可能にし、それにより与えられた手数料率でアウトプットを使用するための最悪の場合のコストを算出します。
  トランザクションのweightが予測可能になると、L2プロトコルの開発者はより信頼性の高い手数料引き上げの仕組みを書くことができます。
  さらに、あるポリシーが与えられると、コンパイラーは最小限のMiniscriptのスクリプトを生成し、
  （Miniscriptはすべてのスクリプトのサブセットをエンコードするだけなので、必ずしも最小とは限りませんが）
  それは手動で作成したものよりも小さくなる可能性があります。
  参加者は、Miniscriptが過去にLNのテンプレートの最適化に役立ったことに注目しました。
  最後に、構成により、複数の参加者が複雑な使用条件を組み合わせて、そららのすべてを完全に理解することなく、
  結果のスクリプトの正しさを保証することができます。"
  a0link="https://bitcoincore.reviews/24148#l-41"

  q1="<!--miniscript-expressions-can-be-represented-as-trees-of-nodes-where-each-node-represents-a-fragment-what-does-it-mean-when-a-node-is-sane-or-valid-do-they-mean-the-same-thing-->
  Miniscriptの式は、ノードのツリーとして表現でき、各ノードはフラグメントを表します。
  ノードが正常（sane）または有効(valid)であるというのはどういう意味ですか？これらは同じ意味ですか？"
  a1="各ノードはフラグメントタイプ（`and_v`、`thresh`、`multi`など）と引数を持ちます。
  有効（valid）なノードの引数は、フラグメントタイプが期待するものと一致します。
  正常（sane）なノードは、有効かつそのスクリプトのセマンティクスがそのポリシーに合致し、
  コンセンサスが有効で標準に準拠し、細工不可能な解のみを持ち、
  タイムロックの単位を混合せず（つまり、ブロック高と時間の両方を使用せず）、
  重複する鍵を持たないものです。この定義のように、これらの2つの特性は同じではありません。
  すべての正常（sane）なノードは有効（valid）ですが、すべての有効（valid）なノードが正常（sane）であるとは限りません。"
  a1link="https://bitcoincore.reviews/24148#l-107"

  q2="<!--what-does-it-mean-for-an-expression-to-be-non-malleably-satisfiable-after-segwit-why-do-we-still-need-to-worry-about-malleability-->
  式が細工不可能で充足可能というのはどういう意味ですか？Segwit展開後もまだトランザクションの細工を気にする必要があるのでしょうか？"
  a2="（例えば、対応する秘密鍵やその他の前提条件にアクセスできない）第三者が、
  スクリプトを修正でき使用条件を満たすことができる場合、スクリプトは細工可能であると言えます。
  Segwitは、トランザクションの細工の可能性を完全に排除するものではありません。
  未承認の子孫の有効性を損なうようなトランザクションの細工はできませんが、
  細工の可能性は他の理由でまだ問題になる可能性があります。
  例えば、攻撃者が余分なデータをwitnessに詰め込み、それでも使用条件を満たせる場合、
  攻撃者はトランザクションの手数料率を引き下げ、トランザクションの伝播に悪影響を与える可能性があります。
  細工不可能な充足式は、既存の充足条件を別の充足条件に修正するようなオプションを第三者に与えることはありません。
  より完全な回答は[こちら][sipa miniscript]でご覧いただけます。"
  a2link="https://bitcoincore.reviews/24148#l-170"

  q3="<!--which-function-is-responsible-for-parsing-the-output-descriptor-strings-how-does-it-determine-whether-the-string-represents-a-miniscriptdescriptor-how-does-it-resolve-a-descriptor-that-can-be-parsed-in-multiple-ways-->
  アウトプットディスクリプターの文字列のパースはどの関数が担当していますか？
  その文字列が`MiniscriptDescriptor`を表しているかどのように判断するのですか？
  複数の方法でパースできるディスクリプターをどのように解決するのですか？"
  a3="script/descriptor.cpp内の`ParseScript`関数が、アウトプットディスクリプター文字列のパースを担当します。
  他のディスクリプタータイプを最初にすべて試し、次に`miniscript::FromString`を呼んで、
  その文字列が有効なMiniscript式かどうか確認します。この操作順序により、
  Miniscriptと非Miniscript（`wsh(pk(...))`のような）の両方として解釈可能なディスクリプターは、
  非Miniscriptとしてパースされます。"
  a3link="https://bitcoincore.reviews/24148-2#l-30"

  q4="<!--when-choosing-between-two-available-satisfactions-why-should-the-one-that-involves-fewer-signatures-rather-than-the-one-which-results-in-a-smaller-script-be-preferred-->
  利用可能な充足条件から選択する際、スクリプトが小さくなるものではなく、署名が少ない方を優先すべきなのは何故ですか？"
  a4="トランザクションを改ざんしようとする第三者（つまり秘密鍵にアクセス出来ないような）は、
  署名を削除することはできますが、新しい署名を作ることはできません。
  追加の署名の充足条件を選択すると、第三者がスクリプトを細工して使用条件を満たすオプションが残ります。
  たとえば、ポリシー`or(and(older(21), pk(B)), thresh(2, pk(A), pk(B)))`には、
  2つの使用パスがあります。AとB両者が署名した場合は常に使用可能で、
  21ブロック後はBのみが署名すれば使用可能です。
  21ブロック後は、どちらも使用条件を満たすことができますが、AとB両方の署名があるトランザクションがブロードキャストされた場合、
  第三者がAの署名を削除して、もう一方の使用パスを満たすことが可能です。
  一方、ブロードキャストされたトランザクションがBの署名のみを含むものであれば、
  攻撃者はAの署名を偽造しない限り、もう一方の使用条件を満たすことはできません。"
  a4link="https://bitcoincore.reviews/24148-2#l-106"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.15.0-beta.rc4][]は、この人気のLNノードの次のメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #24408][]は、与えられたOutPointから支払いを行うmempool内のトランザクションをフェッチするRPCを追加し、
  `getrawmempool`から取得したtxidのリストからでなく、個別にトランザクションを選択することでOutPointの検索を効率化します。
  これは、チャネルのファンディング・トランザクションが使用された際に、その使用トランザクションを特定する場合や、
  競合するトランザクションをフェッチしたことで[RBF][topic rbf]トランザクションがブロードキャストに失敗した理由を調べる場合など
  Lightningで役立ちます。

- [LDK #1401][]は、ゼロ承認チャネルの開設をサポートしました。
  関連情報については、以下のBOLTs #910の要約をご覧ください。

- [BOLTs #910][]は、LNの仕様を更新し2つの変更を加えました。
  1つめは、プライバシーを向上させるShort Channel Identifier (SCID)のエイリアスを許可し、
  そのtxidが不安定な場合（デポジットトランザクションが信頼できる承認数を得る前など）でも、
  チャネルの参照を可能にします。
  2つめの仕様変更は、ノードが[ゼロ承認チャネル][topic zero-conf channels]を使用したい場合に設定できる
  `option_zeroconf`機能ビットを追加しました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="24408,1401,910" %}
[lnd 0.15.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc4
[reviews 24148]: https://bitcoincore.reviews/24148
[sipa miniscript]: https://bitcoin.sipa.be/miniscript
