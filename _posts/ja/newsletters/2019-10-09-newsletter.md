---
title: 'Bitcoin Optech Newsletter #67'
permalink: /ja/newsletters/2019/10/09/
name: 2019-10-09-newsletter-ja
slug: 2019-10-09-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---

今週のニュースレターは、Bitcoin CoreおよびLNDのリリース候補のテストの協力の推奨、以前提案されたnoinputおよびanyprevout sighashフラグに関する継続的な議論内容の、Bitcoinインフラストラクチャプロジェクトに対するいくつかの注目すべき変更について説明します。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Bitcoin Core 0.19.0rc1のテスト支援:** Bitcoin Coreを活用している事業ユーザーは、 [最新のリリース候補][core 0.19.0]をテストして、自身の組織のニーズを満たすことを確認することが特に推奨されています。特にテスト実行可能な経験豊富なユーザーは、GUIをテストする時間を取り、本テストに参加していない経験の少ないユーザーに影響する可能性のある問題を探ることが推奨されています。


- **LND 0.8.0-beta-rc2のテスト支援:**  LNDの経験豊富なユーザーは、次のリリースの [テスト支援][lnd 0.8.0-beta]することを推奨します。このテストには、LNDの [ビルドの再現性][lnd repo build] も含まれており（今回が初）、LND開発者が配布したバイナリと同一のものがビルドで生成されたかを確認することが含まれています。

## News

- **NOINPUT / anyprevoutの議論が継続:** LN上で [eltoo][] を使用可能とするsighash flagが、Bitcoin-devとLightning-devのメーリングリスト上で再び  [議論されました][noinput thread]。
今まで議論を要約した後、クリスチャン・デッカーはいくつかの質問をしました：
本提案の背後にあるアイデアは有用か？（ここは同意を得られているように見受けられました）
chaperon signaturesが必須となることはどう考えているか？（反対意見もいくつかあるように見受けられました）
Transaction outputに強制的にタグがつけられることに対してどう考えているか？（反対意見が挙がり、特にその一部は強くそれを感じました。）

    Transaction outputのタグ付けに関する質問に応えて、C-Lightningの貢献者ZmnSCPxj は、タグをtaprootコミットメント内に配置する代替タグ付けメカニズムを[提案しました][zmn internal tagging]。これにより、outputのタグ付けの[元の目標である][orig output tagging]、noinput互換スクリプトへの支払いの防止を、プライバシーとファンジビリティの毀損させることなく実現できます。このアイデアに興味を示した人が何人かいましたが、ZmnSCPxjの提案を知りたいのか、もしくはTransaction outputのタグ付けにそもそも賛成なのかはよくわかりませんでした（上記のように、反対意見が多く見受けられました）。

    スレッド全体は現在20メッセージを超えており、これについての[OP_CATについてのスピンオフディスカッション][cat spinoff]が開始されました 。noinputに関連する課題が解決してソフトフォークの提案に含まれるためにも、このディスカッションが軌道に乗ることを願っています。

## 注目すべきコードとドキュメントの変更点

*[Bitcoin Core][bitcoin core repo],[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals(BIPs)][bips repo], [Lightning BOLTs][bolts repo].における注目すべき変更点*


- [Bitcoin Core #13716][] これは、ウォレットパスフレーズをシェル履歴に保存されるCLIパラメーターとしてではなく、標準入力バッファーから読み取ることができるようにするためのパラメーター`-stdinrpcpass` `-stdinwalletpassphrase`を`bitcoin-cli`に追加しました。また、読み取り中は標準入力のエコーが無効になるため、パスフレーズは画面を見ている人には見えません。

- [Bitcoin Core #16884][] は、RPCインターフェイス（`bitcoin-cli`経由も含む）のユーザーのデフォルトアドレスタイプをP2SHでラップされたP2WPKHからネイティブsegwit（bech32）P2WPKHに切り替えます。この変更はマスター開発コードブランチにあり、2020年半ばのBitcoin Core 0.20.0までリリースされる予定はありません。ただし、来月に0.19.0の一部としてリリースされる予定の[Bitcoin Core #15711][gui bech32]により、GUIユーザーのデフォルトのアドレスタイプもbech32 P2WPKHも使用されるように変更されます。

- [Bitcoin Core #16507][] は、ノードがdynamic minimum feerateよりも高いfeerateのTransactionをメムプールに取り込むが、ピアにリレーしない[問題][bitcoin core #16499]を解消しました。本問題はdynamic minimum feerateが0.00001000 BTC単位で切り上げされた結果、Transactionのfeerateを超えた際に発生するものです。


- [LND #3545][] は、ユーザーがLNDの再現可能なビルドを作成できるようにするコードと[ドキュメント] [lnd repo doc] を追加します。これにより、中程度の技術スキルを持つ人がLightning Labsがリリースしたものと同一のバイナリを構築できるようになり、ユーザーがLNDリポジトリからピアレビューされたコードを実行できるようになります。


- [LND #3365][] は、[このセクションで後述されるように][opt static
  remotekey] 、 `option_static_remotekey` commitment outputsの使用のサポートを追加します。この新しいcommitment protocolは、何らかの原因によりデータを失ったときに特に役立ちます。その場合は、HDウォレットから直接派生したキーを支払うことで、チャンネルの相手がチャンネルを閉じるのを待つだけです。キーは追加のデータ（"tweaking"）なしで生成されたため、ウォレットは資金を見つけて使用するために追加のデータを必要としません。これは、LNDが以前使用していた [data loss protection][] プロトコルの単純化された代替手段です。

- [C-Lightning #3078][] は、LiquidサイドチェーンでLiquid-BTCを使用するチャネルの作成と使用のサポートを追加します。

- [C-Lightning #2803][] はLN仕様の部分的な実装を含む新しいpythonパッケージ `pyln` を追加します。 [ドキュメント][pyln-proto readme],にはこう記載されています。「このパッケージは、純粋なPythonでLightningネットワークプロトコルの一部を実装しています。プロトコルのテストと一部のマイナーなツールのみを対象としています。実際の資金を扱うのに十分な安全性があるとはみなされていません（これは警告です！）」

- [C-Lightning #3062][]  は`plugin` コマンドでは、要求されたプラグインが20秒以内に正常な起動を報告しなかった場合、エラーを返します。

- [BOLTs #676][] は、BOLT2を修正して、ノードがfunding transactionを検証するまで`funding_locked`メッセージを送信しないように指定します。これにより、[先週のニュースレター][ln vuln disclosure]で説明されている脆弱性につながる問題について、今後の実装者に警告します。

- [BOLTs #642][] を使用すると、2つのピアがチャネルを開いて`option_static_remotekey`フラグについてネゴシエートできます 。両方のピアがこのフラグを設定した場合、一方的に（チャネルを強制的に閉じるために）使用できるコミットメントトランザクションは、最初のチャネルのオープン時にネゴシエートされた静的アドレスにピアの資金を支払う必要があります。たとえば、Aliceがaddress`bc1ally`、Bobがaddress`bc1bob`を保持しており、両方が`option_static_remotekey`である場合、Aliceがonchainで発行できるコミットメントトランザクションは`bc1bob`に、Bobがonchainで発行できるコミットメントトランザクションは`bc1ally`に支払われる必要があります。ノードのうち少なくとも1つがこのフラグを設定しない場合、リモートピアのpubkeyとcommitment
  identifierを組み合わせて作成されたアドレスを使用して、コミットメントトランザクションごとに異なる支払いアドレスを使用する古いプロトコルにフォールバックします。

    常に同じアドレスに支払うことで、そのアドレスはクライアントのHDウォレット内の通常の派生可能なアドレスになり、ユーザーはHDシード以外のすべての状態を失った場合でも資金を回収できます。これは、少なくともリモートピアと通信してチャネルを識別できる十分な状態を保存することに依存する [data loss protection][] プロトコルよりも優れていると考えられて います。`option_static_remotekey`を使用することにより、リモートピアは最終的に欠落しているピアが現れるのを待つことにうんざりし、一方的にチャネルを閉じて、HDウォレットが見つけるオンチェーン上のアドレスに返却することが想定できます。



{% include linkers/issues.md issues="13716,16884,16507,16499,3545,3365,3078,2803,3062,676,642" %}
[lnd repo doc]: https://github.com/lightningnetwork/lnd/blob/master/build/release/README.md
[core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[lnd 0.8.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.0-beta-rc2
[lnd repo build]: #lnd-3545
[noinput thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002176.html
[cat spinoff]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002201.html
[ln vuln disclosure]: /en/newsletters/2019/10/02/#full-disclosure-of-fixed-vulnerabilities-affecting-multiple-ln-implementations
[data loss protection]: /en/newsletters/2019/01/29/#fn:fn-data-loss-protect
[pyln-proto readme]: https://github.com/ElementsProject/lightning/blob/master/contrib/pyln-proto/README.md
[opt static remotekey]: #bolts-642
[zmn internal tagging]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002180.html
[gui bech32]: /en/newsletters/2019/04/16/#bitcoin-core-15711
[orig output tagging]: /en/newsletters/2019/02/19/#discussion-about-tagging-outputs-to-enable-restricted-features-on-spending



