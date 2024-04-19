---
title: 'Bitcoin Optech Newsletter #190'
permalink: /ja/newsletters/2022/03/09/
name: 2022-03-09-newsletter-ja
slug: 2022-03-09-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、
将来のソフトフォークでBitcoinのScript言語とTapscript言語の表現力をどの程度向上させるべきかという議論の複数の側面と、
Onionメッセージの中継に使用される帯域幅に課金する提案を掲載しています。
また、Bitcoin Core PR Review Clubミーティングの概要や、
新しいソフトウェアリリースおよびRCの発表、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更を含む恒例のセクションも含まれています。

## ニュース

- **Script言語の表現力の制限:** Bitcoin-Devメーリングリストでは、
  Scriptに`OP_TXHASH`や`OP_TX` opcodeを追加する提案（ニュースレター[#185][news185 optxhash]および[#187][news187 optx]参照）から、
  いくつかの議論が始まりました。
  Jeremy Rubinは、（おそらく[OP_CAT][]などの他のopcodeの提案と組み合わせて）この提案により、
  （それらのビットコインやそれとマージされたビットコインを再使用するすべてのトランザクションで永久に満たされる必要のある）
  再帰的な[Covenants][topic covenants]を作成できるかもしれないと[指摘していました][rubin recurse]。
  Bitcoinで再帰的なCovenantsを認めることに懸念があるかどうかが[問われ][harding recurse]、
  最も注目すべき懸念のいくつかを以下に要約しています:

  - *<!--gradual-loss-of-censorship-resistance-->検閲耐性が徐々に失われる:*
    Shinobiは、以前[ニュースレター #157][news157 csfs]で言及した、
    強力な第三者が現在コントロールしているコインのその後の使用をコントロールする再帰的なCovenantsへの懸念を繰り返し[投稿しました][shinobi recurse]。
    例えば、（Bitcoinのコンセンサスルールによって強制する形で）政府が（法律により）政府により後で押収できるコインのみを受け入れるよう要求することができます。

    Shinobiの投稿への[返信][aj reply]は、[1年前の][harding altcoin]議論と同じように、ユーザーが、
    代替となる暗号通貨（アルトコイン）や第三者のコントールという同じ要件を持つサイドチェーンのような構成に切り替えることで、
    検閲抵抗が徐々に失われる可能性があるという[ものでした][darosior reply]。

  - *<!--encouraging-unnecessary-computation-->不要な計算の促進:* 開発者のJames O'Beirneは、
    Bitcoin Scriptや[Tapscript][topic tapscript]言語に多くの表現力が追加しすぎると、
    コインの使用を許可された人が、そのコインの使用を選択したことを証明するために必要な最低限の操作以上を必要とするような
    Scriptの作成が促進されることになると懸念を[表明しています][obeirne reply]。
    どのUTXO（コイン）も、64バイトの[Schnorr署名][topic schnorr signatures]のような、
    使用が許可されたことを示す1つのコンパクトな証明で使用できるのが理想的です。
    Bitcoinは既にコンパクトなマルチシグやLNのようなプロトコルなど、コントラクトの作成を可能にするためのより複雑なScriptが使用可能ですが、
    この機能を悪用して、コントラクトの条件を強制するために必要のない操作をScriptに含めることができます。
    例えば、Bitcoinは過去に、多くのCPUやメモリを必要とする操作を繰り返し実行する特別に細工されたトランザクションから
    サービス拒否攻撃を受ける[危険性][cve-2013-2292]がありました。
    O'Beirneは、表現力を高めることで新しいDoSベクトルが生まれるだけでなく、
    プログラマーが最適化されていないScriptを作成することで必要以上にノードのリソースを消費する結果になることを懸念しています。

  - *<!--introduction-of-turing-completeness-->チューリング完全性の導入:* 開発者ZmnSCPxjは、
    *意図的な*再帰的なCovenantsの作成を可能にするopcodeの追加は、
    再帰的なCovenantsの*偶然の*作成も可能にすると[批判しています][zmn turing]。
    再帰的なCovenantsに支払われたお金は、意図的であろうと偶然であろうと、
    通常のビットコインと完全に代替可能になることは二度とありません。
    ZmnSCPxjはこの懸念を[チューリング完全性][turing completeness]と[停止性問題][halting problem]の文脈で表現しています。

  - *Drivechainの有効化:* チューリング完全性に関する前の議論を発展させ、
    ZmnSCPxjはさらに、Script言語の表現力が向上すれば、
    [BIP300][]で定義されたものと同様の原理で[Drivechain][topic sidechains]の実装も可能になると[主張しています][zmn drivechains]。
    これは複数のBitcoin開発者がユーザーの資金の損失や検閲耐性の低下のいずれかにつながると[主張しています][towns drivechains]。
    Drivechainのルールを適用するフルノードの実行を選択したBitcoinエコノミーが十分でない場合、
    Drivechainのユーザーは資金を失う可能性がありますが、
    エコノミーの大部分がDrivechainのルールの適用を選択した場合は、
    コンセンサスを維持したい他のすべてのユーザーはそのDrivechainのデータをすべて検証し、
    Bitcoinのルールを変更する明示的なソフトフォークの決定がなくてもDrivechainをBitcoinの一部にすることが可能です。

    このスレッドでは幅広い議論が行われ、ビットコインを盗もうとするマイニングハッシュレートの大部分が存在する場合に、
    Drivechainの安全性とLNの安全性を比較する[スピンオフスレッド][drivechains vs ln]が作成されました。

- **Onionメッセージへの支払い:** Olaoluwa Osuntokunは、
  今週Lightning-Devメーリングリストに、
  ノードが[Onionメッセージ][topic onion messages]の送信に使用する帯域幅への支払いをする機能の追加について[投稿しました][osuntokun bandwidth]。
  以前提案されたOnionメッセージプロトコルでは、
  ノードは[HTLC][topic htlc]を使用せずにLNの経路を経由して他のノードにメッセージを送信することができます。
  HTLC上のkeysendスタイルのメッセージに対するOnionメッセージの主な利点は、
  ビットコインを一時的にロックする必要がないため、よりコスト効率がよく柔軟な点です（例えば、
  Onionメッセージはチャネルを共有していないピア間でも送信できます）。
  しかし、Onionメッセージの送信に直接的な金銭コストがかからないことから、
  LN上のトラフィックを無料で中継するために使用され、
  その結果LNノードの運用コストが高くなり、
  多数のノードがOnionメッセージの中継を無効にするインセンティブが生まれることを懸念する開発者もいます。
  これは、[Offer][topic offers]の提案など、ノード間の重要な通信にOnionメッセージを使用する場合に問題になる可能性があります。

  Osuntokunは、ノードが使用したいOnionメッセージの帯域幅を事前に支払えるよう提案しました。
  例えば、Aliceが10 kBのデータをBobとCarolを経由してZedにルーティングする場合、
  Aliceはまず[AMP][topic amp]を使用して、BobとCarolそれぞれのノードが配信するメッセージ中継レートで少なくとも10 kB分の帯域幅の支払いを行います。
  BobとCarolに支払う際、Aliceはそれぞれ一意のセッションIDを登録し、自分用に中継を依頼する暗号化メッセージにそのIDを含めます。
  Aliceが支払った金額が、彼女のメッセージが使用する帯域幅に対して十分であれば、
  BobとCarolはZedへのメッセージの中継に参加します。

  Rusty Russellは、いくつかの批判を[返信しました][russell reply]。特に:

  - *HTLCは現在既に無料になっている:* Onionメッセージの中継が無料という懸念に対する主な反論は、
    LN上のトラフィックはHTLCを使用して基本的に無料で[^htlcs-essentially-free]中継することが既に可能であるということです。
    ただし、これが永続的に当てはまるかどうかは不明です。
    [チャネルジャミング攻撃][topic channel jamming attacks]を解決するための多くの提案は、
    現在データを自由にルーティングするのに使用可能な、失敗したHTLCに対する課金を提案しています。

  - *セッションIDによるプライバシーの低下:* 前述の例では、
    AliceがBobとCarolに登録したセッションIDにより、同じユーザーからのメッセージを知ることができます。
    セッションIDが無ければ、異なるメッセージがすべて同じユーザーから送信されたのか、
    異なるユーザーが同じ経路の一部を使って送信したのか分からないでしょう。
    Russellは、Onionメッセージの検討の際にブラインドトークンを検討したものの、
    「すぐに複雑になってしまう」ことを懸念していました。

  Russellは、代わりにノードが転送するOnoinメッセージの数を単純にレート制限することを提案しました（ピアのカテゴリ毎に異なる制限を設けます）。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Open p2p connections to nodes that listen on non-default ports][reviews 23542]は、
Vasil DimovによるPRで、アウトバウンドピアの選択における8333ポートの優先的な取り扱いを取り除くものです。
参加者は、Bitcoin Coreの自動接続動作や、デフォルトポートのないネットワークの利点、特定のポートを避ける根拠について議論しました。

{% include functions/details-list.md
  q0="<!--what-are-the-historical-reasons-for-the-preferential-treatment-of-the-default-port-8333-->デフォルトポート8333が優先的に取り扱われている歴史的な理由は何ですか？"
  a0="この動作は昔からありましたが、Satoshiの動機は定かではありません。
  よく聞くのは、そのアドレスをゴシップすることで、Bitcoinネットワークを利用したサービスへのDoSを防ぐためというものですが、
  これは実際の歴史的な理由ではありません。もう1つの噂は、
  デフォルトポートにより、攻撃者がノードのIPアドレステーブルを支配するのを防ぎ、
  単一のIPアドレスで多くのポートを使用するP2P接続（現在は[エクリプス攻撃][topic eclipse attacks]と呼びます）を防ぐのに役立つというものです。"
  a0link="https://bitcoincore.reviews/23542#l-43"

  q1="<!--what-are-the-benefits-of-removing-the-preferential-treatment-of-port-8333-with-this-pr-->このPRで8333ポートの優先的な取り扱いをやめるメリットは何ですか？"
  a1="当初、潜在的なピアのIPアドレスをフィルタリングし保存する方法は、
  現在ほど洗練されていませんでした。現在では、アドレスのネットグループやAS、送信元ピアなどによって、
  保存するIPアドレスの数を制限しています。また、通常、処理と中継を行うアドレスの量も制限しています。
  アドレスマネージャー（addrman）とアドレスの中継に対するこれらの変更を考えると、
  優遇措置はエクリプス攻撃やDoS攻撃の防止にほとんど影響を及ぼさないことになります。
  さらに、デフォルトポートの優先は、非デフォルトポートをリッスンしているノードへの接続がほぼ行われないことを意味します。
  また、ローカルネットワークの管理者が、8333ポートを探すだけで、Bitcoinネットワークのトラフィックを簡単に検出できるプライバシーの漏洩でもあります。
  政府がBitcoinを禁止したい場合、ISPに単一のポートへのトラフィックの記録またはブロックを指示する方が、
  すべての接続で送受信されているデータを監視してBitcoinのトラフィックを識別しようとするのよりはるかに簡単です。"
  a1link="https://bitcoincore.reviews/23542#l-72"

  q2="<!--before-this-change-automatic-connections-to-peers-listening-on-non-default-ports-were-discouraged-but-not-impossible-under-what-circumstances-would-a-node-still-connect-to-such-a-peer-->この変更以前は、非デフォルトポートでリッスンしているピアへの自動接続は推奨されないものの不可能ではありません。
  それでもノードがそのようなピアに接続するのはどのような状況ですか？"
  a2="自動接続ロジックでは、ノードはアドレスマネージャーからランダムに選択されたアドレスに接続しようとします。
  50回試行しても接続が成功しなかった場合は、非デフォルトアドレスの検討が開始されます。
  ある参加者は、機能テストのノードもデフォルトポートを使用していないと述べましたが、
  これらのノードは自動アウトバウンド接続ではなく、手動接続で接続されていると指摘されました。"
  a2link="https://bitcoincore.reviews/23542#l-123"

  q3="<!--after-this-pr-the-default-port-still-plays-a-role-in-bitcoin-core-where-is-it-still-used-->このPRの後も、Bitcoin Coreではまだデフォルトポートが利用されているようですが、どこで使われているのですか？"
  a3="ポートが指定されていない場合にデフォルトが使用されます。これは特にDNSシードと関連しており、
  新しいノードがアドレスマネージャーを立ち上げるために使用します。
  DNSは、サービスのアドレスとポートを提供するのではなく、ドメイン名とIPアドレスを解決するために設計されているため、
  デフォルトポートの概念を完全に削除するには代替手段を見つける必要があります。"
  a3link="https://bitcoincore.reviews/23542#l-137"

  q4="<!--what-is-the-reason-for-allowing-callers-to-pass-salts-to-cservicehash-and-then-initializing-it-with-cservicehash-0-0-in-commit-d0abce9-salt-commit-->コミット[d0abce9][salt commit]で、呼び出し元がCServiceHashにsaltを渡し、CServiceHash(0, 0)で初期化できるようにした理由は何ですか？"
  a4="ノードは24時間毎に自身のアドレスをアナウンスし、各ノードはネットワーク上のノードが新しいピアを見つけるのを支援するためにこのアドレスをゴシップします。
  このコードでは、IPアドレスのハッシュと現在時刻を使って、最近受信したアドレスを転送するピアをランダムに1つまたは2つ選びます。
  しかし、単にアドレスを複数回送信することで、アドレスの伝播を高めることができるようにすることはしたくありません。
  そこで、同じsalt (0, 0)を使用しタイムスタンプの粒度を1日に統一しています。"
  a4link="https://bitcoincore.reviews/23542#l-197"

%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LDK 0.0.105][]は、ファントムノード支払い（[ニュースレター #188][news188 phantom]参照）のサポート、
  確率的な支払い経路探索の改善（[ニュースレター #186][news186 pp]参照）に加え、
  その他の機能やバグ修正（[2つの潜在的なDoS脆弱性][rl dos]を含む）を提供しています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23542][]は、Bitcoinのデフォルトポート（mainnetは8333）でのみピアに接続するBitcoin Coreの設定を削除します。
  代わりに、Bitcoin Coreは、他のサービスによって使用されることが分かっている数十のポートを除いて、
  任意のポートのピアへの接続を可能にします。8333ポートは、
  まだBitcoin Coreがローカルにバインドするデフォルトポートなので、
  デフォルト値をオーバーライドしたノードのみが他のポートでの受け入れを配信することになります。
  この変更に関する追加の情報は、このニュースレターで前述した*Bitcoin Core PR Review Club*の概要で見つけることができます。

- [BDK #537][]は、ウォレットアドレスのキャッシュを公開メソッドにリファクタリングしています。
  これまで、ウォレットの内部データベースにアドレスがロードされキャッシュされていることを確認する唯一の方法は、
  内部関数を介したものでした。つまり、オフラインのウォレットには、
  データベースにアドレスがロードされていることを確認する仕組みがありませんでした。
  このパッチにより、オフラインのウォレットをマルチシグの署名者として使用したり、
  お釣り用のアドレスを検証したりするなどのユースケースが可能になります。
  これに関連して、[BDK #522][]では内部アドレス用のAPIを追加しています。
  これは、アプリケーションがアウトプットをいくつかの小さなアウトプットに分割するトランザクションを作成するのに役立ちます。

## 脚注

[^htlcs-essentially-free]:
    ユーザーAliceがルーティングノードであるBobとCarolを介してユーザーZedにHTLCベースのkeysendメッセージを中継する場合、
    Aliceは既知のプリイメージがないハッシュでHTLCを構築し、
    それが失敗することを保証でき、そのため、BobもCarolもお金を得ることはありません。
    Aliceがそのようなメッセージを送信するために負担する唯一のコストは、
    （彼女が作成した場合）チャネルを作成するためのコストと、
    （彼女がそのコストを支払う責任がある場合）後でそれを閉じるためのコスト、
    さらに攻撃者が彼女のLNのホットウォレットの秘密鍵、もしくは彼女のLNチャネルを危険に晒す可能性のあるその他のデータを盗むリスクです。
    長期間有効なチャネルを持つ安全でバグのないノードでは、
    これらのコストは本質的にゼロであるべきで、したがってHTLCベースのkeysendメッセージは現在無料であると考えることができます。

{% include references.md %}
{% include linkers/issues.md v=1 issues="23542,522,537" %}
[ldk 0.0.105]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.105#security
[news185 optxhash]: /ja/newsletters/2022/02/02/#ctv-apo
[news187 optx]: /ja/newsletters/2022/02/16/#op-txhash
[rubin recurse]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019872.html
[op_cat]: /en/topics/op_checksigfromstack/#relationship-to-op_cat
[shinobi recurse]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019891.html
[news157 csfs]: /ja/newsletters/2021/07/14/#op-checksigfromstack
[darosior reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019892.html
[aj reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019923.html
[harding altcoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019203.html
[obeirne reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019890.html
[cve-2013-2292]: /en/topics/cve/#CVE-2013-2292
[zmn turing]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019928.html
[zmn drivechains]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019976.html
[turing completeness]: https://en.wikipedia.org/wiki/Turing_completeness
[halting problem]: https://en.wikipedia.org/wiki/Halting_problem
[towns drivechains]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019984.html
[drivechains vs ln]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019991.html
[osuntokun bandwidth]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003498.html
[russell reply]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003499.html
[harding recurse]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019885.html
[rl dos]: https://github.com/lightningdevkit/rust-lightning/blob/main/CHANGELOG.md#security
[news188 phantom]: /ja/newsletters/2022/02/23/#ldk-1199
[news186 pp]: /ja/newsletters/2022/02/09/#ldk-1227
[salt commit]: https://github.com/bitcoin-core-review-club/bitcoin/commit/d0abce9a50dd4f507e3a30348eabffb7552471d5
[reviews 23542]: https://bitcoincore.reviews/23542
