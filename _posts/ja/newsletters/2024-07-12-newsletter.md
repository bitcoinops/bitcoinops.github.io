---
title: 'Bitcoin Optech Newsletter #311'
permalink: /ja/newsletters/2024/07/12/
name: 2024-07-12-newsletter-ja
slug: 2024-07-12-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Core PR Review Clubミーティングの概要や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更を含む
恒例のセクションを掲載しています。

## ニュース

*今週はどの[情報源][sources]からも目立ったニュースは見つかりませんでした。
お楽しみのために、最近の[興味深いトランザクション][interesting transaction]をチェックしてみてはどうでしょう。*

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Testnet4 including PoW difficulty adjustment fix][review club 29775]は、
[Fabian Jahr][gh fjahr]によるPRで、Testnet3に代わる新しいテストネットワークとしてTestnet4を導入し、
同時に長年存在していた難易度調整とタイムワープのバグを修正します。これは、
[メーリングリストでの議論][ml testnet4]の結果であり、[BIPの提案][bip testnet4]を伴っています。

{% include functions/details-list.md
  q0="コンセンサスの変更以外に、Testnet 4とTestnet 3の違い、特にチェーンパラメーターの違いは何ですか？"
  a0="過去のソフトフォークの展開の高さはすべて1に設定されており、これは最初からアクティブであることを意味します。
  Testnet4では、異なるポート（`48333`）とmessagestartを使用し、新しいジェネシスブロックメッセージがあります。"
  a0link="https://bitcoincore.reviews/29775#l-29"

  q1="Testnet 3の20分例外ルールはどのように機能しますか？これはどのようにブロックストームのバグにつながるのですか？"
  a1="新しいブロックのタイムスタンプが前のブロックのタイムスタンプより20分以上進んでいる場合、
  そのブロックは最小限のProof-of-Workの難易度で許可されます。次のブロックは、
  20分例外ルールに該当しない限り、再び「本当の」難易度が適用されます。
  この例外は、ハッシュレートが大きく変動する環境でもチェーンが前進できるようにするために設けられています。
  `GetNextWorkRequired()`実装にバグがあるため、難易度期間の最後のブロックが最小難易度のブロックの場合、
  難易度は（一時的に1ブロックだけ低下するのではなく）実際にリセットされます。"
  a1link="https://bitcoincore.reviews/29775#l-47"

  q2="なぜタイムワープの修正がPRに含まれているのですか？タイムワープの修正はどのように機能しますか？"
  a2="[タイムワープ][topic time warp]攻撃により、攻撃者はブロックの生成率を大幅に変更することができるため、
  最小難易度のバグと一緒にこれを修正するのは理にかなっています。これはまた、
  [コンセンサスクリーンアップソフトフォーク][topic consensus cleanup]の一部でもあるため、
  最初にTestnet4で修正をテスト実行することで、有用な初期フィードバックが得られます。
  このPRは、新しい難易度エポックの最初のブロックが前のエポックの最後のブロックの2時間前より早くないことをチェックすることで、
  タイムワープのバグを修正します。"
  a2link="https://bitcoincore.reviews/29775#l-68"

  q3="Testnet 3のジェネシスブロック内のメッセージはどういうものですか？"
  a3="Testnet 3と（Testnet 4より前の）他のネットワークは、よく知られた同じジェネシスブロックメッセージを持っています。
  「The Times 03/Jan/2009 Chancellor on brink of second bailout for banks」
  Testnet4は、独自のジェネシスブロックメッセージを持つ最初のネットワークで、
  最近のmainnetのブロックのハッシュが含まれ（現在は`000000000000000000001ebd58c244970b3aa9d783bb001011fbe8ea8e98e00e`）、
  このmainnetのブロックがマイニングされる前に、このTestnet 4チェーン上でプレマイニングが行われていないことを強力に保証します。"
  a3link="https://bitcoincore.reviews/29775#l-17"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 26.2][]は、Bitcoin Coreの旧リリースシリーズのメンテナンスバージョンです。
  26.1以前のバージョンを使用していて、最新リリース（27.1）にアップグレードできない、
  または、アップグレードしたくない場合は、このメンテナンスリリースにアップグレードすることをお勧めします。

- [LND v0.18.2-beta][]は、旧バージョンのbtcdバックエンドのユーザーに影響するバグを修正するためのマイナーリリースです。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Rust Bitcoin #2949][]は、OP_RETURNアウトプットの現在の標準ルールに対して検証する
  新しい`is_standard_op_return()`メソッドを追加し、プログラマーがBitcoin Coreによって強制される
  80バイトの最大サイズを超えるOP_RETURNデータかどうかをテストできるようにしました。
  現在のデフォルトのBitcoin Coreの制限を超えることを心配しないプログラマーは、
  Rust Bitcoinの`is_op_return`関数を引き続き使用できます。

- [BDK #1487][]では、トランザクション構築の柔軟性を高めるために、
  `TxOrdering`列挙型に`Custom`列挙子を追加することで、インプットとアウトプットのカスタムソート関数をサポートします。
  明示的な[BIP69][]のサポートは、採用率の低さから、望ましいプライバシーを提供しない可能性があるため削除されました（
  ニュースレター[#19][news19 bip69]および[#151][news151 bip69]参照）。
  ただし、適切なカスタムソートを実装することで、ユーザーは引き続きBIP69準拠のトランザクションを作成することができます。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2949,1487" %}
[bitcoin core 26.2]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[sources]: /en/internal/sources/
[interesting transaction]: https://stacker.news/items/600187
[LND v0.18.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.2-beta
[news19 bip69]: /en/newsletters/2018/10/30/#bip69-discussion
[news151 bip69]: /ja/newsletters/2021/06/02/#bolts-872
[gh fjahr]: https://github.com/fjahr
[review club 29775]: https://bitcoincore.reviews/29775
[ml testnet4]: https://groups.google.com/g/bitcoindev/c/9bL00vRj7OU
[bip testnet4]: https://github.com/bitcoin/bips/pull/1601
