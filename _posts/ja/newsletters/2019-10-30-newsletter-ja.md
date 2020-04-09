---
title: 'Bitcoin Optech Newsletter #70'
permalink: /ja/newsletters/2019/10/30/
name: 2019-10-30-newsletter-ja
slug: 2019-10-30-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、最新のC-Lightningリリースを発表、Bitcoin Coreリリース候補のテスト支援リクエスト、CPFP(Child-Pays-For-Parent) carve-outを使用したLNコミットメントの簡素化に関する議論、ビットコインStackExchangeからのトップ投票の質問と回答の要約をお届けします。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **C-Lightning 0.7.3へのアップグレード:** この最新の[リリース] [c-lightning 0.7.3]は、PostgreSQLバックエンドのサポートを追加し、チャンネルを閉じる際の特定のアドレスに直接資金の送信すること、`lightningd`が実行されていないときにHDウォレットシードを暗号化したままにしておくことを可能とします。加えてその他の多くの機能といくつかのバグ修正が含まれています。

- **Bitcoin Coreリリース候補のテストを支援:** 経験豊富なユーザーは、次期バージョン [ビットコインコア] [Bitcoin Core 0.19.0]の最新リリース候補のテストを支援することをお勧めします。

## News

- **LNコミットメントの簡素化:** 2つの別々のスレッドで、LNDの開発者は、LNの決済トランザクションであるコミットメントについて、最小限の取引手数料の支払で済む単純化実装について議論しました。単純化されたコミットメントには取引手数料と2つの追加output（各当事者に1つ）が含まれます。 どちらの当事者も、トランザクションがブロードキャストされたときに支払う取引手数料を選択できるようにするというアイデアです。個々のoutputから Child-Pays-For-Parent (CPFP) fee bumpingを使用して実行できます。 これは過去に議論されていましたが、今後のビットコインコアバージョン0.19.0にCPFPカーブアウトを含めることで解決されると予想される攻撃に対して脆弱でした（[Newsletter＃56] [pr15681]参照）。

    最初のスレッドでは、Johan Halsethが[メール][halseth carve-out]を投稿し、単純化されたコミットメントをさらに簡素化するために、mempoolポリシーを緩めることについて説明しました。これについては、わずかな変更では効果はなく変更が多すぎるとネットワークが帯域幅を浪費する攻撃の危険にさらされる、という理由で、いくつかの反対意見が挙がりました。 しかし、この議論（およびJeremy Rubinが＃bitcoin-core-dev IRCチャンネルで開始した別の[議論] [rubin justification]）により、多くの開発者が現在のルールとそれらの改善方法をよりよく理解することを望んでいたことが明らかになりました 。 この議題の概要は、現在[wikiページ] [daftuar duo]にSuhas Daftuarによるまとめがあります。上記のもう一つのスレッドはJoost Jagerによって [開始] [anchor thread]されました。内容は以前Rusty Russellによって提案された簡素化されたコミットメントの仕様案についてです（[Newsletter＃23] [opt_simplified]を参照）。今後のカーブアウト機能およびLNのその他の開発に基づいて、Jagerは次のようないくつかの提案をしています。内容としては、CPFPで使用することを意図したoutputに「anchor output」という名前を使用すること、コールドウォレットとホットウォレットの間の責任分担を容易にするために、anchorに追加の公開鍵のセットを使用すること、 静的キーを使用してバックアップの回復を簡素化すること、などが含まれています。またJoost JagerはBOLTリポジトリに[PR][BOLTs
    #688]をオープンし、LNプロトコル仕様に簡素化されたコミットメントを追加しています。

- **schnorr / taprootワークショップのビデオおよび教材資料が公開されました:**
  Optechは、ビデオ、Jupyter notebooks、GitHubリポジトリ、および先月サンフランシスコとニューヨークで開催されたschnorrおよびtaprootワークショップ向けに作成された詳細情報へのリンクを含む[ブログ投稿] [taproot workshop]を公開しました。 提案の基礎的な内容から追加された機能を最適に使用するための方法などが説明されています。

   将来Bitcoinに追加される可能性のあるこれらの機能に関心のあるすべての開発者、特に[先週のNewsletter] [tr]で説明されている[taproot review] []に参加している開発者にお勧めします。

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange] [bitcoin.se]は、オプテックの貢献者が質問への回答を探す、または、時間がある時に疑問のあるユーザーを支援するサイトのうちの1つです。 月次で、投稿された上位投票の質問と回答の一部をピックアップします。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}


- [<!--hashing-quantum-resistance-->なぜ公開鍵をハッシュしても実際に量子耐性が得られないのですか？]({{bse}}91049)
  Andrew Chowは、公開鍵と量子耐性に関するいくつかの考慮事項を挙げています。支払い中に公開鍵を明らかにする必要性があることや、既知の公開鍵を含むビットコインのoutputが多数存在すること、公開鍵が取引以外の理由で公開されている、など公開鍵が秘密として扱われていない現状についてです。


- [Schnorrのマルチ署名はECDSAを完全に置き換えますか？]({{bse}}90855)
  Ugam Kamatは、提案されたsegwit v1でのシュノア署名の追加がECDSAの必要性を除去しないことを説明しています。 segwit v0 outputだけでなくsegwit非対応アドレスもECDSAを必要とします。

- [RBFの仕様がoutputに関する制約を含まないのはなぜですか？]({{bse}}90858)
  Andrew Chowが、[BIP125] [] Opt-in Replace by Fee（RBF）の設計上の選択のいくつかを取り上げ、それをFirst Seen Safe Replace by Fee（FSS-RBF）アプローチと比較しています。 ChowはFSS-RBFの欠点を指摘していますが、未確認のトランザクションの受け入れについても警告しています。

## Notable code and documentation changes

*今週の[Bitcoin Core] [bitcoin core repo]、[C-Lightning] [c-lightning repo]、[Eclair] [eclair repo]、[LND] [lnd repo]、[libsecp256k1] [libsecp256k1 repo]、[Bitcoin Improvement Proposals（BIPs）] [bips repo]、および [Lightning BOLT] [bolts repo]の注目すべき変更点*

- [Bitcoin Core #17165][] は、[BIP70] []支払いプロトコルのサポートを削除します。 この変更はマスター開発ブランチでのみ行われており、おそらく約6か月後に予定されているバージョン0.20まではリリースされません。 BIP70は[バージョン0.18.0][core 0.18.0]でオプションになり、今後の0.19.0ではデフォルトで無効になります。 詳細については、[Newsletter＃19] [pr14451]を参照してください。

    これは、OpenSSLに依存するBitcoin Coreの最後の重要な機能であり、更に[PR] [Bitcoin Core #17265]が、その依存関係を完全に削除するためにオープンされました。 OpenSSLは、Bitcoin Coreの以前の脆弱性（たとえば[Heartbleed] []および[non-strict signature encoding] [ber]）の原因となっておりであり、依存関係の排除のために過去5年以上にわたる努力が費やされてきました。

{% include linkers/issues.md issues="17165,17265,688" %}
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[c-lightning 0.7.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.3
[tr]: https://github.com/ajtowns/taproot-review
[tr rsvp]: https://forms.gle/iiPaphTcYC5AZZKC8
[core 0.18.0]: https://bitcoincore.org/en/releases/0.18.0/#build-system-changes
[pr14451]: /en/newsletters/2018/10/30/#bitcoin-core-14451
[heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[ber]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[pr15681]: /en/newsletters/2019/07/24/#bitcoin-core-15681
[opt_simplified]: /en/newsletters/2018/11/27/#simplified-fee-bumping-for-ln
[anchor thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002249.html
[halseth carve-out]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002240.html
[daftuar duo]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/Mempool-and-mining
[rubin justification]: http://www.erisian.com.au/bitcoin-core-dev/log-2019-10-24.html#l-660
[taproot workshop]: /ja/schorr-taproot-workshop/
[taproot review]: https://github.com/ajtowns/taproot-review
[tr]: /ja/newsletters/2019/10/23
