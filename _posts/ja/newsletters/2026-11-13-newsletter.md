---
title: 'Bitcoin Optech Newsletter #431'
permalink: /ja/newsletters/2026/11/13/
name: 2026-11-13-newsletter-ja
slug: 2026-11-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、データ流出に耐性のある署名方式に関するBIPドラフトのリンクと、
旧バージョンのBitcoin Coreに影響する3件の脆弱性の開示、testnet5のジェネシスブロックのマイニング計画の告知、
コンパクトブロックの再構築率の低下に関する調査について掲載しています。また、新しいリリースとリリース候補の発表や、
人気のBitcoin基盤ソフトウェアの注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **データ流出防止署名のBIPドラフト:** Connor Avilaは、
  ハードウェアデバイス向けの[データ流出防止署名][topic exfiltration-resistant signing]を標準化する提案について
  Bitcoin-Devメーリングリストに[投稿しました][anti ex ml]。nonceは署名デバイスが選択するため、
  デバイスが侵害された場合にシードを漏洩させることができる可能性があります。この提案では、
  ホストがnonceの生成に関与できるようにします。この手法はすでに複数のメーカーで使われていますが、
  これまで標準化されたことはありませんでした（[ニュースレター #136][news136 anti ex]参照）。
  このトピックが議論されるのは今回が初めてではありません。2020年にはStepan Snigirevが
  データ流出防止署名の標準化を最初に提案し（[ニュースレター #87][news87 anti ex]参照）、
  Pieter Wuilleは利用可能なさまざまな手法の概要を示しました（[ニュースレター #88][news88 anti ex]参照）。
  2024年にはMoonsettlerがデータ流出防止プロトコルを提案し（[ニュースレター #317][news317 anti ex]参照）、
  最近マージされた[BIP461][]は、署名デバイスによる鍵情報の漏洩の試みを検知する方法を提供しています
  （[ニュースレター #424][news424 bip461]参照）。

  Avilaの提案には2つのBIPドラフトが含まれています。[1つめ][anti ex bip]は、
  [Schnorr][topic schnorr signatures]署名とECDSA署名のデータ流出防止署名を扱うもので、
  ホストがnonce生成のために独自の乱数を提供し、
  署名デバイスが実際にそれを使用したかどうかを確認する2ラウンドのプロトコルを定義しています。
  [2つめのドラフト][anti ex psbt]は、データ流出防止プロトコルを実行するために、
  [PSBT][topic psbt]にインプットごとの専用フィールドを3つ追加するものです。この提案には、
  テストベクター、Pythonによるリファレンス実装、libsecp256k1用のCモジュールも含まれています。

  Avilaは、Sjors ProvoostがすでにシングルシグのTaproot key-path署名を対象とした
  [実験的なドラフト][anti ex sjors]を公開していることにも言及しました。作成者によると、
  Provoostは自身の実装をAvilaの仕様に合わせる予定です。最後にAvilaは、
  この提案の暗号部分についてはまだ監査を受けていないため、他の開発者にフィードバックとレビューを求めました。

- **Bitcoin Coreの3件の脆弱性の開示:** Antoine Poinsotは、
  Bitcoin Core 29.2および30.0で修正された脆弱性に関する3件のBitcoin Coreセキュリティアドバイザリ（重大度「高」が1件、
  「中」が2件）をBitcoin-Devメーリングリストに[投稿しました][poinsot adv ml]。
  [開示ポリシー][disc pol]（[ニュースレター #306][news306 disclosures]参照）では、
  重大度「中」および「高」の脆弱性は、影響を受ける最後のリリースがサポート終了（EOL）を迎えてから2週間後に開示されることになっており、
  29.xシリーズは10月27日にEOLを迎えました。開示された3件の脆弱性は以下のとおりです:

  - [再編成中のTRUCの兄弟エビクションによるブロックテンプレート作成の停止][CVE-2025-62861]:
    この重大度「高」のバグはマイニングに使用されるノードにのみ影響し、特定の再編成の後、
    再起動するまでブロックテンプレートを作成できなくなるというものでした。
    切断されたブロックのトランザクションがmempoolに再投入される際にも
    [TRUC][topic v3 transaction relay]の兄弟トランザクションの排除が実行されていたため、
    子孫トランザクションを残したままトランザクションが排除される可能性がありました。
    このバグはバージョン28.0から29.1に影響していました。2025年9月にNiklas Göggeによって[責任ある開示][topic responsible disclosures]が行われ、
    Greg Sandersによって[Bitcoin Core #33504][]で修正されました（[ニュースレター #375][news375 truc]参照）。

  - [インバウンドTor接続に誤って`-whitelist`権限が付与される][CVE-2025-62860]:
    この重大度「中」のバグは、`-whitelist`の範囲に自身のTorデーモンのアドレスが含まれているノードにおいて、
    すべてのインバウンド[Tor][topic anonymity networks]ピアに対するDoS制限とプライバシー漏洩対策を解除してしまうものでした。
    この構成は、到達可能な数千のノードで使用されていました。このバグは2025年9月に
    Martin ZumsandeとAntoine Poinsotによって責任ある開示が行われ、
    Zumsandeによって[Bitcoin Core #33395][]で修正されました。

  - [witnessの改ざんによるブロック処理の停止][CVE-2025-62859]: この重大度「中」のバグは、
    [コンパクトブロック][topic compact block relay]を最初にアナウンスしたピアが、
    ノードによるそのブロックの処理を最大10分間停滞させることができ、
    条件によってはその停滞を無期限に繰り返すことができるというものでした。
    このバグは2025年4月にEugene Siegelによって責任ある開示が行われ、
    Greg Sandersによって[Bitcoin Core #32646][]で修正されました。

  最初の2件の脆弱性の修正は、Bitcoin Core 28.3にも含まれていました。
  影響を受けるリリースシリーズはすべてEOLを迎えているため、それらをまだ実行している場合は、
  メンテナンスリリースにアップグレードする必要があります。

- **testnet5のジェネシスブロックのマイニング:** Anthony Townsは、
  [BIP95][]で規定されているtestnet4の後継案である[testnet5][topic testnet]のジェネシスブロックをマイニングする計画を
  Bitcoin-Devメーリングリストに[投稿しました][towns tn5]（ニュースレター[#409][news409 testnet5]および[#412][news412 bip95]参照）。
  マイニングは、mainnetがブロック975,744で次の難易度調整を迎えた時点（11月13日の見込み）で開始される予定です。
  ジェネシスブロックはその高さ以降のmainnetのブロックハッシュにコミットするため、
  誰も事前にtestnet5のブロックをマイニングすることはできません。
  testnet5の最小難易度はtestnet4の約100万倍に設定されているため（難易度が調整される前のローンチ直後に
  大量のブロックが短時間でマイニングされるのを防ぐため）、最初のブロックのマイニングにはASICが必要です。
  Townsは、開発者が先行者利益を得られないよう、
  誰でもハッシュレートを向けることができる公開プールについて[説明しました][towns tn5 gist]。

  ジェネシスブロックがマイニングされると、その値でBIP95内のプレースホルダー（仮のデータ）が置き換えられます。
  Townsは、ネットワークが一般利用できるようになるまでには、
  ノードソフトウェアにtestnet5のパラメーターとBIP54の[コンセンサスクリーンアップ][topic consensus cleanup]ロジックが必要であり、
  さらにDNSシード、faucet、エクスプローラーも必要になると指摘しました。

- **<!--continued-discussion-of-compact-block-reconstruction-stats-->コンパクトブロック再構築の統計に関する議論の続き:**
  0xB10Cは、自身のDelving Bitcoinのスレッド（[ニュースレター #382][news382 cb]参照）に、
  7月中旬から10月中旬にかけて[コンパクトブロックリレー][topic compact block relay]のパフォーマンスが
  低下した理由の説明を[投稿しました][b10c cb summary]。9月に彼は、
  自身のノードがトランザクションを要求せずに再構築できたブロックは1%から5%に過ぎず、
  ブロックあたり約100 kBを要求していたと[報告していました][b10c cb sept]。Gregory Sandersは、
  自身のノードに欠けていたトランザクションのほぼすべてが、他のノードよりも数分早くマイニングプールに届いた
  runeの発行関連のトランザクションチェーンに属していることを[発見しました][sanders cb investigation]。

  Bitcoin Network Operations Collectiveフォーラムでの調査（[その1][bnoc fleet]、
  [その2][bnoc degradation]）により、これらのチェーンは、
  トークンをできるだけ安価に発行しようとしていた何者かによるものであることが突き止められました。
  各トランザクションは約100 vbyteで、[P2A（Pay-to-Anchor）][topic ephemeral anchors]のインプットと、
  P2Aおよび`OP_RETURN`のアウトプットを持ち、約10 satsの手数料を支払っていました。
  ピアはこれらのチェーンをアナウンスせずにノードに直接送信し、別のピアは、
  チェーンの途中にあるP2Aアウトプットを使用し、その全額を手数料として支払うトランザクションをそれぞれ送信していました。
  これらのトランザクションはそれぞれ、それを受け入れたmempool内でチェーンの残りの部分を[置き換え][topic rbf]、
  ノードがチェーンと置き換えトランザクションのどちらを保持するかは、どちらが先に到着したかに部分的に依存していました。
  その結果、mempoolの内容がプールがマイニングする内容と乖離し、
  ノードは欠けているトランザクションを要求しなければならなくなりました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LDK v0.3-rc4][]は、LN対応のウォレットやアプリケーションを構築するための
  このライブラリの次期メジャーバージョンの4つめのリリース候補で、
  [ニュースレター #426][news426 ldk rc]で紹介した候補に続くものです。開発者は、テストの前に、
  支払いメタデータを含む以前に発行された[BOLT11][]インボイスの無効化を含む
  [APIおよび後方互換性に関する変更][ldk 0.3 notes]を確認する必要があります。

- [LDK v0.2.8][]および[v0.1.14][ldk v0.1.14]は、このライブラリの0.2ブランチおよび0.1ブランチの
  セキュリティリリースです。どちらも、資金の損失やDoS攻撃につながる可能性のある脆弱性に加えて、
  後述する協調閉鎖の問題とルートヒントの処理の問題を修正しています。バージョン0.2.8では、
  静的な[BOLT12][]インボイスの支払いに影響する手数料の過払いの脆弱性と、
  LSPS2サービスに影響するDoS脆弱性も修正されています。

- [LND v0.21.8-beta][]および[v0.20.8-beta][lnd v0.20.8-beta]は、
  このLNノード実装のメンテナンスリリースです。どちらにも、後述するAMPのリカバリー、チャネルのファンディング、
  復元されたチャネルの強制閉鎖、承認ヒントの修正が含まれています。また、
  リンクの再接続をまたいだ転送HTLCのリカバリーに対処し、スイーパーとチャネル状態の修正も含まれています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #36142][]は、[Tor][topic anonymity networks]のコントロールエンドポイントを介した
  コマンドインジェクションを修正しました。そのエンドポイントを制御またはなりすましている攻撃者は、
  悪意のあるオニオンサービスの秘密鍵を返すことができました。Bitcoin Coreはその鍵を保存して再利用するため、
  攻撃者は追加のTorコントロールコマンドや引数を注入することができました。Bitcoin Coreは現在、
  鍵を保存または再利用する前に検証し、返されたオニオンサービスIDもチェックするようになりました。
  既存のキャッシュされた鍵が検証に失敗した場合、オニオンサービスは利用できなくなります。
  キャッシュされた鍵を削除して再起動すると、新しいオニオンアドレスが生成されます。

- [BIPs #2251][]は、[ニュースレター #419][news419 rawtr]で以前取り上げた
  `rawtr()`アウトプットスクリプトディスクリプターのドラフト仕様である[BIP394][]を追加しました。
  内部鍵とオプションのスクリプトツリーから[Taproot][topic taproot]のアウトプット鍵を導出する`tr()`とは異なり、
  `rawtr()`はtweakを適用せずにアウトプット鍵を直接受け取ります。これにより、
  ウォレットは内部構造を知らなくてもアウトプットを記述できます。ただし、`rawtr()`
  [ディスクリプター][topic descriptors]は、他の使用パスが存在しないことを証明するものではありません。そのため、
  信頼できないソースからこのディスクリプターをインポートするソフトウェアは、
  隠れたスクリプトパスが存在する可能性についてユーザーに警告する必要があります。
  Bitcoin Coreはバージョン24.0からこのディスクリプターをサポートしています（[ニュースレター #213][news213 rawtr]参照）。

- [BIPs #2347][]は、[testnet5][topic testnet]のドラフト仕様である
  [BIP95][]（[ニュースレター #412][news412 bip95]参照）を更新し、
  提案されているジェネシスブロックを[プールのインフラストラクチャ][topic pooled mining]を使って
  マイニングしやすくしました（[上記のニュース](#testnet5)参照）。最近のmainnetのブロックハッシュへのコミットメントは、
  コインベースアウトプットの公開鍵フィールドから、コインベースのインプットスクリプト内の可読テキストに移されました。
  アウトプットには代わりに`OP_RETURN`が使用され、使用不可能であることが明示されるとともに、
  8 byteのextra nonce領域が提供されます。このドラフトでは、マイナーがブロックバージョンを変更することも許可され、
  利用可能なマイニングの探索空間が拡大されます。例として示されているジェネシスブロックは、引き続き仮のデータのままです。

- [BIPs #2342][]は、[signet][topic signet]や[testnet4][topic testnet]のように
  ジェネシス直後からこのルールを適用するチェーンについて、コインベースのインプットスクリプトの先頭における
  ブロック高の[BIP34][]のエンコーディングを明確化しました。高さ1から16は、長さのプレフィックスなしで、
  1 byteのオペコード`OP_1`から`OP_16`を使用する必要があります。以前の文言は、
  長さのプレフィックス付きの数値が必要であると解釈される可能性がありました。この明確化は、
  Bitcoin Coreの既存の動作と一致しています。また、コインベースのインプットスクリプトは
  引き続き少なくとも2 byteを含む必要があるため、
  高さのオペコードのみでは不十分であることも記載されています（[ニュースレター #406][news406 coinbase]参照）。

- [Core Lightning #9610][]は、過大な[HTLC][topic htlc]の金額によってピアが引き起こせるクラッシュを修正しました。
  このクラッシュは、チャネルピアが、金額フィールドの最上位ビットが立つ約9,200万BTC以上の
  不正な金額のHTLCを提案することで引き起こされる可能性がありました。
  その値は符号付きの残高チェックの際に負の値として解釈され、資金が十分かどうかのチェックを回避することができました。
  その後のコミットメントトランザクションの構築でアサーションが発生し、
  影響を受けたチャネルのサブプロセスである`channeld`が終了していました。現在、CLNは残高の計算を行う前に、
  ミリサトシで表した[BOLT1][]で規定された上限である2,100万BTCを超える金額を拒否するようになりました。

- [LDK #5507][]および[#5532][ldk #5532]は、異なるトランザクションに対する署名を組み合わせてしまう可能性があった
  協調閉鎖のバグを修正しました。1つめのPRは、提案された手数料が一致するというだけで、
  別の閉鎖トランザクションのキャッシュされた署名を再利用するのではなく、
  LDKがピアの提案したトランザクションに署名するようにしました。2つめのPRは、
  非同期署名者が利用できなかった後にピアが切断した場合に、保留中の署名状態をクリアするようにし、
  再接続後に古いピアの署名が新しいローカルの提案と組み合わされるのを防ぎます。これまではどちらのケースでも、
  LDKがチャネルを閉鎖済みとして扱いながら無効な閉鎖トランザクションをブロードキャストしてしまう可能性があり、
  その結果、資金が取り残され、別途リカバリー作業が必要となる事態を招いていました。

- [LND #11492][]は、強制閉鎖後に受信したアトミックマルチパスペイメント（[AMP][topic amp]）の
  オンチェーンリカバリーを修正しました。これまでは、すでに支払いを決済済みとして記録していたにもかかわらず、
  未処理の[HTLC][topic htlc]を請求するのに必要なプリイメージをLNDが見つけられない場合がありました。
  LNDは、個々のAMP HTLC用に保存されたプリイメージではなく、インボイスレベルのプリイメージを誤ってチェックしていました。
  現在は、そのHTLCのプリイメージを取得するようになりました。このPRでは、
  新しい支払いを対象とした有効期限チェックが、リカバリー中に再処理される、
  過去に記録されたAMPおよび[keysend][topic spontaneous payments]のHTLCを拒否しないようにもしています
  （LNDの有効期限チェックに関する以前の記事については[ニュースレター #412][news412 cltv]参照）。

- [LND #11479][]は、[複数のチャネルを開設するトランザクション][topic payment batching]を
  ブロードキャストする際のエラー処理を修正しました（[ニュースレター #166][news166 batch]参照）。
  これまでは、ブロードキャスト中にエラーが発生すると、トランザクションがネットワークに到達していて
  まだ承認される可能性がある場合でも、LNDは保留中のチャネルを放棄し、
  確保されていたウォレットのインプットを解放していました。現在は、
  ブロードキャストが試行された時点で保留中のチャネルの状態を保持し、
  トランザクションを監視してチャネルを復旧するために必要な情報を保持するようになりました。
  トランザクションが承認されない場合、保持された保留中のチャネルは手動でクリーンアップする必要があります。

- [LND #11340][]および[#11374][lnd #11374]は、
  LNDの実験的な[BOLT12オファー][topic offers]のサポート（[ニュースレター #424][news424 bolt12]参照）を拡張し、
  オファーの作成とインボイスリクエストの処理を追加しました。1つめのPRは、保存されたオファーに対してリクエストを検証し、
  署名済みのインボイスで応答するハンドラーを追加しました。2つめのPRは、
  そのハンドラーを受信した[オニオンメッセージ][topic onion messages]に接続し、`CreateOffer` RPCと
  `lncli createoffer`コマンドを追加しました。ただし、このハンドラーは、
  発行したインボイスに対する支払いを決済するのに必要なインボイスの状態をまだ保持しません。
  この機能は開発ビルドでのみ利用可能で、追加の設定が必要です。

- [LND #11480][]は、[静的チャネルバックアップ][topic static channel backups]から復元されたチャネルを
  強制閉鎖しようとした際のクラッシュを修正しました。このようなバックアップには
  使用可能なローカルのコミットメントトランザクションが含まれておらず、
  リカバリーには取引相手がそのコミットメントを公開する必要があります。これまでは、
  強制閉鎖のパスでローカルのデータ損失はチェックしていたものの、復元されたチャネルのステータスはチェックしていなかったため、
  存在しないコミットメントトランザクションにアクセスしてパニックが発生していました。現在LNDは、
  そのようなローカルの強制閉鎖の試みを拒否し、再起動後に中断された閉鎖を再開する場合も含めて、
  利用できないトランザクションを安全に処理するようになりました。

- [LND #11481][]は、トランザクションが承認されたかどうかをチェックするスキャンの開始ブロック高を
  LNDがキャッシュする方法を修正しました。これまでは、攻撃者が、
  失効したコミットメントトランザクションのtxidと異なるアウトプットスクリプトを持つ
  偽のチャネルファンディングアウトプットを提案することができました。
  LNDはスキャンの開始高をtxidのみでキャッシュしていたため、偽のファンディングリクエストは、
  失効したコミットメントを追跡するリクエストとキャッシュエントリーを共有していました。
  一致しないファンディングリクエストによって開始高が失効したトランザクションの承認ブロックを超えて進められ、
  その後のスキャンでそのトランザクションを見逃してしまう可能性がありました。これにより、
  LNDによる失効したコミットメントとその[ペナルティトランザクション][topic ln-penalty]の検知が
  遅れる可能性がありました。現在LNDは、
  txidとアウトプットスクリプトの組ごとに個別の開始高を保存するようになりました。この問題は、
  Neutrinoやトランザクションインデックスなしで使用されるBitcoin Coreなどによる過去のスキャンに影響します。

{% include snippets/recap-ad.md when="2026-11-17 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33504,33395,32646,36142,2251,2347,2342,9610,11492,11479,11340,11374,11480,11481,5507,5532" %}

[anti ex ml]: https://groups.google.com/g/bitcoindev/c/cB37_jChkEI/m/3paRGQ_IBgAJ
[news136 anti ex]: /ja/newsletters/2021/02/17/#anti-exfiltration
[anti ex bip]: https://github.com/AvilaLabs/anti-exfil/blob/main/spec/bip-anti-exfil.md
[anti ex psbt]: https://github.com/AvilaLabs/anti-exfil/blob/main/spec/bip-anti-exfil-psbt.md
[news87 anti ex]: /ja/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news88 anti ex]: /ja/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[news317 anti ex]: /ja/newsletters/2024/08/23/#simple-but-imperfect-anti-exfiltration-protocol
[news424 bip461]: /ja/newsletters/2026/09/25/#bips-2224
[anti ex sjors]: https://github.com/Sjors/bips/pull/2/
[poinsot adv ml]: https://groups.google.com/g/bitcoindev/c/tOLTRSOz87k/m/7eiOFoHIAQAJ
[disc pol]: https://bitcoincore.org/ja/security-advisories/
[news306 disclosures]: /ja/newsletters/2024/06/07/#bitcoin-core
[CVE-2025-62861]: https://bitcoincore.org/ja/2026/11/10/disclose-cve-2025-62861/
[CVE-2025-62860]: https://bitcoincore.org/ja/2026/11/10/disclose-cve-2025-62860/
[CVE-2025-62859]: https://bitcoincore.org/ja/2026/11/10/disclose-cve-2025-62859/
[news375 truc]: /ja/newsletters/2025/10/10/#bitcoin-core-33504
[towns tn5]: https://groups.google.com/g/bitcoindev/c/DmFiHeo-xRw/m/YI3cpl5vAQAJ
[towns tn5 gist]: https://gist.github.com/ajtowns/ebb148819c6028387271e6f0dce5e1da
[news409 testnet5]: /ja/newsletters/2026/06/12/#testnet5-bip
[news412 bip95]: /ja/newsletters/2026/07/03/#bips-2196
[b10c cb summary]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/63
[news382 cb]: /ja/newsletters/2025/11/28/#stats-on-compact-block-reconstructions-updates
[b10c cb sept]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/53
[sanders cb investigation]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/56
[bnoc fleet]: https://bnoc.xyz/t/satoshi-31-0-0-peers-with-no-service-flags-and-protocol-70015-pushed-transactions-then-stopped-together-on-oct-18/193/
[bnoc degradation]: https://bnoc.xyz/t/compact-block-reconstruction-degradation-between-september-october-2026/198/

[LDK v0.3-rc4]: https://github.com/lightningdevkit/rust-lightning/tree/v0.3-rc4
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc4/CHANGELOG.md
[LDK v0.2.8]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.8
[ldk v0.1.14]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.14
[LND v0.21.8-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.8-beta
[lnd v0.20.8-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.8-beta
[LDK #5507]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5507
[LDK #5532]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5532
[news426 ldk rc]: /ja/newsletters/2026/10/09/#ldk-v0-3-rc3
[news412 cltv]: /ja/newsletters/2026/07/03/#lnd-10927
[news166 batch]: /ja/newsletters/2021/09/15/#lnd-5356
[news424 bolt12]: /ja/newsletters/2026/09/25/#lnd-11146
[news419 rawtr]: /ja/newsletters/2026/08/21/#rawtr-bip
[news213 rawtr]: /ja/newsletters/2022/08/17/#bitcoin-core-23480
[news406 coinbase]: /ja/newsletters/2026/05/22/#bitcoin-core-34860
