---
title: 'Bitcoin Optech Newsletter #82'
permalink: /ja/newsletters/2020/01/29/
name: 2020-01-29-newsletter-ja
slug: 2020-01-29-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LND 0.9.0-betaのリリースの発表、Bitcoin Coreのリリース候補(RC)に対するテスターの公募、UTXOと未公開LNチャネル間のリンクを削除する提案の説明、eltooベースのペイメント・チャネルでの支払い管理をシンプルにすると期待されている`SIGHASH_ANYPREVOUTANYSCRIPT`署名ハッシュの変更に対する要約をお送りします。また、注目すべきBitcoin Stack ExchangeのQ＆A、主なBitcoinインフラストラクチャおよびドキュメント・プロジェクトなどの主要な変更についてもお送りします。

## Action items

- **LND 0.9.0-betaへのアップグレード:** この新しいメジャーバージョン・[リリース][lnd
  0.9.0-beta]は、アクセス制御・リストメカニズム（通称「マカロン」）の改善、[マルチパス・ペイメント][topic multipath payments]の受信サポート、暗号化されたオニオン・メッセージで追加データを送信する機能をもたらし（[Newsletter#81][news81 lnd3900]参照）、ネイティブ・リバランスのサポート（[Newsletter#74][news74 lnd3739]参照）、チャネルクローズ出力の指定されたアドレスへの支払いリクエスト機能、（例えばハードウェア・ウォレットなど、[Newsletter#76][news76 lnd3655]参照）その他の多くの機能とバグ修正が含まれます。

- **Bitcoin Core 0.19.1rc1のテスト:** 今回のメンテナンス・[リリース][bitcoin core 0.19.1]には、いくつかのバグ修正が含まれています。経験豊かなユーザーは、予期した通りに動くか、テストで確認することをお勧めします。

## News

- **UTXOと未公開チャネル間のリンクの削除:** Bastien Teinturierは、未公開チャネル（LNネットワーク上、公開されていない、通常は他のユーザーの支払いをルーティングしていないチャネル）に送信される支払いの[BOLT11][]・インボイスに追加されるデータの変更について、Lightning-Devメーリングリストに[投稿しました][teinturier post]。提案された変更により、チャネルのデポジットUTXOを識別するために使用されるインボイスから情報が削除され、1回限りのインボイスごとのキーペアと、そのキーペアから派生したシークレットに置き換えられ、オニオン暗号化ペイメントの一部としてルーティングされます。これには、支払者と未公開チャネルにルーティングできるピアの両方からの特別なサポートが必要になりますが、ルーティングパスに沿った他のノードの実装を変更する必要はありません。Teinturierは、（本提案における欠点とも言える）暗号化されたシークレットを支払いに含める必要性を排除する方法に関する提案を含め、このアイデアに対するフィードバックを求めています。

- **eltooによる階層化されたコミットメント:** Anthony Townsは、[eltooベース][topic eltoo]のLNチャネルをシンプルにできる、前回彼が出した[anyprevout提案][bip-anyprevout]（[SIGHASH_NOINPUT][topic sighash_anyprevout]の派生）の変更について[説明しました][towns
  layered commitments]。現在提案されているように、eltooベースのLN実装は、支払いの一方的なクローズに含まれる遅延条件（to_self_delay）の前に、支払いのタイムアウトに伴う払い戻し(cltv_expiry_delta)を受け入れないようにする必要があります。そうでないと、受信ノードが正当に支払いを請求する十分な機会を得る前に、支払ノードが支払いを取り戻すことが出来てしまいます（アダプタ署名（「ポイントロック」）を使用してこれは行われます）。これは、タイムアウト(cltv_expiry_delta)と遅延条件（to_self_delay）を独立した形で選択できる現在のスタイルのLN払いとは異なります。

  eltooが同様のタイムアウトと遅延パラメーターの独立性を実現するために、Townsは`SIGHASH_ANYPREVOUTANYSCRIPT`署名ハッシュ（sighash）フラグを使用して作成された署名から入力値（`sha_amounts`）への[BIP341][]コミットメントを削除することを提案します。これには、[tapscript][topic tapscript]の`OP_CODESEPARATOR`オペコードのバリエーションの使用など、eltooで使用されるスクリプトの変更も必要です。

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・答えについて共有しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [OP_CHECKTEMPLATEVERIFYはどのようなスケーリングソリューションですか？]({{bse}}92755) Confused_Coderは、提案された新しいオペコード`OP_CHECKTEMPLATEVERIFY`が、複数の支払いを、のちに複数のアウトプットに拡張できる単一のアウトプットにカプセル化することにより、[フィーが安くなるまでブロックスペースの使用を遅らせる][news48 output commitments]方法を説明しました。

- [BIP174 psbtにBIP32フィンガー・プリントが使用されたのはなぜですか？]({{bse}}92848) Andrew Chowは、BIP32フィンガー・プリントがフルハッシュの代わりにBIP174 [PSBT][topic psbt]仕様全体で使用される理由を、ハードウェア・ウォレットからフルpubkey hash160を取得することの非実用性を持ち出しながら説明しました。

- [<!--how-is-the-size-of-a-bitcoin-transaction-calculated-->ビットコイン・トランザクションのサイズはどのように計算されますか？]({{bse}}92689) ユーザーSeptem151は、セグウィット・トランザクションと非セグウィット・トランザクションの両方で重量単位（vbytes）がどのように計算されるかについて、各項目ごとに詳細な説明を提供しました。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[libsecp256k1][libsecp256k1 repo]、[Bitcoin Improvement Proposals
(BIPs)][bips repo]および [Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #17492][]を使用すると、ユーザーがウォッチ・オンリーウォレットで、トランザクションをフィー・バンプしようとすると、Bitcoin Core GUIが部分署名ビットコイン・トランザクション（[PSBT][topic psbt]）をクリップボードに配置します。ユーザーは、署名のためにPSBTを別のプログラム（[HWI][topic hwi]など）に貼り付けることができます。

- [C-Lightning #3376][]は、支払者と受信者のブロックの高さが一致しない場合、リトライによりこの事象を解消する処理します。実装を簡素化するために[仕様][BOLT4]を変更する必要があるかどうかについては、PRで議論されていますが、この状況につながった仕様の変更により[プライバシーリークが解消される][bolt4 privacy leak]ことが指摘されています。

- [LND #3809][]は、`BumpFee` RPCに`force`パラメーターを追加して、作成するトランザクションに「非経済的なUTXO」を含めることができるようにし、[Newsletter #79][news79 lnd3814]で説明されている変更を拡張します。「非経済的なUTXO」は、そのものの価値（アマウント）よりも送付に多くのフィーがかかるUTXOです。提案された[アンカー・アウトプット][topic anchor outputs]のフィー・バンピング方法がLNプロトコルに採用された場合、LNDがこの方法を使用できることが重要となります。

- [BIPs #875][]は、[BIP119][]を`OP_CHECKTEMPLATEVERIFY`提案に割り当てます。提案が採用されると、ユーザーは特定のトランザクションまたは一連のトランザクションでのみ使用できるUTXOを作成でき、一種の[契約(covenants)][topic covenants]を提供します。これは、支払いを一時的にオフチェーンに保つが、支払い先のアウトプットを取り消したり変更する方法がない（不可能である）ことを最終的な受信者に対して保証する必要があるプロトコルで役立ちます。

- [BIPs #876][]は、schnorr-taproot-tapscript提案の各部分に1つずつ、3つのBIPを割り当てます。

    - [BIP340][]は、「secp256k1のSchnorr署名」に割り当てられます。これは、ビットコインが使用するsecp256k1[楕円曲線][elliptic curve]と互換性のある署名スキームを記述しています。署名は、バッチ検証と、[MuSig][topic musig]などのキーおよび署名集約スキームと互換性があります。Schnorr署名は、次の2つのBIP（341および342）で使用できます。詳細については、BIPまたは[schnorr署名][topic schnorr signatures]を参照してください。

    - [BIP341][]は、「Taproot: SegWitバージョン1の支払いルール」に割り当てられます。これは、ユーザーがschnorrスタイルの署名、もしくはマークル・ツリーを介した特定のスクリプト（スクリプトの条件も満たされたとして）へのキーのコミット証明を利用して支払える、schnorrスタイルの公開キーを含むソフトフォーク提案の一部を説明します。詳細については、BIPまたは[taproot][topic taproot]を参照してください。

    - [BIP342][]は、「Taprootスクリプトの検証」に割り当てられます。これは、taproot（*tapscript*）と組み合わせて使用​​されるスクリプトを評価するためのルールを記述しています。tapscriptのほとんどすべての操作は、従来のBitcoin Scriptと同じですが、いくつかは異なる点があります。tapscriptにアップグレードする既存のユーザーにとって最も重要な変更点は、すべての署名チェックのオペコード（`OP_CHECKSIG`など）がschnorr公開キーと署名を使用することです。また、注目に値するのは、`OP_CHECKMULTISIG`が削除されたことです。スクリプト作成者は、代わりに新しい`OP_CHECKSIGADD`オペコードを使用するか、スクリプトを再設計することで対応します。他のいくつかの新しいルールは、ユーザーには影響を与えません。さらに、tapscriptには、将来のソフトフォークアップグレードを容易にするための新機能がいくつか含まれています。詳細については、BIPまたは[tapscript][topic tapscript]を参照してください。

    {% comment %}<!--
    $ git log --oneline --no-merges  802520e...9cf4038 | wc -l
    163

    $ git shortlog -s  802520e...9cf4038 | wc -l
    30  ## devrandom and Orfeas Litos each appear twice, so 28
    -->{% endcomment %}

    BIPリポジトリへの多くのマージには、複数の人々からのコントリビューションが含まれますが、このマージにはこれまで見た中で最も多くの貢献者がいました：163件のコミットで28人の異なる人々からのコンテンツと編集が含まれ、ここに含まれない他の貢献者、このリポジトリを可能にした基礎を作り出した開発者、および多くの「[構造化されたレビュー][structured reviews]の参加者」に感謝します。

- [BOLTs #697][]は、[BOLT4][]で説明されているsphinxパケットの構造を変更して、宛先ノードがソースノードに戻るパスの長さを発見できるプライバシーリークを修正します。リークの詳細については、[Newsletter #72][news72 leak]を参照してください。Optechが追っている3つの実装すべて（[C-Lightning][news72 cl3246]、[Eclair][news81 eclair1247]、および[LND-Onion][]ライブラリ）もリークを修正するためにコードを更新しました。

- [BOLTs #705][]は、実験的でアプリケーション固有のメッセージに[BOLT1][]メッセージタイプ32768--65535を割り当てます。また、コンフリクトを防ぐために、この範囲内で自分自身にメッセージタイプを割り当てる人について使用している番号を[BOLT #716][bolts #716]に投稿するよう要求するなど、実装者向けのガイドラインも提案しています。

{% include references.md %}
{% include linkers/issues.md issues="17492,3376,3809,875,876,697,705,716" %}
[lnd 0.9.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.0-beta
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[structured reviews]: https://github.com/ajtowns/taproot-review
[news72 leak]: /ja/newsletters/2019/11/13/#ln
[news72 cl3246]: /ja/newsletters/2019/11/13/#c-lightning-3246
[news81 eclair1247]: /ja/newsletters/2020/01/22/#eclair-1247
[lnd-onion]: https://github.com/lightningnetwork/lightning-onion/pull/40
[news81 lnd3900]: /ja/newsletters/2020/01/22/#lnd-3900
[news74 lnd3739]: /ja/newsletters/2019/11/27/#lnd-3739
[news76 lnd3655]: /ja/newsletters/2019/12/11/#lnd-3655
[news79 lnd3814]: /ja/newsletters/2020/01/08/#lnd-3814
[teinturier post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002435.html
[towns layered commitments]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002448.html
[elliptic curve]: https://en.bitcoin.it/wiki/Secp256k1
[news48 output commitments]: /en/newsletters/2019/05/29/#proposed-transaction-output-commitments
[bolt4 privacy leak]: /en/newsletters/2019/08/28/#bolts-608

