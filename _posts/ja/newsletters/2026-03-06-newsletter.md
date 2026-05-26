---
title: 'Bitcoin Optech Newsletter #395'
permalink: /ja/newsletters/2026/03/06/
name: 2026-03-06-newsletter-ja
slug: 2026-03-06-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、異なるArk実装におけるVTXOの検証に関する標準と、
ブロックヘッダーの`nVersion`フィールドにおけるマイナーが利用可能なナンス空間を
拡張するためのBIPドラフトのリンクを掲載しています。
また、コンセンサスの変更に関する議論や、新しいリリースおよびリリース候補の発表、
人気のあるBitcoin基盤ソフトウェアの注目すべき更新など恒例のセクションも含まれています。

## ニュース

- **ステートレスVTXO検証の標準**: Jgmcalpineは、V-PACKの提案をDelving Bitcoinに[投稿しました][vpack del]。
  V-PACKは、ステートレスな[VTXO][topic ark]検証の標準で、
  ArkエコシステムにおけるVTXOを独立して検証および可視化するメカニズムを提供することを目的としています。
  そのゴールは、ハードウェアウォレットなどの組み込み環境で実行可能な軽量な検証ツールを開発し、
  オフチェーンの状態の監査と、一方的な退出に必要なデータの独立したバックアップを可能にすることです。

  特に、V-PACKは、マークルパスが有効なオンチェーンアンカーに繋がっていること、
  およびトランザクションプリイメージが署名と一致することを確認することで、
  一方的な退出パスが存在することを検証します。ただし、SecondのCEO、Steven Rooseは、
  パスの排他性（つまり、ASP（Ark Service Provider）がバックドアを導入していないことの検証）がチェックされていないと指摘しました。
  これに対しJgmcalpineは、このトピックをロードマップの最優先事項とする旨を回答しました。

  Arkの実装（特にArkadeとBark）間には大きな差異があるため、
  V-PACKは実装固有のコードベース全体を組み込み環境にインポートすることなく、
  各実装の「方言」を共通の中立的なフォーマットに変換するためのMVV（Minimal Viable VTXO）スキーマを提案しています。

  V-PACK実装である[libvpack-rs][vpack gh]は、オープンソースで、
  VTXOを可視化するための[ライブツール][vpack tool]もテスト用に公開されています。

- **マイナー向けに拡張された`nVersion`ナンス空間のBIPドラフト**: Matt Coralloは、
  `nVersion`のナンス空間のビット数を16から24に拡張するBIPドラフトについて
  Bitcoin-Devメーリングリストに[投稿しました][mailing list nversion]。
  これにより、秒間1回以上`nTime`をローリングすることなく、
  ヘッダーのみのマイニングでより多くのブロック候補を生成できるようになり、
  [BIP 320][BIP 320]に取って代わることになります。

  この変更の動機は、[BIP 320][BIP 320]がこれまで`nVersion`の16 bitを追加のナンス空間として定義したものの、
  マイニングデバイスが追加ナンス空間として`nTime`の7 bitを使い始めていることが判明したためです。
  ソフトフォークのシグナリング用途での`nVersion`の追加bitの有用性は限られているため、
  このBIPドラフトでは、これらのシグナリングbitの一部を`nVersion`の追加ナンス空間の拡張に使用することを提案しています。

  この変更の根拠は、ASICがコントローラーからの新しい作業を必要とせずにロールオーバーできるように追加のナンス空間を提供することで
  ASICの設計が簡素化できる可能性があり、ブロックのタイムスタンプを歪める可能性がある`nTime`ではなく
  `nVersion`でこれを行うことが望ましいためです。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **TEMPLATEHASH-CSFS-IKサポートのための標準ツールの拡張:**
  Antoine Poinsotは、[Taprootネイティブの`OP_TEMPLATEHASH`ソフトフォーク提案][news365 thikcs]を
  [miniscript][topic miniscript]と[PSBT][topic psbt]に統合するための準備作業について
  Bitcoin-Devメーリングリストに[投稿しました][ap ml thikcs]。

  新しいopcodeは、署名とトランザクションのコミットが常に一緒に行われるという前提に反するため、
  miniscriptの特性を再検討する必要があります。また、この作業では、
  型システムに変更を加えずにminiscriptで使用する場合、
  各`OP_CHECKSIGFROMSTACK`の前に`OP_SWAP`が必要となるため、
  Scriptのスタック構造の限界も浮き彫りになっています。`OP_CHECKSIGFROMSTACK`は、
  メッセージ・鍵またはその両方が他のスクリプトの断片によって計算される3つの引数を取るため、
  ほとんどのケースで`OP_SWAP`を回避できるような明らかに優れた引数の順序が存在しません。

  PSBTに必要な変更はよりシンプルで、主に署名者による検証のために
  `OP_TEMPLATEHASH`コミットメントをその完全なトランザクションにマッピングするための
  アウトプット毎のフィールドの追加です。

- **Hourglass V2アップデート:** Mike Caseyは、特定の失われたコインに対する
  [量子][topic quantum resistance]攻撃の市場への影響を緩和するための
  [Hourglassプロトコル][bip draft hourglass2]のアップデートをBitcoin-Devメーリングリストに[投稿しました][mk ml hourglass]。
  以前の提案については[こちら][hb ml hourglass]で議論されています。このソフトフォークは、
  1ブロック内で使用できるP2PKでロックされたビットコインの総量を、
  1つの使用済みアウトプットかつ1ビットコインに制限するものです。これらの具体的な数値はやや恣意的ですが、
  このような制限に対する合理的な均衡点として、コメントした人々には適切に映ったようです。
  賛成派は、量子技術を持つ攻撃者によって大量のビットコインが売却された場合の経済的影響の大きさに注目しました。
  一方反対派は、プロトコルが所有権を識別できる唯一の方法はビットコインをアンロックする秘密鍵の保有であって、
  基盤となる暗号セキュリティが破られた場合においても、プロトコルはコインの所有や移動に追加の制限を課すべきではないと主張しました。

- **Bitcoinにおけるアルゴリズムのアジリティ:** Ethan Heilmanは、
  Bitcoinにおける[RFC7696暗号アルゴリズムのアジリティ][rfc7696]の必要性について
  Bitcoin-Devメーリングリストに[投稿しました][eh ml agility]。
  Heilmanは、[BIP360][]のP2MRスクリプトで利用可能な暗号アルゴリズムを提案しました。
  このアルゴリズムは現在の支払いを目的としたものではなく、現在のsecp256k1ベースの署名アルゴリズム（あるいは
  それ以降の主要なアルゴリズム）が安全でなくなった場合に、主要なアルゴリズム間の橋渡しとなるフォールバックとして機能します。
  中心となるアイディアは、Bitcoinが2つの署名アルゴリズムを同時にサポートすることで、
  将来どちらか一方が破られた場合でも、現在議論されているsecp256k1の量子耐性の問題ほど深刻にならずに済むというものです。

  他の開発者たちは、Heilmanの75年間というタイムスパンでは破られる可能性が低い、
  さまざまなバックアップ署名アルゴリズムについて議論しました。

  また、BIP360のP2MRなのか、あるいは[P2TR][topic taproot]に近い形で
  キー支払いをソフトフォークによって後から無効化できる形式が望ましいかという議論も行われました。
  P2MRでは、すべての支払いはスクリプト支払いであり、マークルリーフの中からコストの低いプライマリ署名方式か
  コストの高いフォールバックかを選択できます。P2TRの変形では、プライマリ署名タイプは、
  暗号的な破綻により無効化されるまでコストの低いキー支払いで、フォールバックのみがマークルリーフとなります。
  Heilmanは、コールドストレージのユーザーはP2MRを好み、ホットウォレットは必要に応じて新しいアウトプットタイプに容易に移行できるため、
  スクリプトバックアップ署名アルゴリズムを用いたキー支払いは、どちらの主要なタイプのユーザーにとっても無関係であると示唆しました。

- **<!--the-limitations-of-cryptographic-agility-in-bitcoin-->Bitcoinにおける暗号学的アジリティの限界:**
  Pieter Wuilleは、前の項目で言及した暗号学的なアジリティの限界について、
  Bitcoin-Devメーリングリストに[投稿しました][pw ml agility]。具体的には、
  Bitcoinはあらゆる通貨と同様に信頼に基づいており、Bitcoinの所有権が複数の暗号システムによって保護される場合、
  各方式の支持者は自らの方式を普遍的に採用させたいと考え、さらに重要な点として、
  所有権の安全性という根本的な不変条件を弱めるため、他の方式が採用されることを望みません。
  Wuilleは、時間の経過と共に、ある方式から別の方式への移行の一環として無効化する必要があると主張しています。

  Heilmanは、アルゴリズムのアジリティのために提案されたセカンダリ署名方式は現行の方式（
  そして将来のプライマリ方式）よりもはるかにコストが高いため、あくまでバックアップとして残し、
  プライマリ方式が十分に弱体化していることが示された場合にのみ移行に使用し、
  新しいプライマリ方式に移行するたびにセカンダリ署名方式を無効化する必要を回避すべきだと[提案][eh ml agility2]しています。

  John Lightは、Wuilleとは反対の立場を[取り][jl ml agility]、古い、
  たとえ安全でない署名方式であっても無効化することは、そのような安全でない方式で保護されているコインが、
  それを破ったものの手に渡るよりも、ビットコインの所有権モデルに対する共通の信念に対するより大きな脅威であると主張しています。
  本質的には、ビットコインの所有権モデルの最も重要な側面は、各ロックスクリプトの有効性が、
  作成時から使用されるときまで消えることがない点にあると主張しています。

  Conduitionは、（Scriptの柔軟性のおかげで）ユーザーはコインのロックを解除するために
  複数の署名方式からの署名を要求できることを示すことでWuilleの前提条件に[反論しています][c ml agility]。
  これにより、ユーザーはWuilleの「安全でない方式は無効化する必要があり、
  各方式のユーザーは他者にほとんど別の方式を使わせたくない」という結論の前提となっていたものよりも、
  幅広いセキュリティ前提を表明できるようになります。

  議論はいくつかの補足説明を伴いながら続いていますが、量子技術を持つ攻撃者への対応やその他の理由を問わず、
  Bitcoinが実際にどのように1つの暗号システムから別の暗号システムに移行できるかについて
  明確な結論には至っていません。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 28.4rc1][]は、以前のメジャーリリースシリーズのメンテナンスリリースのリリース候補です。
  主にウォレット移行の修正と信頼性の低いDNSシードの削除が含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33616][]は、承認済みトランザクションがmempoolに再び入る際のブロックの再編成時に、
  [エフェメラル・ダスト][topic ephemeral anchors]の支払いチェック（`CheckEphemeralSpends`）をスキップするようにします。
  これまでは、これらのトランザクションはパッケージとしてではなく個別に戻されるため、
  リレーポリシーによって拒否されていました。これは、同じ理由で再編成時に
  [TRUC][topic v3 transaction relay]トポロジーチェックをスキップしていた
  [Bitcoin Core #33504][]（[ニュースレター #375][news375 truc]参照）と同じパターンです。

- [Bitcoin Core #34616][]は、スパニングフォレスト・[クラスターリニアライゼーション][topic cluster mempool]
  （SFL）アルゴリズム（[ニュースレター #386][news386 sfl]参照）のより正確なコストモデルを導入します。
  これは、コスト制限を用いて各クラスターの最適なリニアライゼーションを探索するCPU時間を制限するものです。
  これまでのモデルは、1種類の内部操作を追跡していたため、報告されるコストと実際のCPU消費時間の相関が低くなっていました。
  新しいモデルは、多様なハードウェアのベンチマークから調整された重みを用いて多くの内部操作を追跡し、
  実時間により近い近似値を提供します。

- [Eclair #3256][]は、ファンディングまたは[スプライシング][topic splicing]トランザクションが署名され、
  公開準備が整った際に発行される`ChannelFundingCreated`イベントを新たに追加しました。
  これは、非ファンディング側が事前にインプットを検証する機会がなく、
  チャネルが承認される前に強制的にクローズしたい可能性がある、単一ファンディングチャネルで特に役立ちます。

- [Eclair #3258][]は、`ValidateInteractiveTxPlugin`トレイトを追加します。
  これにより、プラグインが署名前に対話トランザクションにおけるリモートピアのインプットとアウトプットを検査、
  拒否できるようになります。これは、両者がトランザクション構築に参加する
  [デュアルファンディング][topic dual funding]チャネルの開設および
  [スプライシング][topic splicing]に適用されます。

- [Eclair #3255][]は、[Eclair #3250][]（[ニュースレター #394][news394 eclair3250]参照）で導入された
  自動チャネルタイプ選択を修正し、パブリックチャネルに`scid_alias`が含まれないようにします。
  BOLTによると、`scid_alias`は[プライベートチャネル][topic unannounced channels]にのみ許可されています。

- [LDK #4402][]は、HTLCクレームタイマーをオニオンペイロードの値ではなく実際の
  HTLC CLTVの期限値を使用するように修正します。ノードが[トランポリン][topic trampoline payments]の
  ホップと最終受取人の両方を兼ねるトランポリンペイメントの場合、外側のトランポリンルートが、
  独自の[CLTV delta][topic cltv expiry delta]を付加するため、実際のHTLCの期限はオニオンが指定する値より高くなります。
  オニオンの値を使用することで、ノードが必要以上に厳しいクレーム期限を設定してしまっていました。

- [LND #10604][]は、LNDの送信支払いデータベース用のSQLバックエンド（SQLiteまたはPostgres）を追加します。
  これは既存のbboltキーバリュー（KV）ストアの代替となるものです。この統合PRは、複数のサブPRをまとめており、
  特に抽象的なペイメントストアインターフェースを導入した[#10153][LND #10153]、
  SQLスキーマとコアバックエンドを実装した[#9147][LND #9147]、
  実験的なKV-to-SQLデータ移行を追加した[#10485][LND #10485]が含まれています。
  LNDは、[ニュースレター #169][news169 lnd-sql]でPostgreSQLのサポートを、
  [ニュースレター #237][news237 lnd-sql]でSQLiteのサポートを追加しました。

- [BIPs #1699][]は、`OP_PAIRCOMMIT`を規定した[BIP442][]をマージします。
  これは、スタックから2つの要素を取り出し、タグ付きSHA256ハッシュをプッシュする新しい[Tapscript][topic tapscript]
  opcodeです。[OP_CAT][topic op_cat]が実現するのと同様のマルチコミットメント機能を提供しつつ、
  再帰的な[コベナンツ][topic covenants]の有効化を回避します。`OP_PAIRCOMMIT`は、
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（[BIP119][]）、
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]（[BIP348][]）、
  OP_INTERNALKEY（[BIP349][]）と並んで、[LNHANCE][news383 lnhance]ソフトフォーク提案の一部です。
  最初の提案については、[ニュースレター #330][news330 paircommit]をご覧ください。

- [BIPs #2106][]は、[BIP352][]（[サイレントペイメント][topic silent payments]）を更新し、
  受取人グループ毎の上限値`K_max` = 2323を導入します。これにより、
  悪意あるトランザクションによるワーストケースのスキャン時間を緩和します（[ニュースレター #392][news392 kmax]参照）。
  この上限は、1つのトランザクション内で1つの受取人グループのスキャナーがチェックしなければならないアウトプット数を制限します。
  当初は1000が提案されていましたが、標準サイズ（100 kvB）のトランザクションに収まる[P2TR][topic taproot]アウトプットの最大数に合わせ、
  またサイレントペイメントトランザクションのフィンガープリンティングを防ぐために2323に引き上げられました。

- [BIPs #2068][]は、タイムロックリカバリープランを保存するための標準JSONフォーマットを規定する
  [BIP128][]を公開します。リカバリープランは、所有者がウォレットへのアクセスを失った場合に資金を回収するための
  2つの事前署名済みトランザクションで構成されます。
  1つはウォレットのUTXOを単一アドレスに集約するアラートトランザクション、
  もう1つは2〜388日の相対的[タイムロック][topic timelocks]後にそれらの資金をバックアップウォレットに移動するリカバリートランザクションです。
  アラートトランザクションが早期にブロードキャストされた場合、
  所有者はアラートアドレスから送金することでリカバリーを無効化できます。

- [BOLTs #1301][]は、[アンカー][topic anchor outputs]チャネルに対してより高い
  `dust_limit_satoshis`を推奨するよう仕様を更新します。`option_anchors`では、
  事前署名済みHTLCトランザクションの手数料がゼロであるため、そのコストはダスト計算に含まれなくなります。
  これにより、ダストチェックを通過したHTLCアウトプットでも、それを使用するためのセカンドステージトランザクションの手数料が、
  アウトプットの価格を上回る可能性があるため、オンチェーンでの請求が[経済的に][topic uneconomical outputs]成り立たなくなる場合があります。
  この仕様では、ノードがこれらのセカンドステージトランザクションのコストを考慮したダスト制限を設定すること、
  およびピアからのBitcoin Coreの標準ダスト閾値を超える値を受け入れることを推奨しています。

{% include snippets/recap-ad.md when="2026-03-10 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33616,33504,34616,3256,3258,3255,3250,4402,10604,10153,9147,10485,1699,2106,2068,1301" %}

[vpack del]: https://delvingbitcoin.org/t/stateless-vtxo-verification-decoupling-custody-from-implementation-specific-stacks/2267
[vpack gh]: https://github.com/jgmcalpine/libvpack-rs
[vpack tool]: https://www.vtxopack.org/
[ap ml thikcs]: https://groups.google.com/g/bitcoindev/c/xur01RZM_Zs
[news365 thikcs]: /ja/newsletters/2025/08/01/#taproot-op-templatehash
[mk ml hourglass]: https://groups.google.com/g/bitcoindev/c/0E1UyyQIUA0
[bip draft hourglass2]: https://github.com/cryptoquick/bips/blob/hourglass-v2/bip-hourglass-v2.mediawiki
[hb ml hourglass]: https://groups.google.com/g/bitcoindev/c/zmg3U117aNc
[eh ml agility]: https://groups.google.com/g/bitcoindev/c/7jkVS1K9WLo
[rfc7696]: https://datatracker.ietf.org/doc/html/rfc7696
[pw ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A
[eh ml agility2]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/OXmZ-PnVAwAJ
[jl ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/5GnsttP2AwAJ
[c ml agility]: https://groups.google.com/g/bitcoindev/c/O6l3GUvyO7A/m/5y9GkeXVBAAJ
[news375 truc]: /ja/newsletters/2025/10/10/#bitcoin-core-33504
[news386 sfl]: /ja/newsletters/2026/01/02/#bitcoin-core-32545
[news394 eclair3250]: /ja/newsletters/2026/02/27/#eclair-3250
[news169 lnd-sql]: /ja/newsletters/2021/10/06/#lnd-5366
[news237 lnd-sql]: /ja/newsletters/2023/02/08/#lnd-7252
[news330 paircommit]: /ja/newsletters/2024/11/22/#lnhance
[news383 lnhance]: /ja/newsletters/2025/12/05/#lnhance
[news392 kmax]: /ja/newsletters/2026/02/13/#proposal-to-limit-the-number-of-per-group-silent-payment-recipients
[Bitcoin Core 28.4rc1]: https://bitcoincore.org/bin/bitcoin-core-28.4/test.rc1/
[mailing list nversion]: https://groups.google.com/g/bitcoindev/c/fCfbi8hy-AE
[BIP 320]: https://github.com/bitcoin/bips/blob/master/bip-0320.mediawiki
