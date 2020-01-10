---
title: 'Bitcoin Optech Newsletter #77'
permalink: /ja/newsletters/2019/12/18/
name: 2019-12-18-newsletter-ja
slug: 2019-12-18-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、LND 0.8.2-betaのリリースの発表、最新のC-Lightningリリース候補のテスト支援要請、LNの基本的なマルチパス・ペイメントの広範なサポートについてのディスカッション、bech32エラー検出の信頼性に関するアップデートの提供、`OP_CHECKTEMPLATEVERIFY`オペコードの提案に関するアップデートのサマリー、LNチャネルにおけるエクリプス攻撃の影響に関するディスカッションのリンクなどをお送りします。また、主要なBitcoinインフラストラクチャ・プロジェクトに関する注目すべき変更、サービスとクライアント・ソフトウェアの変更、および主要なBitcoin StackExchangeのQ&Aもお届けします。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **LND 0.8.2-betaへのアップグレード:** 本[リリース][lnd 0.8.2-beta]には、複数のバグ修正とUXのマイナーな改善が含まれます。特に、Static channel backupsのリカバリに関するものです。

- **C-Lightning 0.8.0 RCのテストのご協力:** C-Lightningの次期バージョン[リリース候補][cl 0.8.0]では、デフォルト・ネットワークをテストネットからメインネットへ変更し（[Newsletter #75][news75 cl mainnet]を参照）、後述する基本的なマルチパス・ペイメントのサポートを追加します。また、その他の追加機能、バグ修正も含まれます。

- **bech32アクションプランの確認:** 後述のとおり、Pieter Wuilleは、すべてのbech32アドレスを20または32バイトのウィットネス・プログラムに制限し、`p`で終わるアドレスに関連する転記エラーによる資金損失の防止を提案しています。 このルールは、P2WPKHおよびP2WSHに使用されるv0 segwitアドレスに既に適用されているため、変更は、将来のアップグレード（提案されている[taproot][topic taproot]など）のために現在予約されているv1以降のアドレスに拡張するだけのものです。 これには、bech32送信サポートを既に実装しているウォレットとサービスは、コードをアップデートする必要がありますが、変更は小さいものとなります。例えば[Pythonリファレンス実装][bech32 python]の場合、次のようになります。

    ```diff
    --- a/ref/python/segwit_addr.py
    +++ b/ref/python/segwit_addr.py
    @@ -110,7 +110,7 @@ def decode(hrp, addr):
             return (None, None)
         if data[0] > 16:
             return (None, None)
    -    if data[0] == 0 and len(decoded) != 20 and len(decoded) != 32:
    +    if len(decoded) != 20 and len(decoded) != 32:
             return (None, None)
         return (data[0], decoded)
    ```

   この提案された変更について質問や懸念がある場合は、以下の*News*セクションにリンクされているメーリングリストの投稿に返信してください。

## News

- **LN実装へのマルチパス・ペイメントのサポート追加:** 数多くの議論と開発を経て、Optechがトラッキングしている3つのLN実装はすべて、[マルチパス・ペイメント][topic multipath payments]の基本サポートを追加しました（C-Lightning、Eclair、LND）。 マルチパス・ペイメントは、異なるパスを介してルーティングされる複数のLNペイメントで構成され、これらのペイメントはすべて、受信者によって同時に請求されます。これにより、ユーザーは同一の全体のペイメントにおいて、複数のチャネルで資金を使用または受信できるようになるため、LNの使いやすさが大幅に向上します。 このアップグレードにより、すべてのチャネルで利用可能な最大残高まで送信できるため（他のLN制限次第）、特定のチャネルでどのくらいの残高があるかを気にする必要がなくなります。

- **bech32エラー検出の分析:** Pieter Wuilleは、以前のニュースレター（[#72][news72 bech32]、[#74][news74 bech32]および[#76][news76 bech32]）で説明されているbech32のマリアビリティの懸念をフォローアップする[メール][wuille bech32 analysis]をBitcoin-Devメーリングリストに送信しました。bech32文字列の最後にある`p`の直前に任意の数の`q`を追加または削除できます。 Wuilleの[分析][wuille bech32 analysis]は、これがbech32に期待したエラー検出能力の唯一の例外であり、「bech32の1つの定数を変更するとこの問題が解決する」ことを示しています。

   Wuilleは、弱点を説明するために[BIP173][]を修正し、既存のbech32アドレスの使用を20バイトまたは32バイトのwitness programに制限する変更を提案する予定です。またWuilleは、Bitcoin以外の使用、および20バイトまたは32バイトではないwitness programが必要な将来のために、別の定数を用いたbech32の修正バージョンを定義する予定です。

- **bip-ctvに関する変更提案:** Jeremy Rubinはソフトフォークによる更新を可能にする提案をしているオペコード`OP_CHECKTEMPLATEVERIFY`(CTV)に対するさらなる変更を[提案][rubin ctv update]しました。最も注目すべきは、この変更により、CTVで使用されるテンプレートをビットコインスクリプトを介して他のデータから導出できないという制限がなくなります。 この更新により、[Newsletter#75][news75 ctv]で説明されているScript言語への変更が簡単になります。 いずれの更新も、CTVの動作を、前述のユースケースに重大な影響を与える方法で変更することは私たちが知る限りありません（ただし、根本的な変更を認識している方は、リストで議論することをお勧めします）。

- **LNノードに対するエクリプス攻撃の議論:** Antoine Riardは、Lightning-Devメーリングリストに、エクリプス攻撃によりブロックのリレーが遅らせることによるLNユーザーに対して可能な2つの攻撃について[投稿][riard eclipse]しました。攻撃者がISPもしくはユーザーのルーターを制御している場合によくあることですが、フルノードまたは軽量クライアントによって行われたすべての接続が1人の攻撃者によって制御されることによりエクリプス攻撃が起こります。これにより、攻撃者はノードまたはクライアントが送受信するデータを完全に制御できます。１つ目の攻撃手法として、攻撃者は、取り消されたコミットメントトランザクションを、正直なユーザーに気づかないように送信することができます。本来、取り消されたコミットメントトランザクションを検知した場合の対応策として、送信された相手側は一定時間内に対応するペナルティトランザクションを送信する必要があります。この検知を妨げることにより攻撃者は正直なユーザーから資金を盗むことができます。 もう１つの攻撃手法としては、HTLCの1つ以上が期限切れになりそうなため最新のコミットメントトランザクションをブロードキャストする必要があることを正直なユーザーに気づかなくさせることができます。これにより、攻撃者はHTLCの有効期限が切れた後に資金を盗むことができます。

   Riardの投稿と[Matt Corallo][corallo eclipse]および[ZmnSCPxj][zmn eclipse]からの返信の両方で、フルノードと軽量クライアントをエクリプス攻撃耐性のための今までの積み重ねてきた対策について説明します。 エクリプス攻撃とその軽減策について詳しく知りたい読者は、先週のビットコインコアレビュークラブの[ミーティングノートとログ][review club notes]を読むことを強くお勧めします。

## Changes to services and client software

*この月刊セクションでは、ビットコインのウォレットとサービスの興味深い更新を取り上げます。*

- **BitfinexはLNの入出金をサポートしています:** [最近のブログ投稿][bitfinex ln blog]で、Bitfinexの取引所はLightning Networkのサポートを発表しました。 Bitfinexのユーザーは、LNを使用して資金の入金と引き出しの両方ができるようになりました。

- **BitMEX ResearchがLNペナルティトランザクショントラッカーを開始:**
 [BitMEX Researchが投稿した記事][bitmex ln penalty blog]によると、オープンソースのForkMonitorツールが[Lightningペナルティトランザクションを一覧表示][fork monitor lightning]するようになりました。このツールは、フォークを検出するために、さまざまなビットコイン（BTC、BCH、BSVなど）のチェーン情報とバージョンも監視します。

- **BitMEX bech32送信サポート:** [最近のブログ投稿][bitmex bech32 blog]で、BitMEXは取引所からネイティブbech32アドレスへの送信のサポートを発表しました。 この投稿では、BitMEX自身のウォレットをP2SHからP2SHでラップされたsegwitアドレスに移行する計画の概要も説明しています。

- **Unchained CapitalがマルチシグコーディネーターであるCaravanをオープンソース化:**
 [ブログ投稿とデモビデオ][unchained caravan blog]を使用して、Unchained Capitalは、[Caravanというマルチシグコーディネーター][unchained caravan github]をオープンソース化しました。 Caravanは、さまざまな外部キーストアを使用してマルチシグアドレスの作成および支払いをするためのステートレスWebアプリケーションです。

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange] [bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・答えについて共有しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Lightningネットワークのパス長制限（20ホップ）の理論的根拠は？]({{bse}}92073)
  Sergei TikhomirovがBOLT4の20ホップ制限とTorのオニオンルーティングとLNのスフィンクスの違いについて質問しています。 Rene Pickhardtは、プロトコルの違いと現在の20ホップの根拠を説明しています。20ホップの根拠については、TCP/ IPパッケージを小さく保つ必要があり、またLN自体が小規模なネットワークである（20ホップもあれば相手に到達できる規模である）という説明しています。

- [トランザクションの構築で未コンファーム状態のRBF(Rplace-by-Fee)アウトプットを使用できるようにする方法はありますか？]({{bse}}92164)
  G. Maxwellは、Bitcoin Coreは、RBFサポートを通知しないトランザクションのアウトプットを処理するのと同じ方法で、RBFを選択したことを通知するトランザクションのアウトプットを処理することを説明しています。 Bitcoin Coreによるアウトプットの処理方法で違いが発生するのは、出力を含むトランザクションがコンファームされたかどうか、およびトランザクションがユーザーのBitcoin Coreウォレットによって作成されたかどうかによるものです。

- [BIP32派生パスに許可される最大の深さは？]({{bse}}92056)
  Andrew Chowは、BIP32が深さのフィールドに1バイトを割り当てているため派生パスに最大256個の可能な要素があると説明しています。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[ビットコイン改善提案（BIP）][bips repo]、および[Lightning BOLT][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #17678][] は、[S390X][]および64ビット[POWER][] CPUアーキテクチャへのコンパイルのサポートを追加します。

- [Bitcoin Core #12763][] は、特定のユーザーが実行できるRPCを制限できるRPCホワイトリスト機能を追加します。 デフォルトでは、認証されたユーザーはすべてのコマンドを実行できますが、新しい設定オプション`rpcwhitelist`と`rpcwhitelistdefault`を使用して、どのユーザーがどのRPCにアクセスできるかを設定できます。

- [C-Lightning #3309][] は、上記の*news*セクションの説明としてマルチパス・ペイメントのサポートを追加します。

- [LND #3697][] は、デフォルトの最小HTLC値を0ミリサトシ（msat）に設定します。新しいチャネルの場合、以前のデフォルトの1,000 msatから減少します。 チャンネルを開いた後、HTLCの最小値を変更することはできません。この変更により、本設定を使用するチャンネルでサブサトシの支払いを受け入れることができます。

- [LND #3785][] は、[Newsletter#74][news74 c-lightning-3264]で言及されている問題を解消します。これまではC-LightningとLNDとで同じメッセージに異なる形式を使用し、解析エラーおよびコネクション切断が発生していました。

- [LND #3702][] は、`closechannel`RPCを`delivery_address`パラメーターで拡張します。このパラメーターを使用して、指定したアドレスに資金を送信するチャネルの相互クローズを要求できます。[先週のニュースレター][news76 upfront shutdown]で説明されているアップフロント・シャットダウン・スクリプト機能をユーザーが以前にアクティブにした場合、これは機能しません。

- [LND #3415][] は、LNDに基本的なマルチパス・ペイメント・サポートのために必要なコードを追加し、マルチパス・ペイメントによるインボイスの決済を可能にします。（上記の*News*セクションの説明を参照）

- [BOLTs #643][] は、*News*セクションに記載されている通り、基本的なマルチパス・ペイメントのサポート追加します。Lighting Specification 1.1 Meetingにて1年前に設定された[主要なゴール][news22 multipath]の１つである[LNウォレットUX][news22 ux]を大幅に改善に関して達成したことになります。

## Holiday publication schedule

12月25日または1月1日には、ニュースレターの発行はありません。 代わりに、12月28日土曜日に2回目のアニュアル・レビュー特別レポートを発行します。 通常のニュースレターの発行は、1月8日水曜日に再開されます。

良い休日を！

{% include linkers/issues.md issues="17678,12763,3309,3697,3785,3702,3415,643" %}
[lnd 0.8.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.2-beta
[wuille bech32 post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017521.html
[wuille bech32 analysis]: https://gist.github.com/sipa/a9845b37c1b298a7301c33a04090b2eb
[news75 cl mainnet]: /ja/newsletters/2019/12/04/#c-lightning-3268
[news72 bech32]: /ja/newsletters/2019/11/13
[news74 bech32]: /ja/newsletters/2019/11/27
[news76 bech32]: /ja/newsletters/2019/12/11/#lnd-3767
[news75 ctv]: /ja/newsletters/2019/12/04/#op-checktemplateverify-ctv
[news22 multipath]: /en/newsletters/2018/11/20/#multi-path-payments
[news22 ux]: /en/newsletters/2018/11/20/#multipath-splicing-ux
[power]: https://en.wikipedia.org/wiki/IBM_POWER_instruction_set_architecture
[s390x]: https://en.wikipedia.org/wiki/Linux_on_IBM_Z
[cl 0.8.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.0rc2
[riard eclipse]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002369.html
[corallo eclipse]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002370.html
[zmn eclipse]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002372.html
[news74 c-lightning-3264]: /ja/newsletters/2019/11/27/#c-lightning-3264
[news76 upfront shutdown]: /ja/newsletters/2019/12/11/#lnd-3655
[rubin ctv update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017525.html
[bitfinex ln blog]: https://www.bitfinex.com/posts/440
[bitmex bech32 blog]: https://blog.bitmex.com/bitmex-enables-bech32-sending-support/
[bitmex ln penalty blog]: https://blog.bitmex.com/lightning-network-part-5-bitmex-research-launches-penalty-transaction-alert-system/
[fork monitor lightning]: https://forkmonitor.info/lightning
[unchained caravan blog]: https://www.unchained-capital.com/blog/the-caravan-arrives/
[unchained caravan github]: https://github.com/unchained-capital/caravan
[bech32 python]: https://github.com/sipa/bech32/tree/master/ref/python
[review club notes]: https://bitcoincore.reviews/16702.html

