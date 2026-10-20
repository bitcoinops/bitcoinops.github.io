---
title: 'Bitcoin Optech Newsletter #398'
permalink: /ja/newsletters/2026/03/27/
name: 2026-03-27-newsletter-ja
slug: 2026-03-27-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Stack Exchangeから厳選された質問と回答や、
新しいリリースおよびリリース候補の発表、人気のBitcoin基盤ソフトウェアの注目すべき更新など
恒例のセクションが掲載されています。

## ニュース

_今週は、どの[情報源][sources]からも重要なニュースは見つかりませんでした。_

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [「Bitcoinでは暗号化を使用していない」とはどういう意味ですか？]({{bse}}130576)
  Pieter Wuilleは、認可されていない第三者からデータを秘匿するための暗号化（BitcoinのECDSAはこの目的には使用できない）と、
  Bitcoinが検証および認証に使用するデジタル署名とを区別しています。

- [Bitcoin Scriptはいつ、なぜコミット-開示構造に移行したのですか？]({{bse}}130580)
  ユーザーbca-0353f40eは、ユーザーが公開鍵に直接支払うBitcoinの初期のアプローチから、
  P2PKHやP2SH、[segwit][topic segwit]、[taproot][topic taproot]へと進化してきた経緯を説明しています。
  これらのアプローチでは、使用条件がアウトプットにコミットされ、使用時にのみ開示されます。

- [P2TR-MS (TaprootのM-of-Nマルチシグ) は公開鍵を漏洩しますか？]({{bse}}130574)
  Murchは、単一リーフのTaprootのスクリプトパスマルチシグでは、
  OP_CHECKSIGとOP_CHECKSIGADDの両方が署名に対応する公開鍵の存在を要求するため、
  使用時にすべての対象公開鍵が公開されることを確認しています。

- [OP_CHECKSIGFROMSTACKは、意図的にUTXO間で署名の再利用を許可しているのですか？]({{bse}}130598)
  ユーザーbca-0353f40eは、[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]（[BIP348][]）が
  意図的に署名を特定のインプットにバインドしないことを説明しています。これにより、
  CSFSを他の[コベナンツ][topic covenants]opcodeと組み合わせて再バインド可能な署名を実現でき、
  これが[LN-Symmetry][topic eltoo]の基盤となるメカニズムです。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 28.4][]は、主要なフルノード実装の以前のメジャーリリースシリーズのメンテナンスリリースです。
  主に、ウォレットの移行に関する修正と、信頼性の低いDNSシードの削除が含まれています。
  詳細は、[リリースノート][bcc 28.4 rn]をご覧ください。

- [Core Lightning 26.04rc1][]は、この人気のLNノードの次期メジャーバージョンのリリース候補で、
  多数のスプライシング関連の更新とバグ修正が含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33259][]は、[assumeUTXO][topic assumeutxo]スナップショットを使用するノード向けに、
  `getblockchaininfo` RPCのレスポンスに`backgroundvalidation`フィールドを追加しました。
  この新しいフィールドは、スナップショットの高さ、バックグラウンド検証の現在のブロック高とハッシュ、
  中央値時間、chainworkおよび検証の進捗状況を報告します。これまでは、`getblockchaininfo`のレスポンスは、
  検証とIBDが完了したことを単に示すだけで、バックグラウンド検証に関する情報はありませんでした。

- [Bitcoin Core #33414][]は、接続されたTorデーモンがサポートしている場合に、
  自動作成されたオニオンサービスに対してTorの[Proof of Work防御][tor pow]を有効にします。
  Torデーモンがアクセス可能なコントロールポートを持ち、Bitcoin Coreの`listenonion`設定がオン（デフォルト）の場合、
  自動的にHidden Serviceが作成されます。これは手動で作成されたオニオンサービスには適用されませんが、
  ユーザーにはProof of Work防御を有効にするために`HiddenServicePoWDefensesEnabled 1`を追加することが推奨されています。

- [Bitcoin Core #34846][]は、[タイムロック][topic timelocks]フィールドにアクセスするための関数
  `btck_transaction_get_locktime`および`btck_transaction_input_get_sequence`を
  `libbitcoinkernel` C API（[ニュースレター #380][news380 kernel]参照）に追加しました。
  これはトランザクションの`nLockTime`およびインプットの`nSequence`にアクセスするためのものです。
  これにより、トランザクションを手動でデシリアライズすることなく、
  [BIP54][]（[コンセンサスクリーンナップ][topic consensus cleanup]）のルール（コインベースの
  `nLockTime`制約など）を検証できるようになります（sigops制限など他のBIP54ルールは、
  引き続き個別の処理が必要です）。

- [Core Lightning #8450][]は、CLNの[スプライス][topic splicing]スクリプトエンジンを拡張し、
  クロスチャネルスプライス、（3つ以上の）マルチチャネルスプライスおよび動的な手数料計算を処理できるようにしました。
  これが解決する主な問題は、手数料推定における循環依存です。ウォレットインプットを追加するとトランザクションのウェイトが増加し、
  それに伴い必要な手数料も増加し、さらに追加のインプットが必要になる場合があります。
  このインフラは、新しい`splicein`および`spliceout`RPCの基盤となっています。

- [Core Lightning #8856][]および[#8857][core lightning #8857]は、
  内部ウォレットからチャネルに資金を追加するための`splicein` RPCコマンドと、
  チャネルから内部ウォレットやBitcoinアドレスまたは別のチャネル（事実上クロススプライス）に資金を移動するための
  `spliceout` RPCコマンドを追加しました。この新しいコマンドにより、オペレーターが実験的な`dev-splice`
  RPCを使って[スプライシング][topic splicing]トランザクションを手動で構築する必要がなくなります。

- [Eclair #3247][]は、ピア毎の転送収益と支払いボリュームを時系列で追跡するオプションのピアスコアリングシステムを追加しました。
  有効にすると、定期的にピアの収益性をランク付けし、オプションで収益上位のピアへのチャネルの自動ファンディング、
  流動性を回収するための非生産的なチャネルの自動閉鎖およびボリュームに基づくリレー手数料の自動調整を、
  すべて設定可能な範囲内で行うことができます。オペレーターは、自動化を選択する前に、
  まず可視化のみから始めることができます。

- [LDK #4472][]は、チャネルのファンディングおよび[スプライシング][topic splicing]中に、
  相手方のコミットメント署名が永続化される前に`tx_signatures`が送信される可能性がある資金喪失シナリオを修正しました。
  トランザクションが承認された後にノードがクラッシュした場合、チャネル状態を強制する能力が失われる可能性がありました。
  この修正は、対応するモニターの更新が完了するまで、`tx_signatures`の送信を遅延させます。

- [LND #10602][]は、実験的な`switchrpc`サブシステム（[ニュースレター #386][news386 sendonion]参照）に
  `DeleteAttempts` RPCを追加し、外部コントローラーがLNDの試行ストアから完了（保留中でない、成功または失敗）した
  [HTLC][topic htlc]試行レコードを明示的に削除できるようにしました。

- [LND #10481][]は、LNDの統合テストフレームワークに`bitcoind`マイナーバックエンドを追加しました。
  これまでは、`lntest`は、`bitcoind`をチェーンのバックエンドとして使用する場合でも、
  `btcd`ベースのマイナーを前提としていました。この変更により、[v3トランザクションリレー][topic v3 transaction relay]や
  [パッケージリレー][topic package relay]を含む、
  Bitcoin Coreのmempoolおよびマイニングポリシーに依存する動作をテストできるようになります。

- [BOLTs #1160][]は、[スプライシング][topic splicing]プロトコルをライトニングの仕様にマージしました。
  [BOLTs #863][]のドラフトを、書き換えの動機となったエッジケースの更新されたフローとテストベクトルで置き換えています（
  そのドラフトが活発に開発されていた頃の議論については、[ニュースレター #246][news246 splicing draft]参照）。
  スプライシングにより、ピアはチャネルを閉じることなく資金を追加または削除できます。
  ネゴシエーションは静止状態（[BOLTs #869][]、[ニュースレター #309][news309 quiescence]参照）から開始されます。
  マージされたBOLT2のテキストは、スプライストランザクションの対話的な構築、
  スプライスが未承認の間のチャネル運用の継続、保留中のスプライスの[RBF][topic rbf]、
  再接続時の動作、十分な深さの後の`splice_locked`および更新された[チャネルアナウンス][topic channel announcements]をカバーしています。

{% include snippets/recap-ad.md when="2026-03-31 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33259,33414,34846,8450,8856,8857,3247,4472,10602,10481,1160,863,869" %}
[sources]: /ja/internal/sources/
[Bitcoin Core 28.4]: https://bitcoincore.org/ja/2026/03/18/release-28.4/
[bcc 28.4 rn]: https://bitcoincore.org/ja/releases/28.4/
[Core Lightning 26.04rc1]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc1
[tor pow]: https://tpo.pages.torproject.net/onion-services/ecosystem/technology/security/pow/
[news380 kernel]: /ja/newsletters/2025/11/14/#bitcoin-core-30595
[news386 sendonion]: /ja/newsletters/2026/01/02/#lnd-9489
[news246 splicing draft]: /ja/newsletters/2023/04/12/#splicing-specification-discussions
[news309 quiescence]: /ja/newsletters/2024/06/28/#bolts-869
