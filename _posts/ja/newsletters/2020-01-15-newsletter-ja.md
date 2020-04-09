---
title: 'Bitcoin Optech Newsletter #80'
permalink: /ja/newsletters/2020/01/15/
name: 2020-01-15-newsletter
slug: 2020-01-15-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、LNDの次期バージョンのテストのヘルプリクエスト、
ソフトフォーク・アクティベーション・メカニズムに関する議論の要約、Bitcoinインフラストラクチャ・ソフトウェアに対するいくつかの注目すべき変更について説明します。

## Action items

- **LND 0.9.0-beta-rc1のテスト支援:** LNDの次期メジャーバージョンのこの[プレリリース][lnd 0.9.0-beta]には、いくつかの新しい機能とバグ修正が含まれています。経験豊富なユーザーは、リリース前に問題を特定して修正できるように、ソフトウェアのテストを支援することをお勧めします。

## News

- **<!--discussion-of-soft-fork-activation-mechanisms-->ソフトフォーク・アクティベーション・メカニズムの議論:** Matt Coralloは、Bitcoin-Devメーリングリストで、ソフトフォーク・アクティベーション手法の望ましい内容について[議論][corallo sf]を開始し、メカニズムの提案を提出しました。その内容は簡潔にまとめると以下の通りです。

    1. 提案されたコンセンサス・ルールの変更に対する重大な異議が発生した場合に中止する機能

    2. 更新されたソフトウェアのリリース後、これらのルールを施行するにあたり合理的なノードが、確実にアップグレードされるための十分な時間の割り当て

    3. ネットワーク・ハッシュレートが変更前と変更後、および移行中とほぼ同じになるということ

    4. 新しいルールの下で無効なブロックの作成を可能な限り防止すること（これらの無効なブロックより、アップグレードされていないノードおよびSPVクライアントで誤ったコンファメーションが行われる可能性あり）

    5. 既知の問題がないにも関わらず、広く望まれているアップグレードを差し控えるために、嫌がらせ等により拒否のメカニズムが悪用されないことの保証

    Coralloは、[BIP9][] versionbitsアクティベーション・メカニズムを使用し、コミュニティとの良好なエンゲージメントに囲まれた、良く練られたソフトフォークであれば最初の4つの基準を満たしているものの、5番目は満たしていないと考えています。または、[BIP8][] flag-dayソフトフォークは5番目の基準を満たしますが、他の4つの基準を満たすという課題に直面します。 Coralloは、ソフトフォークの展開の開始からBIP8を使用すると、ノード・ソフトウェアの開発者がシステムのルールを決定できるという印象を与えることも心配しています。

    BIP9またはBIP8それぞれ単独の代替として、Coralloは3段階のプロセスを提案しています。まず、1年以内に提案を有効化できるようにBIP9を使用します。次に提案がまだ有効になっていない場合は、6か月の議論期間の間、一時停止します。 そしてコミュニティがまだ提案のアクティベーションを希望していることが明らかな場合、さらに2年後に設定されたBIP8フラグを使用したアクティベーションを強制します（バージョンビット・シグナリングを使用して、より早期のアクティベーションが可能です）。 Nodeソフトウェアは、初期バージョンでさえ、必要に応じてユーザーが手動でBIP8フラグを実施できるようにする構成オプションを含めることにより、この最大42か月のプロセスに備えることができます。 アクティベーション期間の最初の18か月がアクティベーションなしで（ただし、アクティベーションを阻害するような問題が発見されることなく）経過した場合、新しいリリースでは、アクティベーション期間の残りの24か月に対してデフォルトでこのオプションを有効にできます。

   投稿への反応で、[JorgeTimón][timon sf]と[Luke Dashjr][dashjr sf]は二人とも、BIP8のようなメカニズムはフラグ・デイまでの必須バージョンビット・シグナリングを使用することを提案しました（segwitをアクティブにするために[BIP148][]が提案された時と同様）。 Corallo [注][corallo reply timon]は、これが3番目と4番目の目標と矛盾することを示しています。Jeremy Rubinは、5つの目標のコンテキストで、以前の[spork提案][spork vid]（[Newsletter＃32][spork summary]を参照）の[簡単な分析][rubin sf]について触れています。 またAnthony Townsは、Coralloの提案とTimónの反応のいくつかの側面について[明快な解説][towns sf]を行いました。

    スレッド内で明確な結論に達していないため、議論が続くことを期待しています。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[ビットコイン改善提案（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #17578][]は、アドレスで使用されるラベルに対応する文字列の配列を返すよう、`getaddressinfo` RPCを更新します。 以前は、「名前」と「目的」のフィールドを含むオブジェクトの配列をラベルとして返していました。「目的」のフィールドは、そのアドレスを生成したウォレットの一部に対応するものです。以前の古い動作が好ましいユーザーは、Bitcoin Core 0.21までは `-deprecatedrpc = labelspurpose`設定パラメーターを使用できます。

- [Bitcoin Core #16373][]は、ユーザーが秘密鍵を持っていないwalletで[Replace-by-Fee][topic rbf]・バンピングを試みた場合（`bumpfee` RPCを実行した場合）、[Partially Signed Bitcoin Transaction][topic psbt]（PSBT）を返すようにします。返されたPSBTは、署名のために外部のウォレット（ハードウェアデバイスやコールドウォレットなど）にコピーできます。

- [Bitcoin Core #17621][]は、`avoid_reuse`ウォレット・フラグを利用しているユーザーの潜在的なプライバシー漏洩を修正します。このフラグは、ウォレットが既に支出に使用しているアドレスに受信したビットコインをウォレットが使用することを防ぎます（[ニュースレター＃52][news52 avoid_reuse]を参照）。これらはすべて同じアドレスを含むため、無関係のトランザクションが一緒に関連付けられるのを防ぐことにより、プライバシーを強化します。ただし、Bitcoin Coreは現在、いくつかの異なるアドレス形式のいずれかを使用して、その公開キーへの支払いを監視しています。つまり、同じ公開キーへの複数の支払い---ただし、異なるアドレス（P2PKH、P2WPKH、P2SH-P2WPKHなど）で---`avoid_reuse`の動作がこのタイプのリンク付けを防ぐことを想定されているにもかかわらず、ブロックチェーン上で互いに関連付けられる可能性があります。今回マージされたPRは、上記`avoid_reuse`フラグの問題を修正します。また、[output script descriptors][topic output script descriptors]の継続的な採用により、代替アドレスのBitcoin Coreモニタリングの問題が解消されることが期待されます。この変更は、次のBitcoin Coreメンテナンスリリースにバックポートされる予定です（[PR＃17792][Bitcoin Core #17792]を参照）。

- [LND #3829][]は、将来の[アンカー・アウトプット][anchor outputs]の追加を簡素化するために、いくつかの内部変更とドキュメントの更新を行います。

{% include references.md %}
{% include linkers/issues.md issues="17578,16373,17621,3829,17792" %}
[lnd 0.9.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.0-beta-rc1
[corallo sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017547.html
[timon sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017548.html
[dashjr sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017551.html
[corallo reply timon]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017549.html
[rubin sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017552.html
[towns sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017553.html
[spork vid]: https://www.youtube.com/watch?v=J1CP7qbnpqA&feature=youtu.be
[spork summary]: /en/newsletters/2019/02/05/#probabilistic-bitcoin-soft-forks-sporks
[anchor outputs]: /en/newsletters/2019/10/30/#ln-simplified-commitments
[news52 avoid_reuse]: /en/newsletters/2019/06/26/#bitcoin-core-13756
