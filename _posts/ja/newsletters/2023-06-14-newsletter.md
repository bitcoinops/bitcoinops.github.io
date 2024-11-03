---
title: 'Bitcoin Optech Newsletter #255'
permalink: /ja/newsletters/2023/06/14/
name: 2023-06-14-newsletter-ja
slug: 2023-06-14-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Taprootのannexフィールドにデータを含むトランザクションの
リレーを許可することについての議論と、サイレントペイメントのBIPドラフトのリンクを掲載しています。
また、mempoolポリシーに関する限定週刊シリーズの新しい記事に加えて、
Bitcoin Core PR Review Clubミーティングの要約や、新しいソフトウェアのリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **Taproot annexに関する議論:** Joost Jagerは、
  [Taproot][topic taproot]のannexフィールドに任意のデータを保存できるようにするために、
  Bitcoin Coreのトランザクションリレーとマイニングポリシーの変更を求める要望を
  Bitcoin-Devメーリングリストに[投稿しました][jager annex]。
  このフィールドは、Taprootトランザクションのwitnessデータのオプション部分です。
  このフィールドが存在する場合、Taprootと[Tapscript][topic tapscript]内の署名は、
  そのデータにコミットしなければなりません（第三者が追加、削除、変更できないようにするため）が、
  現時点ではそれ以外に定義された目的はなく、将来のプロトコルアップグレード、特にソフトフォークのために予約されています。

  annexのフォーマットを定義する提案は[以前から][riard annex]ありましたが、
  広く受け入れられ実装されたものはありませんでした。Jagerは、
  ソフトフォークにバンドルされる可能性のある将来の標準化の取り組みを著しく複雑にするこなく、
  誰でも任意のデータをannexに追加できるようにするために使用できる2つのフォーマット（[1][jager annex]、[2][jager annex2]）を提案しました。

  Greg Sandersは、Jagerが具体的にどんなデータをannexに保存したいのかを[尋ね][sanders annex]、
  Bitcoin Inquisitionを使用した[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]のソフトフォーク提案で、
  [LN-Symmetry][topic eltoo]プロトコルをテストするためにannexを使用した自分の使用法を説明しました
  （[ニュースレター #244][news244 annex]参照）。
  Sandersはまた、annexの問題点を説明しました。マルチパーティプロトコル（[Coinjoin][topic coinjoin]など）では、
  各署名はその署名が含まれるインプットのannexのみにコミットし、
  同じトランザクションの他のインプットのannexにはコミットしません。
  つまり、アリス、ボブ、マロリーが一緒にCoinjoinに署名する場合、
  アリスとボブは、マロリーが巨大なannexを持つバージョンのトランザクションをブロードキャストして
  承認を遅らせることを防ぐことができません。Bitcoin Coreや他のフルノードは、
  現在annexを含むトランザクションをリレーしないため、これは今のところ問題になっていません。
  Jagerは、ソフトフォークを必要としないタイプの[Vault][topic vaults]のために、
  一時鍵の署名を保存したいと[答え][jager annex4]、Bitcoin Coreのいくつかの[これまでの研究][bitcoin core #24007]により、
  マルチパーティプロトコルにおけるannexのリレーの問題に対処できる可能性があることを[示唆しました][jager annex3]。

- **サイレントペイメントのBIPドラフト:** Josie BakerとRuben Somsenは、
  [サイレントペイメント][topic silent payments]のBIPドラフトをBitcoin-Devメーリングリストに[投稿しました][bs sp]。
  サイレントペイメントは、使用される度に一意のオンチェーンアドレスを生成し、
  [アウトプットのリンク][topic output linking]を防止する再利用可能なペイメントコードの一種です。
  アウトプットのリンクは、（トランザクションに直接関与していないユーザーも含む）ユーザーのプライバシーを著しく低下させる可能性があります。
  ドラフトでは、この提案の利点、トレードオフ、ソフトウェアが効果的に利用する方法について詳しく説明されています。
  BIPの[PR][bips #1458]には、すでにいくつかの洞察に満ちたコメントが投稿されています。

## 承認を待つ #5: ノードリソースの保護に関するポリシー

_トランザクションリレーや、mempoolへの受け入れ、マイニングトランザクションの選択に関する限定週刊[シリーズ][policy series]です。
Bitcoin Coreがコンセンサスで認められているよりも制限的なポリシーを持っている理由や、
ウォレットがそのポリシーを最も効果的に使用する方法などが含まれます。_

{% include specials/policy/ja/05-dos.md %}

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Allow inbound whitebind connections to more aggressively evict peers when slots are full][review club 27600]は、
Matthew Zipkin（pinheadmz）によるPRで、特定のケースでノードオペレーターが
希望するピアをノードに設定する機能を改善します。
具体的には、ノードオペレーターが潜在的なインバウンドピア（たとえば、ノードオペレーターが管理する軽量クライアント）を
ホワイトリストに登録している場合、このPRがなければ、
ノードのピアの状態によっては、この軽量クライアントの接続試行をノードが拒否する可能性があります。

このPRにより、目的のピアがノードに接続できる可能性が大幅に高まります。
これは、このPRがなければ排除対象外だった既存のインバウンドピアを排除することで行われます。

{% include functions/details-list.md
  q0="なぜこのPRはインバウンドピアのリクエストのみに適用されるのですか？"
  a0="私たちのノードは、アウトバウンド接続を _開始_ します。このPRは、
      ノードがインバウンド接続リクエストに _反応する_ 方法を変更します。
      アウトバウンドノードは排除することはできますが、それは全く別のアルゴリズムで行われます。"
  a0link="https://bitcoincore.reviews/27600#l-33"

  q1="`SelectNodeToEvict()`の`force`パラメーターは、戻り値にどのような影響を及ぼしますか？"
  a1="`force`を`true`に設定すると、非`noban`のインバウンドピアが存在する場合、
      それらが排除対象外であっても、確実にピアが返されます。
      このPRがないと、すべてのピアが排除対象外である場合、ピアは返されません。"
  a1link="https://bitcoincore.reviews/27600#l-70"

  q2="このPRでは、`EraseLastKElements()`関数のシグネチャはどのように変更されますか？"
  a2="戻り値が`void`から、排除候補リストから削除された最後のエントリーを返すように変更されました。
      （この保護されたノードは、必要であれば排除されるかもしれません。）
      しかし、Review Clubでの議論の結果、PRはその後簡素化され、
      この関数は変更されなくなりました。"
  a2link="https://bitcoincore.reviews/27600#l-126"

  q3="`EraseLastKElements`はテンプレート関数でしたが、このPRでは、
      2つのテンプレート引数を削除しています。これはなぜですか？この変更にはなにか不都合があるのでしょうか？"
  a3="この関数は、以前も（このPRでも）一意のテンプレート引数で呼び出されていたため、
      この関数をテンプレート化する必要はありません。PRによるこの関数の変更は取り消され、
      これを変更するのはPRの範囲を超えるため、まだテンプレート化されたままになっています。"
  a3link="https://bitcoincore.reviews/27600#l-126"

  q4="`SelectNodeToEvict()`に40個の排除候補を渡すとします。このPRの前後で、
      排除から保護できるTorノードの理論上の最大数はいくつですか？"
  a4="PRの有無に関わらず、`noban`やインバウンドでないと仮定すると、その数は40の内34になります。"
  a4link="https://bitcoincore.reviews/27600#l-156"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 23.05.1][]は、このLN実装のメンテナンスリリースです。
  リリースノートには、「これはバグ修正のみのリリースで、実際に報告されているいくつかのクラッシュを修正しています。
  これは、v23.05を使用しているすべての人に推奨されるアップグレードです。」と記載されています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #27501][]では、ユーザーが`prioritisetransaction`で作成したすべての手数料デルタのマップを
  txidでインデックスして返す`getprioritisedtransactions`を追加しました。
  このマップは、各トランザクションがmempoolに存在するかどうかも示します。
  [ニュースレター #250][news250 getprioritisedtransactions]もご覧ください。

- [Core Lightning #6243][]は、`listconfigs`RPCを更新し、
  すべての設定情報を１つの辞書にまとめ、すべての設定オプションの状態を再起動したプラグインに渡すようにします。

- [Eclair #2677][]は、`max_cltv`のデフォルト値を1,008ブロック（約1週間）から、
  2,016（約2週間）に増やしました。これは、支払いの試行がタイムアウトするまでのブロック数の最大許容値を延長します。
  この変更は、ネットワーク上のノードが、オンチェーン手数料率の高さに対応して、
  期限切れのHTLC（`cltv_expiry_delta`）に対処するための予約時間枠が引き上げられたことに起因しています。
  同様の変更が[LND][lnd max_cltv]とCLNにマージされています。

- [Rust bitcoin #1890][]は、非Tapscriptスクリプトの署名操作（sigops）の数をカウントするメソッドを追加しました。
  sigopsの数は、ブロック毎に制限されており、Bitcoin Coreのマイニング用トランザクションの選択コードは、
  サイズ（weight）あたりのsigopsの比率が高いトランザクションを、より大きなトランザクションのように扱い、
  事実上、そのトランザクションの手数料率を下げます。そのため、トランザクション作成者は、
  この新しいメソッドのようなものを使用して、自分が使用しているsigopsの数を確認することが重要になる可能性があります。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27501,6243,2677,1890,1458,24007" %}
[policy series]: /ja/blog/waiting-for-confirmation/
[jager annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021731.html
[riard annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020991.html
[jager annex2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021756.html
[sanders annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021736.html
[news244 annex]: /ja/newsletters/2023/03/29/#bitcoin-inquisition-22
[jager annex3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021743.html
[bs sp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021750.html
[review club 27600]: https://bitcoincore.reviews/27600
[jager annex4]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021737.html
[lnd max_cltv]: /ja/newsletters/2019/10/23/#lnd-3595
[news250 getprioritisedtransactions]: /ja/newsletters/2023/05/10/#bitcoin-core-pr-review-club
[Core Lightning 23.05.1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05.1
