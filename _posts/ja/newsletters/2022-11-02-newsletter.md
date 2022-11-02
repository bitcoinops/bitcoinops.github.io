---
title: 'Bitcoin Optech Newsletter #224'
permalink: /ja/newsletters/2022/11/02/
name: 2022-11-02-newsletter-ja
slug: 2022-11-02-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ノードがフルRBFを有効にするオプションについての継続的な議論と、
BIP324のバージョン2暗号化トランスポートプロトコルの設計要素に関するフィードバックの要求、
LNの障害と遅延を特定のノードに確実に帰すための提案、
最新のLNのHTLCのアンカーアウトプットを使用する代替案に関する議論のリンクを掲載しています。
また、LNDのセキュリティクリティカルなアップデートを含む、新しいソフトウェアリリースとリリース候補の発表や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、恒例のセクションも含まれています。

## ニュース

- **mempoolの一貫性:** Anthony Townsは、
  Bitcoin Coreの開発ブランチに`mempoolfullrbf`オプションを追加することで行われたような（ニュースレター[#205][news205 rbf]、
  [#208][news208 rbf]、[#222][news222 rbf]および[#223][news223 rbf]参照）、
  トランザクションのリレーとmempoolの受け入れに関するBitcoin Coreのポリシーを構成しやすくすることの結果について
  Bitcoin-Devメーリングリストで[議論][towns consistency]を始めました。
  彼は、「これはCoreが過去に行ったこととは異なる。以前は、新しいポリシーは誰にとっても良いものであることを
  （あるいは、できるだけそうなるように）確認しようとし、それが実装されるとすぐに有効にしてきた。
  追加されたオプションはいずれも、Txの伝播に大きく影響しない方法でリソースの使用を制限するためのもので、
  新しい動作が物議を醸す際に利用者が従来の動作に戻すため（たとえば、0.12から0.18までの-mempoolreplacement=0オプションなど）、
  また実装のテストやデバッグを簡単にするためのものだった。デフォルトでオンにする自信がないのに、
  オプトイン可能な新しいリレー動作を提供するのは、私が過去に見たCoreのアプローチとは一致しない。」と主張しました。

    Townsは次に、これが開発の新しい方向性かどうかを考えています:
    「フル[RBF][topic RBF]は長い間議論の的だったが、開発者には広く好まれている。[...]そのため、
    これは単に特殊ケースで、前例はないのかもしれない。人々が他の誤ったデフォルトオプションを提案すると、
    ユーザーにはオプションがあるという現在進行中の議論があるにも関わらず、それがマージされることに対して大きな抵抗があるだろう。」
    しかし、それが新しい方向性であると仮定して、その決定がもたらすいくつかの潜在的な結果を評価しています:

    - *<!--it-should-be-easier-to-get-default-disabled-alternative-relay-options-merged-->デフォルトで無効化されたオプションをマージする方が簡単なはず:*
      もしユーザーに多くのオプションを与えることが良いのであれば、リレーポリシーの多くの側面を設定可能にすることができます。
      たとえば、Bitcoin Knotsでは、[アドレスの再利用][topic output linking]をするトランザクションのリレーを拒否するように
      ノードに設定する`spkreuse`（script pubkey reuse）オプションが提供されています。

    - *<!--more-permissive-policies-require-widespread-acceptance-or-better-peering-->より寛容なポリシーは、広く受け入れられるか、より良いピアリングを必要とする:*
      Bitcoin Coreノードはアウトバウンド接続を介してデフォルトで8つのピアとトランザクションをリレーします。
      そのため、ノードが同じポリシーをサポートする少なくとも1つのランダムに選択されたピアを見つける可能性が95%になる前に、
      ネットワークの少なくとも30%がより寛容なポリシーをサポートする必要があります。
      ポリシーをサポートするノードが少ないほど、ノードがそのポリシーをサポートするピアを見つける可能性は低くなります。

    - *<!--better-peering-involves-tradeoffs-->良いピアリングにはトレードオフがある:*
      Bitcoinノードは、P2Pで`addr`、[`addrv2`][topic addr v2]および`version`メッセージのservicesフィールドを使用して
      自身の機能を通知することができ、共通の関心を持つノードが互いを見つけて（*優先ピアリング*と呼ばれる）サブネットワークを形成することができます。
      また、共通の関心を持つフルノードのオペレーターは、
      他のソフトウェアを使用して独自のリレーネットワーク（LNノード間のネットワークなど）を形成することもできます。
      これにより、ポリシーを実装するノードが少数でも効果的にリレーすることができますが、
      希少なポリシーを実装しているノードは特定されやすく、検閲もしやすくなります。
      また、マイナーはこれらのサブネットワークや代替ネットワークに参加する必要があり、
      マイニングの複雑さやコストが増加します。そのため、トランザクション選択の一元化のプレッシャーが高まり、
      これも検閲を容易にします。

        さらに、一部のピアと異なるポリシーを実装しているノードは、
        2つのピアが既に同じ情報のいくつかを保持している場合に、レイテンシーや帯域幅を最小化する
        [Compact Block Relay][topic compact block relay]や[erlay][topic erlay]などの技術を十分に活用できなくなります。

    Townsの投稿には、洞察力に富んだ複数の反応が寄せられており、この記事の執筆時点で議論が続いています。
    来週のニュースレターで最新情報をお伝えする予定です。

- **BIP324のメッセージ識別子:** Pieter Wuilleは、Bitcoin-Devメーリングリストに
  [バージョン2 P2P暗号化トランスポートプロトコル][topic v2 p2p transport] (v2 transport)
  の[BIP324][bips #1378]ドラフト仕様のアップデートに対する返答を[投稿しました][wuille bip324]。
  帯域幅を削減するために、v2トランスポートでは既存のプロトコルの12バイトのメッセージ名を1バイトの短い識別子に置き換えるようにします。
  たとえば、12バイトにパディングされる`version`というメッセージ名は、0x00に置き換えられます。
  しかし、メッセージ名を短くすると、将来ネットワークにメッセージを追加する際に、異なる提案で衝突が発生するリスクが高くなります。
  Wuilleは、この問題に対処するための4つの異なるアプローチのトレードオフを説明し、このテーマについてコミュニティの意見を求めています。

- **LNのルーティング失敗の属性:** LN支払いの試行は、最終的に受信者がペイメントプリイメージのリリースを拒否したり、
  ルーティングノードの1つが一時的にオフラインになるなど、さまざまな理由で失敗に終わることがあります。
  どのノードによって支払いが失敗したかという情報は、送信者が近い将来の支払いでそのノードを避けるのにとても有益な情報ですが、
  現在のLNプロトコルは、ルーティングノードがその情報を送信者に伝えるための認証方法を提供していません。

    数年前、Joost Jagerが解決策を提案し（[ニュースレター #51][news51 attrib]参照）、
    彼はそれを改良し詳細を追加して[更新しました][jager attrib]。
    この仕組みでは、支払いが失敗したノードのペア（または前の失敗のメッセージを検閲または文字化けされたノードのペア）を確実に識別することができます。
    Jagerの提案の主な欠点は、他のLNの特性が同じままであれば、失敗のオニオンメッセージのサイズが大幅に増加することです。
    ただし、LNの最大ホップ数を減らせば、失敗のオニオンメッセージのサイズはそれほど大きくする必要はないでしょう。

    代わりに、Rusty Russellは、最終的な支払いが失敗した場合でも
    各ルーティングノードに1 sat支払われる[Spontaneous Payment][topic spontaneous payments]に似た仕組みを使用する[提案][russell attrib]を行いました。
    送信者は、送信したsatoshiの量と戻ってきたsatoshiの量を比較することで、どのホップで支払いが失敗したかを特定することができます。

- **<!--anchor-outputs-workaround-->アンカーアウトプットの回避策:** Bastien Teinturierは、
  [アンカーアウトプット][topic anchor outputs]を、異なる手数料率が設定された[HTLC][topic htlc]の複数の事前署名バージョンに置き換える[提案][bolts #1036]を
  Lightning-Devメーリングリストに[投稿しました][teinturier fees]。
  アンカーアウトプットは、LNの2者間のコントラクトプロトコルで[固定できない][topic transaction pinning]方法で、
  [CPFP][topic cpfp]の仕組みを使用してトランザクションに手数料を追加することを可能にする[CPFP carve-out][topic cpfp carve out]ルールの開発と共に導入されました。
  しかし、Teinturierは、CPFPを使用するには、各LNノードが非LNのUTXOをいつでも使用できるようプールしておく必要があると[指摘しています][bolts #845]。
  それと比べて、手数料が異なる複数のバージョンのHTLCに事前署名しておけば、手数料をHTLCの値から直接支払うことができ、
  追加のUTXO管理は必要ありません。

    彼は、他のLN開発者に複数の手数料率のHTLCに移行するためのアイディアへの支持を求めています。
    この記事を書いている時点では、すべての議論はTeinturierの[PR][bolts #1036]で行われています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.15.4-beta][]および[0.14.4-beta][lnd 0.14.4-beta]は、
  最近のブロックの処理の問題に関するバグ修正を含む**セキュリティクリティカル**なリリースです。
  すべてのユーザーにアップグレードが必要です。

- [Bitcoin Core 24.0 RC2][]は、ネットワークで最も広く使われているフルノード実装の次期バージョンのリリース候補です。
  [テストのガイド][bcc testing]が利用できるようになっています。

  **警告:** このリリース候補には、`mempoolfullrbf`設定オプションが含まれており、
  いくつかのプロトコルやアプリケーション開発者は、ニュースレター[#222][news222 rbf]および[#223][news223 rbf]で説明したように、
  マーチャントサービスに対して問題を引き起こす可能性があると考えています。
  Optechは、影響を受ける可能性のあるサービスに対して、RCを評価し、公開討論に参加することを推奨しています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23927][]は、プルーニングされたピアでの`getblockfrompeer`を、
  ノードの現在の同期進捗以下の高さに制限します。
  これは、将来のブロックを取得することで、ノードのブロックファイルがプルーニングの対象外になるのを防止します。

  Bitcoin Coreは、約130MBのファイルにブロックを受信した順に格納します。
  プルーニングはブロックファイル全体を廃棄しますが、同期処理されていないブロックを含むファイルは廃棄しません。
  データ容量の小ささと`getblockfrompeer`RPCの繰り返しの組み合わせにより、
  複数のブロックファイルがプルーニングの対象外になり、プルーニングノードが許可されたデータ量を超える原因になる可能性があります。

- [Bitcoin Core #25957][]は、ウォレットに関連するUTXOを使用したり作成したりしないブロックをスキップするために、
  （有効になっている場合に）[Block Filter Index][topic compact block filters]を使用することで、
  ディスクリプターウォレットの再スキャンのパフォーマンスを向上します。

- [Bitcoin Core #23578][]は、[HWI][topic hwi]と最近マージされた[BIP371][]のサポート（[ニュースレター #207][news207 bc22558]）を使用して、
  [Taproot][topic taproot]のkeypath支払いに対する外部署名のサポートを可能にしました。

- [Core Lightning #5646][]は、実験的な[Offer][topic offers]のサポートを更新し、
  [x-only public key][news72 xonly]を削除しました（代わりに余分な1バイトを含む[圧縮公開鍵][compressed pubkeys]を使用します）。
  また、別の実験的なプロトコルである[ブラインドペイメント][blinded payments]の転送も実装しています。
  PRの説明では、「ブラインドペイメントのインボイスの生成や実際の支払いは含まれない」と警告しています。

- [LND #6517][]では、新しいRPCとイベントが追加され、
  ユーザーは新しいチャネル残高の分配を反映するためにコミットメントトランザクションが更新されることで、
  入ってくる支払い（[HTLC][topic htlc]）が完全にロックされた際に監視できるようになります。

- [LND #7001][]は、転送履歴のRPC（`fwdinghistory`）に新しいフィールドを追加し、
  どのチャネルパートナーが自分に支払い（HTLCが）を転送したかと、自分が支払いをリレーしたパートナーを表示します。

- [LND #6831][]は、HTLCのインターセプターの実装（[ニュースレター #104][news104 intercept]参照）を更新し、
  インターセプターに接続されたクライアントが妥当な時間内に支払いの処理を完了しなかった場合に、
  自動的に受信した支払い（HTLC）を拒否します。有効期限が近づく前にHTLCが承認または拒否されない場合、
  チャネルパートナーは自身の資金を保護するためにチャネルを強制クローズする必要があります。
  このマージされたPRの自動拒否は、チャネルを開いたままにすることを保証します。送信者はいつでも再び支払いの送信を試せます。

<!-- The commit below appears to be a direct push to LND's master branch -->
- [LND 609cc8b][]は、脆弱性を報告するための指示を含む[セキュリティポリシー][lnd secpol]を追加しました。

- [Rust Bitcoin #957][]は、[PSBT][topic psbt]に署名するためのAPIを追加しました。
  まだ、[Taproot][topic taproot]支払いの署名はサポートしていません。

- [BDK #779][]は、ECDSA署名の[low-r grinding][topic low-r grinding]のサポートを追加し、
  すべての署名の約半分で1バイトのサイズを削減します。

{% include references.md %}
{% include linkers/issues.md v=2 issues="23927,25957,5646,6517,7001,6831,957,779,1036,845,1378,23578,22558" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[lnd 609cc8b]: https://github.com/LightningNetwork/lnd/commit/609cc8b883c7e6186e447e8d7e6349688d78d4fd
[lnd secpol]: https://github.com/lightningnetwork/lnd/security/policy
[towns consistency]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021116.html
[news205 rbf]: /ja/newsletters/2022/06/22/#rbf
[news208 rbf]: /ja/newsletters/2022/07/13/#bitcoin-core-25353
[wuille bip324]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021115.html
[news72 xonly]: /ja/newsletters/2019/11/13/#x-only-pubkeys
[compressed pubkeys]: https://developer.bitcoin.org/devguide/wallets.html#public-key-formats
[blinded payments]: /en/topics/rendez-vous-routing/
[news104 intercept]: /en/newsletters/2020/07/01/#lnd-4018
[news51 attrib]: /en/newsletters/2019/06/19/#authenticating-messages-about-ln-delays
[jager attrib]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003723.html
[russell attrib]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003727.html
[teinturier fees]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003729.html
[news222 rbf]: /ja/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /ja/newsletters/2022/10/26/#rbf
[lnd 0.15.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.4-beta
[lnd 0.14.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.5-beta
[news207 bc22558]: /ja/newsletters/2022/07/06/#bitcoin-core-22558
