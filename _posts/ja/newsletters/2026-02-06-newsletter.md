---
title: 'Bitcoin Optech Newsletter #391'
permalink: /ja/newsletters/2026/02/06/
name: 2026-02-06-newsletter-ja
slug: 2026-02-06-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、定数時間の並列化されたUTXOデータベースの研究に関するリンクと、
Bitcoin Scriptを記述するための高水準言語の要約および、ダスト攻撃を軽減するアイディアについて掲載しています。
また、Bitcoinのコンセンサスルールの変更に関する議論や、新しいリリースおよびリリース候補の発表、
人気のBitcoin基盤ソフトウェアの注目すべき更新など恒例のセクションも含まれています。

## ニュース

- **定数時間および並列化UTXOデータベース**: Toby Sharpは、
  彼の最新プロジェクトであるHornet UTXO(1)と呼ばれる、定数時間クエリを備えたカスタムの高並列化UTXOデータベースについて
  Delving Bitcoinに[投稿しました][hornet del]。
  これは、Bitcoinのコンセンサスルールの最小限の実行可能仕様の提供にフォーカスした実験的クライアントである
  [Hornet Node][hornet website]の新しい追加コンポーネントです。この新しいデータベースは、
  ロックフリーで高度に並行なアーキテクチャを通じて、IBD（Initial Block Download）の改善を目指しています。

  コードは外部依存なしで最近のC++23で書かれています。速度の最適化のため、
  [ハッシュマップ][hash map wiki]ではなく、ソート済みの配列と[LSMツリー][lsmt wiki]が採用されました。
  append、query、fetchなどの操作は並行して実行され、ブロックは到着順ではなく順不同で処理され、
  データの依存関係は自動的に解決されます。コードはまだ公開されていません。

  Sharpは、彼のソフトウェアの性能を評価するためのベンチマークを提供しました。mainnetチェーン全体の再検証において、
  Bitcoin Core v30は167分（スクリプトおよび署名の検証はなし）かかったのに対し、
  Hornet UTXO(1)は検証完了まで15分でした。テストは、
  32コアのコンピューター（128GBのRAM、1TBのストレージ）上で行われました。

  その後の議論では、他の開発者らがSharpに対して非常に効率的なIBDを提供することで知られている
  [libbitcoin][libbitcoin gh]との性能比較を提案しました。

- **Bithoven: Bitcoin用の形式検証済みの命令型言語:**
  Hyunhum Choは、[miniscript][topic miniscript]の代替である
  Bithovenに関する彼の[研究][arxiv hc bithoven]についてDelving Bitcoinに[投稿しました][delving hc bithoven]。
  ロックスクリプトの可能な充足条件を表現するためのminiscriptの述語言語とは対照的に、
  Bithovenは、`if`、`else`、`verify`、`return`を主要な操作とする、より馴染みのあるC系統の構文を使用します。
  コンパイラはすべてのスタック管理を処理し、すべてのパスで少なくとも1つの署名が必要であることなど、
  miniscriptコンパイラと同様の保証を提供します。miniscriptと同様に、
  さまざまなScriptバージョンをターゲットにすることができます。

- **<!--discussion-of-dust-attack-mitigations-->ダスト攻撃の緩和策に関する議論**:
  Bubb1esは、オンチェーンウォレットにおける[ダスト攻撃][topic output linking]を処理する方法について
  Delving Bitcoinに[投稿しました][dust attacks del]。ダスト攻撃は、
  攻撃者が特定したいすべての匿名アドレスにダストUTXOを送信することで発生します。
  その一部が無関係のUTXOと一緒に意図せず使用されることを期待しています。

  現在、ほとんどのウォレットがこれに対処するために選択する方法は、
  ウォレットクライアントでダストUTXOをダストUTXOとしてマークすることで、
  その使用を防ぐというものです。しかし、将来ユーザーが鍵からウォレットを復元した場合、
  新しいウォレットクライアントがこれらのUTXOがマークされていることを認識せずに、
  ダストUTXOの使用を解除してしまうという問題が発生する可能性があります。
  Bubb1esは、このダストUTXO攻撃を防ぐために、ダストUTXOの全額を使用し、
  `OP_RETURN`アウトプットにより使用不可能であることを証明可能にするトランザクションを作成することを提案しています。
  これは、Bitcoin Core v30.0が最小リレー手数料率を引き下げた（0.1 sats/vbyte）ことで可能になりました。

  彼はその後、ダストUTXOをこのように処理するウォレットを実装する際のいくつかのリスクを列挙しています。

  1. ごく少数のウォレットだけがこれを実装した場合のフィンガープリンティングの問題

  2. 複数のダストUTXOが同時にブロードキャストされた場合、相関付けが可能になること

  3. 手数料率が上昇した場合、再ブロードキャストが必要になる可能性があること

  4. マルチシグやハードウェア署名のセットアップにおいて、ダストUTXOへの署名が混乱を招く可能性があること

  AJ Townsは、最小リレーサイズが65 byteであることに言及し、
  ANYONECANPAY|ALLと3-byteのOP_RETURNを使用することでより効率的になると説明しました。

  その後Bubb1esは、これがどのように行われるかを実演するための実験的ツール[ddust][ddust tool]を提供しました。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **SHRINCS: 静的バックアップを備えた324-byteのステートフルなポスト量子署名:**
  [Bitcoin用のハッシュベースの署名スキーム][news386 jn hash]に関する継続的な議論として、
  Jonas Nickは、Bitcoinでの使用に潜在的に有用な特性を持つ特定のハッシュベースの
  [量子耐性][topic quantum resistance]署名アルゴリズムについてDelving Bitcoinに[詳述しました][delving jn shrings]。

  論文では、ステートフル署名とステートレス署名のトレードオフが議論されており、
  ステートフル署名は複雑なバックアップスキームを犠牲として大幅にコストを削減できます。
  SHRINCSは、鍵＋状態の忠実性が確実に分かる場合にはステートフル署名を使用し、
  状態が有効であるか懸念がある場合にはより高コストのステートレス署名にフォールバックするという妥協案を提供します。

  SHRINCSに選択された2つのスキームは、ステートレス署名用のSPHINCS+と、
  ステートフル署名用のUnbalanced XMSSです。アウトプットスクリプトに記載される公開鍵は、
  ステートフルの鍵とステートレスの鍵のハッシュです。これらのハッシュベースの署名スキームは、
  検証の一部として署名用公開鍵を返すため、署名者は自身の署名と一緒に未使用の公開鍵を提供し、
  検証者は返された公開鍵と提供された公開鍵のハッシュがロックスクリプトで指定された鍵と一致するかを確認します。
  Unbalanced XMSSスキームは、鍵から比較的少数の署名しか必要とされないケースを最適化するために選択されています。

- **BIP54の残された論点への対応:** Antoine Poinsotは、
  [コンセンサスクリーンアップソフトフォーク][topic consensus cleanup]における残された論点について[投稿しました][ml ap gcc]。

  最初の議論は、コインベーストランザクションの`nLockTime`にブロック高から1を引いた値を設定することを強制する提案です。
  この議論の中心は、将来のマイナーが既存のバージョン、タイムスタンプ、nonceフィールドというnonce空間を使い果たした場合に、
  マイニングチップがこのフィールドを追加nonceとして使用する能力を不必要に制限するかどうかです。
  複数の投稿者が、`nLockTime`フィールドには既にコンセンサスで強制されるセマンティクスがあるため、
  追加のnonceローリングの主要な候補ではないと指摘しました。
  追加のバージョンビットや別の`OP_RETURN`アウトプットなどを含む、
  代替のnonce空間に関するさまざまな提案がなされました。

  議論されたもう1つの変更は、（witnessを除いて）64 byteのトランザクションをコンセンサスで無効にする提案です。
  このようなトランザクションはデフォルトのリレーポリシーでも既に制限されていますが、
  コンセンサスの変更はSPV（またはその他の類似の）軽量クライアントを特定の攻撃から保護することになります。
  複数の投稿者が、他の緩和策が存在すること、また特定の種類のトランザクション（たとえば特定のプロトコルにおける[CPFP][topic cpfp]）に対して
  予期しない有効性のギャップを導入する可能性があることから、この変更が本当に価値があるのかを疑問視しました。

- **Falconポスト量子署名スキームの提案:** Giulio Golinelliは、
  Falcon署名の検証をBitcoinで有効にするフォークの提案をメーリングリストに[投稿しました][ml gg falcon]。
  Falconアルゴリズムは格子暗号に基づいており、ポスト量子署名アルゴリズムとしてFIPS標準化を目指しています。
  ECDSA署名と比較してオンチェーンで約20倍のスペースを必要としますが、検証速度は約2倍です。
  このため、Bitcoinに対してこれまで提案されたポスト量子署名スキームの中で最もコンパクトなものの1つとなっています。

  Conduitionは、Falconアルゴリズムのいくつかの制限、特に定数時間での署名実装の難しさについて投稿しました。
  他の参加者は、Bitcoin用のポスト量子署名アルゴリズムは将来のSTARK/SNARKとの親和性を念頭に置いて検討されるべきかどうか
  という問題について議論しました。

  注: メーリングリストでの投稿ではソフトフォークとして説明されていますが、
  P2WPKH検証パスにおけるフラグデイ方式の分岐として実装されているようで、
  これはハードフォークとなります。このアルゴリズム用のソフトフォーククライアントを開発するにはさらに作業が必要です。

- **SLH-DSAの検証はECCに匹敵可能:** Conduitionは、
  自身のポスト量子SLH-DSA検証実装をlibsecp256k1と比較ベンチマークしている進行中の研究について
  [投稿しました][ml cond slh-dsa]。彼の結果は、一般的なケースにおいてSLH-DSAの検証が
  [Schnorr][topic schnorr signatures]の検証に匹敵できることを示しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LDK 0.1.9][]および[0.2.1][ldk 0.2.1]は、LN対応アプリケーション構築用のこの人気のライブラリのメンテナンスリリースです。
  どちらも、未承認トランザクションが存在する場合に、`ElectrumSyncClient`が同期に失敗するバグを修正しています。
  バージョン0.2.1ではさらに、ピアが[スプライシング][topic splicing]をサポートしていない場合に
  `splice_channel`がすぐに失敗しない問題を修正し、`AttributionData`構造体を公開するとともに、
  その他いくつかのバグ修正も含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33604][]は、[assumeUTXO][topic assumeutxo]ノードの動作を修正します。
  バックグラウンドでの検証中、ノードはベストチェーンにスナップショットブロックを持たないピアからのブロックのダウンロードを回避します。
  これは、潜在的な再編成を処理するために必要なundoデータがノードに存在しないためです。
  しかし、この制限はバックグラウンドでの検証が完了した後も不必要に維持されていました。
  ノードが再編成を処理できるにもかかわらずです。現在、ノードはバックグラウンドでの検証が進行中の間のみこの制限を適用します。

- [Bitcoin Core #34358][]は、`removeprunedfunds` RPCを介してトランザクションを削除する際に発生するウォレットのバグを修正します。
  これまでは、トランザクションを削除すると、同じUTXOを使用する競合トランザクションがウォレットに含まれている場合でも、
  そのすべてのインプットが再び使用可能としてマークされていました。

- [Core Lightning #8824][]は、経路探索の`askrene`プラグイン（[ニュースレター #316][news316 askrene]参照）に
  `auto.include_fees`レイヤーを追加し、ルーティング手数料を支払い金額から差し引くことで、
  実質的に受信者が手数料を負担するようにします。

- [Eclair #3244][]は2つのイベントを追加します。`PaymentNotRelayed`は、
  おそらく流動性不足のため支払いを次のノードにリレーできなかった場合に発行され、
  `OutgoingHtlcNotAdded`は、特定のチャネルに[HTLC][topic htlc]を追加できなかった場合に発行されます。
  これらのイベントは、ノードオペレーターが流動性配分のためのヒューリスティクスを構築するのに役立ちますが、
  PRでは単一のイベントが配分をトリガーすべきではないと注記しています。

- [LDK #4263][]は、`pay_for_bolt11_invoice` APIにオプションパラメーター`custom_tlvs`を追加し、
  呼び出し元が支払いのオニオンに任意のメタデータを埋め込めるようにします。
  低レベルのエンドポイント`send_payment`では
  既に[BOLT11][]支払いにおけるカスタム[TLVs][]（Type-Length-Values）が許可されていましたが、
  高レベルエンドポイントでは適切に公開されていませんでした。

- [LDK #4300][]は、汎用的な[HTLC][topic htlc]インターセプションのサポートを追加します。
  これは[非同期支払い][topic async payments]用に追加されたHTLC保持メカニズム上に構築されており、
  偽のSCID宛のHTLC保持のみをインターセプトしていた以前の機能（[ニュースレター #230][news230 intercept]参照）を拡張します。
  新しい実装は、設定可能なビットフィールドを使って以下の宛先のHTLCをインターセプトします。
  （従来どおり）インターセプトSCID、オフラインのプライベートチャネル（LSPがスリープ中のクライアントを起動するのに有用）、
  オンラインのプライベートチャネル、パブリックチャネルおよび未知のSCID。
  これは、LSPS5のサポート（クライアント側の実装については[ニュースレター #365][news365
  lsps5]参照）やその他のLSPユースケースの基盤となります。

- [LND #10473][]は、`SendOnion` RPC（[ニュースレター #386][news386 sendonion]参照）を完全に冪等にし、
  ネットワーク障害後にクライアントが重複支払いのリスクなくリクエストを安全にリトライできるようにします。
  同じ`attempt_id`が既に処理されている場合、RPCは`DUPLICATE_HTLC`エラーを返します。

- [Rust Bitcoin #5493][]は、互換性のあるARMアーキテクチャ上でハードウェア最適化されたSHA256演算を使用する機能を追加します。
  ベンチマークでは、大きなブロックに対してハッシュ処理が約5倍高速になることが示されています。
  これは、x86アーキテクチャ上のSHA256アクセラレーション（[ニュースレター #265][news265 x86sha]参照）を補完するものです。

{% include snippets/recap-ad.md when="2026-02-10 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33604,34358,8824,3244,4263,4300,10473,5493" %}

[news386 jn hash]: /ja/newsletters/2026/01/02/#bitcoin
[delving jn shrings]: https://delvingbitcoin.org/t/shrincs-324-byte-stateful-post-quantum-signatures-with-static-backups/2158
[ml ap gcc]: https://groups.google.com/g/bitcoindev/c/6TTlDwP2OQg
[delving hc bithoven]: https://delvingbitcoin.org/t/bithoven-a-formally-verified-imperative-smart-contract-language-for-bitcoin/2189
[arxiv hc bithoven]: https://arxiv.org/abs/2601.01436
[ml gg falcon]: https://groups.google.com/g/bitcoindev/c/PsClmK4Em1E
[ml cond slh-dsa]: https://groups.google.com/g/bitcoindev/c/8UFkEvfyLwE
[hornet del]: https://delvingbitcoin.org/t/hornet-utxo-1-a-custom-constant-time-highly-parallel-utxo-database/2201
[hornet website]: https://hornetnode.org/overview.html
[lsmt wiki]: https://en.wikipedia.org/wiki/Log-structured_merge-tree
[hash map wiki]: https://ja.wikipedia.org/wiki/ハッシュテーブル
[libbitcoin gh]: https://github.com/libbitcoin
[dust attacks del]: https://delvingbitcoin.org/t/disposing-of-dust-attack-utxos/2215
[ddust tool]: https://github.com/bubb1es71/ddust
[LDK 0.1.9]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.9
[ldk 0.2.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.1
[news316 askrene]: /ja/newsletters/2024/08/16/#core-lightning-7517
[TLVs]: https://github.com/lightning/bolts/blob/master/01-messaging.md#type-length-value-format
[news230 intercept]: /ja/newsletters/2022/12/14/#ldk-1835
[news365 lsps5]: /ja/newsletters/2025/08/01/#ldk-3662
[news386 sendonion]: /ja/newsletters/2026/01/02/#lnd-9489
[news265 x86sha]: /ja/newsletters/2023/08/23/#rust-bitcoin-1962
