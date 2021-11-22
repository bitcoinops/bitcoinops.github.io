---
title: 'Bitcoin Optech Newsletter #86'
permalink: /ja/newsletters/2020/02/26/
name: 2020-02-26-newsletter
slug: 2020-02-26-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、2020 Chaincode residency programの発表、LNの2つの提案されたルーティングの改善についての説明、Stanford Blockchain Conferenceからの3つの興味深い講演、Bitcoin Stack Exchangeからの主な質問と回答へのリンク、Bitcoinインフラストラクチャソフトウェアに対するいくつかの注目すべき変更をお送りします。

## Action items

- **Chaincode Residencyへの応募:** Chaincode Labsは[5回目のresidency program][residency]を、今年6月にニューヨークで開催することを[発表][residency announcement]しました。このプログラムは、ビットコインとLNプロトコルの開発を対象とした2つのセミナーとディスカッションシリーズで構成されています。オープンソースプロジェクトへの貢献に関心のある開発者は、ビットコインシリーズ、LNシリーズ、またはその両方に[応募][residency apply]できます。あらゆるバックグラウンドの応募者を歓迎し、必要に応じてChaincodeが旅費と宿泊費を負担します。

*注：リリースおよびリリース候補のリストは、独自の[セクション][release rc section]に移動されました。*

## News

- **前払いの逆引き(Reverse up-front payments):** [Newsletter#72][news72 upfront]で説明されているように、LN開発者は、支払いが拒否された場合でも、LN支払い（HTLC）のルーティングに少額の料金を請求する方法を探しています。これにより、帯域幅と流動性を無料で消費するように（あえて失敗するように）設計された支払いを阻止できます。今週、Joost Jagerは、前払い料金がHTLCの受信者から支払いの送信者に返される新しいスキームを[提案][jager up-front]しました。たとえば、支払いがアリスからボブ、キャロルに送られる場合、アリスはボブから小額の手数料を受け取り、ボブはキャロルから小額の手数料を受け取ります。料金は、HTLCが保留中の時間に比例します。これによりHTLCの迅速なルーティングもしくは拒否が奨励されます。[保留請求書][topic hold invoices]を保持しているユーザ（例えばキャロル）はルーティング・ノード（例えばボブ）にルーティング資本をロックする代わりに支払いを行います。

    数人の回答者がこのアイデアを気に入っているようで、それをどのように実装し、どのような技術的課題を克服する必要があるかについて議論し始めました。

- **LNダイレクトメッセージ:** Rusty RussellがLNノードがLN支払いメカニズムを使用せずにピア間で暗号化されたメッセージをルーティングできるような[提案][russell dm]をしています。これは、[Whatsat][]などのメッセージ・オーバー・ペイメントの現在の使用を、より簡単なプロトコルに置き換えることができます（[Newsletter#72][news72 offers]参照）。Russellの提案は、もともとLN支払い（HTLC）に使用される同じオニオン・ルーティングを使用して指定されていましたが、開発者ZmnSCPxjはメッセージ送信者が自身のノードから受信ノード、受信ノードから戻りの自身ノードへの完全なパスを指定する方法を[提案][zmn circular]しました。たとえば、AliceがCarolと通信したい場合、次のパスを選択できます。

        Alice → Bob → Carol → Dan → Alice

    このタイプのサークルルーティングは監視をより困難にし、リターンパスを保存する必要があるルーティング・ノードのオーバーヘッドを排除し、ルーティング・ノードのプロトコルをステートレスにします。この記事の執筆時点では、プライバシーの強化とスパムによるメカニズムの悪用の防止に重点を置いて議論が続けられています。

## 2020年のStanford Blockchain Conferenceでの注目すべき講演

The Stanford Center for Blockchain Researchは先週、毎年恒例の[Stanford Blockchain Conference][sbc]を開催しました。この会議には、3日間で30を超えるプレゼンテーションが含まれていました。Optechニュースレターの読者にとって特に興味深いと思われる3つの講演をまとめました。

プログラムをまとめて、講演のビデオをオンライン([day 1][]、[day 2][]、[day 3][])で提供してくれた会議主催者、および[transcripts][]を提供してくれたBryan Bishopに感謝します。

- **<!--an-axiomatic-approach-to-block-rewards-->報酬をブロックする公理的アプローチ:** Tim Roughgardenは、Xi ChenとChristos Papadimitriouに、[メカニズム設計][mechanism design]理論の観点からBitcoinのブロック報酬配分ルールを分析した研究を発表しました（[transcript][axiomatic txt]、[video][axiomatic vid]、[paper][axiomatic paper]）。

    Roughgardenは、よく知られている「ゲーム理論」の逆として「メカニズム設計」を導入することから彼の講演を始めました。ゲーム理論では、ゲームのルールと、それらのルールがもたらす均衡と行動に関する理由を説明します。対照的に、メカニズムの設計は意図した結果から始まり、その望ましい結果をもたらすゲームルールの設計を試みます。Roughgardenは「好きな目的関数を選択して最適なプロトコルが選定できるような、ブロックチェーンプロトコルの空間の数学的記述があればいいのではないでしょうか。」と述べています。またRoughgardenは、ブロックチェーンの報酬メカニズムを設計するときに、望ましい動作に対して3つの「軸」を提供します。

    1. _シビル耐性(sybil resistance)_:マイナーは、自分のパブリックIDを複数分割することで報酬を増やすことはできません。

    2. _共謀抵抗(collusion resistance)_:マイナーのグループは、独立したアイデンティティを単一の結合されたアイデンティティに結合することによって報酬を増やすことはできません。

    3. _匿名性(anonymity)_: 報酬の分配はマイナーの公開IDに依存せず、マイナーのハッシュレートが変更される場合、報酬も同じように変更されます。

    次に、この論文は、これらの公理を満たすユニークな報酬メカニズムが比例メカニズムであること（つまり、各マイナーがハッシュレートに比例した報酬を受け取ること）を正式に証明しています。この論文は、単一ブロックの作成に関する理論のみを扱っているため、[セルフィッシュ・マイニング][selfish mining]のような長期的な戦略を考慮していません。

    結果はビットコインに精通している人には自明のように見えるかもしれませんが、このような形で言及されることは斬新であり、マイナーのためのより複雑な行動（例えば、長期戦略やプーリング行動）を探る良い基礎になるかもしれません。

- **Boomerang：冗長性による支払いチャネルネットワークのレイテンシーとスループットの改善:** Joachim Neuは、Lightning Networkなどの支払いチャネルネットワークで[アトミック・マルチパス・ペイメント][topic multipath payments]を使用する場合の遅延の削減と流動性ロックアップの防止に関するVivek BagariaとDavid Tseの研究を発表しました（[transcript][boomerang txt]、[video][boomerang vid]、[paper][boomerang paper]）。

    マルチパス・ペイメントは、「誰もが最後まで待つ」_straggler problem_の問題を抱えています。分散コンピューティングのこの概念は、目標がn個のタスクに依存する場合、それらのタスクのn個すべてのうち最も遅いものが完了するまで待機する方法を説明しています。マルチパス・ペイメントのコンテキストでは、これは、支払者が0.05BTCを0.01BTCの5つの部分に分割して支払いたい場合、それらの構成部分がすべて完了したときにのみ支払いが完了することを意味します。これにより、特に1つ以上のパーツが失敗して再試行が必要な場合、支払いの待ち時間が長くなり、ルーティングの流動性が低下します。

    straggler problemを修正する一般的なアプローチは、冗長性を導入することです。上記の例では、支払者が0.01BTCの7回の部分支払いを行い、受信者が正常にルーティングされた支払いの最初の5回を請求することになります。問題は、受信者が7つすべてを要求して0.02BTCの過剰支払いを引き起こすのを防ぐ方法です。

    Neuなどは_boomerang_コントラクトと呼ばれる新しいスキームを提示します。受信者は、[公的に検証可能な秘密の共有][pvss]スキームのシェアとして、支払い部分のプレイメージを選択します。上記の例では、7つの支払い前画像のうち6つから秘密を再構築できます。支払者は7つの支払部分(paymentparts)を作成しますが、支払者が完全な秘密を知っている場合、支払者は全額を返済する逆（ブーメラン）条件に関連付けられます。受取人が5つ以下の支払い部分を要求する場合、支払者は完全な秘密を知ることはできず、ブーメラン条項を呼び出すことはできません。また受取人が6つ以上の部分をチートして要求する場合、支払者は契約のブーメラン条項、および支払い部分のいずれも受取人が引き出すことはできません。

    この論文では、シュノア署名スキームに基づいて、[アダプター署名][adaptor signatures]を使用したビットコインでのブーメラン契約の実装について説明します。Neuはまた、ECDSAを介してアダプター署名を作成することが可能であるため、現在のブーメラン契約は理論的にはBitcoinで実装できると述べています。

- **<!--remote-side-channel-attacks-on-anonymous-transactions2-->匿名トランザクションに対するリモートサイドチャネル攻撃:** Florian Tramerは、Dan BonehおよびKenneth G. Patersonと、MoneroおよびZcashでのユーザープライバシーに対するサイドチャネルおよびトラフィック分析攻撃のタイミングに関する研究を発表しました（[transcript][side-channel txt]、[video][side-channel vid]、[paper][side-channel paper]）。

    MoneroおよびZcashは、暗号技術（Moneroの[リング署名][ring signatures]および[bulletproofs][]およびZcashの[zk-SNARKs][]）を使用して送信者のID、受信者のID、および金額を隠すプライバシー重視の暗号通貨です。Tramerなどは、 これらの暗号構造が正しい場合でも、実装の詳細により、アイデンティティと量に関する情報がネットワーク上の悪意のある者に漏洩する可能性があることを示します。

    MoneroまたはZcashノードがピアツーピアネットワークからトランザクションを受信すると、そのトランザクションはノードのウォレットに渡され、トランザクションがウォレットに属しているかどうかを判断します。トランザクションがウォレットに属する場合、ウォレットはトランザクションからデータと金額を復号化するために追加の計算を行う必要があり、ウォレットがこの追加の計算作業を行っている間にノードのピアツーピアアクティビティを一時停止すると、攻撃者は[タイミング攻撃][timing attack]を使用して、どのトランザクションがどのノードに関連付けられているかを発見できます。著者は、これらのタイミング攻撃がリモートで（ロンドンからチューリッヒへのWAN接続を介して）実行可能であり、同様のタイミング攻撃を使用してZcashトランザクションの金額を明らかにすることもできることを実証しています。

    論文の攻撃はビットコインコアには適用されません。ビットコインコア・ウォレットが独自のトランザクションと他のトランザクションで行う計算の違いは最小限であり（高度な暗号化は含まれません）、v0.16以降、ウォレット操作はピアツーピアの振る舞いから非同期に処理されます（[Bitcoin Core #10286][]参照）。ただし、この論文の観察結果は、Bitcoinでシステムを実装する人にとって興味深い一般的な問題と言えるでしょう。つまり、ウォレットまたはアプリケーションの処理がピアツーピアの動作に影響を与えると、情報が漏洩する可能性があります。

関連：Optechニュースレターは、昨年のStanford Blockchain Conferenceの講演の抜粋を[Newsletter#32][news46 sbc]にまとめています。

## Bitcoin Stack Exchangeから選ばれたQ＆A

*[Bitcoin Stack Exchange] [bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・答えについて共有しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [SLIP39とBIP39の関係は？]({{bse}}93413) ユーザーThalis K.は、ニーモニックの生成と決定論的ウォレットシードへの変換の仕様であるBIP39（ビットコイン改善提案）とSLIP39 （Satoshi Labs Improvement Proposal）、ShamirのSecret Sharing Scheme（SSSS）を使用して秘密を部分に分割するスキームを区別して説明しています。

- [<!--how-is-the-bitcoin-difficulty-granularity-encoded-->ビットコインの難易度の粒度はどのようにエンコードされますか？]({{bse}}92990) zndtoshiは、ヘッダーハッシュにゼロを追加すると難易度が指数関数的に増加する場合、マイニングの難易度をどのように細かく調整できるかを疑問に挙げています。Murchは`nBits`、*難易度*と*ターゲット*しきい値の関係、および[詳細な例と図][stack exchange harding target answer]へのリンクについて説明しています。

- [Taprootは、より大きなセキュリティリスクを生み出したり、Quantum脅威に対する将来のプロトコル調整を妨げたりする可能性がありますか？]({{bse}}93047) Pieter Wuilleは、schnorr、taproot、およびそれらのPost Quantum Cryptography（PQC）との関係に関するいくつかの質問に回答しています。彼はさらに、いくつかのゼロ知識証明システムを量子耐性にできる可能性があることを説明しています。

## Releases and release candidates

*Bitcoinインフラストラクチャの新しいリリースおよびリリース候補。新しいリリースへのアップグレードを検討するか、リリース候補のテスト支援をお願いします。*

- [Bitcoin Core 0.19.1][]（リリース候補）

- [LND 0.9.1][]（リリース候補）

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の主な変更点。*

- [Bitcoin Core #13339][]は、ウォレット名を引数としてユーザー提供の`walletnotify`トランザクション通知スクリプトに渡すことができます。以前は、txidのみが`walletnotify`スクリプトに渡されていたため、マルチウォレットモードで実行しているユーザーがインカミング・トランザクションを受信したウォレットを判別することが困難でした。この変更は、[マルチウォレットサポート][multi-wallet support]を強化するための継続的な取り組みの一環です。現在、この変更はWindowsではサポートされていません。

- [Eclair #1325][]は、`SendToRoute`エンドポイントが、消費ノードが受信ノードへのパスを見つけるのに役立つルーティングヒントを受け入れることを許可します。

- [BOLTs #682][]は、ノードが関心を持っているネットワークの識別子（チェーンハッシュ）を含む`networks`フィールドを`init`メッセージに含めることを許可します。これにより、1つのネットワーク（testnetなど）から別のネットワーク上のノード（mainnetなど)につなぐことを防ぎます。

- [BOLTs #596][]は、[BOLT2][]を更新して、LNノードが以前の最大値制限である約0.17BTCを超えるチャネルオープンを受け入れることをアドバタイズできるようにします。これは「wumbo」提案の機能の1つであり、もう1つの機能としてチャネルでより大きな支払いを送信できることが挙げられます。詳細については、[Newsletter#22][news22 wumbo]をご覧ください。

## 謝辞

このニュースレターのStanford Blockchain Conferenceトークサマリーの草案をレビューしてくれたJoachim NeuとTim Roughgardenに感謝します。残りのエラーは、ニュースレター作成者の責任です。

{% include references.md %}
{% include linkers/issues.md issues="1325,886,682,596,13339,10286" %}
[residency]: https://residency.chaincode.com
[residency announcement]: https://medium.com/@ChaincodeLabs/chaincode-summer-residency-2020-e80811834fa8
[residency apply]: https://residency.chaincode.com/#apply
[side-channel txt]: https://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2020/linking-anonymous-transactions/
[side-channel vid]: https://youtu.be/JhZUItnyQ0k?t=7706
[side-channel paper]: https://crypto.stanford.edu/timings/paper.pdf
[news46 sbc]: /en/newsletters/2019/02/05/#notable-talks-from-the-stanford-blockchain-conference
[axiomatic txt]: https://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2020/block-rewards/
[axiomatic vid]: https://youtu.be/BXLcKQ6fLsU?t=8545
[axiomatic paper]: https://arxiv.org/pdf/1909.10645.pdf
[boomerang txt]: https://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2020/boomerang/
[boomerang vid]: https://youtu.be/cNyB-MJdI20?t=6530
[boomerang paper]: https://arxiv.org/pdf/1910.01834.pdf
[sbc]: https://cbr.stanford.edu/sbc20/
[transcripts]: https://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2020/
[day 1]: https://www.youtube.com/watch?v=JhZUItnyQ0k
[day 2]: https://www.youtube.com/watch?v=BXLcKQ6fLsU
[day 3]: https://www.youtube.com/watch?v=cNyB-MJdI20
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[sipa nonce updates]: https://github.com/sipa/bips/pull/198
[lnd 0.9.1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.1-beta.rc1
[release rc section]: #releases-and-release-candidates
[news72 upfront]: /ja/newsletters/2019/11/13/#ln
[jager up-front]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002547.html
[russell dm]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002552.html
[whatsat]: https://github.com/joostjager/whatsat
[news72 offers]: /ja/newsletters/2019/11/13/#ln-bolt
[news83 nonce safety]: /en/newsletters/2020/02/05/#schnorr
[news22 wumbo]: /en/newsletters/2018/11/20/#wumbo
[multi-wallet support]: https://github.com/bitcoin/bitcoin/projects/2#card-31911994
[stack exchange harding target answer]: https://bitcoin.stackexchange.com/questions/23912/how-is-the-target-section-of-a-block-header-calculated/36228#36228
[mechanism design]: https://en.wikipedia.org/wiki/Mechanism_design
[selfish mining]: https://www.cs.cornell.edu/~ie53/publications/btcProcFC.pdf
[pvss]: https://en.wikipedia.org/wiki/Publicly_Verifiable_Secret_Sharing
[adaptor signatures]: https://download.wpsoftware.net/bitcoin/wizardry/mw-slides/2018-05-18-l2/slides.pdf
[ring signatures]: https://en.wikipedia.org/wiki/Ring_signature
[bulletproofs]: https://eprint.iacr.org/2017/1066.pdf
[zk-SNARKs]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[timing attack]: https://en.wikipedia.org/wiki/Timing_attack
[zmn circular]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002555.html
