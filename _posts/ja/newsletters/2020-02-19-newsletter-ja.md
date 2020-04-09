---
title: 'Bitcoin Optech Newsletter #85'
permalink: /ja/newsletters/2020/02/19/
name: 2020-02-19-newsletter-ja
slug: 2020-02-19-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---

今週のニュースレターは、Bitcoin Coreのリリース候補（RC）のテスト支援募集、BIP119 `OP_CHECKTEMPLATEVERIFY`提案に関する議論についてです。また、Bitcoinのコードとドキュメントの主要な変更についてもお送りします。

今週のニュースレターでは、C-Lightning 0.8.1のリリースの発表、Bitcoin Coreメンテナンスリリースのテスト募集、taprootとMASTおよびschnorr署名の個別実装に関する議論の要約、LNチャネル構築でのPoDLEの使用に関する新しいアイデアについての説明、プライバシーが強化されたLNの非公開チャネルへの支払いに関する説明をまとめています。また、Bitcoinのサービス、クライアントソフトウェア、およびインフラストラクチャプロジェクトの主要な変更についてもお送りします。

## Action items

- **C-Lightning 0.8.1へのアップグレード:** この[リリース][cl 0.8.1]ではいくつかの新機能（以下の*Notable code and documentation changes*で説明されている機能含む）が追加され、複数のバグ修正が提供されます。詳細については、[変更ログ][cl changelog]を参照してください。

- **Bitcoin Core 0.19.1rc2のテスト支援:** 今回の[メンテナンス・リリース][bitcoin core 0.19.1] には、いくつかのバグ修正が含まれています。経験豊かなユーザーは、予期した通りに動くか、テストで確認することをお勧めします。

## News

- **Taprootと代替案についての議論:** 匿名のままにすることを好む開発者グループ（したがって、Anonと呼びます）は、Bitcoinで[MAST][topic mast]および[Schnorr署名][topic schnorr signatures]を有効にする代替手法と比較して、Taprootを[批判][anon reflowed]しています。Anonは、Anonの懸念の概要と複数のBitcoinコントリビューターが投稿した回答を整理するために、以下の5つの質問をまとめました。

    1. {:#tap1} Anonは、「Taprootは、実際にMASTとschnorrを個別に使用するよりもプライベートですか？個別に使用した際、匿名性の実際の利点は何ですか？」と聞きました。

       Anthony Townsは、「はい（よりプライベートです）、single-pubkey-single-signatureが依然一般的な認証パターンであると仮定して」と回答しています。 Townsは、シングルシグでの送金が現在、すべてのトランザクション・アウトプットの57％以上を占めていることを示しています（P2SHでラップされたP2WPKHを頻繁に使用する場合、この数字はさらに大きくなる）。シングルシグを使用できる人の数は、schnorrが利用可能になった場合、増加します。これは、インタラクティブn-of-nマルチシグ、インタラクティブk-of-nしきい値署名、onchainでのシングルシグ支払いのようなアダプター署名（スクリプトレススクリプト）などの使用をシンプルにするためです。

       しかし、より多くの人々がマルチシグや高度な契約に目を向けると、ほとんどの場合単一の署名（シングルシグ）で満たすことができる実用的なユースケースが増えていますが、それでもスクリプトの使用が必要な場合があります。TaprootではなくMASTのみを使用する場合、これらのユースケースでは常にMASTを使用する必要があります。MASTはシングルシグ支出にも使用できますが、純粋なシングルシグ構造よりも大きなトランザクションとより多くのフィーが必要になるため、シングルシグユーザーはおそらくMASTを使用しないでしょう。これにより、MASTを使用する支出と使用しない支出との間のチェーン分析の明確な区分が作成されます。

       Taprootは、シングルシグを使用できてもフォールバックスクリプトも持っているユーザーが同様に見える、安価なシングルシグ支出を提供することにより、この問題を解消します（ただし、実際にはフォールバックスクリプトの使用はオンチェーンで識別できます）。これにより、単一の署名を使用することもあればスクリプトを使用することもあるグループが実際に存在する限り、MASTとschnorrを別々に実行するよりも大きな匿名性を保てます。

    2. {:#tap2} Anonは「Taprootは、MASTとschnorrをそれぞれ実行する場合より（フィーは）安いのですか？」と聞きました。Anonは、Taprootがキーパスの支出に対してMAST + Schnorrと比較して67バイトを節約するが、スクリプトパスの支出に対して67バイトを追加すると主張しました。

       TownsはAnonの計算で冗長なデータフィールドを指摘し、Taprootが実際にスクリプトパスの支出ケースで約33バイトしか追加しないことを示しており、Taprootが優れた費用対効果分析を持つと分析を行いました。David Hardingは、余分なサイズ（8.25vbyteに変換される）は、スクリプトパスのユーザーがUTXOを使用するために提供する必要がある他のすべてのデータと比較して、非常に小さいことを[言及][harding tap]しています。（例えば41vbyteの入力データ、16vbyteの署名またはさまざまなサイズの他のウィットネス、1つ以上の8vbyteのマークルノード、および実行するスクリプトなど）

    3. {:#tap3} Anonは、「MASTとSchnorrを別々で利用した時と比較して、Taprootはリスクは高いですか？」と聞きました。

       Townsは「そうは思わない。複雑な暗号部分のほとんどは、[MuSig][topic musig]、しきい値署名、アダプター署名、スクリプトレススクリプトなどのアプリケーション層にあるからです。」と答えています。また、詳細を知りたい人のためにいくつかのリソースをリンクしています。（[1][taplearn1], [2][taplearn2], [3][taplearn3]）

    4. {:#tap4} Anonは、「[Nothing Up My Sleeve]<!-- prevent link --> [NUMS][]ポイント要件を無視し、それが直接ハッシュルートであるかどうかを確認できませんか？」と聞きました。これは、ウォレットがキーパスの使用を意図していないため、単なるランダムな曲線ポイントであっても、Taprootの内部キーを作成して後で公開するための要件です。Anonは要するに、支出者が内部キーの公開をスキップして、スクリプトパスの検証に直接進むことを許可することを提案しています。

       これについてTownsは、「匿名性を大幅に減らすだろう」と答えています。その理由は、存在しない内部キーは、支出時にキーパスの使用を意図していないことを明らかにし、キーパスの使用がオプションである他の支出と区別するためです。Townsはさらに、内部キーを公開しないと8vbyteしか節約できないことを言及しました。

       Jonas NickとJeremy Rubinは、それぞれ独自の分析を提供しています。 Nickは「(なぜなら)ビットコインの匿名性は永続的であり、ソフトウェアは誰もが予想するよりも長く展開される傾向があるため、現実的にはTaprootは(Anonの提案した)最適化よりも優れている」と[結論づけて][nick tap]います。Rubinは[反論][rubin tap]を提示しており、Anonの提案またはRubin自身の提案された代替案を支持しています（それでも同じ匿名性の損失には繋がります）。

    5. {:#tap5} Anonは、「ビットコインの開発に一度に多くの機能を詰め込もうとする開発モデルはそもそもいいのか？」と聞きました。

       Townsは、「これらの特定の変更を一緒にバンドルすると、Taprootの利点が得られる」と答えました。キーパスまたはスクリプトパスの支出を使用できる柔軟性、「キーパスは、taprootを使用しない場合コストがかからないこと」、「スクリプトパスは、使用しなくてもコストがかからないこと」、「スクリプトの状態をオフチェーンでインタラクティブに検証できる場合は、常にキーパスを使用できること」を展開しました。

       これらの議論はまだ明らかな結論には達していません。その他の注目すべき開発がある場合は、今後のニュースレターで報告します。

- **LNでのPoDLE利用:** [Newsletter#83][news83 interactive]で説明されているように、LN開発者は、デュアル・ファンディング・トランザクション・チャネルおよび[チャネル・スプライシング][topic splicing]に向けたステップとして、ファンディング・トランザクションのインタラクティブな構築のためのプロトコル開発に取り組んでいます。デュアル・ファンディング・チャネル設定の問題の1つは、誰かがあなたとチャネルを開くことを提案し、UTXOの1つ以上を学習してから、トランザクションに署名してフィーを支払う前にチャネル設定プロセスを放棄できることです。この問題に対する提案された解決策は、JoinMarketが同じタイプの費用のかからないUTXO開示アタックを回避するために使用する、離散対数等価性の証明（Proof of Discrete Logarithm Equivalence または[PoDLE][])）を含むチャネルオープンの提案を要求することです。

    今週、Lisa Neigutは、インタラクティブなファンディングのためのPoDLEアイデアの[分析][neigut podle1]を公開しました。彼女はまた、不正なマロリーが正直なアリスがPoDLEを送信するのを待ち、それを使用して他のノードにアリスをブラックリストに入れさせる攻撃を別に[説明][neigut podle2]しました。Neigutは緩和策を提案しましたが、JoinMarketの開発者Adam Gibsonにより、よりコンパクトな代替緩和策が[提案][gibson podle]されています。 Gibsonのアプローチでは、PoDLEが受信すると予想されるノードにコミットする必要があり、他のノードで悪意を持って再利用されることを防ぎます。Gibsonはまた、JoinMarketによるPoDLEの使用に関する設計上の決定事項についても説明し、LN開発者がLN独自の制約に対して異なるトレードオフを使用する方法を提案しています。

- **<!--decoy-nodes-and-lightweight-rendez-vous-routing-->デコイ・ノードと軽量ランデブー・ルーティング:** Bastien Teinturierは、[BOLT11][]インボイスに含まれるデータと、支払いを受け取るチャネルのファンディング・トランザクションとの間のリンクの切断について以前[投稿][teinturier delink]しました（[Newsletter#82][news82 unannounced]参照）。さらなる議論と改良の後、Teinturierは、彼のスキームの副次効果としてランデブー・ルーティングを可能にすることがあることに注目しました（受信ノードも送信ノードも互いのネット​​ワークIDについて何も学習しない、プライバシー強化の支払いルーティング）。詳細については、スキームに関するTeinturierの[ドキュメント][rv gist]、[Newsletter#22][news22 rv]のランデブー・ルーティングの以前の議論、または月曜日に開催されたLN開発者[仕様会議][spec meet]でトピックの議論を参照してください。

## Changes to services and client software

*この月刊セクションでは、Bitcoinウォレットとサービスの注目すべきアップデートをお送りしています。*

- **署名にHWIを使用するBTCPay Vault:** [BTCPay Vault][btcpay vault blog]は、[HWI][topic hwi]を使用してさまざまなハードウェアウォレットとの署名トランザクションを調整するデスクトップアプリケーションです。 BTCPay ServerがBTCPay Vaultを作成しましたが、このソフトウェアを他のアプリケーションで使用するために再利用することもできます。

- **HSMにPSBTを使用するCKBunker:** [CKBunker][coinkite bunker]を使用すると、ユーザーはオンラインのTor対応Coldcardハードウェアウォレットのルールベースの支出条件を構成できます。 Coldcardはその後HSM（ハードウェア・セキュリティ・モジュール）のように機能し、Torヒドゥン・サービスを介して、配信される[PSBTs][topic psbt]に署名します。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[ビットコイン改善提案（BIP）][bips repo]、および[Lightning BOLT][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #18104][]は、Bitcoin Coreリリースプロセスの一部としてLinux用の32ビットx86バイナリのビルドのサポートを終了します。Windows用の対応する32ビットバイナリは、数か月前に以前に削除されました（[Newsletter #46][news46 win32]参照）。 32ビットLinuxバイナリは、Bitcoin Coreのコンティニュアス・インテグレーション・テスト（CIT）の一部としてまだビルドされており、ユーザーは引き続き手動でビルドできますが、実利用と開発者テストが追いついていないため、バイナリはプロジェクトによって配布されなくなりました。

- [C-Lightning #3488][]は、Bitcoinデータに対するC-Lightningのリクエストを標準化し、Bitcoin Core以外をバックエンドとしてC-Lightningを実行できるようにします。このPRは、[C-Lightning #3354][]で提案されているように、C-LightningがBitcoinバックエンドとインタラクションする方法をより自由にするためのより大きなプロジェクトの一部です。バックエンド・インタラクションを汎用的に保つことにより、プラグインは標準のRPC呼び出しを行ったり、RPCを組み合わせてより抽象的なメソッドにしたり、通知を作成することもできます。`bitcoin-cli`を介した`bitcoind`インタラクションはデフォルトのままですが、このプロジェクトはモバイル・インテグレーションの可能性を広げる（[C-Lightning #3484][]を参照）か、オンラインにたまにしか接続しない可能性のあるユーザー（[チャネル・マネジメントやモニタリングのため][remyers twitter]）に対して、[esplora][esplora]インスタンスなどの[ブロックエクスプローラー][topic block explorers]を共有できるようにします。

- [C-Lightning #3500][]は、どちらの当事者も他方に資金を送信できないため、チャネルがスタックする可能性がある問題の、シンプルな解決策を実装します。[スタックファンドの問題][bolts #728]は 、支払いにより、チャネルに資金を提供した当事者が現在の残高よりも多くの価値を支払う責任を負う場合に発生します。たとえば、アリスはチャンネルに資金を供給し、ボブに利用可能な全残高を支払います。アリスはこれ以上お金を使うことができませんが、ボブはコミットメントトランザクションのサイズとそれに対応するフィー（資金提供者アリスが支払う責任がある手数料）を増やす必要があるため、アリスに支払うこともできません。これにより、チャネルが両方向で使用できなくなります。 C-Lightningのマージは、ユーザーが資金提供者である場合、利用可能な残高をすべて使い切ることを制限し、効果的な短期的な修正を提供します。[C-Lightning #3501][]で代替ソリューションが提案されていますが、すべてのLN実装メンテナー間のさらなる議論の結果を待っています。

- [C-Lightning #3489][]では、複数のプラグインを`htlc_accepted`プラグイン・フックに接続できます。これにより将来、他のフックに複数のプラグインを接続できるようになる見通しです。 `htlc_accepted`フックの場合、これにより、プラグインはHTLCを拒否するか、HTLCを解決する（つまり、preimageを返すことで支払いを請求する）か、HTLCをフックにバインドされた次のプラグインに渡すことができます。

- [C-Lightning #3477][]により、プラグインは、ノードの[BOLT1][bolt1 init] `init`メッセージ、[BOLT7][bolt7 node announce] `node_announcement`メッセージ、または[BOLT11][bolt11 featurebits]インボイスの機能ビットフィールド（フィールド`9`）で送信される機能フラグを登録できます。これにより、プラグインは、ノードがアドバタイズされた機能を処理できることを他のプログラムに通知できます。

- [Libsecp256k1 #682][]は、Java Native Interface（JNI）バインディングを削除します。「JNIバインディングはJava開発者にとって有用であり続けるためにもっと作業が必要になりますが、libsecpのメンテナーと通常のコントリビューターはJavaにあまり馴染みがありません。」PRは、ACINQがプロジェクトでバインディングを使用することが知られており、ライブラリの独自の[フォーク][acinq libsecp]を維持していることに言及しています。

{% include references.md %}
{% include linkers/issues.md issues="18104,3488,3354,3484,3500,3489,3477,682,728,3501" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[cl 0.8.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.1
[news83 interactive]: /ja/newsletters/2020/02/05/#ln
[podle]: /ja/newsletters/2020/02/05/#podle
[news82 unannounced]: /ja/newsletters/2020/01/29/#utxo
[news22 rv]: /en/newsletters/2018/11/20/#hidden-destinations
[news46 win32]: /en/newsletters/2019/05/14/#bitcoin-core-15939
[anon reflowed]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017618.html
[towns tap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017622.html
[harding tap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017621.html
[taplearn1]: https://github.com/bitcoin-core/secp256k1/pull/558
[taplearn2]: https://github.com/apoelstra/taproot
[taplearn3]: https://github.com/ajtowns/taproot-review
[nick tap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017625.html
[rubin tap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017629.html
[neigut podle1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002516.html
[neigut podle2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002517.html
[gibson podle]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002522.html
[teinturier delink]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002435.html
[teinturier rv]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002519.html
[rv gist]: https://gist.github.com/t-bast/9972bfe9523bb18395bdedb8dc691faf
[acinq libsecp]: https://github.com/ACINQ/secp256k1/tree/jni-embed/src/java
[bolt1 init]: https://github.com/lightningnetwork/lightning-rfc/blob/master/01-messaging.md#the-init-message
[bolt7 node announce]: https://github.com/lightningnetwork/lightning-rfc/blob/master/07-routing-gossip.md#the-node_announcement-message
[bolt11 featurebits]: https://github.com/lightningnetwork/lightning-rfc/blob/master/11-payment-encoding.md#feature-bits
[nums]: https://en.wikipedia.org/wiki/Nothing-up-my-sleeve_number
[spec meet]: http://www.erisian.com.au/meetbot/lightning-dev/2020/lightning-dev.2020-02-17-19.06.log.html#l-239
[cl changelog]: https://github.com/ElementsProject/lightning/blob/v0.8.1/CHANGELOG.md#081---2020-02-12-channel-to-the-moon
[esplora]: https://github.com/blockstream/esplora
[remyers twitter]: https://twitter.com/remyers_/status/1226838752267468800
[btcpay vault blog]: https://blog.btcpayserver.org/btcpay-vault/
[coinkite bunker]: http://ckbunker.com/

