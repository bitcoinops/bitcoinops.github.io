---
title: 'Bitcoin Optech Newsletter #277'
permalink: /ja/newsletters/2023/11/15/
name: 2023-11-15-newsletter-ja
slug: 2023-11-15-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、エフェメラル・アンカーに関する提案のアップデートと、
Wizardsardineで働く開発者によるminiscriptに関するフィールドレポートの寄稿を掲載しています。
また、新しいソフトウェアのリリースとリリース候補の発表や、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更のなど、恒例のセクションも含まれています。

## ニュース

- **<!--eliminating-malleability-from-ephemeral-anchor-spends-->エフェメラル・アンカーの支払いからマリアビリティを排除する:**
  Gregory Sandersは、[エフェメラル・アンカー][topic ephemeral anchors]の提案の微調整について
  Delving Bitcoinフォーラムに[投稿しました][sanders mal]。
  エフェメラル・アンカーにより、誰もが使用可能（anyone-can-spend）なアウトプットスクリプトを使用して
  トランザクションにゼロ値のアウトプットを含めることができるようになります。
  誰でもこのアウトプットを使用できるため、誰でもアウトプットを作成したトランザクションの
  [CPFP][topic cpfp]による手数料の引き上げを行うことができます。
  これは、支払うべき手数料率を正確に予測する前にトランザクションが署名されることが多い
  LNなどのマルチパーティコントラクトプロトコルにとって便利です。
  エフェメラル・アンカーを使用すると、コントラクトの参加者は誰でも必要と思われるだけ手数料を追加することができます。
  他の参加者、もしくは何らかの理由で他のユーザーが、より高い手数料を追加したい場合は、
  CPFPによる手数料の引き上げを、より高い手数料率のCPFPに[置き換える][topic rbf]ことができます。

    提案されている誰もが使用可能なスクリプトは、`OP_TRUE`と同等のスクリプトで、
    空のインプットスクリプトを持つインプットで使用可能です。
    Sandersが今週投稿したように、レガシーなアウトプットスクリプトを使用することは、
    それを使用する子トランザクションのtxidが変更可能であることを意味します。
    どのマイナーもインプットスクリプトにデータを追加して、子トランザクションのtxidを変更することができます。
    そのため、トランザクションが承認されたとしても、孫トランザクションを無効にする別のtxidで承認される可能性があるため、
    子トランザクションを手数料の引き上げ以外の用途に使用するのは賢明ではありません。

    Sandersは、代わりに、将来のsegwitのアップグレード用に予約されているアウトプットスクリプトの１つを使用することを提案しています。
    この場合、segwitでは4バイト、素の`OP_TRUE`では１バイトであるため、若干ブロックスペースが増加しますが、
    トランザクションマリアビリティに関する懸念は解消されます。スレッドでの議論の後、
    Sandersは、マリアビリティを気にせずトランザクションサイズを最小限に抑えたい人向けの`OP_TRUE`バージョンと、
    若干大きいものの子トランザクションの変更を許可しないsegwitバージョンの両方を提供する提案をしました。
    スレッドでは、覚えやすい[bech32mアドレス][topic bech32]を作成するために
    segwitアプローチで余分なバイトを選択することに焦点を当てた議論が行われました。

## フィールドレポート: Miniscriptの旅路

{% include articles/ja/wizardsardine-miniscript.md extrah="#" %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.17.1-beta][]は、このLNノード実装のメンテナンスリリースで、
  いくつかのバグ修正と軽微な改善が含まれています。

- [Bitcoin Core 26.0rc2][]は、主流のフルノード実装の次期メジャーバージョンのリリース候補です。
  [推奨されるテストトピック][26.0 testing]の簡単な概要があり、
  テスト専用の[Bitcoin Core PR Review Club][]ミーティングが2023年11月15日に予定されています。

- [Core Lightning 23.11rc1][]は、このLNノード実装の次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #28207][]は、mempoolがディスクに保存される方法を更新しました
  （通常はノードのシャットダウン時に行われますが、`savemempool` RPCによってトリガーされることもあります）。
  これまでは、基礎となるデータを単純にシリアライズして保存していました。
  現在は、シリアライズされたデータが、各ノードで独立して生成されたランダム値によってXORされ、
  データを難読化します。難読化を解除するため、ロード時に同じ値でXORされます。
  この難読化により、誰かがトランザクションに特定のデータを入れて、
  ウィルススキャナーのようなプログラムが保存されたmempoolのデータに危険フラグを付けるような、
  特定のバイト列を表示させることができなくなります。
  同じ方法が以前[PR #6650][bitcoin core #6650]でUTXOセットを保存するために適用されました。
  ディスクからmempoolのデータを読み取る必要があるソフトウェアは、それ自体でXORの演算を適用するか、
  難読化されない形式での保存を要求するために`-persistmempoolv1`の設定を使用できます。
  後方互換の設定は将来のリリースで削除される予定です。

- [LDK #2715][]では、ノードはオプションで配送されると想定されている値よりも小さい金額の[HTLC][topic htlc]を
  受け入れることができるようになりました。
  これは、上流のピアが新しい[JITチャネル][topic jit channels]を通じてノードに支払う場合に便利です。
  この場合、上流のピアにオンチェーントランザクションの手数料がかかり、
  ノードに支払われるHTLCの金額からその手数料を差し引く必要があります。
  この機能の上流側に関するLDKの以前の実装については、[ニュースレター #257][news257 jitfee]を参照ください。

{% include snippets/recap-ad.md when="2023-11-16 15:00" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28207,6650,2715" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc1
[lnd 0.17.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.1-beta
[sanders mal]: https://delvingbitcoin.org/t/segwit-ephemeral-anchors/160
[news257 jitfee]: /ja/newsletters/2023/06/28/#ldk-2319
