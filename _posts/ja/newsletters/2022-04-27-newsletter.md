---
title: 'Bitcoin Optech Newsletter #197'
permalink: /ja/newsletters/2022/04/27/
name: 2022-04-27-newsletter-ja
slug: 2022-04-27-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、`OP_CHECKTEMPLATEVERIFY`のアクティベートに関する議論の要約と、
Bitcoin Stack Exchangeのトップの質問とその回答、
新しいソフトウェアのリリースとリリース候補、人気のあるBitcoinインフラストラクチャソフトウェアの最近の変更など
恒例のセクションを掲載しています。

## ニュース

- **CTVのアクティベートに関する議論:** Jeremy Rubinは、Bitcoin-Devメーリングリストに、
  提案中の[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) opcodeの[BIP119][]ルールを適用する意思があるかどうかを
  マイナーがシグナリングし始めることができるソフトウェアをリリースする計画を[投稿しました][rubin ctv-st]。
  今後いくつかの2,016ブロック（2週間）のリターゲット期間に90%のブロックがポジティブなシグナルを送ると、
  Rubinのソフトウェアを使用するユーザーは、11月初旬頃からCTVのルールを適用し始めることになります。

  Rubinは、Bitcoinユーザーが今すぐCTVをアクティベートする方が良いと考える理由について、
  以下のように詳しく説明してます:

  - *<!--consistency-->一貫性:* CTVは安定した仕様と実装を持っている

  - *<!--popularity-->人気:* Bitcoinコミュニティでよく知られている多くの人々や組織がCTVをサポートしている

  - *<!--viability-->実現性:* CTVがBitcoinに強く望まれる特性に違反していると主張する異論はない

  - *<!--desirability-->望ましさ:* CTVは[Covenant][topic covenants]ベースの[Vault][topic vaults]など、
    ユーザーが望む機能を提供する

  メーリングリストでは、Rubinのメールに直接、あるいは他のスレッドで、10人以上の人が返信しています。
  注目すべき返信をすべてまとめることはできませんが、特に興味深いと思われるコメントをいくつか紹介します:

  - Anthony Townsは、CTVの[signet][topic signet]のトランザクションを[分析しました][towns ctv signet]。
    ほぼすべてが同じソフトウェア（[Sapio][]）で構築されているように見え、
    これはCTVの公開調査が不足していることを示している可能性があります。
    彼はさらに、新しい機能を追加するためにコンセンサスルールを変更することは、
    新しい機能を使用する予定がない人でも、すべてのBitcoinユーザーにリスクが生じるため、
    その機能が「リスクを正当化するのに十分な価値がある」という公的な証拠を非採用者に提供することが重要だと述べています。
    この投稿に続いて、CTVのsignetで[追加の実験][fiatjaf vault]が行われました。

  - Matt Coralloはまた、コンセンサスを変更することは誰にとっても大きなコストを生むので、
    提案が変更により最大の価値を提供すると確信できる場合にのみソフトフォークを試みるべきであると[主張しました][corallo ctv cost]。
    Covenantの場合、Coralloは「最も柔軟で有用で、できればプライベートな」設計を見たいと考えています。
    その後、「私が見た限りでは、CTVが本当に良い選択肢であるかどうかは明らかではない」と[述べています][corallo not clear]。

  - Russell O'Connorは、#bitcoin-wizards IRCで、
    提案されているCTVの使用法の1つは、base58checkや[bech32][topic bech32]およびbech32mなどの
    既存のBitcoinアドレスで通信できないことを[指摘しました][oconnor wizards]。
    *Bare Script*（scriptPubKey内に直接登場するScript）を介してCTVを使用するその方法は、
    ウォレット開発者が、独自の内部トランザクションでBare CTVのみを使用するか、
    アドレスに通常含まれる情報を伝達するための特別なツールを作成する必要があります。
    あるいは、一部のアプリケーション（[Vault][topic vaults]など）にCTVを使用したいウォレットは、
    後でBare CTVを使用することをコミットしたP2TRアドレスへの支払いを受け取ることができます。

    アドレスの制限に関するO'Connorの議論は、Townsによってメーリングリスト上で[言及されました][towns bare]。
    O'Connorはさらに詳細を[返信し][oconnor bare]、Bare CTVのサポートがCTVのBIP119の仕様の一部でない場合、
    よりシンプルでより構成しやすい（他のopcodeと組み合わせて有用なScriptを生成しやすい）別の設計を提唱すると述べました。
    しかし、それ以上に、より一般的な`OP_TXHASH`の設計（[ニュースレター #185][news185 txhash]参照）を好んでいます。
    Rubinは、いくつかの反論を[返信しました][rubin bare]。

  - David Hardingは、CTVの用途が明白でないか、他のCovenantの構成がより一般的な用途に適しているため、
    CTVが長期的にはあまり使用されないかもしれないという懸念を[伝えました][harding transitory]。
    この場合、将来のコンセンサスコードの開発者は、CTVのコードを維持し、
    後で提案されるコンセンサスの変更との潜在的な相互作用性を分析するという永続的な負担を負わなければならなくなります。
    Hardingは、5年間BitcoinにCTVを一時的に追加し、
    その間に人々がそれをどのように使用したかについてデータを収集し、
    5年後にBitcoinのユーザーが維持する価値があると判断しない限り、自動的に無効にすることを提案しました。
    このアプローチに賛成する回答者はおらず、ほとんどの回答者が、この方法のコストは高すぎる、
    もしくはメリットが低すぎると主張していました。また、CTVが有効な間に作成されたブロックを将来完全に検証したい人は、
    依然としてCTVの検証コードを必要とするため、5年後にopcodeが無効になったとしても、
    CTVのコードは永久に維持する必要があるかもしれないと指摘されました。

  - Antoine "Darosior" Poinsotは、CTVの代わりに、
    [BIP118][] `SIGHASH_ANYPREVOUT` ([APO][topic sighash_anyprevout])の少し修正されたバージョンを、
    あるいは少なくともCTVのアクティベートの前にこれをアクティベートすることについてフィードバックを[求めました][darosior apo]。
    APOを修正することで、アプリケーションによってはより高いコストになるものの、
    CTVの機能をエミュレートすることができます。APOをアクティベートすることで、
    LNで提案されている[Eltoo][topic eltoo]レイヤーを有効にするという本来の用途も可能になり、
    より効率的でほぼ間違いなくより安全なLNチャネルの状態の更新が可能になります。

  - James O'Beirneは、彼のCTVベースの[Simple Vault][simple vault]は、
    そのシンプルさとそれが実運用可能であれば多くのBitcoinユーザーのセキュリティを大幅に強化する能力があるため、
    異なるCovenantの設計を評価するためのベンチマークとして使用できると[提案しました][obeirne benchmark]。
    Darosiorは、このチャレンジを最初に受け入れ、Simple Vaultのコードを
    CTVから`SIGHASH_ANYPREVOUT`の実装に[移植しました][darosior vault]。

  この要約が書かれている時点では、メーリングリストでの議論はとても活発なままでした。
  また、TwitterやIRC、Telegramのチャットなどでも、CTVとCovenantの技術に関する興味深い会話がいくつか見受けられました。
  それらの会話の参加者は、重要な洞察をBitcoin-Devメーリングリストで共有することをお勧めします。

  上記の議論の後、Jeremy Rubinは、
  CTVのアクティベートを可能にするソフトウェアのバイナリビルドを直ちにリリースしないことを[発表しました][rubin path forward]。
  その代わりに、彼は受け取ったフィードバックを評価し、他のCTVのサポーターと協力して修正したアクティベートプランを提案する可能性がとのことです。
  Optechは、今後のニュースレターでこの件に関する最新情報を提供します。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--how-was-the-generator-point-g-chosen-in-the-secp256k1-curve-->secp256k1曲線の生成点Gはどのように選ばれたのでしょうか？]({{bse}}113116)
  Pieter Wuilleは、[生成点G][se 29904]を選択した正確な根拠は公表されていないが、
  珍しい特性がその構造を示唆している可能性があると述べています。

- [<!--what-is-the-maximum-realistic-p2p-message-payload-size-->現実的なP2Pメッセージの最大ペイロードサイズはどのくらいですか？]({{bse}}113059)
  0xb10cは、`MAX_SIZE` (32MB)の有効な[P2Pメッセージ][p2p messages]が存在するかどうかを尋ねています。
  Pieter Wuilleは、`MAX_PROTOCOL_MESSAGE_LENGTH`（[4MB][bitcoin protocol 4mb]、
  [Segwitの一部][Bitcoin Core #8149]として[2MB][Bitcoin Core #5843]から増加）
  がサービス拒否攻撃を防止するために受信メッセージのサイズを実際に制限しているものであると説明しています。

- [<!--is-there-evidence-for-lack-of-stale-blocks-->古いブロックがなくなっている証拠はありますか？]({{bse}}113413)
  Lightlikeは、[KIT統計ウェブサイト][KIT statistics]のブロック伝播時間の履歴チャートを参照し、
  [#8068][Bitcoin Core #8068]で最初に実装された[Compact Blockリレー][topic compact block relay]([BIP152][])が、
  時間の経過とともに[古いブロック][se 5866]の頻度を減らす要因になっていると指摘しています。

  {:.center}
  ![Block Propagation Delay History chart](/img/posts/2022-04-block-propagation-delay.png)

- [<!--does-a-coinbase-transaction-s-input-field-have-a-vout-field-->コインベーストランザクションのインプットフィールドにはVOUTフィールドがありますか？]({{bse}}113392)
  Pieter Wuilleは、コインベーストランザクションのインプットの要件を概説しています:
  prevout hashは`0000000000000000000000000000000000000000000000000000000000000000`でなければならず、
  prevout indexは`ffffffff`で、2-100バイトの`scriptSig`が必要で、
  [BIP34][]から`scriptSig`はブロック高から始まる必要があります。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 23.0][]は、この重要なフルノードソフトウェアの次のメジャーバージョンです。
  [リリースノート][bcc23 rn]には、
  新しいウォレットのデフォルトとして[ディスクリプター][topic descriptors]ウォレットが追加され、
  ディスクリプターウォレットが[Taproot][topic taproot]を使用して
  [bech32m][topic bech32]アドレスへの受け取りを簡単にサポートするなど、複数の改善点が記載されています。

- [Core Lightning 0.11.0][]は、この人気のあるLNノードソフトウェアの次のメジャーバージョンのリリースです。
  この新しいバージョンでは、他の機能やバグ修正に加えて、
  同じピアに対する複数のアクティブチャネルと、
  [ステートレスインボイス][topic stateless invoices]への支払いをサポートしています。

- [Rust-Bitcoin 0.28][]は、このBitcoinライブラリの最新リリースです。
  最も大きな変更点は、Taprootのサポートの追加と[PSBT][topic psbt]などの関連APIの改善です。
  その他の改善やバグ修正については、[リリースノート][rb28 rn]に記載されています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [LND #5157][]は、指定されたノードとのピア接続を開始する`--addpeer`起動オプションを追加しています。

- [LND #6414][]は、有効になっている場合、
  keysendによる[自発的な支払い][topic spontaneous payments]のサポートを宣伝します。
  LNDは2019年からkeysendをサポートしていますが、
  当初はノードがそれをサポートしていることを宣伝する方法がないままデプロイされました。
  他のLNノードソフトウェアのkeysendの実装は、彼らのノードの宣伝でサポートを通知しており、
  このマージされたPRはLNDでもそれを再現しています。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5157,6414,5843,8149,8068" %}
[bitcoin core 23.0]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bcc23 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-23.0.md
[core lightning 0.11.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.0.1
[rust-bitcoin 0.28]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.28.0
[rb28 rn]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/CHANGELOG.md#028---2022-04-20-the-taproot-release
[rubin ctv-st]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020233.html
[towns ctv signet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020234.html
[sapio]: https://learn.sapio-lang.org/
[corallo ctv cost]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020263.html
[corallo not clear]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020289.html
[oconnor wizards]: https://gnusha.org/bitcoin-wizards/2022-04-19.log
[towns bare]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020245.html
[oconnor bare]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020256.html
[rubin bare]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020260.html
[harding transitory]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020242.html
[darosior apo]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020276.html
[obeirne benchmark]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020280.html
[simple vault]: https://github.com/jamesob/simple-ctv-vault
[news185 txhash]: /ja/newsletters/2022/02/02/#ctv-apo
[fiatjaf vault]: https://twitter.com/fiatjaf/status/1517836181240782850
[rubin path forward]: https://twitter.com/JeremyRubin/status/1518477022439247872
[darosior vault]: https://twitter.com/darosior/status/1518961471702642689
[se 29904]: https://bitcoin.stackexchange.com/questions/29904/
[p2p messages]: https://developer.bitcoin.org/reference/p2p_networking.html#data-messages
[bitcoin protocol 4mb]: https://github.com/bitcoin/bitcoin/commit/2b1f6f9ccf36f1e0a2c9d99154e1642f796d7c2b
[KIT statistics]: https://www.dsn.kastel.kit.edu/bitcoin/index.html
[se 5866]: https://bitcoin.stackexchange.com/a/5866/87121
