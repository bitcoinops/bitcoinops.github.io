---
title: 'Bitcoin Optech Newsletter #198'
permalink: /ja/newsletters/2022/05/04/
name: 2022-05-04-newsletter-ja
slug: 2022-05-04-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、MuSig2の実装に関する投稿のまとめと、
一部の古いLN実装に影響を与えるセキュリティ問題の責任ある開示の共有、
トランザクションの通知によりコンセンサス変更の支持を測定する提案についての議論、
帯域幅効率の良いLNゴシップに対するレート制限の効果の検証について掲載しています。
また、新しいソフトウェアリリースやリリース候補のまとめに加えて、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **MuSig2実装ノート:** Olaoluwa Osuntokunは、
  [ニュースレター #195][news195 musig2]で言及した[MuSig2][topic musig]のBIPドラフトに、
  彼とその他の人がbtcdとLNDのために取り組んだ実装のノートを[返信しました][osuntokun musig2]:

  - *BIP86との相互作用:* [BIP86][]を実装した[BIP32 HDウォレット][topic bip32]によって作成された鍵は、
    keypathのみの鍵を作成するのに、鍵自体のハッシュを使って鍵を調整することで、
    [BIP341][]の勧告に従います。これにより、鍵が[マルチシグ][topic multisignature]において、
    １人の参加者が自分が制御するscriptpathの使用オプションを密かに含め、すべての資金を盗むことを可能にするようなことを防ぐことができます。
    しかし、マルチシグの参加者が意図的にscriptpathの使用オプションを含めたい場合、
    鍵に調整をしていないバージョンをお互いに共有する必要があります。

    Osuntokunは、BIP86の実装が、元の鍵（内部鍵）と調整された鍵（アウトプット鍵）の両方を返し、
    呼び出し関数がそのコンテキストに適したほうを使用できるようにすることを推奨しています。

  - *scriptpathの使用との相互作用:* scriptpathの使用を意図した鍵には、関連する問題があります:
    scriptpathを使用するためには、使用者は内部鍵を知っている必要があります。
    ここでも、内部鍵を必要とする他のコードで使用できるように、実装が内部鍵を返すことを示唆しています。

  - *<!--shortcut-for-final-signer-->最終署名者のショートカット:* Osuntokunは、
    最終署名者（および最終署名者のみ）が、署名のnonceの生成に、決定論的なランダム性を使用できるか、
    低品質のランダム性のソースを使用できる方法を記述したBIPのセクションについても説明を求めました。
    Brandon Blackは、このセクションの動機となった状況について[説明しました][black musig2]。
    彼らは、通常のMuSig2の署名セッションを安全に管理することが困難な署名者を抱えていましたが、
    代わりに、それを常に最終署名者として使用することができました。

- **<!--measuring-user-support-for-consensus-changes-->コンセンサスの変更に対するユーザーサポートの測定:**
  Keagan McClellandは、Bitcoin-Devメーリングリストに、
  コンセンサスルールを変更するための特定の取り組みを[支持するかどうか][topic soft fork activation]を
  トランザクションで通知する、[以前の提案と同様の][bishop signal]提案を[投稿しました][mcclelland measure]。
  この投稿のスレッドでは、関連するいくつかの感情測定のアイディアも議論されましたが、
  いずれも[技術的な課題][aronesty signal parse scripts]や、
  ユーザープライバシーの著しい[低下][grant signal chainalysis]、
  Bitcoinエコノミーの特定の部分を他よりも[優遇することになる][tetrud signal favor]、
  合意形成への参加を待っている人よりも早期の投票者に[ペナルティを与えることになる][ivgi signal hodl voting]といった問題を抱えているようでした。

  このトピックが議論された以前の時と同様に、提案された方法のいずれも
  Bitcoinのコンセンサスルールの変更に関する意思決定に情報を提供するとなると、
  議論参加者の大半から十分に尊重されるような結果を生むとは思われませんでした。

- **LNのAnchor Outputのセキュリティ問題:** Bastien Teinturierは、
  以前彼が責任を持ってLN実装のメンテナーに開示したセキュリティ問題の発表をLightning-Devメーリングリスト[投稿しました][teinturier security]。
  この問題は、（実験的な機能を有効にした）Core LightningとLNDの旧バージョンに影響を及ぼしました。
  Teinturierの投稿で言及されたバージョンを使用している場合は、アップグレードを強く推奨します。

  [Anchor Output][topic anchor outputs]の実装前は、
  取り消された[HTLC][topic HTLC]トランザクションは、単一のアウトプットしか持たず、
  多くの実装はその単一のアウトプットのみを請求しようとしました。
  LNのAnchor Outputの新しい設計は、複数の取り消されたHTLCアウトプットを1つのトランザクションにまとめることができますが、
  これは実装がトランザクション内の関連するアウトプットをすべて請求できる場合にのみ安全です。
  HTLCのタイムロックが切れるまでに請求されなかった資金は、取り消されたHTLCをブロードキャストした当事者によって盗まれる可能性があります。
  TeinturierによるEclairのAnchor Outputの実装で、他のLN実装をテストし、この脆弱性を発見することができました。

  Anchor Outputに関連した以前の攻撃（[ニュースレター #115][news115 fee stealing]参照）と同様に、
  この問題は`SIGHASH_ALL`を使用した従来の署名をサポートしながら、
  `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`を使用した署名のサポートの追加に関連しているようです。

- **<!--ln-gossip-rate-limiting-->LNゴシップのレート制限:** Alex Myersは、Lightning-Devメーリングリストに、
  LNのチャネルグラフの更新を知るのにノードが使用する帯域幅を減らすために、
  [minisketch][topic minisketch]ベースのset reconciliationを使用する研究について[投稿しました][myers recon]。
  彼の方法では、すべてのピアがほぼすべて同じパブリックチャネルについて、同じ情報を持っていると仮定しています。
  あるピアは、パブリックネットワークの完全なグラフからminisketchを生成し、それをすべてのピアに送信します。
  ピアは、このminisketchを使用して最後の照合以降のネットワークへの更新を見つけることができます。
  これは、[erlay][topic erlay]プロトコルを介してBitcoinのP2Pネットワーク用に提案された、
  過去数秒間の更新（新しい未承認トランザクション）のみが送信されるminisketchの使用とは異なるものです。

  すべてのパブリックチャネルで照合することの1つの課題は、
  すべてのLNノードに同じ情報の保持を求めることです。
  ノード間のチャネルグラフのビューに永続的な差異を生じさせるようなフィルタリングは、
  帯域幅のオーバーヘッドまたはプロトコルの失敗のいずれかにつながります。
  Matt Coralloは、この問題はerlayのモデルをLNに適用することで対処できると[提案しています][corallo recon]。
  新しい情報のみが同期される場合、永続的な差異について心配する必要はありませんが、
  フィルタリングルールに大きな差異があると、依然として帯域幅の消費や照合の失敗が発生する可能性があります。
  Myersは、更新の送信のみで必要となる状態追跡の量について懸念していました。
  Bitcoin Coreのノードは、以前にそのノードに送信した更新の再送を避けるため、
  各ピアに対して個別の状態を保持します。全チャネルに対して照合するという選択肢は、
  ピアごとの状態を不要にし、ゴシップ管理の実装を大幅に簡素化します。

  この要約が書かれている間も、それぞれのアプローチに内在するトレードオフに関する議論が続いていました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BTCPay Server 1.5.1][]は、新しいメインページダッシュボード、
  新しい[転送プロセッサ][btcpay server #3476]機能および、
  自動的に承認されるプル支払いと払い戻しを可能にする機能を含む、
  この人気のセルフホスティング型のペイメントプロセッサの新しいリリースです。

- [BDK 0.18.0][]は、このウォレットライブラリの新しいリリースです。
  これには、依存関係の1つであるrust-miniscriptライブラリの[重要なセキュリティ修正][minimalif bug]が含まれています。
  また、いくつかの改善と小さなバグ修正も含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #18554][]は、デフォルトで同じBitcoin Coreウォレットファイルが
  複数の完全に独立したブロックチェーンで使用されるのを防止します。
  Bitcoin Coreは、そのウォレットの1つに影響を与えるトランザクションについて新しいブロックをスキャンすると、
  そのブロックヘッダーのハッシュをウォレットに記録します。
  このPRは、最も最近記録されたスキャンブロックが、
  現在使用されているブロックチェーンと同じ[ジェネシスブロック][genesis block]の子孫かどうかチェックします。
  そうでない場合、新しい`-walletcrosschain`設定オプションが設定されていない限り、エラーが返されます。
  これにより、あるネットワーク（mainnetなど）での使用を目的としたウォレットが別のネットワーク（testnetなど）で使用されるのを防ぎ、
  偶発的な資金の損失やプライバシーの損失といったリスクを軽減します。
  これは、Bitcoin Coreの内部ウォレットのユーザーにのみ影響します。
  他のBitcoinウォレットソフトウェアは影響を受けません。

- [Bitcoin Core #24322][]は、Bitcoin Coreのコンセンサスコードをそのまま使用するためのライブラリを作成し、
  その後モジュールを段階的に整理してライブラリを最小限に抑えることで、
  コンセンサスエンジンを抽出する大きな取り組みの一部です。
  つまり、このPRは、`bitcoin-chainstate`実行可能ファイル（[Bitcoin Core #24304][]で導入）がリンクする必要のあるすべてのソースファイルを定義する
  `libbitcoinkernel`を導入します。このリストには、コンセンサスに論理的に関係していないようにみえるファイルも含まれており、
  Bitcoin Coreのコンセンサスエンジンの現在の依存性を示しています。
  今後の作業で、残りのコードベースからコンセンサスをモジュール化し、
  これらのファイルを`libbitcoinkernel`のソースリストから削除する予定です。

- [Bitcoin Core #21726][]は、プルーニングされたノード上でもcoinstatsを維持する機能を追加しました。
  coinstatsは、各ブロックにおけるUTXOの状態のMuHashダイジェストを含み、
  [assumeUTXO][topic assumeutxo]の状態の検証を可能にします。
  これまでは、これはアーカイブフルノード（ブロックチェーン上のすべてのブロックを保存するノード）でのみ
  利用可能であることが保証されていました。このマージされたPRは、
  `-coinstatsindex`設定オプションが有効な場合、
  プルーニングされたフルノード（検証後しばらくしてブロックを削除するノード）でもこの情報を利用できるようにします。

- [BDK #557][]は、Oldest Firstコイン選択アルゴリズムを追加しました。
  現在4つのコイン選択アルゴリズムがあります: Branch and Bound (BnB)、
  Single Random Draw (SRD)、Oldest First、Largest First。
  デフォルトで、BnBで解が見つからなかった場合に、
  BDKはフォールバックとしてSRDを使用したBnBを使用します。

- [LDK #1425][]は、高額の支払いをサポートするチャネルである、
  [ラージチャネル][topic large channels]（wumboチャネル）のサポートを追加しました。

- [LND #6064][]は、新しい`bitcoind.config`および`bitcoind.rpccookie`設定オプションを追加し、
  設定ファイルやRPCのcookieファイルの非デフォルトバスを指定できるようになりました。

- [LND #6361][]は、`signrpc`メソッドを更新し、 <!-- yes, "signrpc" is the RPC's name -->
  [MuSig2][topic musig]アルゴリズムを使用した署名を作成できるようにしました。
  詳細については、マージされたこのPRで追加された[ドキュメント][lnd6361 doc]をご覧ください。
  MuSig2のサポートは実験的なものであり、
  特にMuSig2のBIP提案（[ニュースレター #195][news195 musig2]参照）に大きな変更が合った場合には、
  変更される可能性があります。

- [BOLTs #981][]では、LNのネットワークグラフに関するクエリと結果を圧縮する仕様が削除されました。
  圧縮は使われておらず、サポートをやめることでLNの複雑さと依存性を減らすことができると考えられています。

{% include references.md %}
{% include linkers/issues.md v=2 issues="18554,24322,21726,6064,557,981,6361,1425,3476,24304" %}
[tetrud signal favor]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020350.html
[ivgi signal hodl voting]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020364.html
[aronesty signal parse scripts]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020354.html
[grant signal chainalysis]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020355.html
[bishop signal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020346.html
[news115 fee stealing]: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[osuntokun musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020361.html
[news195 musig2]: /ja/newsletters/2022/04/13/#musig2-bip
[black musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020371.html
[mcclelland measure]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020344.html
[teinturier security]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003561.html
[myers recon]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003551.html
[corallo recon]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003556.html
[genesis block]: https://en.bitcoin.it/wiki/Genesis_block
[btcpay server 1.5.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.5.1
[minimalif bug]: https://bitcoindevkit.org/blog/miniscript-vulnerability/
[bdk 0.18.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.18.0
[lnd6361 doc]: https://github.com/guggero/lnd/blob/93e069f3bd4cdb2198a0ff158b6f8f43a649e476/docs/musig2.md
