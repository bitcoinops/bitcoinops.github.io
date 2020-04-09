---
title: 'Bitcoin Optech Newsletter #83'
permalink: /ja/newsletters/2020/02/05/
name: 2020-02-05-newsletter-ja
slug: 2020-02-05-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Eclair 0.3.3のリリースの発表、Bitcoin Coreメンテナンス・リリースに対するテスターの公募、taprootおよびtapscriptを試すためのツールへのリンク、事前計算された公開キーを使用したschnorr署名の安全な生成に関する議論の要約、LNファンディング・トランザクションにおけるインタラクティブな構築についてお送りします。また、Bitcoinインフラストラクチャ・プロジェクトの主要な変更についてもお送りします。

## Action items

- **Eclair 0.3.3へのアップグレード:** この新しいリリースには、[マルチパス・ペイメント][topic multipath payments]のサポート、eclair-coreの決定論的ビルド（以下の[PRについての説明][eclair1295]を参照）、[トランポリン・ペイメント][topic trampoline payments]の実験的サポート、およびさまざまなマイナーな改善とバグ修正が含まれます。

- **Bitcoin Core 0.19.1rc1のテスト支援:** 今回の[メンテナンス・リリース][bitcoin core 0.19.1] には、いくつかのバグ修正が含まれています。経験豊かなユーザーは、予期した通りに動くか、テストで確認することをお勧めします。

## News

- **Taprootおよびtapscript実験ツール:** Karl-Johan Almは、Bitcoin-Devリストに、`tap`というコマンドラインツールを使用して[taproot][topic taproot]および[tapscript][topic tapscript]出力の作成と実行をサポートする彼の[btcdeb][]ツールの実験的なブランチについて[投稿][alm btcdeb]しました。詳細については、彼の詳細な[チュートリアル][tap tutorial]を参照してください。

- **schnorr署名で使用される事前計算された公開キーに関連する安全性の懸念:** [libsecp256k1 PR #558][libsecp256k1 #558]は、Bitcoin Coreおよび他のいくつかのBitcoinプログラムで使用されるlibsecp256k1ライブラリに[BIP340][]互換の[schnorr署名][topic schnorr signatures]の作成と検証を追加することを提案しています。 BIP340では、署名の検証に使用される公開キーにコミットするために署名が必要であるため、現在提案されている署名関数は、秘密キーを使用して必要な公開キーを算出します。 Gregory Maxwellは、署名を生成するプログラムは通常、適切な公開鍵を既に知っているため、関数が公開鍵をパラメーターとして受け入れることでCPU時間を節約できると[指摘][gmaxwell pubkey]しました。

    Jonas Nickは、このアプローチは合理的であると[回答][nick nonce]しましたが、それを安全に行うには、決定論的ナンスの作成に使用されるデータに公開鍵を含める必要があるとも話しています。それ以外の場合、クラッカーが2つの異なる公開鍵に対して同じ秘密鍵によって作成された2つの署名を取得でき、他のすべてのデータが同じままである場合、知らないうちにナンスを再利用し、クラッカーは秘密鍵を取得してビットコインを盗むことができます。問題への対処についての議論は[別の場所][nonce issue]で続けられます。

    さらに、公開鍵を検証せずに受け入れる実装が、再利用されたナンスを生成する可能性があることが明らかになったため、Gregory Maxwellは、このリスクに関する[ed25519][]実装（これもschnorr署名の派生を使用）をメーリングリストに[投稿][curves post]しました。 Ed25519の共著者であるDaniel Bernsteinは、「障害に対する一般的な防御策は、署名者が各署名を検証することである」と回答しています。これにより、無効な公開鍵が提供されたことが検出され、Bitcoin Coreなどの一部のウォレットは、現在使用されているECDSA署名アルゴリズムに対しても、生成する署名に対してこのチェックを確実に実行します。ただし、このアプローチの演算オーバーヘッドは多くのアプリケーションでは受け入れられない可能性があり、経験の浅い開発者がこのステップを実行することを知らないリスクが残っているため、決定論的ナンスの生成に使用されるデータに公開鍵を含めるというJonas Nickの提案（その後Maxwellが引き継いだ）を使用することが望ましいようです。

    これまでのところ、この問題の直接的な結果としてBIP340に変更は加えられていませんが、決定論的ナンスアルゴリズムに公開鍵を含めるなどの提案された変更が議論されています。

- **代替のXのみのpubkeyタイブレーカー:** 上記の問題について議論したように、Pieter Wuilleは、鍵のX座標のみがわかっている場合に使用する公開鍵のバリアントを選択するために使用するアルゴリズムを変更することにより、秘密鍵からの公開鍵の派生をわずかに高速化することを[提案][pubkey pr]しました。（[Newsletter #59][news59 32bpk]の32バイトの公開鍵に関する議論を参照）。これは重要な変更であるため、提案は署名の一部を生成するために使用されるタグ付きハッシュも変更します。

    この変更はまだメーリングリストに発表されていません。おそらく、開発者は、事前演算された公開鍵を署名機能に提供する安全性に対処するために、他にどのような変更を同時に行うべきかを評価しているためでしょう。

- **LNファンディング・トランザクションのインタラクティブな構築:** 現在のLNプロトコルでは、新しいチャネルを開くオンチェーン・トランザクションは、完全に単一のユーザーによって作成されます。これはシンプルであるという利点がありますが、チャネルでの支払いが最初一方向にしか流れないという欠点があります（チャネルに資金を提供したユーザーから他のユーザーへ）。Lisa Neigutは、両当事者がチャネルの開設に資金を提供できるデュアル・ファンディング[プロトコル][bolts #524]に取り組んでいます。これは、支払いが最初に両方向に流れることができるチャネルを作成し、ネットワークの流動性を改善するのに特に役立ちます。

    ただし、デュアル・ファンディングの提案は複雑であるため、Neigutは今週、Lightning-Devメーリングリストで、この新しいプロトコルの1つの側面を分割する[スレッド][neigut thread]を立ち上げました。これはLNノードがファンディング・トランザクションを共同で構築する機能です。

    これは以前にセキュリティの改善として説明され（[Newsletter #78][news78 dual-funding]参照）、Neigutは、コラボレーション・メカニズムがバッチ・クロージング（同時に複数のチャネルを相互にクローズする機能）および[スプライシング][topic splicing]（チャネルにおける資金の出し入れを、そのチャネルにある資金に影響を与えずに行う機能）にも影響します。Neigutの提案への返信には以下が含まれます。

    * nLockTimeフィールドの値を直近または今後のブロックの高さに設定してアンチ・フィー・スナイピングを実装する提案。これによりブロックチェーンの再編成を阻害するのに役立ち、トランザクションが既にアンチ・フィー・スナイピングを実装している他のウォレットとのファンディング・トランザクションの作成にも役立ちます（LNDのスイープモード含む。[Newsletter #18][news18 lnd afs]参照）

    * より広義には、他の共同トランザクション作成システム（[コインジョイン][topic coinjoin]・ソフトウェアなど）を使用して、トランザクションのフリー・パラメーター（nVersion、nSequence、nLockTime、インプット順序、アウトプット順序など）に共通の値のセットを実装する提案。これにより、LNファンディング・トランザクションが作成されていることを示す明確なインジケーターが生成されなくなります（特に[taproot][topic taproot]が採用された場合、相互ルートLNのクローズトランザクションはシングルシグ支出のように見えるため）。

    * [BIP174][]部分署名ビットコイン・トランザクション（PSBT）を使用して、提案されたトランザクションの詳細を伝達するための提案。 Neigutは、PSBTは「2つのピア間のトランザクション・コラボレーションには少し重すぎる」と考えているとも答えています。

    * {:#podle} マロリーがボブとのデュアル・ファンディング・チャンネルを開くプロセスを開始し、ボブのUTXOのいずれかのIDを受け取った後に取引中止するような行為の回避方法についての議論。ファンディング・トランザクションが完了する前に中止することにより、マロリーはどのネットワークID（ノード）がどのUTXOを所有しているかを費用なしで知ることができます。

        これを修正するための1つの提案では、チャネルを開くことを提案している人（上記例の場合マロリー）がUTXOをすぐに使える状態で提供し、こうした行為にお金（例：取引手数料）がかかるようにする事です。このアプローチの欠点は、提案された構造がブロックチェーン分析によって簡単に識別できるため、デュアル・ファンディング・チャネルがいつ開かれたかを簡単に判断できることです。

        もう1つの提案は、Gregory Maxwellの提案に基づいてJoinMarket用に開発された[PoDLE][]を使用することです。このプロトコルにより、マロリーなどの取引を開始するユーザーは、誰でもそのUTXOを識別できないようにUTXOにコミットできます。一方ボブなどの参加ユーザーは、ネットワーク（JoinMarketネットワークなど）でコミットメントを公開し、その特定のUTXOを使用している間に誰もマロリーとのセッションを開始しないようにします。次に、ボブはマロリーにUTXOを識別するように依頼し、それが彼女のコミットメントに一致する有効なUTXOである場合、ボブはマロリーに彼のUTXOを開示して、プロトコル（たとえば、コインジョイン）を続行できるようにします。もしマロリーが完了する前にプロトコルを中止すると、以前にネットワークを介して公開されたコミットメントにより、他のユーザーとの新しいセッションを開始してUTXOを識別することができなくなります。マロリーの唯一の選択肢は、新しいUTXOを生成するために自分からコインを使うことです。このプロセスはお金がかかるため、ユーザーを覗き見する事を制限します。（ただし、JoinMarketに実装されているPoDLEでは、デフォルトでマロリーが最大3回再試行できるため、正直なユーザーは、ネットワーク接続の喪失などの偶発的な失敗に対してペナルティを受けません。）要はこのプロトコルをLNに適応させて、どのUTXOがLNユーザーによって制御されているかをクラッカーが知ることを防ごうとしているのです。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[ビットコイン改善提案（BIP）][bips repo]、および[Lightning BOLT][bolts repo]の注目すべき変更点*

- [Bitcoin Core #16702][]により、Bitcoin CoreはIPアドレス・プレフィックスではなく _オートノマス・システム・ナンバー_（ASN）に基づいてピアを選択できます。 ASNに基づいてピアを区別すると、特定の[エクリプス・アタック][topic eclipse attacks]（[Erebusアタック][erebus]など）を正常に実行することが難しくなる場合があります。この新しい機能はデフォルトで無効になっています。ASNベースのピアリングを利用するには、ユーザーは[asmap][]を使用して生成できるASNテーブルファイルを提供する必要があります。将来のリリースには、Bitcoin Core開発者によって生成およびレビューされるASNテーブルファイルが含まれる可能性があります。このアプローチの詳細については、[#bitcoin-core-devのIRCディスカッションの概要][asn peer selection]をご覧ください。

- [Bitcoin Core #17951][]は、最近のブロックで確認されたトランザクションのローリング・ブルーム・フィルターを保持します。ノードのピアの1つがトランザクションを発信すると、ノードはフィルターに対してトランザクションのtxidをチェックします。一致する場合、ノードはトランザクションのダウンロードをスキップします（既に確認されているため）。これは、トランザクションをダウンロードするかどうかを決定する以前のメカニズムを置き換えます。この以前の方法は、アウトプットが既に使用されている場合、既に確認されたトランザクションを重複してダウンロードしていたので帯域幅を浪費していました。

- [C-Lightning #3315][]は、`dev-sendcustommsg`RPCおよび`custommsg`プラグインフックを追加し、ノードから任意のピアにカスタムネットワーク・プロトコルメッセージを送信できるようにします。この機能は、C-Lightningデーモンによって内部でまだ処理されていないメッセージ、および奇数番号のタイプのメッセージ（[it's ok to be odd][]ルールに従います）でのみ使用できます。注：この機能を、オニオン暗号化された支払い内のネットワークルートを介してチャットメッセージを送信する[WhatSat][]などのアプリケーションと混同しないでください。このマージされたPRは、ノードの直接ピアへのプロトコルメッセージの送信のみを許可します。

- [Eclair #1295][]では、eclair-coreモジュールを決定論的に構築できます。構築の詳細については、 [ドキュメント][eclair deterministic doc]を参照してください。 ACINQは、Eclair MobileやPhoenixなど、他のソフトウェアを再現可能にビルドできるようにする意向も発表しています。

- [Eclair #1287][]は、[マルチパス・ペイメント][topic multipath payments]と[トランポリン・ペイメント][topic trampoline payments]に関連する費用の追跡を改善するために、データベースにフィールドを追加します。

- [Eclair #1278][]では、Torが独自の認証と暗号化を提供するため、サーバーがTorヒドゥン・サービスとして実行されている場合、Electrumスタイルのブロックチェーン・データサーバーへの接続時にSSLの使用をスキップできます。

## Acknowledgments and edits

PoDLEに関するセクションのドラフトをレビューしてくれたAdam Gibsonに感謝します。発行されたテキストに誤りがある場合の責任は全てニュースレター作成者にあります。生成された署名を公開する前に検証することのトレードオフを明確にするために、Pieter Wuilleの提案により、公開後にテキストが追加されました。

{% include references.md %}
{% include linkers/issues.md issues="558,524,16702,17951,3315,1295,1287,1278" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[it's ok to be odd]: https://github.com/lightningnetwork/lightning-rfc/blob/master/01-messaging.md#lightning-message-format
[whatsat]: https://github.com/joostjager/whatsat
[news59 32bpk]: /en/newsletters/2019/08/14/#proposed-change-to-schnorr-pubkeys
[news78 dual-funding]: /ja/newsletters/2019/12/28/#ln-cve
[news18 lnd afs]: /en/newsletters/2018/10/23/#lnd-1978
[eclair deterministic doc]: https://github.com/ACINQ/eclair/blob/master/BUILD.md#build
[eclair1295]: #eclair-1295
[alm btcdeb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017600.html
[btcdeb]: https://github.com/kallewoof/btcdeb/tree/taproot
[tap tutorial]: https://github.com/kallewoof/btcdeb/blob/taproot/doc/tapscript-example-with-tap.md
[gmaxwell pubkey]: https://github.com/bitcoin-core/secp256k1/pull/558#discussion_r371027220
[nick nonce]: https://github.com/bitcoin-core/secp256k1/pull/558#discussion_r371029200
[nonce issue]: https://github.com/sipa/bips/issues/190
[pubkey pr]: https://github.com/sipa/bips/pull/192
[curves post]: https://moderncrypto.org/mail-archive/curves/2020/001012.html
[ed25519]: https://en.wikipedia.org/wiki/EdDSA
[neigut thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002466.html
[podle]: https://joinmarket.me/blog/blog/poodle/
[asmap]: https://github.com/sipa/asmap
[asn peer selection]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[erebus]: https://erebus-attack.comp.nus.edu.sg/

