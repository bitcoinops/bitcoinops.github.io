---
title: 'Bitcoin Optech Newsletter #222'
permalink: /ja/newsletters/2022/10/19/
name: 2022-10-19-newsletter-ja
slug: 2022-10-19-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、先週BTCDとLNDに影響を与えたブロックのパースバグや、
Replace by Feeに関連する計画的なBitcoin Coreの機能変更に関する議論、
BitcoinにおけるValidity Rollupsの研究の概要、MuSig2のBIPドラフトの脆弱性に関する発表の共有、
Bitcoin Coreがリレーする未承認トランザクションの最小サイズを削減する提案の検討、
Bitcoinのバージョン2暗号化トランスポートプロトコルに関する提案BIP324の更新のリンクを掲載しています。
また、サービスやクライアントソフトウェアの変更や、新しいリリースおよびリリース候補の発表、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべきマージを含む恒例のセクションも含まれています。

## ニュース

- **BTCDとLNDに影響を与えたブロックのパースバグ:** 10月9日、
  [あるユーザー][brqgoo]が[Taproot][topic taproot]を使用して1,000近い署名を含むwitnessを持つ[トランザクション][big msig]を作成しました。
  Taprootのコンセンサスルールでは、witnessのデータサイズに対して直接的な制限は設けていません。
  これはTaprootの開発時に議論された設計要素です（[ニュースレター #65][news65 tapscript limits]参照）。

  大規模なwitnessを持つトランザクションが承認された直後、BTCDのフルノード実装とLNDライトニングネットワーク実装が、
  Bitcoin Coreのフルノードで有効な最新のブロックのデータの提供に失敗するようになったことが、ユーザーから報告されはじめました。
  BTCDノードでは、直近で承認されたトランザクションをまだ未承認であると報告していました。
  LNDでは、直近で使用可能になったチャネルが完全にオープンになったと報告されないようになっていました。

  BTCDとLNDの両方の開発者は、LNDではライブラリとして使用しているBTCDのコードの問題を修正し、
  [LND][lnd 0.15.2-beta]（[先週のニュースレター][news221 lnd]で言及）と[BTCD][btcd 0.23.2]の両方の新しいバージョンを迅速にリリースしました。
  BTCDとLNDのすべてのユーザーは、アップグレードが必要です。

  ユーザーはソフトウェアをアップグレードするまで、上記の承認の欠如の問題が発生し、
  いくつかの攻撃に対して脆弱になる可能性もあります。
  これらの攻撃の中には、かなりのハッシュレートを必要とするものもあります（これは高コストで、あまり現実的なものではないでしょう）。
  他の攻撃、特にLNDユーザーに対する攻撃では、攻撃がチャネル内の資金を一部失うリスクを負う必要があり、
  これもうまくいけば抑止力になるでしょう。私たちは再度アップグレードを推奨します。
  さらに、あらゆるBitcoinソフトウェアを使用している人は、そのソフトウェア開発チームからのセキュリティ通知に登録することをお勧めします。

  上記の開示後、Loki Verlorenは、Taprootのwitnessサイズに直接的な制限を追加する提案をBitcoin-Devメーリングリストに[投稿しました][verloren limits]。
  Greg Sandersは、制限の追加はコードを複雑にするだけでなく、
  すでに大きなwitnessを必要とするスクリプトでビットコインを受け取っている場合、その人たちが資金を失うことになるという指摘を[返信しました][sanders limits]。

- **<!--transaction-replacement-option-->トランザクションの置換オプション:**
  ニュースレター[#205][news205 rbf]と[#208][news208 rbf]に掲載したように、
  Bitcoin Coreは、`mempoolfullrbf`設定オプションのサポートをマージしました。
  これは、[BIP125][]のシグナルを含むトランザクションの[RBFによる置換][topic rbf]のみを許可する既存のBitcoin Coreの動作がデフォルトです。
  しかし、ユーザーがこの新しいオプションをtrueに設定すると、そのノードはBIP125のシグナルを含まないトランザクションの置換を受け入れ、リレーします。
  ただし、置換トランザクションはBitcoin Coreのその他の置換に関するルールに従うことが条件です。

  Dario Sneidermanisは、この新しいオプションは、現在未承認トランザクションを最終的なものとして受け入れているサービスにとって問題を引き起こすかもしれないと、
  Bitcoin-Devメーリングリストに[投稿しました][sne rbf]。
  ユーザーが非Bitcoin Coreソフトウェアを実行し（もしくは、Bitcoin Coreにパッチをあてたバージョン）、
  未シグナルの*完全な*[^full-rbf]トランザクションの置換を可能にすることは何年も前から可能でしたが、
  これらのソフトウェアが広く使用されているという証拠はありませんでした。
  Sneidermanisは、Bitcoin Coreで簡単に設定可能なオプションがあれば、
  十分な数のユーザーとマイナーが完全なRBFを有効にし、未シグナルの置換を信頼できるようにすることで、この状況を変える可能性があると考えています。
  より信頼性の高い未シグナルの置換は、未承認トランザクションを最終的なものとして受け入れるサービスから資金を盗むことの信頼性も上げることになり、
  これらのサービスは動作の変更が必要になるでしょう。

  問題について説明し、サービスが未承認トランザクションをいつ受け入れるかを選択する方法の詳細な説明に加えて、
  Sneidermanisは代替アプローチも提案しました。今後のBitcoin Coreのリリースから設定オプションを削除しつつ、
  将来の時点で完全なRBFをデフォルトで有効にするコードを追加するというものです。
  Anthony Townsは、検討のためにいくつかの選択肢を[投稿し][towns rbf]、
  Sneidermanisの提案を若干修正したものを実装した[プルリクエスト][bitcoin core #26323]を公開しました。
  もしこれがマージされリリースされると、TownsのPRは、2023年5月1日からデフォルトで完全なRBFを有効にすることになります。
  完全なRBFに反対するユーザーは、`mempoolfullrbf`オプションをfalseに設定することで、自分のノードは参加しないようにすることができます。

- **Validity Rollupsの研究:** John Lightは、彼が作成したValidity Rollupsに関する[詳細な研究レポート][light ru]を
  Bitcoin-Devメーリングリストに[投稿しました][light ml ru]。
  これは、現在のサイドチェーンのステートをゼロ知識証明でメインチェーン上にコンパクトに格納するタイプの[サイドチェーン][topic sidechains]です。
  サイドチェーンのユーザーは、メインチェーンに保存されているステート使用して、
  自分が管理しているサイドチェーン上のビットコインの量を証明することができます。
  その有効性を証明したメインチェーンのトランザクションを送信することで、
  サイドチェーンのオペレーターやマイナーが引き出しを阻止しようとしても、
  サイドチェーンからビットコインを引き出すことができます。

  Lightの研究は、Validity Rollupsを詳細に説明し、そのサポートをBitcoinに追加する方法を検討し、
  その実装に関するさまざまな懸念事項を検証しています。

- **MuSig2のセキュリティの脆弱性:** Jonas Nickは、彼と他の数名が発見した、
  [BIPドラフト][bips #1372]に文書化された[MuSig2][topic musig]アルゴリズムの脆弱性について、
  Bitcoin-Devメーリングリストに[投稿しました][nick musig2]。
  簡単に説明すると、攻撃者がユーザーの公開鍵と、ユーザーが署名する公開鍵への調整値を知っており（[BIP32][topic bip32]の拡張公開鍵のように）、
  ユーザーが署名するその公開鍵の操作が可能な場合、プロトコルは脆弱です。

  Jonas Nickは、この脆弱性は「比較的レアケースにのみ適用される」と考えており、
  MuSig2を使用している（もしくは使用を計画している）人は、彼と彼の共著者に質問するように勧めています。
  MuSig2のBIPドラフトは、この問題に対処するためまもなく更新される予定です。

- **<!--minimum-relayable-transaction-size-->リレー可能な最小トランザクションサイズ:**
  Greg Sandersは、脆弱性[CVE-2017-12842][]の悪用を困難にするために追加されたポリシーを緩和するBitcoin Coreに対する要求を
  Bitcoin-Devメーリングリストに[投稿しました][sanders min]。
  この脆弱性は、特別に細工された64バイトのトランザクションをブロックで承認させることができる攻撃者により、
  1つまたは複数の異なる任意のトランザクションが承認されたと信じるように軽量クライアントを騙すことを可能にします。
  たとえば、無実のユーザーであるボブのSPV（ Simplified Payment Verification）ウォレットは、
  そのような支払いは承認されていないにも関わらず、100万BTCの支払いが数十回の承認を受けたと表示する場合があります。

  この脆弱性が一部の開発者の間でしか知られていなかった頃、Bitcoin Coreに制限が加えられ、
  標準的なトランザクションテンプレートを使用して作成できるほぼ最小サイズである85バイト（witnessのバイトは除く）
  未満のトランザクションのリレーを防止するようになりました。この場合、攻撃者は
  Bitcoin Coreをベースにしていないソフトウェアで自分のトランザクションをマイニングさせる必要があります。
  その後、[コンセンサスクリーンアップのソフトフォーク案][topic consensus cleanup]では、
  65バイト以下のサイズのトランザクションを新しいブロックに含めないようにすることで、
  この問題を恒久的に解決することが提案されました。

  Sandersは、トランザクションリレーポリシーの制限を85バイトから
  コンセンサスクリーンアップで提案された65バイトの制限に下げることを提案しており、
  これは、現在のリスクプロファイルを変更することなく追加の実験と使用を可能にするかもしれません。
  Sandersは、この変更をするための[プルリクエスト][bitcoin core #26265]を公開しています。
  この変更案に関する以前の議論については、[ニュースレター #99][news99 min]をご覧ください。

- **BIP324の更新:** Dhruv Mは、
  [バージョン2の暗号化P2Pトランスポートプロトコル][topic v2 p2p transport]であるBIP324の提案について、
  いくつかの更新の概要をBitcoin-Devメーリングリストに[投稿しました][dhruv 324]。
  これには、[BIPドラフト][bips #1378]の書き換えと、
  複数のリポジトリにまたがる[提案されたコード変更について優れたガイド][bip324 changes]を含む、
  レビューアが提案を評価するのに役立つ[さまざまなリソース][bip324.com]が含まれています。

  BIPドラフトの*動機*セクションに掲載されているように、Bitcoinノードのネイティブな暗号化トランスポートプロトコルは、
  トランザクション公開時のプライバシーを改善し、接続の改ざんを防ぎ（または少なくとも改ざんの検知を容易にし）、
  またP2P接続の検閲や[エクリプス攻撃][topic eclipse attacks]をより困難にすることができます。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **btcd v0.23.2リリース:**
  btcd v0.23.2（および[v0.23.1][btcd 0.23.1]）には、[addr v2][topic addr v2]と
  [PSBT][topic psbt]、[Taproot][topic taproot]、[MuSig2][topic musig]の追加のサポートおよび、
  その他の拡張と修正が含まれています。

- **ZEBEDEEがHosted Channelのライブラリを発表:**
  ZEBEDEEは、最近の[ブログ記事][zbd nbd]で、[Hosted Channel][hosted channels]のサポートを中心とした、
  オープンソースウォレット（Open Bitcoin Wallet）、 Core Lightningプラグイン（Poncho）、
  ライトニングクライアント（Cliché）、ライトニングライブラリ（Immortan）を発表しました。

- **Cashuがライトニングのサポートを開始:**
  E-cashソフトウェア[Cashu][cashu github]は、ライトニングでの受信をサポートする概念実証ウォレットを立ち上げました。

- **アドレスエクスプローラSpiralのローンチ:**
  [Spiral][spiral explorer]は、オープンソースのパブリックアドレス[エクスプローラ][topic block explorers]で、
  暗号を使用してアドレスに関する情報を照会するユーザーにプライバシーを提供します。

- **BitGoがライトニングのサポートを発表:**
  BitGoは、[ブログ記事][bitgo lightning]で、クライアントの代わりにノードを実行し、
  ペイメントチャネルの流動性を維持するカストディアルなライトニングサービスについて掲載しています。

- **ZeroSyncプロジェクトのローンチ:**
  [ZeroSync][zerosync github]プロジェクトは、IBD（Initial Block Download）で発生するBitcoinノードの同期に
  [Utreexo][topic utreexo]とSTARK proofsを使用しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 24.0 RC2][]は、ネットワークで最も広く使われているフルノード実装の次期バージョンの最初のリリース候補です。
  [テストのガイド][bcc testing]が利用できるようになっています。

- [LND 0.15.3-beta][]は、いくつかのバグを修正したマイナーリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23549][]は、提供された[ディスクリプター][topic descriptors]のセットに対して、
  指定された範囲の関連ブロックを識別する`scanblocks`RPCを追加しました。
  このRPCは、[Compact Block Filter][topic compact block filters]のインデックスを保持するノード
  （`-blockfilterindex=1`）でのみ利用可能です。

- [Bitcoin Core #25412][]は、既存の`getdeploymentinfo`RPCと同様に、
  ソフトフォークのデプロイに関する情報を含む新しい`/deploymentinfo`RESTエンドポイントを追加しました。

- [LND #6956][]では、チャネルの相手から受け取った支払いに適用される最小チャネルリザーブを設定できるようになりました。
  ノードはチャネル内の相手の資金額がリザーブ（LNDではデフォルトで1%）を下回る場合、相手からの支払いを受け入れません。
  これにより、相手が期限切れの状態でチャネルを閉鎖しようとした場合に、
  相手はペナルティとして少なくともリザーブ金額を支払う必要があることが保証されます。
  このマージされたPRでは、リザーブ額を上げたり下げたりすることができます。

- [LND #7004][]は、LNDが使用するBTCDライブラリのバージョンを更新し、
  このニュースレターで説明したセキュリティの脆弱性を修正しました。

- [LDK #1625][]は、ローカルノードが支払いをルーティングしようとした遠隔チャネルの流動性に関する情報を追跡するようになりました。
  ローカルノードは、リモートノード経由で支払いに成功した、あるいは明らかに資金不足で失敗した支払いのサイズに関する情報を保存します。
  この情報は、年齢を調整した上で、確率的な経路探索の入力として使用されます（[ニュースレター #163][news163 pr]参照）。

## 脚注

<!-- TODO:harding is 95% sure the below is correct and will delete this
comment when he gets verification from the person he thinks first used
the "full RBF" term.  -->

[^full-rbf]:
    トランザクションの置換は、Bitcoinの初期のバージョンに含まれており、
    長年にわたって多くの議論を受けてきました。その間、その側面を説明するために使用されるいくつかの用語が変更され、
    混乱を招く可能性があります。おそらく最も大きな混乱は「完全なRBF（フルRBF）」という用語で、
    これは、2つの異なる概念で使用されてきました:

    - *<!--full-replacement-of-any-->インプットとアウトプットの追加だけでなくトランザクションの**一部**の完全な置換:*
      RBFを有効にすることが論争の的になった時期に、オプトインRBFのアイディアが提案される前、
      １つの[提案][superset rbf]は、同じアウトプットすべてに加えて
      手数料の支払いやお釣りの徴収に使用する新しいインプットとアウトプットが追加されている場合のみ
      置換可能にするというものでした。元のアウトプットを残すという要件により、
      置換後も同じ受取人に同じ金額が支払われることが保証されます。このアイディアは、
      後にFSS（First Seen Safe）RBFと呼ばれ、*部分的な*置換の一種でした。

      それに比べ、*完全な*置換は、元のトランザクションについて何でも完全に変更できることを意味していました
      （ただし、少なくとも同じインプットを1つ使用することで元のトランザクションとまだ競合します）。
      [BIP125][]のタイトル「Opt-in Full Replace-by-Fee Signaling」で使用されているfullは、この用法です。

    - *<!--full-replacement-of-->BIP125のシグナルを介して置換の許可をオプトインするトランザクションのみを置換するのとは異なるトランザクションの完全な置換:*
      オプトインRBFは、RBFを許可したくない人と、RBFが必要または不可避であると考えている人たちとの間の妥協案として提案されました。
      ただし、この記事の執筆時点では、少数のトランザクションのみがRBFにオプトインしており、
      RBFの部分的な採用であるとみなすことができます。

      それに比べ、どんな未承認トランザクションも置換できるようにすることでRBFを*完全に*採用することができます。
      現在議論されているBitcoin Coreの設定オプション`mempoolfullrbf`で使用されているのは、このfullの用法です。

{% include references.md %}
{% include linkers/issues.md v=2 issues="23549,25412,25667,2448,6956,6972,7004,1625,26323,1372,1378,26265" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[superset rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2013-March/002240.html
[brqgoo]: https://twitter.com/brqgoo/status/1579216353780957185
[big msig]: https://blockstream.info/tx/7393096d97bfee8660f4100ffd61874d62f9a65de9fb6acf740c4c386990ef73?expand
[news65 tapscript limits]: /en/newsletters/2019/09/25/#tapscript-resource-limits
[lnd 0.15.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.2-beta
[news221 lnd]: /ja/newsletters/2022/10/12/#lnd-v0-15-2-beta
[btcd 0.23.2]: https://github.com/btcsuite/btcd/releases/tag/v0.23.2
[verloren limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020993.html
[sanders limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020996.html
[news205 rbf]: /ja/newsletters/2022/06/22/#rbf
[news208 rbf]: /ja/newsletters/2022/07/13/#bitcoin-core-25353
[sne rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020980.html
[towns rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021017.html
[light ml ru]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020998.html
[light ru]: https://bitcoinrollups.org/
[nick musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021000.html
[sanders min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020995.html
[cve-2017-12842]: /en/topics/cve/#CVE-2017-12842
[news99 min]: /en/newsletters/2020/05/27/#minimum-transaction-size-discussion
[dhruv 324]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020985.html
[bip324.com]: https://bip324.com
[bip324 changes]: https://bip324.com/sections/code-review/
[news163 pr]: /ja/newsletters/2021/08/25/#zero-base-fee-ln-discussion-ln
[lnd 0.15.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.3-beta
[btcd 0.23.1]: https://github.com/btcsuite/btcd/releases/tag/v0.23.1
[zbd nbd]: https://blog.zebedee.io/announcing-nbd/
[hosted channels]: https://fanismichalakis.fr/posts/what-are-hosted-channels/
[cashu github]: https://github.com/callebtc/cashu
[spiral explorer]: https://btc.usespiral.com/
[bitgo lightning]: https://blog.bitgo.com/bitgo-unveils-custodial-lightning-898554d3b749
[zerosync github]: https://github.com/zerosync/zerosync
