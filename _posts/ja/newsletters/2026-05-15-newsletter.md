---
title: 'Bitcoin Optech Newsletter #405'
permalink: /ja/newsletters/2026/05/15/
name: 2026-05-15-newsletter-ja
slug: 2026-05-15-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、十分なProof-of-Workを持つ攻撃者がBitcoin Coreノードをクラッシュさせる可能性のある
脆弱性の責任ある開示と、UTXOセットをP2Pネットワーク経由で共有するためのドラフトBIP提案を掲載しています。
また、新しいリリース候補の発表や、人気のあるBitcoinインフラソフトウェアにおける注目すべき更新など
恒例のセクションも含まれています。

## ニュース

- **Bitcoin Coreスクリプトインタプリタのリモートクラッシュに関する開示:** Niklas Göggeは、
  Bitcoin Coreのバージョン0.14.0以降29.0未満に影響を及ぼす脆弱性[CVE-2024-52911][topic cve disclosure]の開示を
  Bitcoin-Devメーリングリストに[投稿][topic cve mailing list]しました。
  バージョン0.14.0(2017年3月リリース)以降、特別に細工されたブロックを検証すると、
  ノードが解放済みのメモリにアクセスする可能性がありました。検証中、
  トランザクションのインプットをチェックするために必要なデータがキャッシュされます。このバグは、
  並列スクリプト検証中のオブジェクトのライフタイムの順序に起因し、キャッシュされた事前計算済みのトランザクションデータが、
  バックグラウンドのスクリプトチェックスレッドが完了する前に解放される可能性がありました。
  特別に細工された無効ブロックに対して、このデータがバックグラウンドスレッドからまだアクセスされている間に破棄される可能性がありました。

  十分なProof-of-Workを持つ攻撃者は、特別に細工された無効なブロックを使用することで、被害者のノードをクラッシュさせる可能性があります。
  use-after-freeバグの性質上、被害者のノード上でリモートコード実行を行うことも可能ですが、
  それを実現するブロックを細工することは困難なため、実際にこの攻撃が実行される可能性は低いとされています。

  この脆弱性はCory Fieldsによって発見され、[責任ある開示][topic responsible disclosures]が行われ、
  概念実証(PoC)と緩和策の提案も提供されました。この問題はBitcoin Core 29.0で修正されました。

- **P2Pネットワーク経由でUTXOセットを共有するためのBIP提案**: Fabian Jahrは、
  UTXOセットをP2P レイヤー経由で共有するための[ドラフトBIP][BIPs #2137]について
  Bitcoin-Devメーリングリストに[投稿][p2p share ml]しました。この提案の目的は、
  新しいノードが外部ソースからではなく、ピアから直接UTXOセットを受信する方法を提供することで、
  [assumeUTXO][topic assumeutxo]機能を改善することです。具体的には、
  この提案はP2Pプロトコルへの拡張を定義し、新しいサービスビット、4つの新しいP2Pメッセージおよび
  提供されたUTXOセットの正当性を検証するために要求側ノードが知っているUTXOセットのマークルルートを導入します。

  この提案にはフィードバックが寄せられました。Antoine Riardは、現在のドラフトを
  ピア機能ネゴシエーションを定義した[BIP434][]([ニュースレター #386][news386 feat negot] 参照)上に構築することを提案し、
  悪意のあるピアが不正なUTXOセットを転送することについての懸念を示しました。
  Eric Voskuilは、このようなBIPがUTXOの状態へのマイナーコミットメントの新たな提案につながる可能性があるという
  長期的なリスクについて著者に警告しました。Voskuilによれば、これはBitcoinのセキュリティモデルを弱め、
  新しいノードがチェーン全体をジェネシスブロックから検証するのではなく、マイナーを信頼することになるとのことです。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 26.06rc1][]は、この人気のあるLNノードの次期メジャーバージョンのリリース候補です。
  新しい`graceful`、`sendamount`、`xkeysend`RPCが含まれ、`pay`の非推奨化サイクルを開始して`xpay`を優先するほか、
  BOLT12 payer-proof RPCのサポートを追加しています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #35209][]は、[CVE-2024-52911][topic cve disclosure]の根本原因に対処するため、
  `CCheckQueueControl`オブジェクトより前に`txsdata`ベクトルを構築するようになりました(上記のニュースセクション参照)。
  C++ はローカルオブジェクトを構築順序の逆順で破棄するため、これによりキューに入れられた
  `CScriptCheck`オブジェクトから参照される事前計算済みトランザクションデータが破棄される前に、
  スクリプトチェックキューが完了することが保証されます。これにより、
  早期リターンの検証パスがバックグラウンドのスクリプトチェックスレッドに解放済みメモリへアクセスさせることを防ぎます。
  この脆弱性は以前、早期リターン動作の秘密裏の修正を通じてBitcoin Core 29.0で修正されていました([ニュースレター #333][news333 fix] 参照)。

- [BIPs #2116][]は[BIP323][]を公開しています。これはマイナー向けに`nVersion`のnonce空間で利用可能なビット数を
  16から24に拡張することを提案するもので、[BIP320][]を置き換えるものです。
  1秒に1回より頻繁に`nTime`をローリングすることなく、ヘッダーのみのマイニング用にビット5から28を予約します。
  以前の議論については[ニュースレター #395][news395 nversion]を参照してください。

- [BIPs #2141][]と[BIPs #2155][]は、2018年に[汎用署名メッセージ形式][topic generic signmessage]を提案した
  [BIP322][]を改訂・拡張しています。今回の更新では長年の未解決の質問やフィードバックに対処し、
  提案されたProof of Fundsの構造を詳細化し、PSBTベースの署名フローを追加しています。
  今回の改訂は、署名に人間が読みやすい新しいプレフィックスを追加したり、Proof of Fundsの署名形式を変更するなど、
  以前の仕様に対して破壊的な変更が行われています。BIPがCompleteに進められ、
  エコシステムでの採用に向けて正式に提案されるにあたり、btcdベースのより包括的なリファレンス実装と追加のテストベクトルが追加されました。

- [Core Lightning #9116][]は、[BOLT12][topic offers]payer proofの実験的サポートを追加し、
  [BOLTs #1295][]の最新のドラフト提案を実装しています。payer proofは、
  支払人がインボイスの支払いを[証明できる][topic proof of payment]BOLT12レシートフォーマットであり、
  支払いのプリイメージ、請求ノードの署名および`invreq_payer_id`からの支払者の署名を使用し、
  プライバシー保護のために特定のインボイスフィールドを省略できます。このPRでは、
  payer proofの作成と検証のための共通ルーチンが追加され、`bolt12-cli`が更新され、
  実験的な`createproof`RPCが追加されました。フォーマットは実験的なものであり、変更される可能性があります。

- [Core Lightning #9110][]は`pay`、`paystatus`、`keysend`、`getroute`、`renepay`および
  `renepaystatus` の各RPCを非推奨にしました。非推奨化はバージョン26.06から始まり、
  削除はバージョン27.03で予定されています。`xpay`RPC([ニュースレター #330][news330 xpay] 参照)が
  現在ほとんどの支払いを処理しており、[keysend][topic spontaneous payments]機能を維持するために
  `xkeysend`RPCが追加されました。このPRはまた、`xpay`を`label`および `localinvreqid` パラメーター、
  CLTVシャドウルーティング、繰り返し支払いの処理改善および`channel_update`エラーの処理で拡張しています。
  さらに、`getroutes`をホップごとの金額、ノード、CLTV フィールドをより明確に返すように更新し、
  `sendpay`をそれらのフィールドを使ったルートを受け入れるように更新しています。

- [LDK #4598][]は、`OutputSweeper` を更新し、進行中のスイープ試行が完了前にキャンセルされた場合でも
  `pending_sweep`フラグがクリアされるようにしました。このフラグは並行スイープ試行を防止しますが、
  キャンセルされたスイープの後にもセットされたままだと、後続の試行が誤ってスキップされ、
  時間に敏感な[HTLC][topic htlc]アウトプットがノードが再起動されるまで請求できない可能性がありました。
  このPRでは、通常のリターン、エラー、またはキャンセル時に実行されるガードオブジェクトを使用してフラグをクリアするようになりました。

- [LDK #4528][]は、BOLT11の`payment_metadata`([ニュースレター #182][news182 metadata] 参照)を
  インバウンド支払いHMACにコミットしました。メタデータがインボイスに含まれている場合、
  LDKは最終的なオニオンペイロードが同じメタデータを返すことを要求するようになり、
  送信側での変更や省略を防ぎます。さらに、インボイスビルダーはデフォルトでpayment metadataを要求するようになりましたが、
  ユーザーはそれをサポートしない送信者との互換性のために`optional_payment_metadata()`を使ってオプトアウトすることができます。

- [LND #10612][]は、以前の転送サポート([ニュースレター #396][news396 onion]参照)を基盤として、
  [オニオンメッセージ][topic onion messages]のためのグラフベースの経路探索機能を追加しました。
  LNDは機能ビット38/39でオニオンメッセージのサポートを通知するノードを経由して宛先までのルートを見つけられるようになりました。
  オニオンメッセージは支払いではないため、検索では流動性や手数料を考慮しません。

- [BTCPay Server #7354][]は、[BTCPay Server #7329][]で粒度の細かいウォレット権限を追加した後に発生した、
  ホットウォレットの秘密鍵漏洩の問題を修正しました。ウォレット署名権限は持っているものの、
  ウォレットのシードを表示する権限やストア設定を変更する権限を持たないユーザーは、
  [PSBT][topic psbt]署名中に、派生したホットウォレットの秘密鍵が漏洩する可能性がありました。
  このPRは、ホットウォレットへのアクセスを一元化するための`HotwalletSafe`ヘルパーを導入し、
  署名権限とシード情報を表示する権限を分離し、署名フローを更新してHTTPフォームフィールドを介して
  秘密署名鍵を返すことなくサーバー側でホットウォレットを使用するようにしています。

- [BDK #2195][]は、トランザクションの最初のアウトプットがインデックスされていない場合(例えば`OP_RETURN`
  アウトプットなど)のElectrumサーバーからの同期を修正します。これまでは、
  `BdkElectrumClient::populate_with_txids`が最初のアウトプットのスクリプトを使用して承認履歴をクエリしており、
  空の履歴が返される可能性がありました。BDKは現在、最初にインデックスされたアウトプットスクリプトを使用するか、
  いずれのアウトプットもインデックスされていない場合はインプットの以前のアウトプットスクリプトにフォールバックします。

- [Bitcoin Inquisition #100][]は、[signet][topic signet]上で提案されたコンセンサスの変更をテストするために、
  [BIP446][]の`OP_TEMPLATEHASH`opcodeを実装します。`OP_TEMPLATEHASH`は、
  支払いトランザクションのハッシュをスタックにプッシュする[Tapscript][topic tapscript]のopcodeです([ニュースレター
  #397][news397 templatehash]参照)。このPRには包括的なテストフレームワークも追加されています。

- [BINANAs #20][]は、[BIP443][]の[OP_CHECKCONTRACTVERIFY][topic matt](OP_CCV)opcodeの
  将来のBitcoin Inquisition実装にBIN-2026-0002を割り当てています。
  この提案された[コベナンツ][topic covenants]に関する以前の議論については、
  ニュースレター[#348][news348 op_ccv]および[#356][news356 op_ccv]をご覧ください。

{% include snippets/recap-ad.md when="2026-05-19 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2137,20,100,1295,2116,2141,2155,2195,4528,4598,7329,7354,9110,9116,10612,35209" %}
[topic cve mailing list]: https://groups.google.com/g/bitcoindev/c/e1UEdViSYkU
[topic cve disclosure]: https://bitcoincore.org/ja/2026/05/05/disclose-cve-2024-52911/
[Core Lightning 26.06rc1]: https://github.com/ElementsProject/lightning/releases/tag/v26.06rc1
[news333 fix]: /ja/newsletters/2024/12/13/#bitcoin-core-31112
[news330 xpay]: /ja/newsletters/2024/11/22/#core-lightning-7799
[news182 metadata]: /ja/newsletters/2022/01/12/#bolts-912
[news396 onion]: /ja/newsletters/2026/03/13/#lnd-10089
[news395 nversion]: /ja/newsletters/2026/03/06/#nversion-bip
[news397 templatehash]: /ja/newsletters/2026/03/20/#bips-1974
[news348 op_ccv]: /ja/newsletters/2025/04/04/#op-checkcontractverify
[news356 op_ccv]: /ja/newsletters/2025/05/30/#bips-1793
[p2p share ml]: https://groups.google.com/g/bitcoindev/c/rThmyI8ZN3Q
[news386 feat negot]: /ja/newsletters/2026/01/02/#peer-feature-negotiation
