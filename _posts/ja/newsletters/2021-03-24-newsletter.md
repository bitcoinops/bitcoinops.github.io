---
title: 'Bitcoin Optech Newsletter #141'
permalink: /ja/newsletters/2021/03/24/
name: 2021-03-24-newsletter-ja
slug: 2021-03-24-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinの既存のコンセンサスルールの下で署名を委譲する手法、
Bitcoinの量子暗号への耐性に対するTaprootの影響についての議論の要約、
Taprootのアクティベートを支援するための一連のウィークリーミーティングの公表について掲載しています。
また、サービスやクライアントソフトウェアの注目すべき変更点や、新しいリリースとリリース候補、
人気のあるBitcoinのインフラストラクチャソフトウェアの注目すべき変更点の解説などの通常のセクションも含まれています。

## ニュース

- **<!--signing-delegation-under-existing-consensus-rules-->既存のコンセンサスルール下での署名の委譲:**
  アリスが、すぐにオンチェーン・トランザクションを作成したり、ボブに自身の秘密鍵を渡したりすることなく、
  ボブにアリスのUTXOの１つを使う能力を与えたいと考えているとします。
  これは*デリゲーション*と呼ばれ、何年も前から議論されており、
  最近では[Graftrootの提案][graftroot proposal]の一部として議論されてきました。
  先週、Jeremy RubinがBitcoin-Devメーリングリストに、
  現在のBitcoinを使ってデリゲーションを実現する技術の説明を[投稿しました][rubin delegation]。

  アリスが`UTXO_A`を持ち、ボブが`UTXO_B`を持っているとします。
  アリスは、`UTXO_A`と`UTXO_B`を両方使用する部分的に署名されたトランザクションを作成します。
  アリスは自分のUTXOにsighashフラグ[SIGHASH_NONE][]を使用して署名し、
  署名がトランザクションのどのアウトプットにもコミットしないようにします。
  これにより、トランザクションのもう一方のインプットの所有者であるボブは、
  アウトプットの選択を一方的に制御することができ、
  通常の`SIGHASH_ALL`フラグを持つ彼の署名を使用してアウトプットにコミットし、
  他の誰もトランザクションを変更できないようにします。
  この２つのインプットと`SIGHASH_NONE`トリックを使うことで、
  アリスは自分のUTXOに署名する能力をボブに委譲することができます。

  この手法は主に理論的な関心事であると思われます。他にも、
  Graftrootや[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]、
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]など、
  いくつかの点で優れた委譲技術が提案されていますが、
  このような実験を行いたい人には、この手法だけが現在mainnetで利用可能です。

- **<!--discussion-of-quantum-computer-attacks-on-->Taprootに対する量子コンピューターの攻撃についての議論:**
  オリジナルのBitcoinソフトウェアでは、ビットコインを受け取るのに２つの方法が用意されていました:

  - *Pay-to-Public-Key (P2PK)* は、ビットコインを公開鍵で受け取り、そのコインを署名で使用できるようにするという、
    [オリジナルのBitcoinの論文][original Bitcoin paper]に記載されている単純明快な方法を実装していました。
    Bitcoinのソフトウェアは、公開鍵のマテリアルをソフトウェアですべて処理できる場合、
    デフォルトでこれを使用していました。

  - *Pay-to-Public-Key-Hash (P2PKH)* は、
    使用される公開鍵をコミットしたハッシュダイジェストでビットコインを受け取るという、
    間接的なレイヤーを追加したものです。コインを使用するには、公開鍵を署名と一緒に公開する必要があり、
    ハッシュダイジェストにさかれる20バイトがオーバーヘッドコストになります。
    この方法は、コピー＆ペーストできるアドレスなど、
    支払い情報を人が扱う必要がある場合にデフォルトで使用されてきました。

  Nakamotoは、なぜこの２つの方法を実装したのか説明していませんが、
  Bitcoinアドレスを小さくして通信しやすくするために、
  ハッシュの間接参照を追加したのではないかと言われています。
  当初のBitcoinの公開鍵の実装は65バイトでしたが、アドレスのハッシュは20バイトしかありません。

  それから10年、さまざまな開発が行われてきました。
  特定のマルチシグプロトコルを[デフォルトでシンプルかつ安全なものにするため][bech32 address security]
  マルチパーティプロトコル用のスクリプトでは、32バイトのコミットメントを使用すべきだと判断されました。
  Bitcoinの開発者は、公開鍵を33バイトに圧縮することができる以前から知られていた技術を知り、
  その後それを32バイトに[最適化する][news48 oddness]方法を説明しました。
  最後に、[Taprootの主なイノベーション][news27 taproot]は、
  32バイトの公開鍵が32バイトのハッシュと同様の[セキュリティ][news87 fournier proof]でスクリプトにコミットできることを示しました。
  これはつまり、ハッシュと公開鍵のどちらを使っても通信に必要なアドレスデータの量は変わらないということを意味します。
  普遍的なアドレス形式が必要な場合、どちらを使っても32バイトです。
  しかし、公開鍵を直接使用することで、ハッシュの間接参照に起因する余分な帯域幅やストレージをなくすことができます。
  もし、すべての支払いが32バイトのハッシュではなく公開鍵になったとしたら、
  年間で約13GBのブロックチェーンスペースを節約できることになります。
  Taprootの[BIP341][]仕様では、P2PKHスタイルのハッシュの代わりにP2PKスタイルの公開鍵への支払いを受け付ける理由として、
  スペースの節約を挙げています。

  {:#p2pkh-hides-keys}
  しかし、P2PKHのハッシュの間接参照には１つの利点があります:
  それは、支払いを承認するのに必要になるまで公開鍵を一般の目から隠すことができることです。
  つまり、公開鍵のセキュリティを侵害する能力を持つ敵対者は、
  トランザクションがブロードキャストされるまで、その能力を使い始めることができず、
  トランザクションが一定の深さまで承認されると、
  その鍵で管理されている資金を盗む能力を失ってしまう可能性があります。
  これにより攻撃に使える時間が制限され、ゆっくりとした攻撃ではうまくいかない可能性があることを意味します。
  これについては、P2PKスタイルで直接公開鍵を使用するTaprootの選択の文脈で前から長く議論されてきましたが
  （[1][tap qc1]、[2][tap qc2]およびニュースレター [#70][news70 qc]と[#86][news86 qc]参照）、
  今週、Bitcoin-Devメーリングリストで、Bitcoinスタイルの公開鍵を攻撃できるほどの強力な量子コンピューターが
  "早ければ10年後"に登場するのではないかという懸念からTaprootに反対する[メール][friedenbach post]が公開されたことで、
  [再び議論][dashjr quantum]の対象になりました。

  メーリングリストでの議論では、誰もTaprootに反対だとは言いませんでしたが、
  議論の前提を吟味し、代替案を議論し、その代替案が意味するトレードオフを評価しました。
  それらの会話の抜粋を以下に要約します:

  - *<!--hashes-not-currently-doing-a-good-job-at-qc-resistance-->ハッシュは現在QC耐性としてうまく機能しない:*
    [2019年の調査][wuille stealable]によると、強力なQCを持ちBitcoinのブロックチェーンのコピー以外何も持たない攻撃者は、
    全ビットコインの1/3を盗むことができるようです。そのほとんどは、
    ユーザーが[アドレスを再利用][topic output linking]した結果であり、
    これは推奨されていない行為ですが、すぐにはなくならないと考えられています。

    さらに、議論の参加者からは、個々の公開鍵や[BIP32][]拡張公開鍵（xpub）を第三者と共有している人も、
    その公開鍵が漏洩した場合、強力なQCのリスクにさらされるという指摘がありました。
    これには、ハードウェアウォレットやLNのペイメントチャネルに保管されているほとんどのビットコインが含まれる可能性があります。
    つまり、P2PKHスタイルのハッシュされた公開鍵をほぼ一般的に使用しているにもかかわらず、
    公開データやサードパーティのデータにアクセスできる強力なQCによって、
    ほぼすべてのビットコインが盗まれる可能性があるということです。
    つまり、TaprootでP2PKスタイルのハッシュしていない公開鍵を使用するという選択は、
    Bitcoinの現在のセキュリティモデルを大きく変えるものではないということです。

  - *<!--taproot-improvement-in-post-qc-recovery-at-no-onchain-cost-->オンチェーンコストをかけずにポストQCのリカバリーを向上させるTaproot:*
    ビットコイナーは、強力なQCが登場した、もしくは登場することを知った場合、
    Taprootの（単一の署名のみを必要とするタイプの）key-pathの使用を拒否することができます。
    しかし、Taprootアドレスの作成時にそのアドレスに受信したビットコインをscript-pathで使用することもできるよう準備することもできます。
    この場合、Taprootアドレスはユーザーが使用したい[Tapscript][topic tapscript]のハッシュにコミットします。
    このハッシュコミットメントは、
    QCに対して安全な新しい暗号アルゴリズムに移行するための[スキーム][ruffing scheme]の一部として使用することができます。
    また、QCが脅威となる前にそのようなアルゴリズムがBitcoin用に標準化されていれば、
    ビットコインの所有者はすぐに新しいスキームに移行することができます。
    この方法が有効なのは、個々のユーザーがバックアップ用のTapscriptの使用パスを作成し、
    そのバックアップパスに含まれる公開鍵（BIP32のxpubを含む）を共有していない場合、
    そして強力なQCがBitcoinに大きなダメージを与える前に判明した場合に限られます。

  - *<!--is-the-attack-realistic-->攻撃は現実的なのか？*
    ある回答者は、10年後までに高速なQCの[実現][fournier progress]は"予測される進捗率の中では非常に楽観的な部類に入る"と考えています。
    別の回答者は、1台の低速なQCを並行して機能できるQCファームに変換し、僅かな時間で結果を達成することは
    "かなり単純なエンジニアリングの課題"であり、P2PKHスタイルのハッシュの間接参照からの保護は無意味であると[述べています][towns parallelization]。
    3人め回答者は、高速なQCで成果を挙げている人だけが使用可能なBitcoinアドレスを構築し、
    ユーザーが自主的にそのアドレスにビットコインを寄付することで、
    インセンティブ付きの早期警告システムを構築することを[提案しました][harding bounty]。

  - *<!--we-could-add-a-hash-style-address-after-taproot-is-activated-->Taprootアクティベート後にハッシュスタイルのアドレスを追加することもできる:*
    かなりの数のユーザーが、強力なQCの出現を本当に驚異に感じているのであれば、
    その後のソフトフォークでハッシュを使用するP2PKHスタイルのTaprootアドレスを[追加する][dashjr quantum]ことができます。
    しかし、これには複数の回答者が反対する結果となりました:

    - 混乱が生じる

    - より多くのブロックスペースを使用する

    - *<!--reduces-->* 直接でも[リング署名のメンバーシップ証明][nick ring]や[Provisions][]などのプロトコルを使用した場合でも、
      Taprootの匿名セットのサイズが[小さくなる][poelstra anon]

  - *<!--bandwidth-storage-costs-versus-cpu-costs-->帯域幅/ストレージコストとCPUコストの比較:*
    *キーリカバリー*と呼ばれる手法では、署名とその署名をしたトランザクションデータから公開鍵を導出することで、
    ハッシュの間接参照による余分な32バイトのストレージオーバーヘッドをなくすることが[できます][rubin recovery]。
    これも、反対されました。キーリカバリーには[大量のCPU][corallo recovery overhead]が必要で、
    ノードの動作が遅くなる上、履歴ブロックの検証を最大3倍高速化できるSchnorrのバッチ検証も使えなくなります。
    また、匿名のメンバーシップ証明やそれに関連する手法の開発が[困難になり][poelstra slowdowns]、CPUに負担がかかります。
    また、[特許][US7215773B1]の問題も[あるかもしれません][poelstra patent story]。

  この記事を書いている時点では、メーリングリストでの議論は終了しているようですが、
  Taprootに対するコミュニティの支持は明らかに失われていません。
  研究者や企業が量子コンピューティングの技術を向上させていくなかで、
  Bitcoinの安全性を保つための方法が今後も議論されることを期待しています。

- **<!--weekly-taproot-activation-meetings-->Taprootアクティベーションミーティングを毎週開催:**
  [Taproot][topic taproot]のアクティベーションに関する詳細を議論するための10回のミーティングが、
  毎週火曜の19:00 UTCにIRCの[##taproot-activation][]チャンネルで予定され、
  最初の[ミーティング][activation meeting log]が昨日（3月23日）行われました。

## サービスとクライアントソフトウェアの変更点

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **<!--okcoin-launches-lightning-deposits-and-withdrawals-->OKCoinがLightningの入出金を開始:**
  [ブログ記事][okcoin lightning blog]では、OKCoinのLightning入出金サポートの概要を紹介しています。
  また、それに伴い、入出金の最低限度額を0.001から0.000001 BTCに引き下げました。
  現時点では、LNを使って取引する場合、0.05 BTCがOKCoinの上限です。

- **<!--bitmex-announces-bech32-support-->BitMEXがbech32のサポートを発表:**
  BitMEXは、[ブログ記事][bitmex bech32 blog]の中で、[bech32][topic bech32]による入金サポートの立ち上げ計画を詳しく説明しました。
  BitMEXは[以前][news77 bitmex bech32 send]、bech32の引き出し（送金）サポートを展開していました。

- **<!--specter-v1-2-0-released-->Specter v1.2.0リリース:**
  [Specter v1.2.0][specter v1.2.0] には、
  Bitcoin Coreの[Descriptor Wallet][topic descriptors]とコインコントロール機能のサポートが含まれています。

- **<!--breez-streams-audio-for-lightning-payments-->BreezがオーディオにLightning支払いをストリーム:**
  Breezウォレットには[オーディオプレーヤーが統合されており][breez podcast blog]、
  [keysend][topic spontaneous payments]と組み合わせることで、
  ユーザーはポッドキャストを聞きながら作者への支払いをストリーミングしたり、一度きりのチップを送信したりできます。

- **<!--key-manager-dux-reserve-announced-->キーマネージャーDux Reserveの発表:**
  Thibaud Maréchalは、MacOS、WindowsおよびLinuxに対応し、
  LedgerやColdcard、Trezorといったハードウェアウォレットをサポートする
  オープンソースのデスクトップキーマネージャーDux Reserveのベータ版を[発表しました][dux reserve tweet]。

- **<!--coldcard-now-using-libsecp256k1-->Coldcardがlibsecp256k1を使用するようになりました:**
  Coldcardの[バージョン 4.0.0][coldcard blog 4.0.0]では、その他の機能として、
  暗号処理にBitcoin Coreの[libsecp256k1][]ライブラリを使用するようになりました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [C-Lightning 0.10.0-rc1][C-Lightning 0.10.0]は、
  このLNノードソフトウェアの次のメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #20861][]では、[BIP350][] (v1以上のwitnessアドレス用のBech32mフォーマット)
  のサポートが実装されています。
  Bech32mはバージョン1〜16のネイティブSegwitアウトプットのアドレスフォーマットとしてBech32([BIP173][])に取って代わります。
  バージョン0のネイティブSegwitアウトプット(P2WPKHおよびP2WSH)は、引き続きBech32を使用します。
  このPRによりBitcoin Coreのユーザーは、ネットワーク上でTaprootアウトプット([BIP341][])が定義されると、
  Pay to Taproot (P2TR)アドレスに支払いを送信できるようになります。
  この変更はmainnetのシステムに影響を与えることはありませんが、以前提案されたように、
  Bech32でエンコードされたアドレスを使ってTaprootが既に有効になっているsignetのようなテスト環境で
  アドレスの非互換性の問題を引き起こす可能性があります。
  Bech32mのサポートはBitcoin Core 0.19、0.20、0.21にもバックポートされます。

- [Bitcoin Core #21141][]は、ロードされたウォレットに影響を与えるトランザクションが発生するたびに
  ユーザー指定のコマンドを呼び出す`-walletnotify`の設定を更新しました。
  コマンドに渡すことができる引数に、トランザクションが含まれるブロックのハッシュを表す`%b`と、
  ブロックの高さを表す`%h`という2つのプレースホルダーが追加されました。
  どちらも未承認のトランザクションには定義された値を設定します。

- [C-Lightning #4428][]では、`fundchannel_complete`RPCによるtxidの受け入れを非推奨にし、
  代わりに[PSBT][topic psbt]の受け渡しを要求します。
  PSBTにファンディング・アウトプットが含まれているかどうかをチェックすることができ、
  誤ったデータを渡したユーザーが資金を回収できなくなるという[問題][c-lightning #4416]を解消します。

- [C-Lightning #4421][]では、
  [先週のニュースレター][news140 recovery]で紹介したファンディング・トランザクションのリカバリー手順を実装しています。
  （RBFを使用するなど）誤って資金提供トランザクションが変更されたチャネルに資金提供したものの、
  まだそのチャネルを使用していないユーザーは、トランザクション・アウトプットを`lightning-close`コマンドに提供し、
  `shutdown_wrong_funding`機能をサポートするピアとリカバリーを交渉できるようになりました。

- [LND #5068][]では、LNDが処理するネットワークのゴシップ情報の量を制限するための新しい設定オプションが多数追加されました。
  これはリソースが限定されているシステムで役立ちます。

- [Libsecp256k1 #831][]は、署名検証を15%高速化するアルゴリズムを実装しました。
  また、サイドチャネル攻撃への耐性を最大化する定数時間アルゴリズムを使用しながら、
  署名生成にかかる時間を25%削減することができます。さらにLibsecp256k1が他のライブラリに依存していた部分を削除しました。
  この最適化についての詳細は[ニュースレター #136][news136 safegcd]を参照してください。

- [BIPs #1059][]は、以前メーリングリストで議論されたとおり（[ニュースレター #128][news128 psbtv2]参照）、
  PSBTバージョン2を定義する[BIP370][]を追加しました。

{% include references.md %}
{% include linkers/issues.md issues="20861,21141,4428,4416,4421,1059,5064,5068,831" %}
[c-lightning 0.10.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.0rc1
[news136 safegcd]: /ja/newsletters/2021/02/17/#faster-signature-operations
[graftroot proposal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[original bitcoin paper]: https://bitcoin.org/bitcoin.pdf
[bech32 address security]: /en/bech32-sending-support/#address-security
[news48 oddness]: /en/newsletters/2019/05/29/#move-the-oddness-byte
[news27 taproot]: /en/newsletters/2018/12/28/#taproot
[news87 fournier proof]: /ja/newsletters/2020/03/04/#taproot
[dashjr quantum]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018641.html
[friedenbach post]: https://freicoin.substack.com/p/why-im-against-taproot
[wuille stealable]: https://twitter.com/pwuille/status/1108097835365339136
[ruffing scheme]: https://gist.github.com/harding/bfd094ab488fd3932df59452e5ec753f
[fournier progress]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018658.html
[harding bounty]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018648.html
[provisions]: https://eprint.iacr.org/2015/1008
[nick ring]: https://twitter.com/n1ckler/status/1334240709814136833
[poelstra anon]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018667.html
[rubin recovery]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018643.html
[corallo recovery overhead]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018644.html
[towns parallelization]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018649.html
[poelstra slowdowns]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018667.html
[poelstra patent story]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018646.html
[##taproot-activation]: https://webchat.freenode.net/##taproot-activation
[activation meeting log]: http://gnusha.org/taproot-activation/2021-03-23.log
[news128 psbtv2]: /en/newsletters/2020/12/16/#new-psbt-version-proposed
[news70 qc]: /ja/newsletters/2019/10/30/#hashing-quantum-resistance
[news86 qc]: /ja/newsletters/2020/02/26/#taproot-quantum
[tap qc1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015620.html
[tap qc2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016556.html
[rubin delegation]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018615.html
[sighash_none]: https://btcinformation.org/en/developer-guide#term-sighash-none
[US7215773B1]: https://patents.google.com/patent/US7215773B1/en
[news140 recovery]: /ja/newsletters/2021/03/17/#rescuing-lost-ln-funding-transactions-ln
[okcoin lightning blog]: https://blog.okcoin.com/2021/03/04/how-to-use-bitcoin-lightning-network/
[dux reserve tweet]: https://twitter.com/thibm_/status/1369331407441510405
[bitmex bech32 blog]: https://blog.bitmex.com/introducing-bech32-deposits-on-bitmex-to-deepen-bitcoin-integration-lower-fees/
[news77 bitmex bech32 send]: /ja/newsletters/2019/12/18/#bitmex-bech32
[specter v1.2.0]: https://github.com/cryptoadvance/specter-desktop/releases/tag/v1.2.0
[breez podcast blog]: https://medium.com/breez-technology/podcasts-on-breez-streaming-sats-for-streaming-ideas-d9361ae8a627
[coldcard blog 4.0.0]: https://blog.coinkite.com/version-4.0.0-released/
