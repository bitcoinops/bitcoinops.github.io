---
title: 'Bitcoin Optech Newsletter #157'
permalink: /ja/newsletters/2021/07/14/
name: 2021-07-14-newsletter-ja
slug: 2021-07-14-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、提案された新しいopcodeについての議論と、
bech32mのサポートを追跡するために更新されたwikiページのリンクを掲載しています。
また、Bitcoin Core PR Review Clubミーティングのハイライトや、
Taprootの準備についての提案、人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更の説明など、
恒例のセクションも含まれています。

## ニュース

- **`OP_CHECKSIGFROMSTACK`の設計の提案リクエスト:**
  Jeremy Rubinは、[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] opcodeの仕様案を
  Bitcoin-Devメーリングリストに[投稿し][rubin csfs]、
  代替設計を好む開発者からのフィードバックを求めました。
  いくつかの代替案が議論されましたが、スレッドは[OP_CAT][] opcodeを同時に導入すべきかどうかという議論にも分岐しました。

    `OP_CAT`と`OP_CSFS`は、任意のトランザクションのイントロスペクションを可能にします。
    つまり、ビットコインを受け取ったスクリプトが、そのビットコインを後で使用するトランザクションのほぼすべてのパーツをチェックできるようになります。
    これにより多くの高度な機能（[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]や、
    [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]などの、
    他の提案中のアップグレードバージョン[^expensive]を含む）を有効にできますが、
    `OP_CAT`を使用すると再帰的な[Covenants][topic covenants]を作成することが可能で、
    そのCovenantsにコミットしたビットコインの使用可能性を永続的に制限することができます。
    BitcoinでCovenantsを許可することをに[反対する][rubin cost/benefit]人もいますが、
    再帰的なCovenantsの最悪なケースの問題は、現在のビットコインで既に存在しているという趣旨で
    いくつか[議論][harding altcoins]が[されて][towns multisig]おり、
    `OP_CAT`または同様のopcodeを有効にすることについて心配する必要はありません。

    そのような議論がありながらも、Rubinは、
    `OP_CSFS`はそれ自体で十分に役に立つと[主張し][rubin just csfs]、
    `OP_CAT`を追加する提案から独立した`OP_CSFS`の提案を維持したいと考えています。

- **bech32mサポートの追跡:**
  Bitcoin Wikiの[bech32採用][wiki bech32 adoption]ページが[更新され][erhardt bech32m tweet]、
  どのソフトウェアやサービスがTaprootの[bech32m][topic bech32]アドレスへの支払いや受け取りをサポートしているかが追跡されています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Use script_util helpers for creating P2{PKH,SH,WPKH,WSH} scripts][review club #22363]は、
Sebastian FalbesonerによるPRで、機能テストで手動のスクリプト作成を`script_util`ヘルパー関数の呼び出しに置き換え、
`get_multisig()`関数のエラーを修正しています。
Review Clubミーティングでは、PRで使用されている用語と各スクリプトアウトプットタイプが分類されました。

{% include functions/details-list.md

  q0="script\_util.pyの`key_to_p2pkh_script`および`script_to_p2sh_script`、`key_to_p2wpkh_script`、
`script_to_p2wsh_script`は、何をする関数ですか？"
  a0="これらは、公開鍵やスクリプトからPay to Public Key Hashや、Pay to Script Hash、
Pay to Witness Public Key Hash、Pay to Witness Script Hash
スクリプト用の`CScript`オブジェクトを構築するヘルパー関数です。"
  a0link="https://bitcoincore.reviews/22363#l-17"

  q1="scriptPubKeyおよびscriptSig、witnessの定義"
  a1="scriptPubKeyおよびscriptSigは、それぞれトランザクションのアウトプットとインプットのフィールドで、
使用条件を指定および満たすためのものです。witnessはSegregated Witnessで導入された同じ目的のための追加フィールドです。
使用条件はアウトプットのscriptPubKeyでコミットされ、
それを使用するインプットにはその条件を満たすデータをscriptSigやwitnessに添付する必要があります。"
  a1link="https://bitcoincore.reviews/22363#l-31"

  q2="redeem scriptとwitness scriptの定義。それらの関係は？"
  a2="P2SHおよびP2WSHアウトプットタイプは、scriptPubKey内のスクリプトハッシュにコミットします。
アウトプットが使用される際、使用者はスクリプト自体とそれをパスするために必要な署名やその他のデータを一緒に提供する必要があります。
スクリプトがscriptSigに含まれる場合はredeemScriptと呼ばれ、witnessに含まれる場合はwitness scriptと呼ばれます。
そういう意味で、両者は似ています。P2SHアウトプットにおけるredeemScriptは、P2WSHアウトプットにおけるwitness scriptのようなものです。
ただし、P2SH-P2WSHアウトプットを使用するトランザクションには両方が含まれているため、両者は相互に排他的ではありません。"
  a2link="https://bitcoincore.reviews/22363#l-55"

  q3="スクリプトにエンコードされた使用条件でコインを誰かに送信する場合、アウトプットのscriptPubKeyには何が含まれますか？
またコインが使用される際、インプットで何を提供する必要がありますか？"
  a3="scriptPubKeyにはスクリプトのハッシュとそれが一致することを検証するためのopcodeが含まれています: `OP_HASH160
OP_PUSHBYTES_20 <20B script hash> OP_EQUAL`。scriptSigには、スクリプト自体と初期スタックが含まれています。"
  a3link="https://bitcoincore.reviews/22363#l-102"

  q4="なぜPay-To-ScriptではなくPay-To-Script-Hashを使用するのですか？"
  a4="[BIP16][]に記載されている主な動機は、資金を使用する人に使用条件を提供する負担をかけながら、
任意の複雑なトランザクションに資金を供給する一般的な方法を作成することです。
参加者はまた、scriptPubKeyからスクリプトを除外することはスクリプトに関連する手数料がコインが使用されるまで支払われないことを意味し、
結果としてUTXOセットが小さくなることに言及しました。"
  a4link="https://bitcoincore.reviews/22363#l-112"

  q5="非segwitノードがP2SH-P2WSHインプットを検証する際、何をしているのですか？
非segwitノードによって実行される手順に加えて、segwit対応ノードは何をするのでしょうか？"
  a5="非segwitノードはwitnessを確認することはありあません。
redeemScriptがscriptPubKeyでコミットされたハッシュと一致することを確認することで、
P2SHルールを適用するだけです。segwitノードはこのデータをwitness programと認識し、
witnessデータと適切なscriptCodeを使用してsegwitルールを適用します。"
  a5link="https://bitcoincore.reviews/22363#l-137"

  q6="元の[`get_multisig()`](https://github.com/bitcoin/bitcoin/blob/091d35c70e88a89959cb2872a81dfad23126eec4/test/functional/test_framework/wallet_util.py#L109)
関数のP2SH-P2WSHスクリプトのどこが問題なのでしょうか？"
  a6="P2SH-P2WSHのredeem scriptで、そのハッシュの代わりにwitness scriptを使用しています。"
  a6link="https://bitcoincore.reviews/22363#l-153"
%}

## Taprootの準備 #4: P2WPKHからシングルシグのP2TRへ

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/03-p2wpkh-to-p2tr.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.13.1-beta.rc2][LND 0.13.1-beta]は、0.13.0-betaで導入された機能の
  マイナーな改善とバグ修正を含むメンテナンスリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [C-Lightning #4625][]は、最新の[仕様の変更][offers spec changes]に合わせて、
  [LN offers][topic offers]の実装を更新しました。
  注目すべきは、offerに署名を含める必要がなくなったことです。
  これによりofferのエンコード文字列が大幅に短くなり、QRコードの認識性が向上します。

- [Eclair #1746][]では、プライマリのSQLiteデータベースと並行して、
  PostgreSQLデータベースにデータを複製する機能が追加されました。
  この機能は、最終的にバックエンドの移行を希望するサーバーのテストを容易にするためのものです。
  昨年、SuredbitsのエンジニアであるRoman Taranchenkoは、Optechの[フィールドレポート][suredbits enterprise ln]で、
  PostgreSQLバックエンドを使用してEclairをエンタープライズ用途にカスタマイズしたことを紹介していました。

- [LND #5447][]では、クラスターのノード間で複製され自動フェイルオーバーを可能にする代替データベースを使用して、
  クラスタ内に複数のLNDノードをセットアップする方法を説明する[ドキュメント][lnd leader]を追加しています。
  興味のある方は、[ニュースレター #128][news128 eclair akka]に掲載されているEclairのアプローチと比較してみてください。

- [Libsecp256k1 #844][]は、[Schnorr 署名][topic schnorr signatures]のAPIをいくつか更新しています。
  最も注目すべきは、任意の長さのメッセージの署名と検証を可能にする[コミット][nick varsig]です。
  現在Bitcoinで使用されている署名は、すべて32バイトのハッシュに署名していますが、
  可変長データへの署名を可能にすることは、Bitcoin以外のアプリケーションで有用で、
  また[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]などの新しいopcodeを有効にして
  Bitcoin以外のシステムで作成された[署名を検証][oconnor var csfs]できるようになります。
  BitcoinのSchnorr署名の仕様[BIP340][]が更新され、可変長データへの安全な署名について記述されることが期待されます。

- [BIPs #943][]は、SegWit v0ではなく、
  まもなくアクティベートされるTaprootおよびTapscriptに基づいて構築されるように[BIP118][]を更新しています。
  さらに、このリビジョンでは、
  タイトルの名前がSIGHASH_NOINPUTから[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]に変更され、
  sighash flagは"ANYPREVOUT"と呼ばれるようになりました。
  これは、prevoutが署名で使用される可能性がある一方で、インプットのいくつかの側面がまだコミットされているためです。

- [BTCPay Server #2655][]は、[ブロックエクスプローラ][topic block explorers]で
  ユーザーがトランザクションのリンクをクリックした際に、
  HTTP `referer`フィールドを送信しないようWebブラウザに通知します。
  これにより、ユーザーがどのBTCPay Serverから来たのかをブロックエクスプローラに伝えないようにします。
  この情報は、サーバーがブロックエクスプローラで表示されているトランザクションを作成もしくは受信したことを示す強力な証拠です。
  この変更があっても、強力なプライバシーを望むユーザーは、
  サードパーティのブロックエクスプローラで自分のトランザクションを検索するのを避ける必要があります。

## 脚注

[^expensive]:
    [BIP118][]の[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]や
    [BIP119][]の[OP_CHECKTEMPLATEVERIFY][topic op_checksigfromstack]のような提案の機能を実装するのに、
    `OP_CHECKSIGFROMSTACK` (`OP_CSFS`)を使用すると、
    scriptpathで使用する場合に最適化された提案よりも多くのブロックスペースが必要になります。
    `OP_CSFS`を支持する[議論][news48 generic csfs]は、
    より効率的な実装を追加するためにコンセンサスの変更をする前に、
    一般的な構成から始めて、人々が実際にその機能を使用することを証明することができるからです。
    さらに、[Taproot][topic taproot]のkeypathでの使用により、
    どのようなスクリプトでも、状況によってはブロックスペースの使用を最小限に抑えることができ、
    最適化されていない状況でスペースを節約するために特定の構成の必要性が減る可能性があります。

{% include references.md %}
{% include linkers/issues.md issues="4625,5447,844,1746,943,2655,22363" %}
[LND 0.13.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.1-beta.rc2
[bip341 cite22]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_ref-22-0
[News128 eclair akka]: /en/newsletters/2020/12/16/#eclair-1566
[oconnor var csfs]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019193.html
[erhardt bech32m tweet]: https://twitter.com/murchandamus/status/1413687483246776322
[wiki bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
[rubin csfs]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019192.html
[harding altcoins]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019203.html
[towns multisig]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019209.html
[rubin just csfs]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019229.html
[lnd leader]: https://github.com/bhandras/lnd/blob/f41771ce54bb7721101658477ad538991fc99fe6/docs/leader_election.md
[nick varsig]: https://github.com/bitcoin-core/secp256k1/pull/844/commits/a0c3fc177f7f435e593962504182c3861c47d1be
[news48 generic csfs]: /en/newsletters/2019/05/29/#not-generic-enough
[op_cat]: /en/topics/op_checksigfromstack/#relationship-to-op_cat
[rubin cost/benefit]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019200.html
[offers spec changes]: https://github.com/lightningnetwork/lightning-rfc/pull/798#issuecomment-871124755
[suredbits enterprise ln]: /en/suredbits-enterprise-ln/
[series preparing for taproot]: /ja/preparing-for-taproot/