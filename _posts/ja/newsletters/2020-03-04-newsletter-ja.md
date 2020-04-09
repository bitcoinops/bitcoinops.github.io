---
title: 'Bitcoin Optech Newsletter #87'
permalink: /ja/newsletters/2020/03/04/
name: 2020-03-04-newsletter
slug: 2020-03-04-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のNewsletterでは、BIP340:schnorrのキーと署名の更新案についての説明、フルノード間のスタートアップ機能のネゴシエーションを改善する提案についてフィードバック募集、ハードウェア・ウォレットが破損したナンスを使用して秘密キーを漏らさないために標準化された方法の提案、taprootが安全であるためのハッシュ関数に必要なプロパティの分析についてお送りします。通常セクションであるリリースのお知らせ、Bitcoinインフラストラクチャプロジェクトの主な変更点についてもお送りします。

## Action items

*今週はなし。*

## News

- **BIP340 schnorrのキーと署名の更新:** Newsletter#84の2つの個別項目（[1][news83 safety]、[2][news83 tiebreaker]）で前述したように、[BIP340][]schnorr署名の更新がいくつか提案されています（これは[BIP341][]taprootにも影響します）。Pieter Wuilleは、公開鍵のどのバリアントを[BIP340][]で使用するかを変更することを[提案][wuille update]しています。新しい選択は、鍵の均一性に基づいています。ナンスを生成するための推奨手順が変更されます。ナンス生成に公開鍵が含まれ、利用可能な場合は独立して生成されるランダム性が含まれ、ランダム性を使用して秘密鍵を難読化するステップをナンス生成アルゴリズムに含めるようになります。キーを[differential power analysis][]から保護するためです。

これらは重要な変更のため、BIP340のタグ付きハッシュのタグが変更され、以前のドラフト用に記述されたコードで署名を生成すると、提案されたリビジョンでの検証に失敗することが保証されます。Wuilleは、変更に関するコミュニティフィードバックを要求しています。

- **<!--improving-feature-negotiation-between-full-nodes-at-startup-->起動時のフルノード間の機能ネゴシエーションの改善:** Suhas Daftuarは、新しいピアとの接続を開くためにノードが使用するシーケンスにメッセージを挿入する提案について[フィードバックを求めています][daftuar wtxid]。新しいメッセージは、ノードがピアから受信する機能をネゴシエートしやすくします。ここでの課題は、特定のメッセージが特定の順序で表示されなかった場合、Bitcoin Coreの以前のバージョンが新しい接続を終了することです。Daftuarが新しいメッセージを挿入したいのはこの厳密なシーケンスです。提案はP2Pプロトコルバージョンを増やして後方互換性を提供しますが、Daftuarはネゴシエーションメッセージの挿入が問題を引き起こすかどうかについて、フルノードのメンテナーからフィードバックを求めています。問題を認識している場合は、スレッドに返信してください。

- **<!--proposal-to-standardize-an-exfiltration-resistant-nonce-protocol-->耐漏出性ナンスプロトコルを標準化する提案:** Stepan Snigirev はBitcoin-Devメーリングリストで、ハードウェア・ウォレットがバイアスされたnonceを使用してユーザーの秘密鍵を漏らさないようにするプロトコルの標準化に関する議論を[開始][snigirev nonce]しました。この攻撃を防御するための[以前に提案された][sign to contract]メカニズムの1つは、*sign to contract protocol*を使用して、署名がハードウェア・ウォレットのホストコンピューターまたはモバイルデバイスによって選択されたランダム性にコミットすることを確認することです。libsecp256k1の開発者は、既に[契約への一般的な署名を有効にする][secp s2c]ことと、[抽出耐性ナンス機能][secp nonce]をその上に構築するAPIに取り組んでいます。Snigirevのメールでは、現在推奨されているプロトコルと、それを複数のコンピューターおよび部分署名付きビットコイン・トランザクション（[PSBT][topic psbt]）に拡張する方法について説明がされています。

- **汎用グループモデルのTaproot:** Lloyd Fournierは、2週間前、taprootが安全であるためにtaprootで使用されるハッシュ関数に必要なプロパティを説明する彼の[ポスター][fournier poster]をFinancial Cryptography conferenceに公開しました。これは、以前のAndrew Poelstraによる[proof][poelstra proof]を拡張したもので、ハッシュ関数が[random oracle][]として機能するというより広範な仮定を作成しました。taprootの暗号化セキュリティを評価する人は、Poelstraの証明とFournierのポスターを確認することをお勧めします。

## Releases and release candidates

*Bitcoinインフラストラクチャの新しいリリースおよびリリース候補。新しいリリースにアップグレードするか、リリース候補のテストを支援することを検討してください。*

- [LND 0.9.1][]は新しいマイナーバージョンリリースであり、新しい機能は含まれていませんが、「ノード間で誤った強制終了」を引き起こす可能性があるバグを含むいくつかのバグを修正します。

- [Bitcoin Core 0.19.1][]（リリース候補）

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #17985][]は、トランザクションがmempoolから拒否された場合でも、ホワイトリストに登録されたピアからのトランザクションを中継するという、デッドコードを削除します。この機能はBitcoin Core 0.13.0で動作を停止しましたが、それが意図的なものなのか偶然なのかは不明です。

- [Bitcoin Core #17264][]は、部分的に署名されたビットコイン・トランザクション（[PSBTs][topic psbt]）の作成や処理をするRPCのデフォルトを変更し、既知の[BIP32][]HDウォレット派生パスを含めます。これにより、後でPSBTを処理する他のウォレットは、その情報を使用して適切な署名キーを選択したり、おつり用のアウトプットが正しいアドレスに支払うことを確認したりできます。派生パスを非公開のままにしたい人は、 `bip32_derivs`パラメータを使用して共有を無効にすることができます。

- [C-Lightning #3490][]は、ローカルノードのプライベートキーとユーザー指定のパブリックキーの組み合わせから共有シークレットを取得する「getsharedsecret」RPCを追加します。この共有シークレットは、他の共有シークレットがLNプロトコルで派生するのと同じ方法で派生します（[ECDH][]結果のSHA256ダイジェスト）。他のプログラムが楕円曲線暗号を使用して共有シークレットを派生する方法とは異なる場合があります（例：[ECIES][]）。このRPCは、他のLNノードとの通信を暗号化するプラグインに役立ちます。

- [Eclair #1307][]は、Eclairが使用するパッケージスクリプトを更新し、ソフトウェアの使用に必要なすべてのzipファイルを生成します。この新しい方法により、コアライブラリ（[Newsletter#83][news83 eclair determ]で報告した）に加えて、決定論的にEclair GUIを構築できます。[再現可能なビルド][topic reproducible builds]は、ユーザーが実行するソフトウェアが公開レビューされているソースコードに基づいていることを確認するのに役立ちます。

- [Libsecp256k1 #710][]は、テストを支援するためにライブラリに小さな変更を加えます。変更の1つでは、以前に値の範囲を返すことができた[関数][secp256k1_ecdh]（文書化された動作とは反対に）は、`0`または`1`のみを返すようになりました。少なくとも1つの他のライブラリが[古い][rust-secp256k1 ecdh ret]動作を[使用][ruffing concern]しており、#secp256k1 IRCチャットルームでは、他のプログラムまたはライブラリも古い推奨されない動作を使用している可能性があるという懸念に[言及][ruffing concern]されています。あなたのプログラムが `secp256k1_ecdh`関数を使用している場合、[このPR][710 comment]と関連する[rust-secp256k1に対するissue][rust-secp256k1 #196]の議論を確認することを検討してください。

- [BIPs #886][]は、[BIP340][]schnorr署名を以下2つの推奨事項で更新します。（1）乱数ジェネレーターが利用可能な場合は常にナンス計算にエントロピーを含めること（2）外部プログラムに配布する前に 、ソフトウェアで作成された署名が有効であることを検証すること（少なくとも追加の計算と遅延が負担にならない限り）  これら2つの手順は、再利用されたnonceで無効な署名を取得することにより、攻撃者がユーザーの秘密キーを取得できないようにするのに役立ちます。攻撃の詳細については、[Newsletter#83][news83 safety]をご覧ください。BIP340のその他の提案された変更については、今週のNewsletterの上記の[ニュースアイテム][bip340 update]をご覧ください。

{% comment %}<!-- BOLTs #714 merged but reverted -->{% endcomment %}

{% include references.md %}
{% include linkers/issues.md issues="17985,17264,3490,1307,710,886" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[lnd 0.9.1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.1-beta.rc1
[fournier poster]: https://github.com/LLFourn/taproot-ggm/blob/master/main.pdf
[poelstra proof]: https://github.com/apoelstra/taproot/blob/master/main.pdf
[random oracle]: https://en.wikipedia.org/wiki/Random_oracle
[differential power analysis]: https://en.wikipedia.org/wiki/Power_analysis#Differential_power_analysis
[bip-wtxid-relay]: https://github.com/sdaftuar/bips/blob/2020-02-wtxid-relay/bip-wtxid-relay.mediawiki
[news83 safety]: /ja/newsletters/2020/02/05/#schnorr
[news83 tiebreaker]: /ja/newsletters/2020/02/05/#x-pubkey
[wuille update]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017639.html
[daftuar wtxid]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017648.html
[snigirev nonce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017655.html
[sign to contract]: https://www.wpsoftware.net/andrew/secrets/slides.pdf
[secp s2c]: https://github.com/bitcoin-core/secp256k1/pull/589
[secp nonce]: https://github.com/bitcoin-core/secp256k1/pull/590
[ecdh]: https://en.wikipedia.org/wiki/Elliptic_curve_Diffie-Hellman
[ecies]: https://en.wikipedia.org/wiki/Integrated_Encryption_Scheme
[bip340 update]: #bip340-schnorr
[news83 eclair determ]: /ja/newsletters/2020/02/05/#eclair-1295
[secp256k1_ecdh]: https://github.com/bitcoin-core/secp256k1/blob/96d8ccbd16090551aa003bfa4acd108b0496cb89/src/modules/ecdh/main_impl.h#L29-L69
[rust-secp256k1 ecdh ret]: https://github.com/rust-bitcoin/rust-secp256k1/blob/master/src/ecdh.rs#L162
[ruffing concern]: https://gist.githubusercontent.com/harding/603c2b18241bf61bb0bbe7a0383cf1c9/raw/20656e901472f217d1faa381ddda1d11214900da/foo.txt
[710 comment]: https://github.com/bitcoin-core/secp256k1/pull/710#discussion_r370987476
[rust-secp256k1 #196]: https://github.com/rust-bitcoin/rust-secp256k1/issues/196
