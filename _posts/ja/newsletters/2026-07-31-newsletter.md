---
title: 'Bitcoin Optech Newsletter #416'
permalink: /ja/newsletters/2026/07/31/
name: 2026-07-31-newsletter-ja
slug: 2026-07-31-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、COLDCARD署名デバイスで生成されたウォレットに影響する深刻な脆弱性について警告し、
Core Lightningにおける2つのサービス拒否脆弱性の開示と、ゼロ知識証明を用いたProof of Reserveの概念実証について掲載しています。
また、Bitcoin Stack Exchangeから厳選されたQ&A、新しいリリースとリリース候補の発表、
人気のBitcoin基盤ソフトウェアの注目すべき更新など恒例のセクションも含まれています。

## アクションアイテム

- **COLDCARDで生成された鍵で管理されている資金の移動:** COLDCARD Mk3を使用してウォレットを生成した場合、
  そのウォレットで受け取ったすべての資金は盗難のリスクにさらされています。
  そのため、影響を受けていないウォレットへ慎重かつ速やかに移動させるべきです。
  他のCOLDCARDモデルで生成されたウォレットも影響を受けている可能性があります。
  詳細は以下のニュースセクションを参照してください。

## ニュース

- **<!--wallets-generated-by-coldcard-at-risk-of-theft-->COLDCARDで生成されたウォレットに盗難のリスク**:
  2026年7月30日、一部のビットコインユーザーが、自身のCOLDCARDウォレットから7月29日に一連の予期せぬトランザクションを通じて資金が盗まれていることに気付きました。
  同日中に、COLDCARD Mk3のファームウェアにバグがあり、それにより不十分なエントロピーでウォレットが生成されてしまうことが判明しました。
  本記事執筆時点で、推定被害額は1,000BTCを超えており、事態の進展に伴いこの数字はさらに増加する可能性があります。

  Coinkiteによる[セキュリティ勧告][coinkite advisory]では、ファームウェアの
  バージョン4.0.1（2021年3月）以降（最新版を含む）を使用してCOLDCARD Mk3で生成されたウォレットが、
  盗難に対して脆弱であると指摘されました。ただし、十分な外部エントロピー（50回以上のサイコロを振るなど）を用いてシードが作成されていた場合や、
  強力なパスフレーズが追加設定されていた場合は例外です。
  この勧告では、バージョン5.6.0未満のMk4およびMk5ファームウェア、ならびにバージョン1.5.0Q未満のQファームウェアで生成されたシードも、
  影響を受けるとされています。

  Coinkiteはその後の[技術解説][coinkite backgrounder]の中で、このバグの原因を、
  2021年のコード変更により、シード生成がデバイスのハードウェアRNGではなく、
  予測可能なデバイス固有値で初期化されるソフトウェアPRNGへ意図せずルーティングされてしまったことにあると説明しています。
  追加のサイコロ操作による補足なしに影響を受けたMk3で生成されたシードは、本来意図された128bitではなく、実質的に約40bitのエントロピーしか持ちません。
  影響を受けたMk4、Mk5、Qデバイスから生成されたシードは、セキュアエレメントの出力もミックスされているため攻撃はより困難ですが、
  Coinkiteとの連携のもと匿名の研究者と共に実施され開示されたBlockによる[分析][block analysis]では、
  そのエントロピーのうちPRNG状態に反映されるのはわずか32bitに過ぎず、これらのシードも意図されたセキュリティレベルには依然として大きく届かないことが判明しました。

  複数の開発者が最先端のAIモデルの支援を受けて、この攻撃を即座に再現することに成功したため、この脆弱性は現在悪用が進行中であると想定すべきです。
  Blockの分析では、4.xファームウェアを実行している古いCOLDCARD Mk2もMk3と同程度に影響を受けていることが追加で特定されており、
  ペーパーウォレットの秘密鍵やエフェメラルシードなど、他のランダム生成された秘密情報も影響を受けることが指摘されています。

  事態は依然として進行中であり、このニュースレターの公開後にもさらなる情報が明らかになる可能性が高いです。
  読者は[Coinkiteのブログ][coinkite blog]をはじめとする情報源で最新情報を確認してください。
  Bitcoin Optechは、影響を受ける可能性のあるCOLDCARDユーザーに対し、
  影響を受けていないウォレットへ慎重かつ速やかに資金を移動させるよう推奨しています。
  追加のサイコロ操作による補足なしに影響を受けたデバイスで生成されたシードは、侵害されたものとして扱うべきです。
  Mk4、Mk5、Qデバイスのユーザーは、新しいウォレットを生成する前に、修正されたファームウェアにアップグレードしてください。
  アップグレードするだけでは既存のシードは安全になりません。

- **Core Lightningの2つのDoS脆弱性の開示**: Chandra Pratapは、[Summer of Bitcoin][sob]プログラムのインターンシップ中に
  Core Lightningで発見した2つのサービス拒否（DoS）脆弱性についてDelving Bitcoinに[投稿しました][cln vuln del]。
  具体的には、これらの脆弱性により、攻撃者はノードのメモリを枯渇させてノードをクラッシュさせることが可能でした。
  このバグは`gossipd`デーモンのステートマシン、特に`connectd`デーモンとのインターフェイスに関連するものです。
  Pratapは、2つのモジュール間の通信の堅牢性をテストすることを目的とした新しいファズターゲット
  `fuzz-gossipd-connectd`に取り組んだことで、これらの脆弱性を発見することができました。

  1つめの脆弱性は、2つのデーモン間で共有されるデーモン間メッセージキューに関連するもので、
  このキューの目的はネットワークから届くすべての`channel_update`メッセージを保存することです。
  攻撃者はノードをメッセージで溢れさせることで、内部キューを際限なく増大させ、
  利用可能なすべてのRAMを消費させることが可能でした。
  このバグは、[Core Lightning #8376][]で、キューがメッセージをドロップできるようにし、
  50万メッセージという上限（カットオフポイント）を設けるというシンプルな方法で修正されました。

  2つめの脆弱性は、1つめの脆弱性を修正しようとした際に発見されました。
  具体的には、欠落している可能性のあるチャネルについてピアに問い合わせるために、
  未知のショートチャネルID（SCID）を追跡するのに使用される内部マップに関連するものでした。
  攻撃者は偽のSCIDでノードを溢れさせることで、メモリ消費を増大させ続けることが可能でした。
  このバグ自体はそれまで報告されていなかったものの、Rusty Russellによって[Core Lightning #8903][]で既にパッチの作業が進められており、
  そこでは内部マップの改良されたガベージコレクションメカニズムが導入されました。

- **ゼロ知識Proof of Reserveの概念実証**: fabohaxは、Bitcoin向けの
  非カストディアルな[Proof of Reserve][topic proof of reserves]システムの概念実証である
  zkPoH（"zero-knowledge proof-of-hodl"）について[投稿しました][zkpoh del]。
  このプロトタイプでは、ユーザーは合計金額が1億sats（1BTC）以上のUTXOのセットを自身が保持していることを、
  それ以上の情報を一切明らかにすることなく証明できます。

  この概念実証は、オフチェーンで生成されたUTXOのスナップショットを入力として受け取り、
  それをマークルツリーにコミットし、そのルートが公開コミットメントになります。
  証明者はスナップショットから最大4つのUTXOを選択し、[Noir][noir lang]回路用のウィットネス入力を生成します。
  この回路は、選択されたUTXOが実際にスナップショットに属していること、マークルパスが有効であること、
  選択されたUTXOの合計が少なくとも要求された金額であることを検証します。検証者が知ることができるのは、
  証明者が1億sats（1BTC）の要件を満たしているということだけです。

  本記事執筆時点では、この概念実証に明示的な所有権の紐付けを行う手順は組み込まれていません。つまり、
  選択されたUTXOが実際に証明者に属していることを証明する方法はありません。
  著者は現在、回路外での所有権チェック、あるいは回路内に直接組み込む形のいずれかで、
  この機能の追加に取り組んでいます。プロトタイプは現在、専用の[リポジトリ][zkpoh gh]で公開されています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Bitcoinにおけるトランザクションの中立性の客観的な定義とは？]({{bse}}130849)
  Ava Chowは、中立性とは、以前は使用可能だったスクリプトを使用不可能にしたり、
  デプロイ済みのプロトコルを壊したりするなど、ある変更によって誰かがBitcoinを
  これまで通り使い続けることが妨げられるかどうかという観点で捉えられると説明しています。

- [なぜBIP110の分散化のメリットは、トランザクションの中立性への影響を上回らないのでしょうか？]({{bse}}130848)
  Pieter Wuilleは、データを含むトランザクションパターンを無効化してもノードのコストは削減されないと主張しています。
  なぜなら、ブロックのウェイト制限が既にリソース使用量を制限しており、
  データ保存用のバイトは処理コストが最も安い部類に入り、禁止されたパターンは単に他のトランザクションに置き換えられるだけだからです。

- [BIP110において、ノードは非シグナリングブロックを拒否するのに、なぜ55%のシグナリング閾値が必要なのでしょうか？]({{bse}}130885)
  Vojtěch Strnadは、この閾値は強制シグナリング期間が始まる前の、
  マイナーによる自発的なシグナリングに適用されるものだと説明しています（[ニュースレター #392][news392 bip110]参照）。
  早期のロックインはより広範な支持を示し、ソフトフォークをより早く有効化できる可能性がありますが、
  強制シグナリングが始まると、強制適用を施行するノードは非シグナリングブロックを破棄します。

- [なぜBIP324ではElligatorSwiftエンコーディングが採用されているのですか？]({{bse}}130887)
  Pieter Wuilleは、ハンドシェイクの公開鍵を一様にランダムなバイト列としてエンコードすることで、
  [v2トランスポート][topic v2 p2p transport]のバイトストリーム全体が擬似ランダムになり、パターンマッチによる識別を防ぎ、
  検閲を行うファイアウォールに完全な中間者攻撃を仕掛けるか許可リストを運用するかのいずれかを強いると説明しています。
  また、他のプロトコルを模倣することも容易になります。

- [BIP342のOP_SUCCESSxの予約は、特定のopcodeファミリーを念頭に設計されたものですか？]({{bse}}130670)
  Murchは、`OP_SUCCESS` opcodeを汎用的なアップグレードフックとして説明しています。
  任意の`OP_SUCCESS`は[Tapscript][topic tapscript]を無条件に有効にするため、
  将来のソフトフォークでは、再定義した`OP_NOP` opcodeでは決して実行できないスタック操作を含む、
  より制限的な動作でopcodeを再定義できます。

- [<!--what-is-the-difference-between-the-long-term-feerate-and-the-discard-feerate-->長期手数料率と破棄手数料率の違いは何ですか？]({{bse}}130861)
  Murchは、この2つが互換性があるものではないことを明確にしています。破棄手数料率は、
  それを下回るとお釣り候補のアウトプットの価値が手数料に充てられるダスト制限を設定するもので、
  長期手数料率は、ウォレットにおける[コイン選択][topic coin selection]の戦略を
  統合的にするか節約的にするかの境界を設定するものです。

- [<!--what-is-the-quickest-method-for-migrating-a-legacy-wallet-to-a-descriptor-wallet-on-a-pruned-node-->プルーニングされたノードでレガシーウォレットをディスクリプターウォレットに移行する最も迅速な方法はなんですか？]({{bse}}130713)
  Pol Espinasaは、移行処理では移行後のウォレットのロードが試みられ、
  ウォレットの誕生日より前のブロックがプルーニングされているノードでは、これが失敗します。
  バージョン32.0で導入予定の[Bitcoin Core #35266][]（[ニュースレター #412][news412 migratewallet]
  参照）により、ウォレットをロードせずに移行できるようになりますが、
  移行後の[ディスクリプター][topic descriptors]ウォレットのロードには、
  依然として関連するブロックを持つノードが必要になります。

- [高手数料期間中のorphan/staleブロック率に関する過去のデータはありますか？]({{bse}}130889)
  0xB10Cは、bitcoin-dataプロジェクトが管理する[stale-blocksデータセット][stale blocks site]を紹介しています。
  これはstaleブロック率の推移をグラフ化しており、独自のメトリクスを導出するための[生データ][stale blocks repo]も提供しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [BTCPay Server 2.4.1][]は、このセルフホスト型ペイメントプロセッサのメンテナンスリリースです。
  [BIP329][]ウォレットラベルのインポート（[ニュースレター #415][news415 labels]参照）や、
  インボイスの編集可能なコメント機能、その他いくつかの改善とバグ修正が追加されています。

- [Eclair 0.14.1][]は、このLNノード実装のメンテナンスリリースです。
  Bitcoin Core 31.xが必要になったほか、[マルチパスペイメント][topic multipath payments]で正しく動作しなかった実験的な
  [BOLT12][topic offers]のブラインドパス手数料割引を無効化し、いくつかのバグ修正とパフォーマンス改善が含まれています。
  カスタムのオファーハンドラープラグインを使用しているオペレーターは、[リリースノート][eclair 0.14.1 notes]を確認してください。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #34628][]は、ピアごとに独立していたトランザクションリレーのバックログを、
  個数およびシリアライズ後のサイズに基づくトークンバケットで制御される、
  グローバルなインバウンド/アウトバウンドバックログに置き換えます。これにより、
  ピア間での重複した保存とソートが削減されます。これらはCPU枯渇問題の一因となっていました（[ニュースレター #324][news324 inv]
  参照）。インバウンドピアのバックログにおけるリレークレジットは、
  初期値として420トランザクショントークンおよび12MBが割り当てられ、
  毎秒14トランザクションと20kBのレートで補充されます。個数の上限は420トークンですが、
  サイズの蓄積上限は50MBとなっています。アウトバウンドの補充レートについては、
  [ニュースレター #373][news373 rate]で説明された2.5倍の係数が維持されます。
  リレー需要が利用可能なクレジットを超えた場合、トランザクション間の依存関係を尊重しつつ、
  マイニングスコアに基づいて優先順位が決定されます。選択されたトランザクションは、その後、
  小規模なランダム化されたピアごとのキューに投入されます。
  新しい`getnetworkinfo`フィールドは各バックログとそのトークン残高を公開し、
  デバッグ専用の`-txsendrate`オプションで異なる個数レートをテストできます。

- [Bitcoin Core #28463][]は、デフォルトの最大接続数を125から200に引き上げるとともに、
  `-inboundrelaypercent`オプション（デフォルト値50）を追加します。このオプションは、
  トランザクションをリレーするピアが占有できるインバウンドスロットの最大割合を設定するものです。
  デフォルトで11個のアウトバウンドスロットが確保されるため、インバウンド接続には189個のスロットが残り、
  デフォルト設定ではそのうち最大94個をトランザクションをリレーするピアが占有できます。この制限は、
  ピアが自身のリレーの設定を通知した後に適用され、ピアが後から[BIP37][]メッセージを使用して
  トランザクションリレーを有効にした場合には再チェックされます。これにより、
  低帯域幅でのブロックリレー用のキャパシティが確保され、[エクリプス攻撃][topic eclipse attacks]への耐性を向上させるための、
  より多くのアウトバウンドのブロックリレー専用接続の追加に備えます。

- [Bitcoin Core #32800][]は、いくつかのRPCに明示的な[BIP141][]および
  ポリシー調整済みトランザクションサイズのフィールドを追加しました。
  `vsize_bip141`はトランザクションのウェイトから計算された仮想サイズを報告し、
  `vsize_adjusted`はその値と設定された`-bytespersigop`ポリシーの下で
  トランザクションのsigopsコストから導かれるサイズのうち、大きい方を報告します。
  調整済みの値は、mempoolポリシーおよびブロックテンプレートの手数料率計算に使用されます。
  `getmempoolentry`、verboseモードの`getrawmempool`、`testmempoolaccept`、`submitpackage`は、
  両方のフィールドを報告するようになりました。既存の`vsize`フィールドは、
  BIP141の仮想サイズとして文書化されていましたが、実際にはポリシー調整済みの値を含んでいたため、
  維持されるものの非推奨としてマークされます。さらに、`getrawtransaction`は
  トランザクションがmempoolにある場合に`vsize_adjusted`を報告し、
  既存の`vsize`はBIP141の値のままです。`getorphantxs`のverbose出力にも明示的な
  `vsize_bip141`フィールドが追加されます。

- [Bitcoin Core #34683][]は、RPCインターフェースの[OpenRPC 1.4.1][]記述を自動生成します。
  新しい`rpc.discover`RPCは公開インターフェースを返し、`getopenrpcinfo`
  はオプションで隠しコマンドと引数を含めることができます。このドキュメントは、
  登録されたすべてのRPCの`RPCHelpMan`メタデータから実行時に生成され、メソッドのパラメータ、
  必須値とデフォルト値、結果の形式、その他のインターフェースの詳細を記述します。

- [Bitcoin Core #33014][]は、ファイナライズ済みのスクリプトフィールドに値が入力されているものの、
  無効な署名を含む[PSBT][topic psbt]を`descriptorprocesspsbt`（[ニュースレター #253][news253 descriptorpsbt]参照）が
  処理する方法を修正します。これまでは、このRPCは最終スクリプトの存在のみをチェックして、
  PSBTを完了とマークし、トランザクションの抽出が失敗した場合は内部エラーを返していました。
  現在は、完了を報告する前にすべてのインプットを検証するため、無効な署名を持つPSBTは、
  `hex`フィールドにシリアライズされたトランザクションを含めずに`complete: false`を返します。

- [Eclair #3325][]は、`reply_path`を含む[BOLT12][topic offers]インボイスの[オニオンメッセージ][topic onion messages]を受け入れます。
  受取人は、支払人がインボイスを無効と判断した場合に`invoice_error`を返せるように、
  [ブラインドされた][topic rv routing]返信パスをインボイスに添付できます。
  Eclairはこれまでこの組み合わせを拒否していたため、インボイスに返信パスを追加したLDK
  （[ニュースレター #321][news321 replypath]参照）との相互運用性の問題を引き起こしていました。

- [BOLTs #1346][]は、[BOLT12][topic offers]のPayer Proof（支払人証明）、つまり
  支払人がペイメントプリイメージ、インボイスを発行したノードの署名、`invreq_payer_id`による支払人の署名を使用して
  （プライバシーのため一部のインボイスフィールドを省略可能にし）
  [支払人がインボイスを支払ったことを証明][topic proof of payment]するレシートフォーマットを規定します。
  この仕様では人が読みやすいプレフィックス`lnp`が割り当てられ、
  生成と検証のテストベクターが追加されています。Core Lightningは初期のドラフトを実験的に実装していました（[ニュースレター #405][news405 proof]参照）。

- [BOLTs #1344][]は、[失敗の帰属][topic attributable failures]プロトコルを成功したペイメントにも拡張し、
  ペイメントプリイメージを返して[HTLC][topic htlc]を決済するメッセージである`update_fulfill_htlc`に
  オプションの`fulfillment_payload`を追加します。パディングフィールドのみが定義されているため、
  このPRは、署名付き[keysend][topic spontaneous payments]レシートなど、
  将来の成功関連データのためのトランスポートを確立するもので、まだ何らかのアプリケーションを標準化するものではありません。

- [BOLTs #1343][]は、チャネルピアからの[オニオンメッセージ][topic onion messages]のみを受け入れるノード向けの
  `option_onion_messages_only_channels`機能ビットを追加します。この機能を通知しないノードは、
  チャネルを持たないピアからのオニオンメッセージを受け入れるべきですが、レート制限やドロップは引き続き行ってもかまいません。
  この機能により、送信者は失敗することが分かっているリレーパスを回避でき、
  同時にオペレーターはサービス拒否攻撃へのエクスポージャーを減らすことができます。
  チャネルを持たないピアからのオニオンメッセージを受信するものの転送しないLNDの動作に対処する
  LDKの回避策については、[ニュースレター #409][news409 onion]を参照してください。

{% include snippets/recap-ad.md when="2026-08-04 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8376,8903,35266,34628,28463,32800,34683,33014,3325,1346,1344,1343" %}

[news392 bip110]: /ja/newsletters/2026/02/13/#bips-2017
[news412 migratewallet]: /ja/newsletters/2026/07/03/#bitcoin-core-35266
[stale blocks site]: https://bitcoin-data.github.io/stale-blocks/
[stale blocks repo]: https://github.com/bitcoin-data/stale-blocks
[cln vuln del]:https://delvingbitcoin.org/t/vulnerability-disclosure-twin-memory-exhaustion-dos-vulnerabilities-in-core-lightning/2731
[sob]:https://www.summerofbitcoin.org/
[zkpoh del]: https://delvingbitcoin.org/t/zkpoh-zero-knowledge-proof-of-hodl/2699
[noir lang]: https://noir-lang.org/
[zkpoh gh]: https://github.com/fabohax/zkPoH
[BTCPay Server 2.4.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.1
[Eclair 0.14.1]: https://github.com/ACINQ/eclair/releases/tag/v0.14.1
[eclair 0.14.1 notes]: https://github.com/ACINQ/eclair/blob/v0.14.1/docs/release-notes/eclair-v0.14.1.md
[OpenRPC 1.4.1]: https://spec.open-rpc.org/
[news415 labels]: /ja/newsletters/2026/07/24/#btcpay-server-7457
[news324 inv]: /ja/newsletters/2024/10/11/#inventory-dos
[news373 rate]: /ja/newsletters/2025/09/26/#bitcoin-core-28592
[news253 descriptorpsbt]: /ja/newsletters/2023/05/31/#bitcoin-core-25796
[news321 replypath]: /ja/newsletters/2024/09/20/#ldk-3163
[news405 proof]: /ja/newsletters/2026/05/15/#core-lightning-9116
[news409 onion]: /ja/newsletters/2026/06/12/#ldk-4647
[coinkite advisory]: https://blog.coinkite.com/coldcard-mk3-seed-generation-warning/
[coinkite blog]: https://blog.coinkite.com/
[coinkite backgrounder]: https://blog.coinkite.com/entropy-technical-backgrounder/
[block analysis]: https://engineering.block.xyz/blog/predictable-rng-fallback-and-32-bit-reseed-in-coldcard-firmware