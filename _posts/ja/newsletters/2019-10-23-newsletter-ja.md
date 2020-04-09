---
title: 'Bitcoin Optech Newsletter #69'
permalink: /ja/newsletters/2019/10/23/
name: 2019-10-23-newsletter-ja
slug: 2019-10-23-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、C-LightningおよびBitcoin Coreのリリース候補(RC)についてのテストのリクエスト、taprootの提案についてのレビュー参加への招待、2つのビットコインウォレットのアップデート、ビットコインインフラストラクチャプロジェクトへの注目すべき変更について説明します。


{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **<!--help-test-release-candidates-->リリース候補のテスト支援:** 経験豊富なユーザーは一般公開前に [Bitcoin Core][Bitcoin Core 0.19.0] と [C-Lightning][c-lightning 0.7.3].のリリース候補(RC)のテストの支援をお願いします。

## News

- **Taprootレビュー:** 提案された[bip-schnorr] []、[bip-taproot] []、および[bip-tapscript] []のレビューにおけるガイダンスを行うべく、11月頭からビットコインコントリビュータがホストする週次ミーティングが始まります。開発者、学者、および技術的な経験のある方は誰でも大歓迎です。期待されるコミットメントとしては週4時間×7週間、毎週1時間はグループミーティングで、残りの3時間は個々人のレビューです。レビュー に加えて、開発者はオプションで概念実証(PoC)として実装することが推奨されます。
PoCの内容としては、schnorrまたはtaprootを既存のソフトウェアにどう統合するかを示したものや、これらの提案で可能になる新しい機能や改善される機能のデモなどです。これは、現状の提案内容に対して、ドキュメントをただ読むだけでは見逃しているかもしれない欠陥や最適でない要件を特定するのに役立ちます。

    レビューの最終的な目標は、参加者が提案について十分な技術的知識を得て、声を出して提案を支持するか、または提案がビットコインのコンセンサスルールに採用されるべきではない理由を明確に説明できるようになることです。ビットコインへの新しいコンセンサスルールの追加は慎重に行われるべきです。誰かしらのビットコインがこれらのルールに依存している限り、安全に元に戻すことができないためです。
    よって、これらが実装される前、すべてのユーザーがノードのアップグレードおよび新しいルールへの適用することへの検討が依頼される前に、多くの技術的なレビューアーが可能性のある欠陥について提案を検討することは皆にとって関心の大きいこととと言えるでしょう。このオーガナイズされたレビューを通して、もしくは他の方法で、Optechは技術的に熟練したBitcoinユーザーにtaprootの提案のレビューに時間をかけることを強く推奨します。
    参加したい人はすぐに[登録] [tr rsvp]してください。主催は参加者のおおよその人数を把握、推定したうえでスタディグループを開始します。 登録または詳細については、[Taproot Review] [tr]リポジトリをご覧ください。

## Changes to services and client software

*月次でお届けするこの機能解説では、ビットコインウォレットおよび周辺サービスの注目すべき更新内容について説明します。*

- **Electrum Lightningのサポート:** [今月の一連のコミット内容][Electrum commits]、ElectrumはLightning Networkのサポートを統合しました。Thomas Voegtlinによる[Lightning Implementation in Electrum] [electrum lightning presentation]というタイトルのプレゼンテーション資料にその説明とデモのスクリーンショットがあります。

- **Blockstream Green Torのサポート:** Blockstream Greenのバージョン3.2.4
   iOSおよびAndroidののWalletにて [Torサポートの追加] [blockstream green tor article]がされました。Torは以前のAndroidバージョンでもサポートされていましたが利用するには別のアプリケーションが必要でした。これでAndroidとiOS共にWallet自体にTorサポートがバンドルされます。


## Notable code and documentation changes

*今週の[Bitcoin Core] [bitcoin core repo]、[C-Lightning] [c-lightning repo]、[Eclair] [eclair repo]、[LND] [lnd repo]、[libsecp256k1] [libsecp256k1 repo]、[Bitcoin Improvement Proposals(BIPs)] [bips repo]、および[Lightning BOLTs] [bolts repo]の注目すべき変更点。*

- [C-Lightning #3150][] は新しい `signmessage`と` checkmessage` RPCを追加します。
   最初のRPCは、自身のLNノードの公開鍵で第三者の検証が可能なメッセージに署名します。2番目のRPCは、メッセージが署名されていることを、ユーザーが提供した公開鍵もしくは既知のLNノードに属する公開鍵によって確認することで、別のノードからの署名付きメッセージを検証します（たとえば、「listnodes」RPCによって返されるセット内のノード） 。

- [LND #3595][]はデフォルトの最大CLTV(CheckLockTimeVerify)有効期限を1,008ブロック（約1週間）から2,016ブロック（約2週間）へ引き上げます。支払いが支出者によって回収される前に保留中として留まることができる最大時間です。
LNDは最近、CLTVデルタ（支払いパスに沿った各ルーティングノードが特定の支払いを請求する必要のあるブロックの最小数）を144ブロックから40ブロックに減らすことで  ([Newsletter #40][lnd cltv delta]参照)、有効期限を1,008ブロックに維持しようとしました。しかし、古いLNDノードと他のいくつかの実装は、デフォルトとして144を使用し続けています。各ホップが144のデルタを必要とする場合、2,016の新しい最大有効期限により、最大長のルーティングパスが約14ホップになります。(2,016÷144=14)



- [LND #3597][]は[Newsletter＃64] [lnd3485]で説明されているアップグレードポリシーを取り下げました（それまでLNDは、最大1つのメジャーリリース先しかアップグレードできませんでした）。取り下げに関するPRでは「以前のより厳格なポリシーにより、特定のアップグレードパスを処理するために特別なコードをデプロイすることを余儀なくされるため、lndをパッケージ化するアプリケーションに大きな負担が生じました。 さらに、ユーザーがバージョンをスキップするのが慣例であるため、ポリシーがモバイル展開に最も損害を与え、エンドユーザーに劇的な影響を与えずにより厳格なアップグレードポリシーを管理することが困難であることがわかりました」と説明されています。

{% include linkers/issues.md issues="3595,3597,3150" %}
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[blockstream green tor article]: https://bitcoinmagazine.com/articles/blockstream-green-wallet-adds-early-access-tor-integration
[c-lightning 0.7.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.3rc3
[electrum commits]: https://github.com/spesmilo/electrum/commits/master
[electrum lightning presentation]: https://www.electrum.org/talks/lightning/presentation.html#slide1
[lnd cltv delta]: /en/newsletters/2019/04/02/#lnd-2759
[lnd3485]: /en/newsletters/2019/09/18/#lnd-3485
[tr]: https://github.com/ajtowns/taproot-review
[tr rsvp]: https://forms.gle/iiPaphTcYC5AZZKC8
