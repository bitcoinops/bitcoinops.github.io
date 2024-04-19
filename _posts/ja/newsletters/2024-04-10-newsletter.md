---
title: 'Bitcoin Optech Newsletter #297'
permalink: /ja/newsletters/2024/04/10/
name: 2024-04-10-newsletter-ja
slug: 2024-04-10-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、コントラクトプロトコルを実験するための新しいドメイン固有言語（DSL）の発表と、
BIPエディターの責任の変更に関する議論の要約、testnetのリセットと変更の提案を掲載しています。
また、Bitcoin Core PR Review Clubの概要や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、恒例のセクションも含まれています。

## ニュース

- **コントラクトを実験するためのDSL:** Kulpreet Singhは、
  Bitcoin用に開発中のドメイン固有言語（DSL）についてDelving Bitcoinに[投稿しました][singh dsl]。
  この言語では、コントラクトプロトコルの一部として実行されるべき操作を簡単に指定できます。
  これにより、コントラクトが期待通りに動作することを確認するためにテスト環境で素早く実行することが容易になり、
  コントラクトの新しいアイディアを迅速に反復できるようになり、
  その後の本格的なソフトウェアを開発するためのベースラインを提供することができます。

  Robin Linusは、高レベル言語でコントラクトプロトコルを記述し、
  そのプロトコルを実行するために必要な操作と低レベルコードにコンパイルする、
  やや類似したプロジェクトのリンクを[返信しました][linus dsl]。
  この取り組みは、[BitVM][topic acc]を強化する一環として行われています。

- **BIP2の更新:** Tim Ruffingは、
  新しいBIPの追加や既存のBIPの更新のための現在のプロセスを規定している[BIP2][]の更新について、
  Bitcoin-Devメーリングリストに[投稿しました][ruffing bip2]。
  Ruffingらが言及した現在のプロセスのいくつかの問題点は以下のとおりです:

  - *<!--editorial-evaluation-and-discretion-->エディターの評価と裁量:*
    新しいBIPが高品質でBitcoinにフォーカスしたものであることを保証するために
    BIPエディターはどの程度の労力を費やす必要がありますか？それとは別に、
    新しいBIPを拒否できる裁量をどの程度持つべきですか？Ruffingと他の何人かは、
    組織的な不正行為（大量のスパムなど）を防ぐためだけにBIPエディターに依存し、
    エディターの要件と権限を最小限にすることが望ましいと述べています。
    もちろんBIPエディターは、他のコミュニティメンバーと同様に、
    興味深いと思ったBIPの提案について自発的に改善を提案することができます。

  - *<!--licensing-->ライセンス:* BIPに許可されているライセンスは、
    ソフトウェア用に設計されており、文書化には意味がない可能性があります。

  - *<!--comments-->コメント:* [BIP1][]からの変更点として、
    BIP2では各BIPに関するコミュニティのフィードバックの場を提供しようとしました。
    これは広く使用されておらず、その結果は議論を呼んでいます。

  BIP2を更新するという考えは、この記事の執筆時点ではまだ議論されていました。

  関連する別の議論として、[先週のニュースレター][news296 editors]で言及された
  新しいBIPエディターの推薦と支持が４月１９日（金）UTCの終わりまで[延長されました][erhardt editors]。
  新しいエディターが次の月曜日の終わりまでにマージ権限を受け取ることが期待されます。

- **testnetのリセットと変更に関する議論:** Jameson Loppは、
  現在公開されているBitcoinのtestnet（testnet3）の問題についてBitcoin-Devメーリングリストに[投稿し][lopp testnet]、
  別の特殊ケースのコンセンサスルールを使用してtestnetを再起動することを提案しました。

  testnetの以前のバージョンでは、一部の人がtestnetのコインに経済的価値を割り当て始めた結果、
  実際のテストを実行したい人が無料でコインを入手することが難しくなったため、再起動しなければなりませんでした。
  Loppは、同じことが再び起こっているという証拠を提供し、
  testnetのカスタマイズされた難易度調整アルゴリズムの悪用による
  ブロックフラッディングのよく知られている問題についても説明しました。
  複数の人が、この問題やその他の問題に対処するためにtestnetに変更を加える可能性について議論しましたが、
  少なくとも１人の回答者は、興味深いテストになるため、問題を継続させることを[望みました][kim testnet]。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Implement 64 bit arithmetic op codes in the Script interpreter][review
club 29221]は、Chris Stewart (GitHubではChristewart)によるPRで、
Bitcoin Scriptで現在許可されている（32ビット）よりも大きな（64ビット）オペランドに対して
ユーザーが算術演算を実行できるようにする新しいopcodeを導入するものです。

この変更は、トランザクションのイントロスペクションを可能にする[OP_TLUV][ml OP_TLUV]のような
既存のソフトフォークの提案と組み合わせることで、（32ビット整数を簡単にオーバーフローさせる可能性がある）
トランザクションのsatoshi単位のアウトプットの値に基づいてスクリプトロジックを構築できるようになります。

既存のopcodeをアップグレードするか、新しいopcode（`OP_ADD64`など）を導入するかなど、
このアプローチに関する議論はまだ進行中です。

詳細については、[BIP][bip 64bit arithmetic]（WIP）および
Delving Bitcoinフォーラムの[議論][delving 64bit arithmetic]をご覧ください。

{% include functions/details-list.md

  q0="`CScriptNum`の`nMaxNumSize`パラメーターは何をするものですか？"
  a0="これは、評価される`CScriptNum`スタック要素の最大サイズ（バイト単位）を表します。
  デフォルトでは4バイトに設定されています。"
  a0link="https://bitcoincore.reviews/29221#l-34"

  q1="5バイトの数値入力を受け入れる2つのopcodeはどれですか？"
  a1="`OP_CHECKSEQUENCEVERIFY`と`OP_CHECKLOCKTIMEVERIFY`は、
  符号付き整数を使用してタイムスタンプを表します。4バイトを使用すると、
  許容される日付の上限が2038年になります。そのため、これらの2つの時間ベースのopcodeには、
  5バイトの入力を受け付けるように切り分けが行われました。
  これは[コード][docs 5byte carveout]に文書化されています。"
  a1link="https://bitcoincore.reviews/29221#l-45"

  q2="なぜ`fRequireMinimal`フラグが`CScriptNum`に導入されたのですか？"
  a2="`CScriptNum`は可変長エンコーディングです。[BIP62][] (ルール4)で説明されているように、
  これはマリアビリティの機会をもたらします。たとえば、ゼロは、
  `OP_0`、`0x00`、`0x0000`、...としてエンコードできます。
  [Bitcoin Core #5065][]では、データプッシュと数値を表すスタック要素に最小限の表現を[求めることで][doc SCRIPT_VERIFY_MINIMALDATA]、
  標準トランザクションにおいてこの問題が修正されました。"
  a2link="https://bitcoincore.reviews/29221#l-57"

  q3="このPRの実装でマリアビリティは安全ですか？またそれはどうしてですか？"
  a3="現在の実装では、64ビットopcodeのオペランドには固定長8バイトの表現が必要で、
  ゼロパディングのマリアビリティに対して安全です。この理由は、
  実装ロジックを単純化するためですが、その代償としてブロックスペースの使用量が増えます。
  作者は、[別のブランチ][64bit arith cscriptnum]で`CScriptNum`の可変エンコーディングを使用することも検討しました。"
  a3link="https://bitcoincore.reviews/29221#l-67" %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [HWI 3.0.0][]は、複数の異なるハードウェア署名デバイスへの共通インターフェースを提供する
  このパッケージの次期バージョンのリリースです。このリリースの唯一の重要な変更は、
  エミュレートされたハードウェアウォレットが自動検出されなくなったことです。
  詳細については、以下の[HWI #729][]の説明をご覧ください。

- [Core Lightning 24.02.2][]は、LNゴシッププロトコルの特定の部分のCore LightningとLDKの実装間の
  「[小さな非互換性][core lightning #7174]」を修正するメンテナンスリリースです。

- [Bitcoin Core 27.0rc1][]は、ネットワークの主要なフルノード実装の次期メジャーバージョンのリリース候補です。
  テスターは、[推奨されるテストトピック][bcc testing]のリストを確認することをお勧めします。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

*注：以下に掲載するBitcoin Coreへのコミットは、master開発ブランチに適用されるため、
これらの変更は次期バージョンの27のリリースから約6ヶ月後までリリースされないでしょう。*

- [Bitcoin Core #29648][]は、以前非推奨となった（[ニュースレター #288][news288 libconsensus]参照）
  libconsensusを削除しました。libconsensusは、
  Bitcoin Coreのコンセンサスロジックを他のソフトウェアで使用できるようにする試みでした。
  しかし、このライブラリはあまり普及しておらず、Bitcoin Coreのメンテナンスの負担となっていました。

- [Bitcoin Core #29130][]は、2つの新しいRPCを追加しました。
  １つめは、ユーザーが必要とする設定に基づいてユーザーの[ディスクリプター][topic descriptors]を生成し、
  そのディスクリプターをウォレットに追加します。たとえば、以下のコマンドは、
  [Taproot][topic taproot]のサポートなしで作成された古いウォレットにTaprootのサポートを追加します。

  ```
  bitcoin-cli --rpcwallet=mywallet createwalletdescriptor bech32m
  ```

  ２つめのRPCのは（[HD][topic bip32]鍵を取得する）`gethdkeys`で、
  ウォレットで使用される各xpubと（オプションで）それぞれのxprivも返します。
  ウォレットに複数のxpubが含まれている場合、`createwalletdescriptor`呼び出し時に
  使用する特定のxpubを指定できます。

- [LND #8159][]および[#8160][lnd #8160]は、
  [ブラインドルート][topic rv routing]への支払いの送信の実験的なサポート（デフォルトでは無効）を追加します。
  [後続のPR][lnd #8485]では、失敗したブラインドペイメントに対する完全なエラーハンドリングが追加される予定です。

- [LND #8515][]は、使用される[コイン選択戦略][topic coin selection]の名前を受け入れるよう複数のRPCを更新します。
  このPRの基礎となるLNDのコイン選択の柔軟性に対するこれまでの改善については、
  [ニュースレター #292][news292 lndcs]をご覧ください。

- [LND #6703][]および[#6934][lnd #6934]は、インバウンドルーティング手数料のサポートを追加します。
  ノードは、特定のアウトバウンドチャネルを通じて支払いを転送するために請求されるコストを既に通知できます。
  たとえば、キャロルは、支払いの価格の0.1%を彼女に提供する場合にのみ、チャネルピアのダンに支払いを転送すると通知できます。
  これにより、キャロルがダンに転送する1分あたりのsatoshiの平均量（sats）が、
  ダンがキャロルに転送する平均量を下回る場合、最終的にチャネル残高のすべてがキャロルの側にあり、
  ダンはそれ以上の支払いをキャロルに転送できなくなり、双方の収益の可能性が減少します。
  それを防ぐために、キャロルはダンへのアウトバウンド転送手数料を0.05%に下げる可能性があります。
  キャロルのダンへのアウトバウンド転送手数料が低くなった結果、同様に、
  ダンがキャロルに転送するよりもキャロルが1分あたり多くのsatsをダンに転送することになれば、
  最終的にすべての残高はダンの側にある状態になり、これも追加の転送と収益の獲得を妨げる可能性があります。
  その場合、キャロルはアウトバウンド手数料を引き上げることができます。

  ただし、アウトバウンド手数料はアウトバウンドチャネルにのみ適用されます。
  キャロルは、どのチャネルで支払いを受け取ったとしても同じ手数料を請求すると申し出ています。
  たとえば、キャロルはチャネルピアであるアリスまたはボブのどちらか支払いを受け取っても同じレートを請求します:

  ```
  アリス -> キャロル -> ダン
  ボブ -> キャロル -> ダン
  ```

  基本的なLNプロトコルでは、アリスまたはボブからの転送リクエストの受信に対してキャロルに手数料は支払われないため、
  これは理にかなっています。アリスとボブは、キャロルとのチャネルに対してアウトバウンド手数料を設定することができ、
  チャネルの流動性を維持するのに役立つ手数料を設定するのは彼ら次第です。同様に、
  キャロルはアリスとボブへのアウトバウンド支払いに対する手数料を調整して（例：`ダン -> キャロル -> ボブ`）、
  流動性の管理に役立てることができます。

  ただし、キャロルは自分に影響するポリシーをより詳細に制御したいと思うかもしれません。
  たとえば、アリスのノードの管理が不十分な場合、
  後でキャロルからアリスに支払いを転送したいと思う人が大勢いるわけでもない中、
  アリスからキャロルに支払いを頻繁に転送する可能性があります。
  最終的には、両者のチャネル内のすべての資金がキャロル側に支払われ、その方向へのその後の支払いが妨げられます。
  このPR前は、キャロルの資本価値が無駄になる前に、アリスとのチャネルを閉じること以外、キャロルにできることは何もありませんでした。

  このPRにより、キャロルは各チャネルに固有の _インバウンド転送手数料_ も請求できるようになりました。
  たとえばキャロルは、アリスの問題のあるノードから到着する支払いには高額の手数料を請求しますが、
  ボブの流動性の高いノードから到着する支払いには低い手数料を請求する可能性があります。
  初期のインバウンド手数料は、インバウンド手数料を理解できない古いノードとの互換性を保つために、
  常にマイナスであることが期待されます。たとえば、キャロルはボブから転送される支払いには10%の手数料のディスカウントを与え、
  アリスから転送される支払いのディスカウントは0%にします。

  手数料は、アウトバウンド手数料と同時に精算されます。たとえば、アリスがキャロルにダンに転送する支払いを提案する際、
  キャロルは元の`dan_outbound`手数料を計算し、新しく`alice_inbound`手数料を計算し、
  転送される支払いが少なくとも両方の合算値をキャロルに提供することを確認します。
  そうでない場合、キャロルは[HTLC][topic htlc]を拒否します。
  初期のインバウンド手数料は常にマイナスであることが予想されるため、
  キャロルは十分なアウトバウンド手数料を支払う支払いを拒否しませんが、
  インバウンド手数料を知っているノードはディスカウントを受けることができるかもしれません。

  インバウンドルーティング手数料は、約3年前に初めて[提案され][bolts #835]、
  約2年前にLightning-Devメーリングリストで[議論され][jager inbound]、
  同じく2年前に[BLIPs #18][]ドラフトで文書化されました。
  最初の提案以来、LND以外のLN実装のメンテナーがこれに反対してきました。
  ある人は[原則的に][teinturier bolts835]反対し、
  またある人は、プラスのインバウンド転送手数料をすぐに使用でき、
  各チャネルに対して追加の手数料の詳細をグローバルに通知する必要がないローカルで汎用的なアップグレードではなく、
  [過度にLNDに特化した][corallo overly specific]設計であると反対しています。
  代替アプローチは[BLIPs #22][]のドラフトで提案されています。
  私たちが知る中で、LND以外の実装のメンテナーでLNDの方法を採用すること[表明している][corallo free money]のは1人だけで、
  それもマイナスのインバウンド転送手数料が提供される場合のみです（ユーザーにとって無料のお金であるため）。

- [Rust Bitcoin #2652][]は、[PSBT][topic psbt]の処理の一環として、
  [Taproot][topic taproot]インプットに署名する際にAPIが返す公開鍵を変更します。
  これまでAPIは、署名する秘密鍵の公開鍵を返していました。しかしPRには、
  「技術的には正しくありませんが、内部鍵が署名を行うものであると考えるのが一般的です。
  PSBTには内部鍵ももあります。」と記載されています。このPRのマージにより、
  APIは内部鍵を返すようになります。

- [HWI #729][]は、デバイスエミュレーターの自動的な列挙と使用を止めます。
  エミュレーターは主に、HWIの開発者によって使用されますが、エミュレーターを自動的に検出しようとすると、
  通常のユーザーにとって問題が発生する可能性があります。エミュレーターを使用したい開発者は、
  今後は`--emulators`オプションを追加で渡す必要があります。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 16:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="729,29648,29130,8159,8160,8485,8515,6703,6934,835,18,22,2652,7174,5065" %}
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[HWI 3.0.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.0.0
[Core Lightning 24.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.02.2
[news292 lndcs]: /ja/newsletters/2024/03/06/#lnd-8378
[news288 libconsensus]: /ja/newsletters/2024/02/07/#bitcoin-core-29189
[teinturier bolts835]: https://github.com/lightning/bolts/issues/835#issuecomment-764779287
[corallo free money]: https://github.com/lightning/blips/pull/18#issuecomment-1304319234
[corallo overly specific]: https://github.com/lightningnetwork/lnd/pull/6703#issuecomment-1374694283
[jager inbound]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-July/003643.html
[singh dsl]: https://delvingbitcoin.org/t/dsl-for-experimenting-with-contracts/748
[linus dsl]: https://delvingbitcoin.org/t/dsl-for-experimenting-with-contracts/748/4
[ruffing bip2]: https://gnusha.org/pi/bitcoindev/59fa94cea6f70e02b1ce0da07ae230670730171c.camel@timruffing.de/
[news296 editors]: /ja/newsletters/2024/04/03/#bip
[erhardt editors]: https://gnusha.org/pi/bitcoindev/c304a456-b15f-4544-8f86-d4a17fb0aa8c@murch.one/
[lopp testnet]: https://gnusha.org/pi/bitcoindev/CADL_X_eXjbRFROuJU0b336vPVy5Q2RJvhcx64NSNPH-3fDCUfw@mail.gmail.com/
[kim testnet]: https://gnusha.org/pi/bitcoindev/950b875a-e430-4bd8-870d-f9a9fab2493an@googlegroups.com/
[review club 29221]: https://bitcoincore.reviews/29221
[delving 64bit arithmetic]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397
[bip 64bit arithmetic]: https://github.com/bitcoin/bips/pull/1538
[64bit arith cscriptnum]: https://github.com/Christewart/bitcoin/tree/64bit-arith-cscriptnum
[docs 5byte carveout]: https://github.com/bitcoin/bitcoin/blob/3206e45412ded0e70c1f15ba66c2ba3b4426f27f/src/script/interpreter.cpp#L531-L544
[doc SCRIPT_VERIFY_MINIMALDATA]: https://github.com/bitcoin/bitcoin/blob/3206e45412ded0e70c1f15ba66c2ba3b4426f27f/src/script/interpreter.h#L69-L73
[ml OP_TLUV]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019419.html
