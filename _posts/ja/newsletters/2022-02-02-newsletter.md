---
title: 'Bitcoin Optech Newsletter #185'
permalink: /ja/newsletters/2022/02/02/
name: 2022-02-02-newsletter-ja
slug: 2022-02-02-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、提案中の`OP_CHECKTEMPLATEVERIFY` (CTV) opcodeがDiscreet Log Contractsに及ぼす影響の分析および、
CTVと`SIGHASH_ANYPREVOUT`を有効にするためのTapscriptへの代替変更案に関する議論の要約について掲載しています。
また、新しいリリースの発表や人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点などの恒例のセクションも含まれています。

## ニュース

- **Scriptの変更によるDLCの効率性の向上:** Lloyd Fournierは、
  提案中の[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify](CTV) opcodeが、
  Discreet Log Contracts([DLC][topic dlc])の作成に必要な署名の数を大幅に削減し、
  また他のいくつかの演算の数を減らすことができることをDLC-Devメーリングリストおよび、
  Bitcoin-Devメーリングリストに[投稿しました][fournier ctv dlc]。

  簡単に言うと、コントラクトの各最終状態（例えば、アリスが1 BTCを入手し、ボブが2 BTCを入手するような）に対して、
  DLCは現在、その状態に対してそれぞれ個別の[署名アダプター][topic adaptor signatures]を作成する必要があります。
  例えば、ビットコインの将来価格に関するコントラクトでは、1ドル未満を四捨五入した価格を指定するため、
  比較的短期のコントラクトでも数千ドルの価格帯をカバーする必要があるため、多数の最終状態を定義することになります。
  そのため、参加者は何千もの部分署名を作成、交換、保存する必要があります。

  代わりに、Fournierは、アウトプットをオンチェーンに配置することをコミットする[Tapleaf][topic tapscript]でCTVを使用し、
  何千もの取りうる状態を作成することを提案しています。
  CTVはハッシュを使ってアウトプットにコミットするため、参加者は取りうる状態のハッシュを迅速かつオンデマンドに計算し、
  計算およびデータの交換、データストレージを最小限に抑えます。
  一部の署名は引き続き使用されますが、その数は大幅に削減されます。
  複数のオラクル（例えば為替レートコントラクトにおける複数の価格データプロバイダーなど）を使用するコントラクトの場合、
  必要なデータ量は更に単純化および削減されます。

  Jonas Nickは、提案中の[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]の署名ハッシュモードを使用しても
  同様の最適化が可能であると[述べています][nick apo dlc]
  （次のニュース項目で説明されている代替手段を使用しても同様の最適化が可能であることも留意してください）。

- **CTVとAPOの代替可能な構成:** Russell O'Connorは、
  Bitcoinの[Tapscript][topic tapscript]言語に２つの新しいopcodeを追加するソフトフォークのアイディアを
  Bitcoin-Devメーリングリストに[投稿しました][oconnor txhash]。
  Tapscriptは、新しい`OP_TXHASH` opcodeを使用して、
  支払いトランザクションのどの部分がシリアライズされハッシュされるかを指定し、
  ハッシュダイジェストは後続のopcodeが使用できるよう評価スタックに配置されます。
  （以前提案された）新しい[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) opcodeは、
  Tapscriptが公開鍵を指定し、スタック上の特定のデータ
  （`OP_TXHASH`によって作成された計算済みのトランザクションダイジェストなど）に対して対応する署名を要求できるようにします。

  O'Connorは、これらの2つのopcodeにより、これまでの2つのソフトフォークの提案、
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] ([BIP118][]で定義されたAPO)および
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] ([BIP119][]で定義されたCTV)を
  エミュレーションできることを説明しました。目的によっては、
  このエミュレーションはCTVやAPOを直接使用するよりも効率が悪いかもしれませんが、
  `OP_TXHASH`と`OP_CSFS`はTapscript言語をよりシンプルに保ち、
  特に[OP_CAT][]などのTapscriptへの他のシンプルな追加要素と組み合わせた場合、
  今後のScript作成者に柔軟性を提供することができます。

  Anthony Townsは、[返信][towns pop_sigdata]で、他の代替opcodeを使用した同様のアプローチを提案しました。

  この要約が書かれている時点では、このアイディアはまだ活発に議論されていました。
  私たちは、将来のニュースレターで、この話題を再度取り上げる予定です。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BTCPay Server 1.4.2][]は、新しい1.4.xシリーズの最新リリースで、
  ログイン認証の改善や多くの[ユーザーインターフェースの改良][btcpay ui blog]が含まれています。

- [BDK 0.16.0][]は、多くのバグ修正と小さな改良を含むリリースです。

- [Eclair 0.7.0][]は、新しいメジャーリリースで、[Anchor Output][topic anchor outputs]、
  [Onionメッセージ][topic onion messages]のリレー、運用環境でのPostgreSQLデータベースの使用などのサポートが追加されています。

- [LND 0.14.2-beta.rc1][lnd 0.14.2-beta]は、メンテナンス版のリリース候補で、
  いくつかのバグ修正と小さな改良が含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23201][]では、データを解決する代わりに最大weightを指定できるようにすることでウォレットユーザーが、
  外部入力（以前[ニュースレター #170][news170 external inputs]で言及した）を使用してトランザクションに資金を提供する機能を向上させました。
  これにより、アプリケーションは`fundrawtransaction` RPC、`send` RPC、`walletfundpsbt` RPCを使用して、
  [HTLC][topic htlc]のような非標準アウトプットでトランザクションの手数料を引き上げることができます
  （[ニュースレター #184][news184 eclair auto bump]に掲載されているLNクライアントの要件）。

- [Eclair #2141][]は、ウォレットのUTXOが少ない時に、より積極的な承認ターゲットを選択することで、
  （以前[ニュースレター #184][news184 eclair auto bump]で取り上げた）自動手数料引き上げメカニズムを改良しました。
  このような状況では、さらに強制クローズした場合にウォレットのUTXOの数を維持するために、
  手数料引き上げトランザクションが迅速に承認されることが重要です。
  Eclairが使用するAnchor Outputスタイルの手数料引き上げの詳細については、[こちら][topic anchor outputs]をご覧ください。

- [BTCPay Server #3341][]では、LNを介して払い戻しを要求する際に、
  これまでのデフォルト30日とは異なる[BOLT11][]の有効期限を設定することができるようになりました。

{% include references.md %}
{% include linkers/issues.md issues="23201,2141,3341" %}
[btcpay server 1.4.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.4.2
[bdk 0.16.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.16.0
[eclair 0.7.0]: https://github.com/ACINQ/eclair/releases/tag/v0.7.0
[lnd 0.14.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.2-beta.rc1
[btcpay ui blog]: https://blog.btcpayserver.org/btcpay-server-1-4-0/
[fournier ctv dlc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019808.html
[nick apo dlc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019812.html
[oconnor txhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019813.html
[towns pop_sigdata]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019819.html
[news184 eclair auto bump]: /ja/newsletters/2022/01/26/#eclair-2113
[news170 external inputs]: /ja/newsletters/2021/10/13/#bitcoin-core-17211
