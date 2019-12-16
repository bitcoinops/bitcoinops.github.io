---
title: 'Bitcoin Optech Newsletter #75'
permalink: /ja/newsletters/2019/12/04/
name: 2019-12-04-newsletter-ja
slug: 2019-12-04-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、schnorrおよびtaprootの提案に関する議論の説明、以前は`OP_CHECKOUTPUTSHASHVERIFY`および`OP_SECURETHEBAG`として知られていた提案の更新の解説、LNのWatchtowerを標準化する提案へのリンク、Bitcoinインフラストラクチャー・プロジェクトの注目すべき変更点をお送りします。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

*今週は特になし。*

## News

- **Continued schnorr/taproot discussion:** 今週、Russell O'ConnorはBitcoin-Devメーリングリストで[スレッド][oconnor checksig pos]を開始し、オペコードの位置に署名をコミットすることについて[前の議論][wuille safer sighashes]を続けました。それは署名（例 オペコード`OP_CHECKSIG`、`OP_CHECKSIGVERIFY`や[tapscript's][topic tapscript]での新しいオペコード`OP_CHECKSIGADD`）を評価することが期待されています。O'Connorは、このコミットメントにより、複数のユーザーからの署名を使用してさまざまな方法でスクリプトを満たすような、複数ブランチのスクリプトを使用する人々にさらなる保護を提供できると主張しています。この保護がなければ、Malloryがブランチ*B*でその署名を実際に使用するときに、Malloryがブランチ*A*に署名するようにボブに依頼することができかねません。既存のオペコードである`OP_CODESEPARATOR`はそのような状況に対処するのに役立ちますが、よく知られていません。よって本問題に直接対処することで安全性が向上し、tapscriptに`OP_CODESEPARATOR`を含める必要がなくなる可能性があります。

    いくつかの参加者による[IRCの議論][irc checksig pos]に続いて、Anthony Townsは提案された代替案に対して[返信][towns checksig pos]しました。それは、この問題の影響を受けやすいスクリプトは、そのブランチを、コードブランチを１つだけ持つような複数のtaprootリーフに分離する必要がある、という内容です。Tapscriptの署名は、実行中のスクリプトに既にコミットされているため、1つのスクリプトに有効な署名を別のスクリプトで使用することはできません。Townsはまた、その位置だけにコミットすることは、再配置された署名に対する保護を保証できない理由を説明しました。彼は優れた保護を提供できると考えている方法を説明しましたが、tapscriptに`OP_CODESEPARATOR`を保持することと比較して、それは特に有用ではないと考えています。

    schnorr関連の別のトピックで、ZmnSCPxjは[MuSig][]署名集約プロトコルをサブグループで安全に使用するという課題について[投稿][zmn composable musig]しました。たとえば、ZmnSCPxjの[nodelets提案][nodelets proposal]は、アリスとボブが、キーの集約（A、B）を使用して、単一のLNノードを通じて共同で資金を制御できることを示唆しています。それらの共同ノードは、チャーリーのノードへのチャネルを、ここでもMuSig集約((A, B), C) を使用して、開くことができます。ただし、ZmnSCPxjは、[先週のニュースレター][news74 taproot updates]で説明されているように、Wargnerのアルゴリズムを考えると、これが安全ではない理由を説明しています。また、問題を回避しようとするいくつかの代替スキームも説明しています。

- **`OP_CHECKTEMPLATEVERIFY` (CTV):** [Newsletter#48][news48 coshv]で説明されている `OP_CHECKOUTPUTSHASHVERIFY`（COSHV）と[Newsletter#49][news49 stb]で言及されている`OP_SECURETHEBAG`の後継です。Jeremy Rubinにより[提案][ctv post]された新しいopcodeは、スクリプトによりファンドが特定の子トランザクションでのみ使用できるようにします。名称変更に加えて、Rubinは[提案済みのBIP][bip-ctv]に詳細を加えて、2020年初にレビューワークショップを開催する予定です（参加を希望する方は[このフォーム][ctv workshop]に記入してください）。

    メーリングリストで、Russell O'Connorは、ビットコイン・スクリプトにて特殊な順序でスタックからデータを引き出すCTVに関する[懸念][oconnor state variable]を[再表明][oconnor suggested amendments]しました。
これは、再帰的な[covenants][topic covenants]の作成を防ぐためにRubinによって追加されたものです。再帰的なcovenantsとは有限の子孫トランザクションだけに適用されるのではなく、特定のスクリプトから派生したすべての支払に永久に適用されるスクリプト条件のことです。例えば、支払者は、一連のコインの将来の受取人を3つのアドレスのみに制限できます。他のアドレスに対するいかなる支払いも禁止されます。O'Connorの懸念は、ビットコイン・スクリプトのセマンティクスのモデル化を難しくするというCTVの特殊な挙動にフォーカスしているようです。これはO'Connorが以前に取り組んでいたもので、彼が継続的に取り組んでいる[Simplicity][]スクリプト言語に関連があります。

    IRCで、Gregory MaxwellとJeremy RubinはCTVの複数の観点について[議論][irc ctv]しており、特に提案されたOpcodeが、提案されている簡易な[congestion controlled transactions][]と[payment pools][]との利用を困難にすることなく、高度なデザインにより容易に利用できるようにする点にフォーカスしています。また彼らは、Maxwellにより開始された[2013年のスレッド][coincovenants]の会話の中で[暗示][covenant allusion]された、再帰的Covenentsを使用する不適切な方法に関して、再帰的なCovenantsを作成できないようにすることが本当に必要か、議論しました。

- **Proposed watchtower BOLT:** Sergi Delgado Seguraは、Lightning-Devメーリングリストに、彼とPatrick McCorryが取り組んでいるBOLTドラフトを[投稿][watchtower protocol]しました。[Watchtowers][topic watchtowers]は、オフラインになっている可能性のあるLNノードに代わってペナルティ・トランザクションをブロードキャストするサービスです。提案された仕様の目標は、すべてのLN実装に異なるWatchtowerがあるのではなく、すべてのLN実装が任意のWatchtowerと相互運用できるようにすることです。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[libsecp256k1][libsecp256k1 repo]、[ビットコイン改善提案（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [C-Lightning #3259][]は、[マルチパス支払い][topic multipath payments]を有効にする一環として[BOLTs #643][]で提案されているpayment secretの実験的サポートを追加します。payment secretは受信者によって生成され、その受信者の[BOLT11][]インボイスに含まれます。支払い者は、暗号化された支払いの一部にこの秘密を含めます。受信者は、秘密が含まれている場合にのみインボイスの入金を受け入れます。こうすることで他のノードが受信者を調べて、以前に使用した支払いハッシュへの追加の支払いを期待しているかどうかを確認することを防ぎます。

- [C-Lightning #3268][]は、デフォルトのネットワークをビットコインテストネットからビットコインメインネットに変更します。また、指定されたファイルで提供される設定ディレクティブを読み込む新しい設定オプション`include`を追加します。

{% include linkers/issues.md issues="3259,643,3268" %}
[news48 coshv]: /en/newsletters/2019/05/29/#proposed-new-opcode-for-transaction-output-commitments
[news49 stb]: /en/newsletters/2019/06/05/#coshv-proposal-replaced
[oconnor checksig pos]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017495.html
[wuille safer sighashes]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016508.html
[irc checksig pos]: http://www.erisian.com.au/taproot-bip-review/log-2019-11-28.html#l-65
[towns checksig pos]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017497.html
[zmn composable musig]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017493.html
[nodelets proposal]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002236.html
[news74 taproot updates]: /ja/newsletters/2019/11/27
[ctv post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017494.html
[bip-ctv]: https://github.com/JeremyRubin/bips/blob/ctv/bip-ctv.mediawiki
[ctv workshop]: https://forms.gle/pkevHNj2pXH9MGee9
[oconnor state variable]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017496.html
[oconnor suggested amendments]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016973.html
[irc ctv]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-11-28#25861123;
[congestion controlled transactions]: https://github.com/JeremyRubin/bips/blob/ctv/bip-ctv.mediawiki#Congestion_Controlled_Transactions
[payment pools]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-05-21#1558427254-1558427441;
[watchtower protocol]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002350.html
[coincovenants]: https://bitcointalk.org/index.php?topic=278122.0
[simplicity]: https://blockstream.com/simplicity.pdf
[covenant allusion]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-11-28#25861296

