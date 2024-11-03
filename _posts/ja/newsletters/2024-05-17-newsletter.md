---
title: 'Bitcoin Optech Newsletter #303'
permalink: /ja/newsletters/2024/05/17/
name: 2024-05-17-newsletter-ja
slug: 2024-05-17-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNのチャネルアナウンスや他の複数のシビル耐性調整プロトコルに使用できる
匿名使用トークンの新しいスキームや、新しいBIP39シードフレーズ分割スキームに関する議論のリンク、
対話型のコントラクトプロトコルにおける任意のプログラムの正常な実行を検証するBitVMの代替案の発表、
BIPプロセスの更新に関する提案を掲載しています。

## ニュース

- **<!--anonymous-usage-tokens-->匿名使用トークン:** Adam Gibsonは、
  UTXOを[keypathで使用][topic taproot]できる人なら誰でも、それがどのUTXOであるかを明らかにすることなく、
  それを使用できることを証明できるようにするために開発したスキームについてDelving Bitcoinに[投稿しました][gibson autct]。
  これは、Gibsonの以前のアンチシビルメカニズム[PoDLE][news85 podle]（Joinmarketの[coinjoin][topic coinjoin]実装で使用）と
  [RIDDLE][news205 riddle]の開発に続くものです。

  彼が説明する用途の1つは、LNチャネルのアナウンスです。各LNノードは、
  そのチャネルを他のLNノードにアナウンスし、ネットワーク全体で資金をルーティングする経路を見つけられるようにします。
  チャネル情報の多くは、メモリに保存され、アナウンスはできるだ多くのノードに届くように、よく再ブロードキャストされます。
  攻撃者が偽のチャネルを安価にアナウンスできれば、経路探索を妨害するだけでなく、
  正直なノードのメモリと帯域幅を過剰に浪費する可能性があります。
  LNノードは現在、有効なUTXOに属する鍵で署名されたアナウンスのみを受け入れることで、
  この問題に対処しています。そのため、チャネルの共同所有者は自分が共同所有するUTXOを特定する必要があり、
  それらの資金がチャネルの共同所有者の過去または将来作成される他のオンチェーントランザクションと関連付けられる可能性があります
  （もしくは、誰かが不正確な関連付けを行う可能性があります）。

  autct（Anonymous usage tokens [with] curve trees）と呼ばれるGibsonのスキームでは、
  チャネルの共同所有者はUTXOを明かすことなくメッセージに署名することができます。
  UTXOを持たない攻撃者は、有効な署名を作成することができません。
  UTXOを持っている攻撃者は有効な署名を作成できますが、
  LNノードがチャネルに保持する必要があるのと同じだけの資金をそのUTXOに保持しなければならず、
  あらゆる攻撃の最悪のケースを制限することになります。
  特定のUTXOから[チャネルアナウンス][topic channel announcements]の関連付けを切り離す以前の議論については、
  [ニュースレター #261][news261 lngossip]をご覧ください。

  Gibsonはまた、autctを使用できる他のいくつかの方法についても説明しています。
  この種のプライバシーを実現する基本的なメカニズムであるリング署名は以前から知られていましたが、
  Gibsonは新しい暗号構造（[curve trees][]）を使って証明をよりコンパクトにし、
  検証を高速化しました。また、1つのUTXOが無制限に有効な署名を作成するために使用されないように、
  各証明は使用される鍵にプライベートにコミットされるようになっています。

  [コード][autct repo]を公開するだけでなく、Gibsonは概念実証の[フォーラム][hodlboard]も公開しました。
  このフォーラムでは、サインアップするのにautct証明を提供する必要があり、
  誰もがBitcoinの保有者であることを知ることができますが、
  誰も自分自身や自身のビットコインに関する識別情報を提供する必要がない環境を提供しています。

- **BIP39シードフレーズの分割:** Rama Ganは、
  電子計算機を一切使用せずに（説明書とテンプレートを除く）、
  [BIP39][]シードフレーズを生成・分割するために開発した[ツールセット][penlock website]のリンクを
  Bitcoin-Devメーリングリストに[投稿しました][gan penlock]。
  これは、[codex32][topic codex32]に似ていますが、
  現在のほぼすべてのハードウェア署名デバイスや多くのソフトウェアウォレットと互換性のあるBIP39シードワードで動作します。

  codex32の共著者であるAndrew Poelstraは、いくつかのコメントと提案を[返信しました][poelstra penlock1]。
  両方のスキームを試してみないと（それぞれ数時間かかります）、両者の正確なトレードオフは分かりません。
  ただ、どちらも同じ基本的な機能を提供しているようです。
  シードをオフラインで安全に生成するための手順、[シャミアの秘密分散法][sss]を使用してシードを複数のシェアに分割する機能、
  シェアから元のシードを再構築する機能、シェアと元のシードの両方のチェックサムを検証し、
  元のデータがまだ復元可能である可能性があるときに、ユーザーがデータの破損を早期に発見できるようにする機能です。

- **BitVMの代替案:** Sergio Demian Lernerと複数の共著者は、
  [BitVM][topic acc]の背後にあるアイディアの一部に基づく新しい仮想CPUアーキテクチャについて
  Bitcoin-Devメーリングリストに[投稿しました][lerner bitvmx]。彼らのプロジェクトBitVMXの目標は、
  [RISC-V][]のような確立されたCPUアーキテクチャ上で実行するためにコンパイルすることができる任意のプログラムの適切な実行を
  効率的に証明できるようにすることです。BitVMのように、BitVMXはコンセンサスの変更を必要としませんが、
  1つ以上の指定された当事者が信頼できる検証者として機能することを必要とします。
  つまり、複数のユーザーがインタラクティブにコントラクトプロトコルに参加すると、
  コントラクトで指定された任意のプログラムを正常に実行しないかぎり、
  参加者の1人（または複数）がコントラクトから資金を引き出すのを防ぐことができます。

  Lernerは、BitVMXをオリジナルのBitVM（[ニュースレター #273][news273 bitvm]参照）と比較した[論文][bitvmx paper]と、
  オリジナルのBitVM開発者による後続のプロジェクトについて限られた詳細をリンクしています。
  付属の[Webサイト][bitvmx website]では、技術的な情報を少し抑えた形で追加情報を提供しています。

- **BIP2の更新についての議論の続き:** Mark "Murch" Erhardtは、
  現在のBIP（Bitcoin improvement proposals）プロセスを記述しているドキュメントである[BIP2][]の更新について
  Bitcoin-Devメーリングリストでの議論を[続けています][erhardt bip2]。
  彼のメールでは、いくつかの問題を説明し、それらの多くに対する解決策を提案し、
  彼の提案に対するフィードバックと残りの問題に対する解決策の提案を求めています。
  BIP2の更新に関する以前の議論については、[ニュースレター #297][news297 bip2]をご覧ください。

## Releases and release candidates

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND v0.18.0-beta.rc2][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [Core Lightning #7190][]は、[HTLC][topic htlc]タイムロックの計算に（`chainlag`と呼ばれる）
  追加のオフセットを追加します。これにより、LNノードが処理した最新ブロック（同期した高さ）ではなく、
  現在のブロック高をHTLCのターゲットにすることができます。これにより、ブロックチェーンの同期プロセス中に
  ノードが安全に支払いを送信できるようになります。

- [LDK #2973][]は、オフラインのピアに代わって[Onionメッセージ][topic onion messages]をインターセプトするための
  `OnionMessenger`のサポートを実装します。メッセージをインターセプトした時と
  ピアが転送のためにオンライン状態に戻った時にイベントを生成します。
  ユーザーは、関連するピアのメッセージのみを保存するために許可リストを管理する必要があります。
  これは、`held_htlc_available` [BOLTs #989][]を通じて[非同期支払い][topic async payments]をサポートするための足がかりです。
  このプロトコルでは、アリスはボブを介してキャロルに支払いをしたいと考えていますが、
  アリスはキャロルがオンラインかどうか知りません。アリスはOnionメッセージをボブに送信します。
  ボブはキャロルがオンラインになるまでメッセージを保持します。キャロルがメッセージを開くと、
  アリス（またはアリスのライトニングサービスプロバイダー）に支払いを要求するよう指示されます。
  キャロルは支払いを要求し、アリスは通常の方法で支払いを送信します。

- [LDK #2907][]は、オプションで`Responder`入力を受け入れ、
  メッセージへの応答をどう処理するかを示す`ResponseInstructions`オブジェクトを返すように`OnionMessage`処理を拡張します。
  この変更により、非同期のOnionメッセージ応答が可能になり、
  [非同期支払い][topic async payments]に必要となるような、より複雑な応答メカニズムに対応できるようになります。

- [BDK #1403][]では、`bdk_electrum`クレートが更新され、
  [BDK #1413][]で導入された新しい同期/フルスキャン構造、
  [BDK #1369][]のクエリ可能な`CheckPoint`リンクドリストおよび、
  [BDK #1373][]の`Arc`ポインターの安価にクローン可能なトランザクションが利用できるようになりました。
  この変更により、Electrumスタイルのサーバを使用してトランザクションデータをスキャンするウォレットのパフォーマンスが向上します。
  また、外部ウォレットから受信したトランザクションの手数料計算を可能にするために、
  `TxOut`をフェッチするオプションも追加されています。

- [BIPs #1458][]は、[サイレントペイメント][topic silent payments]を提案する[BIP352][]を追加しました。
  サイレントペイメントは、使用されるたびに一意のオンチェーンアドレスを生成する、再利用可能な支払いアドレス用のプロトコルです。
  このBIPのドラフトは、[ニュースレター #255][news255 bip352]で初めて議論されました。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-05-21 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7190,2973,2907,1403,1458,989,1413,1369,1373" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[gibson autct]: https://delvingbitcoin.org/t/anonymous-usage-tokens-from-curve-trees-or-autct/862/
[news261 lngossip]: /ja/newsletters/2023/07/26/#updated-channel-announcements
[news205 riddle]: /ja/newsletters/2022/06/22/#riddle
[news85 podle]: /ja/newsletters/2020/02/19/#ln-podle
[curve trees]: https://eprint.iacr.org/2022/756
[autct repo]: https://github.com/AdamISZ/aut-ct
[hodlboard]: https://hodlboard.org/
[gan penlock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9bt6npqSdpuYOcaDySZDvBOwXVq_v70FBnIseMT6AXNZ4V9HylyubEaGU0S8K5TMckXTcUqQIv-FN-QLIZjj8hJbzfB9ja9S8gxKTaQ2FfM=@proton.me/
[penlock website]: https://beta.penlock.io/
[poelstra penlock1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZkIYXs7PgbjazVFk@camus/
[sss]: https://ja.m.wikipedia.org/wiki/秘密分散
[lerner bitvmx]: https://mailing-list.bitcoindevs.xyz/bitcoindev/5189939b-baaf-4366-92a7-3f3334a742fdn@googlegroups.com/
[risc-v]: https://ja.wikipedia.org/wiki/RISC-V
[bitvmx paper]: https://bitvmx.org/files/bitvmx-whitepaper.pdf
[news273 bitvm]: /ja/newsletters/2023/10/18/#payments-contingent-on-arbitrary-computation
[bitvmx website]: https://bitvmx.org/
[erhardt bip2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0bc47189-f9a6-400b-823c-442974c848d5@murch.one/
[news297 bip2]: /ja/newsletters/2024/04/10/#bip2
[news255 bip352]: /ja/newsletters/2023/06/14/#bip
